import admin from 'firebase-admin';

const ts = (v) => (v && typeof v.toDate === 'function' ? v.toDate().toISOString() : v ?? null);
const docOut = (d) => {
  const data = d.data();
  return { id: d.id, ...data, createdAt: ts(data.createdAt), updatedAt: ts(data.updatedAt), lastSeen: ts(data.lastSeen) };
};

/**
 * Firestore layout
 *   users/{uid}                         profile + presence
 *   users/{uid}/aiMessages/{id}         private AI assistant conversation
 *   rooms/{roomId}                      optional meta: { members?: [uid], name?, lastMessage, updatedAt }
 *   rooms/{roomId}/messages/{id}        chat messages
 */
export class FirestoreStore {
  constructor(db) {
    this.db = db;
    this.now = admin.firestore.FieldValue.serverTimestamp;
  }

  async upsertUser(user, extra = {}) {
    const ref = this.db.collection('users').doc(user.uid);
    const snap = await ref.get();
    const data = { ...user, ...extra, updatedAt: this.now() };
    if (!snap.exists) data.createdAt = this.now();
    await ref.set(data, { merge: true });
    return docOut(await ref.get());
  }

  async getUser(uid) {
    const snap = await this.db.collection('users').doc(uid).get();
    return snap.exists ? docOut(snap) : null;
  }

  async setPresence(uid, online) {
    await this.db.collection('users').doc(uid).set({ online, lastSeen: this.now() }, { merge: true });
  }

  async getRoom(roomId) {
    const snap = await this.db.collection('rooms').doc(roomId).get();
    return snap.exists ? snap.data() : null;
  }

  async setRoom(roomId, meta) {
    await this.db.collection('rooms').doc(roomId).set(meta, { merge: true });
  }

  async addMessage(roomId, msg) {
    const room = this.db.collection('rooms').doc(roomId);
    const ref = room.collection('messages').doc();
    const createdAt = admin.firestore.Timestamp.now();
    const data = { ...msg, roomId, createdAt };
    const batch = this.db.batch();
    batch.set(ref, data);
    batch.set(room, { lastMessage: msg.text?.slice(0, 200) ?? '', updatedAt: createdAt }, { merge: true });
    await batch.commit();
    return { id: ref.id, ...data, createdAt: createdAt.toDate().toISOString() };
  }

  async getMessages(roomId, limit) {
    const q = await this.db
      .collection('rooms').doc(roomId).collection('messages')
      .orderBy('createdAt', 'desc').limit(limit).get();
    return q.docs.map(docOut).reverse();
  }

  async addAiMessage(uid, role, content) {
    const ref = this.db.collection('users').doc(uid).collection('aiMessages').doc();
    const createdAt = admin.firestore.Timestamp.now();
    await ref.set({ role, content, createdAt });
    return { id: ref.id, role, content, createdAt: createdAt.toDate().toISOString() };
  }

  async getAiMessages(uid, limit) {
    const q = await this.db
      .collection('users').doc(uid).collection('aiMessages')
      .orderBy('createdAt', 'desc').limit(limit).get();
    return q.docs.map(docOut).reverse();
  }

  async clearAiMessages(uid) {
    const col = this.db.collection('users').doc(uid).collection('aiMessages');
    for (;;) {
      const snap = await col.limit(400).get();
      if (snap.empty) return;
      const batch = this.db.batch();
      snap.docs.forEach((d) => batch.delete(d.ref));
      await batch.commit();
    }
  }
}
