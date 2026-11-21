import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';

process.env.DEV_AUTH = 'true';
process.env.AI_PROVIDER = 'mock';

const { createApp } = await import('../src/app.js');
const { MemoryStore } = await import('../src/store/memoryStore.js');
const { io: ioc } = await import('socket.io-client');

let server, store, url;
const sockets = [];

const connect = (token) =>
  new Promise((resolve, reject) => {
    const s = ioc(url, { auth: { token }, transports: ['websocket'], reconnection: false, forceNew: true });
    sockets.push(s);
    s.once('session', () => resolve(s));
    s.once('connect_error', reject);
  });
const emit = (s, ev, payload) => new Promise((r) => s.emit(ev, payload, r));
const next = (s, ev, pred = () => true) =>
  new Promise((resolve) => {
    const h = (d) => { if (pred(d)) { s.off(ev, h); resolve(d); } };
    s.on(ev, h);
  });

before(async () => {
  store = new MemoryStore();
  ({ server } = createApp({ store }));
  await new Promise((r) => server.listen(0, r));
  url = `http://localhost:${server.address().port}`;
});

after(async () => {
  sockets.forEach((s) => s.close());
  await new Promise((r) => server.close(r));
});

test('rejects connections without a valid token', async () => {
  await assert.rejects(connect('nope'), /unauthorized/);
});

test('stores user profile on connect', async () => {
  await connect('dev:alice:alice@uni.edu:Alice');
  const u = await store.getUser('alice');
  assert.equal(u.email, 'alice@uni.edu');
  assert.equal(u.online, true);
});

test('room messages are broadcast and persisted; @ai replies in room', async () => {
  const a = await connect('dev:alice:alice@uni.edu:Alice');
  const b = await connect('dev:bob:bob@uni.edu:Bob');
  assert.equal((await emit(a, 'room:join', { roomId: 'project:p1' })).ok, true);
  assert.equal((await emit(b, 'room:join', { roomId: 'project:p1' })).ok, true);

  const got = next(b, 'message:new', (m) => m.text === 'hello team');
  const ack = await emit(a, 'message:send', { roomId: 'project:p1', text: 'hello team' });
  assert.equal(ack.ok, true);
  assert.equal((await got).senderName, 'Alice');

  const aiReply = next(b, 'message:new', (m) => m.type === 'ai');
  await emit(a, 'message:send', { roomId: 'project:p1', text: '@ai summarise' });
  assert.match((await aiReply).text, /mock AI/);

  const hist = await emit(b, 'room:history', { roomId: 'project:p1' });
  assert.equal(hist.messages.length, 3);
});

test('direct-message rooms are restricted to participants', async () => {
  const c = await connect('dev:carol:carol@uni.edu:Carol');
  const res = await emit(c, 'room:join', { roomId: 'dm:alice_bob' });
  assert.equal(res.ok, false);
});

test('private AI chat is per user and synced across that user’s devices', async () => {
  const phone = await connect('dev:dave:dave@uni.edu:Dave');
  const laptop = await connect('dev:dave:dave@uni.edu:Dave');
  const other = await connect('dev:erin:erin@uni.edu:Erin');
  let leaked = false;
  other.on('ai:message', () => (leaked = true));

  const mirrored = next(laptop, 'ai:message', (m) => m.role === 'assistant');
  const ack = await emit(phone, 'ai:send', { text: 'What is a B-tree?' });
  assert.equal(ack.ok, true);
  assert.match(ack.message.content, /B-tree/);
  await mirrored;

  const hist = await emit(laptop, 'ai:history', {});
  assert.equal(hist.messages.length, 2);
  assert.equal((await emit(other, 'ai:history', {})).messages.length, 0);
  assert.equal(leaked, false);
});

test('REST endpoints require auth and proxy AI', async () => {
  assert.equal((await fetch(`${url}/api/me`)).status, 401);
  const res = await fetch(`${url}/api/ai/complete`, {
    method: 'POST',
    headers: { Authorization: 'Bearer dev:alice:alice@uni.edu:Alice', 'Content-Type': 'application/json' },
    body: JSON.stringify({ message: 'hi' }),
  });
  assert.equal(res.status, 200);
  assert.match((await res.json()).reply, /mock AI/);
});
