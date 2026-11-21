import 'dotenv/config';

const bool = (v, d = false) => (v === undefined || v === '' ? d : ['1', 'true', 'yes'].includes(String(v).toLowerCase()));
const int = (v, d) => (Number.isFinite(parseInt(v, 10)) ? parseInt(v, 10) : d);

export const config = {
  port: int(process.env.PORT, 3000),
  corsOrigins: (process.env.CORS_ORIGINS || '*').split(',').map((s) => s.trim()).filter(Boolean),

  firebase: {
    // Either a path to a service-account JSON file, the JSON itself (base64 or raw),
    // or nothing (falls back to Application Default Credentials when projectId is set).
    serviceAccountPath: process.env.FIREBASE_SERVICE_ACCOUNT_PATH || process.env.GOOGLE_APPLICATION_CREDENTIALS || '',
    serviceAccountJson: process.env.FIREBASE_SERVICE_ACCOUNT_JSON || '',
    projectId: process.env.FIREBASE_PROJECT_ID || '',
  },

  // DEV ONLY: skip Firebase ID-token verification and keep data in memory.
  // Clients then authenticate with a token of the form "dev:<uid>:<email>:<name>".
  devAuth: bool(process.env.DEV_AUTH, false),

  ai: {
    provider: (process.env.AI_PROVIDER || 'openai').toLowerCase(), // openai | anthropic | mock
    openaiApiKey: process.env.OPENAI_API_KEY || '',
    openaiBaseUrl: process.env.OPENAI_BASE_URL || 'https://api.openai.com/v1',
    openaiModel: process.env.OPENAI_MODEL || 'gpt-4o-mini',
    openaiVisionModel: process.env.OPENAI_VISION_MODEL || 'gpt-4o-mini',
    openaiImageModel: process.env.OPENAI_IMAGE_MODEL || 'dall-e-3',
    anthropicApiKey: process.env.ANTHROPIC_API_KEY || '',
    anthropicModel: process.env.ANTHROPIC_MODEL || 'claude-sonnet-5-5',
    systemPrompt:
      process.env.AI_SYSTEM_PROMPT ||
      'You are UniChat Assistant, a helpful study and research companion for university students and educators. Be clear, accurate and concise.',
    maxHistory: int(process.env.AI_MAX_HISTORY, 20),
    maxTokens: int(process.env.AI_MAX_TOKENS, 1024),
    botName: process.env.AI_BOT_NAME || 'UniChat AI',
    // Messages in group rooms that start with this trigger get an AI reply in the room.
    roomTrigger: process.env.AI_ROOM_TRIGGER || '@ai',
  },

  chat: {
    historyLimit: int(process.env.CHAT_HISTORY_LIMIT, 50),
    maxMessageLength: int(process.env.CHAT_MAX_MESSAGE_LENGTH, 4000),
  },
};
