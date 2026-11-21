import { Server } from 'socket.io';
import { config } from './config.js';
import { verifyToken } from './firebase.js';
import * as ai from './ai.js';

const ROOM_ID = /^[A-Za-z0-9:_\-.]{1,128}$/;
const userRoom = (uid) => `user:${uid}`;
const chatRoom = (roomId) => `room:${roomId}`;

/** Throws if `uid` may not access `roomId`. Returns the room meta (may be null). */
export async function assertRoomAccess(store, uid, roomId, { write = false } = {}) {
  if (typeof roomId !== 'string' || !ROOM_ID.test(roomId)) throw new Error('Invalid roomId');
  if (roomId.startsWith('dm:')) {
    const parts = roomId.slice(3).split('_');
    if (parts.length !== 2 || !parts.includes(uid)) throw new Error('Not a participant of this direct chat');
  }
  const meta = await store.getRoom(roomId);
  if (meta?.members && Array.isArray(meta.members) && !meta.members.includes(uid)) {
    throw new Error('Not a member of this room');
  }
  if (write && meta?.posters && Array.isArray(meta.posters) && !meta.posters.includes(uid)) {
    throw new Error('You may not post in this room');
  }
  return meta;
}

/** Tiny per-socket rate limiter: `max` events per `windowMs`. */
function rateLimiter(max = 20, windowMs = 10_000) {
  let hits = [];
  return () => {
    const now = Date.now();
    hits = hits.filter((t) => now - t < windowMs);
    if (hits.length >= max) return false;
    hits.push(now);
    return true;
  };
}

const safeAck = (ack) => (typeof ack === 'function' ? ack : () => {});
const cleanText = (t) => (typeof t === 'string' ? t.trim().slice(0, config.chat.maxMessageLength) : '');

