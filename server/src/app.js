import http from 'node:http';
import express from 'express';
import cors from 'cors';
import { config } from './config.js';
import { verifyToken, firestore } from './firebase.js';
import { FirestoreStore } from './store/firestoreStore.js';
import { MemoryStore } from './store/memoryStore.js';
import { createSocketServer, assertRoomAccess } from './socket.js';
import * as ai from './ai.js';

export function createStore() {
  const db = firestore();
  if (db) return new FirestoreStore(db);
  console.warn('[store] DEV_AUTH enabled - using in-memory store (data is lost on restart)');
  return new MemoryStore();
}

export function createApp({ store = createStore() } = {}) {
  const app = express();
  app.use(cors({ origin: config.corsOrigins.includes('*') ? true : config.corsOrigins }));
  app.use(express.json({ limit: '8mb' })); // vision uploads are base64

  const auth = async (req, res, next) => {
    try {
      req.user = await verifyToken((req.headers.authorization || '').replace(/^Bearer\s+/i, ''));
      next();
    } catch (err) {
      res.status(401).json({ error: `unauthorized: ${err.message}` });
    }
  };
  const wrap = (fn) => (req, res) =>
    fn(req, res).catch((err) => res.status(err.status || 500).json({ error: err.message }));

  const server = http.createServer(app);
  const io = createSocketServer(server, store);

  app.get('/health', (_req, res) =>
    res.json({ ok: true, aiProvider: config.ai.provider, devAuth: config.devAuth, online: io.onlineUsers().length })
  );

  // Profile stored in Firestore users/{uid}
  app.get('/api/me', auth, wrap(async (req, res) => {
    res.json({ user: (await store.getUser(req.user.uid)) || (await store.upsertUser(req.user)) });
  }));

  app.put('/api/me', auth, wrap(async (req, res) => {
    const allowed = ['displayName', 'photoURL', 'studentId', 'role', 'school', 'bio'];
    const extra = Object.fromEntries(Object.entries(req.body || {}).filter(([k, v]) => allowed.includes(k) && typeof v === 'string'));
    res.json({ user: await store.upsertUser({ uid: req.user.uid, email: req.user.email }, extra) });
  }));

  app.get('/api/users/:uid', auth, wrap(async (req, res) => {
    const u = await store.getUser(req.params.uid);
    if (!u) return res.status(404).json({ error: 'not found' });
    const { uid, displayName, photoURL, online, lastSeen } = u;
    res.json({ user: { uid, displayName, photoURL, online, lastSeen } });
  }));

  app.get('/api/rooms/:roomId/messages', auth, wrap(async (req, res) => {
    try {
      await assertRoomAccess(store, req.user.uid, req.params.roomId);
    } catch (err) {
      return res.status(403).json({ error: err.message });
    }
    const limit = Math.min(parseInt(req.query.limit, 10) || config.chat.historyLimit, 200);
    res.json({ messages: await store.getMessages(req.params.roomId, limit) });
  }));

  // AI over REST (used by the existing GPT screen; realtime clients use socket "ai:*" events)
  app.get('/api/ai/models', auth, (_req, res) => res.json(ai.listModels()));

  app.get('/api/ai/history', auth, wrap(async (req, res) => {
    res.json({ messages: await store.getAiMessages(req.user.uid, 100) });
  }));

  app.post('/api/ai/complete', auth, wrap(async (req, res) => {
    const { message, messages, model } = req.body || {};
    if (model === 'image') {
      return res.json({ type: 'image', url: await ai.generateImage(String(message || '')) });
    }
    const history = Array.isArray(messages) ? messages : [{ role: 'user', content: String(message || '') }];
    res.json({ type: 'text', reply: await ai.chat(history) });
  }));

  app.post('/api/ai/vision', auth, wrap(async (req, res) => {
    const { prompt, imageBase64, mediaType } = req.body || {};
    res.json({ reply: await ai.vision({ prompt, imageBase64, mediaType }) });
  }));

  app.post('/api/ai/image', auth, wrap(async (req, res) => {
    res.json({ url: await ai.generateImage(String(req.body?.prompt || '')) });
  }));

  return { app, server, io, store };
}
