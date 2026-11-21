import { randomUUID } from 'node:crypto';

/** In-memory store with the same interface as FirestoreStore. For DEV_AUTH and tests only. */
export class MemoryStore {
  constructor() {
    this.users = new Map();
    this.rooms = new Map(); // roomId -> { meta, messages: [] }
    this.ai = new Map(); // uid -> [{id, role, content, createdAt}]
  }

  async upsertUser(user, extra = {}) {
    const prev = this.users.get(user.uid) || { createdAt: new Date().toISOString() };
    const next = { ...prev, ...user, ...extra, updatedAt: new Date().toISOString() };
    this.users.set(user.uid, next);
    return next;
  }

  async getUser(uid) {
    return this.users.get(uid) || null;
  }

  async setPresence(uid, online) {
    const u = this.users.get(uid);
    if (u) Object.assign(u, { online, lastSeen: new Date().toISOString() });
  }

  async getRoom(roomId) {
    return this.rooms.get(roomId)?.meta || null;
  }

  async setRoom(roomId, meta) {
    const r = this.rooms.get(roomId) || { meta: {}, messages: [] };
    r.meta = { ...r.meta, ...meta };
    this.rooms.set(roomId, r);
  }

  async addMessage(roomId, msg) {
    const r = this.rooms.get(roomId) || { meta: {}, messages: [] };
    const saved = { id: randomUUID(), roomId, ...msg, createdAt: new Date().toISOString() };
    r.messages.push(saved);
    r.meta = { ...r.meta, lastMessage: saved.text, updatedAt: saved.createdAt };
    this.rooms.set(roomId, r);
    return saved;
  }

  async getMessages(roomId, limit) {
    const msgs = this.rooms.get(roomId)?.messages || [];
    return msgs.slice(-limit);
  }

  async addAiMessage(uid, role, content) {
    const list = this.ai.get(uid) || [];
    const saved = { id: randomUUID(), role, content, createdAt: new Date().toISOString() };
    list.push(saved);
    this.ai.set(uid, list);
    return saved;
  }

  async getAiMessages(uid, limit) {
    return (this.ai.get(uid) || []).slice(-limit);
  }

  async clearAiMessages(uid) {
    this.ai.delete(uid);
  }
}
