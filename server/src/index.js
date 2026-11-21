import { config } from './config.js';
import { createApp } from './app.js';

const { server } = createApp();

server.listen(config.port, () => {
  console.log(`UniChat realtime server listening on :${config.port}`);
  console.log(`  AI provider: ${config.ai.provider}${config.devAuth ? '  |  DEV_AUTH (in-memory store, no Firebase)' : ''}`);
});

const shutdown = () => server.close(() => process.exit(0));
process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);
