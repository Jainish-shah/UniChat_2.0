# UniChat Realtime Server

Node.js backend for UniChat:

- **Socket.IO** for realtime chat (class announcements, project group chats, 1:1 rooms, typing, presence)
- **Firebase** for identity (ID tokens verified with the Admin SDK) and as the **user information store** (Firestore)
- **AI assistant** for every user: a private, persistent AI conversation per user plus `@ai` replies inside group rooms
- AI provider keys stay on the server. The Flutter app never sees them.

```
Flutter app ──(Firebase Auth: Google sign-in)──► Firebase
     │  ID token
     ▼
Socket.IO / REST  ──►  this server ──► Firestore (users, rooms, messages, aiMessages)
                                   └─► OpenAI or Anthropic
```

## Quick start

```bash
cd server
npm install
cp .env.example .env
```

### Option A: local dev, no Firebase

```bash
DEV_AUTH=true AI_PROVIDER=mock npm run dev
npm test                         # integration tests (sockets + REST)
```

With `DEV_AUTH=true`, clients authenticate with `dev:<uid>:<email>:<name>` and data lives in memory.

### Option B: real setup

1. Firebase console → Project settings → **Service accounts** → *Generate new private key*.
   Save it as `server/serviceAccountKey.json` (it is git-ignored) or put its JSON in `FIREBASE_SERVICE_ACCOUNT_JSON`.
2. Enable **Firestore** and **Authentication → Google** in the same Firebase project the app uses.
3. Deploy the rules from the repo root: `firebase deploy --only firestore:rules`.
4. Set `AI_PROVIDER` and `OPENAI_API_KEY` (or `ANTHROPIC_API_KEY`) in `.env`.
5. `npm start`

Docker: `docker build -t unichat-server . && docker run -p 3000:3000 --env-file .env unichat-server`

## Firestore layout

| Path | Contents | Written by |
|---|---|---|
| `users/{uid}` | email, displayName, photoURL, studentId, role, online, lastSeen | app (on login) + server (presence) |
| `users/{uid}/aiMessages/{id}` | `{role, content, createdAt}`: the user's private AI chat | server |
| `rooms/{roomId}` | `lastMessage`, `updatedAt`, optional `members: [uid]`, `posters: [uid]` | server / admin |
| `rooms/{roomId}/messages/{id}` | `{text, type: user\|ai, senderId, senderName, createdAt}` | server |

Room ids: `announcements`, `project:<projectId>`, `dm:<uidA>_<uidB>` (sorted uids).
DM rooms are only open to their two participants. For any other room, add `members` to restrict who can read it, or `posters` to restrict who can write (for example, only instructors in `announcements`).

## Socket.IO protocol

Connect with `auth: { token: <Firebase ID token> }`. Every request takes an ack callback that receives `{ ok, ...data }` or `{ ok: false, error }`.

| Client → server | Payload | Ack |
|---|---|---|
| `room:join` | `{roomId}` | `{messages}` (last 50) |
| `room:leave` | `{roomId}` | |
| `room:history` | `{roomId, limit?}` | `{messages}` |
| `message:send` | `{roomId, text}` | `{message}`. Text starting with `@ai` triggers an AI reply in the room |
| `typing` | `{roomId, isTyping}` | |
| `ai:send` | `{text}` | `{message}`: the assistant's reply |
| `ai:history` | `{}` | `{messages}` |
| `ai:clear` | `{}` | |

| Server → client | Payload |
|---|---|
| `session` | `{user}`: the Firestore profile |
| `message:new` | room message |
| `typing` | `{roomId, uid, name, isTyping}` (`uid: 'ai'` while the bot is answering) |
| `presence` | `{uid, online}` |
| `ai:message` | `{id, role, content, createdAt}`: sent to all of the user's devices |
| `ai:typing` / `ai:error` / `ai:cleared` | |

## REST (Bearer Firebase ID token)

- `GET /health`
- `GET /api/me`, `PUT /api/me`: profile in Firestore
- `GET /api/users/:uid`: public profile
- `GET /api/rooms/:roomId/messages?limit=`
- `GET /api/ai/models`: modes for the GPT screen (`chat`, `vision`, `image`)
- `GET /api/ai/history`
- `POST /api/ai/complete` `{message, model}`: `model: "image"` generates an image
- `POST /api/ai/vision` `{imageBase64, prompt}`
- `POST /api/ai/image` `{prompt}`
