import fs from 'node:fs';
import admin from 'firebase-admin';
import { config } from './config.js';

let app = null;

function loadServiceAccount() {
  const { serviceAccountJson, serviceAccountPath } = config.firebase;
  if (serviceAccountJson) {
    const raw = serviceAccountJson.trim().startsWith('{')
      ? serviceAccountJson
      : Buffer.from(serviceAccountJson, 'base64').toString('utf8');
    return JSON.parse(raw);
  }
  if (serviceAccountPath && fs.existsSync(serviceAccountPath)) {
    return JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));
  }
  return null;
}

/** Initialise firebase-admin. Returns null in DEV_AUTH mode or when no credentials exist. */
export function initFirebase() {
  if (app) return app;
  if (config.devAuth) return null;

  const sa = loadServiceAccount();
  if (sa) {
    app = admin.initializeApp({ credential: admin.credential.cert(sa), projectId: sa.project_id });
  } else if (config.firebase.projectId) {
    app = admin.initializeApp({ credential: admin.credential.applicationDefault(), projectId: config.firebase.projectId });
  } else {
    throw new Error(
      'Firebase credentials missing. Set FIREBASE_SERVICE_ACCOUNT_PATH / FIREBASE_SERVICE_ACCOUNT_JSON, ' +
        'or set DEV_AUTH=true for local development without Firebase.'
    );
  }
  return app;
}

export function firestore() {
  return initFirebase() ? admin.firestore() : null;
}

/**
 * Verify a client credential and return a normalised user.
 * Production: Firebase ID token (from FirebaseAuth.instance.currentUser.getIdToken()).
 * DEV_AUTH:   "dev:<uid>:<email>:<display name>".
 */
export async function verifyToken(token) {
  if (!token || typeof token !== 'string') throw new Error('Missing auth token');

  if (config.devAuth) {
    if (!token.startsWith('dev:')) throw new Error('DEV_AUTH expects tokens like dev:<uid>:<email>:<name>');
    const [, uid, email = '', ...name] = token.split(':');
    if (!uid) throw new Error('Invalid dev token');
    return { uid, email, displayName: name.join(':') || email || uid, photoURL: '' };
  }

  initFirebase();
  const decoded = await admin.auth().verifyIdToken(token);
  return {
    uid: decoded.uid,
    email: decoded.email || '',
    displayName: decoded.name || decoded.email || decoded.uid,
    photoURL: decoded.picture || '',
  };
}