export function createSocketServer(httpServer, store) {
  const io = new Server(httpServer, {
    cors: { origin: config.corsOrigins.includes('*') ? true : config.corsOrigins, credentials: true },
    pingInterval: 25_000,
    pingTimeout: 20_000,
  });

  // Live connection count per uid (a user can be connected from several devices).
  const connections = new Map();
  // Users with an in-flight private AI request.
  const aiBusy = new Set();

  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth?.token || socket.handshake.headers?.authorization?.replace(/^Bearer\s+/i, '');
      socket.data.user = await verifyToken(token);
      next();
    } catch (err) {
      next(new Error(`unauthorized: ${err.message}`));
    }
  });

  io.on('connection', async (socket) => {
    const user = socket.data.user;
    const allow = rateLimiter();
    socket.join(userRoom(user.uid));

    connections.set(user.uid, (connections.get(user.uid) || 0) + 1);
    try {
      const profile = await store.upsertUser(user, { online: true, lastSeen: new Date().toISOString() });
      socket.emit('session', { user: profile });
      socket.broadcast.emit('presence', { uid: user.uid, online: true });
    } catch (err) {
      console.error('[socket] upsertUser failed', err);
      socket.emit('session', { user });
    }

    // ---------- Group / project / DM chat ----------

    socket.on('room:join', async ({ roomId } = {}, ack) => {
      ack = safeAck(ack);
      try {
        await assertRoomAccess(store, user.uid, roomId);
        await socket.join(chatRoom(roomId));
        const messages = await store.getMessages(roomId, config.chat.historyLimit);
        ack({ ok: true, roomId, messages });
      } catch (err) {
        ack({ ok: false, error: err.message });
      }
    });

    socket.on('room:leave', ({ roomId } = {}, ack) => {
      socket.leave(chatRoom(roomId));
      safeAck(ack)({ ok: true });
    });

    socket.on('room:history', async ({ roomId, limit } = {}, ack) => {
      ack = safeAck(ack);
      try {
        await assertRoomAccess(store, user.uid, roomId);
        const n = Math.min(Math.max(parseInt(limit, 10) || config.chat.historyLimit, 1), 200);
        ack({ ok: true, messages: await store.getMessages(roomId, n) });
      } catch (err) {
        ack({ ok: false, error: err.message });
      }
    });

    socket.on('message:send', async ({ roomId, text, clientId } = {}, ack) => {
      ack = safeAck(ack);
      try {
        if (!allow()) throw new Error('Slow down - too many messages');
        const body = cleanText(text);
        if (!body) throw new Error('Message is empty');
        await assertRoomAccess(store, user.uid, roomId, { write: true });
        if (!socket.rooms.has(chatRoom(roomId))) await socket.join(chatRoom(roomId));

        const saved = await store.addMessage(roomId, {
          text: body,
          type: 'user',
          senderId: user.uid,
          senderName: user.displayName,
          senderEmail: user.email,
          senderPhoto: user.photoURL || '',
          clientId: clientId || null,
        });
        io.to(chatRoom(roomId)).emit('message:new', saved);
        ack({ ok: true, message: saved });

        const trigger = config.ai.roomTrigger.toLowerCase();
        if (body.toLowerCase().startsWith(trigger)) {
          replyInRoom(roomId, body.slice(trigger.length).trim()).catch((e) => console.error('[ai room]', e));
        }
      } catch (err) {
        ack({ ok: false, error: err.message });
      }
    });

    socket.on('typing', async ({ roomId, isTyping } = {}) => {
      if (typeof roomId !== 'string' || !socket.rooms.has(chatRoom(roomId))) return;
      socket.to(chatRoom(roomId)).emit('typing', { roomId, uid: user.uid, name: user.displayName, isTyping: !!isTyping });
    });

    async function replyInRoom(roomId, question) {
      io.to(chatRoom(roomId)).emit('typing', { roomId, uid: 'ai', name: config.ai.botName, isTyping: true });
      let text;
      try {
        const recent = await store.getMessages(roomId, Math.min(config.ai.maxHistory, 30));
        const transcript = recent.map((m) => `${m.type === 'ai' ? config.ai.botName : m.senderName}: ${m.text}`).join('\n');
        text = await ai.chat([
          {
            role: 'user',
            content:
              `You are participating in a group chat as "${config.ai.botName}". Recent conversation:\n\n${transcript}\n\n` +
              `Reply to the latest request${question ? `: "${question}"` : ''}. Keep it brief and useful for the group.`,
          },
        ]);
      } catch (err) {
        text = `Sorry, I couldn't answer that (${err.message}).`;
      } finally {
        io.to(chatRoom(roomId)).emit('typing', { roomId, uid: 'ai', name: config.ai.botName, isTyping: false });
      }
      const saved = await store.addMessage(roomId, {
        text: text || '(no response)',
        type: 'ai',
        senderId: 'ai',
        senderName: config.ai.botName,
        senderEmail: '',
        senderPhoto: '',
      });
      io.to(chatRoom(roomId)).emit('message:new', saved);
    }

    // ---------- Private per-user AI assistant ----------

    socket.on('ai:history', async (_payload, ack) => {
      ack = safeAck(typeof _payload === 'function' ? _payload : ack);
      try {
        ack({ ok: true, messages: await store.getAiMessages(user.uid, 100) });
      } catch (err) {
        ack({ ok: false, error: err.message });
      }
    });

    socket.on('ai:clear', async (_payload, ack) => {
      ack = safeAck(typeof _payload === 'function' ? _payload : ack);
      try {
        await store.clearAiMessages(user.uid);
        io.to(userRoom(user.uid)).emit('ai:cleared');
        ack({ ok: true });
      } catch (err) {
        ack({ ok: false, error: err.message });
      }
    });

    socket.on('ai:send', async ({ text } = {}, ack) => {
      ack = safeAck(ack);
      const prompt = cleanText(text);
      if (!prompt) return ack({ ok: false, error: 'Message is empty' });
      if (!allow()) return ack({ ok: false, error: 'Slow down - too many messages' });
      if (aiBusy.has(user.uid)) return ack({ ok: false, error: 'The assistant is still answering your previous message' });

      aiBusy.add(user.uid);
      const toUser = io.to(userRoom(user.uid));
      try {
        const userMsg = await store.addAiMessage(user.uid, 'user', prompt);
        toUser.emit('ai:message', userMsg);
        toUser.emit('ai:typing', { isTyping: true });

        const history = await store.getAiMessages(user.uid, config.ai.maxHistory);
        const reply = await ai.chat(history.map(({ role, content }) => ({ role, content })), {
          system: `${config.ai.systemPrompt}\nYou are talking with ${user.displayName}.`,
        });
        const botMsg = await store.addAiMessage(user.uid, 'assistant', reply || '(no response)');
        toUser.emit('ai:message', botMsg);
        ack({ ok: true, message: botMsg });
      } catch (err) {
        toUser.emit('ai:error', { error: err.message });
        ack({ ok: false, error: err.message });
      } finally {
        aiBusy.delete(user.uid);
        toUser.emit('ai:typing', { isTyping: false });
      }
    });

    // ---------- Disconnect / presence ----------

    socket.on('disconnect', async () => {
      const left = (connections.get(user.uid) || 1) - 1;
      if (left > 0) return connections.set(user.uid, left);
      connections.delete(user.uid);
      io.emit('presence', { uid: user.uid, online: false });
      try {
        await store.setPresence(user.uid, false);
      } catch (err) {
        console.error('[socket] setPresence failed', err);
      }
    });
  });

  io.onlineUsers = () => [...connections.keys()];
  return io;
}
