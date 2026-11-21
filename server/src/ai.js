import { config } from './config.js';

/**
 * Provider-agnostic AI helper. All provider keys live on the server only.
 * history: [{ role: 'user' | 'assistant', content: string }]
 */

class AiError extends Error {
  constructor(message, status = 502) {
    super(message);
    this.status = status;
  }
}

async function postJson(url, headers, body) {
  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...headers },
    body: JSON.stringify(body),
  });
  const json = await res.json().catch(() => ({}));
  if (!res.ok) {
    const msg = json?.error?.message || json?.message || `AI provider returned HTTP ${res.status}`;
    throw new AiError(msg, res.status >= 500 ? 502 : res.status);
  }
  return json;
}

function trimHistory(history) {
  return history
    .filter((m) => m && (m.role === 'user' || m.role === 'assistant') && typeof m.content === 'string' && m.content.trim())
    .slice(-config.ai.maxHistory);
}

async function openaiChat(history, { system, model } = {}) {
  if (!config.ai.openaiApiKey) throw new AiError('OPENAI_API_KEY is not configured on the server', 503);
  const json = await postJson(
    `${config.ai.openaiBaseUrl}/chat/completions`,
    { Authorization: `Bearer ${config.ai.openaiApiKey}` },
    {
      model: model || config.ai.openaiModel,
      messages: [{ role: 'system', content: system || config.ai.systemPrompt }, ...history],
      max_tokens: config.ai.maxTokens,
      temperature: 0.7,
    }
  );
  return json.choices?.[0]?.message?.content?.trim() || '';
}

async function anthropicChat(history, { system, model } = {}) {
  if (!config.ai.anthropicApiKey) throw new AiError('ANTHROPIC_API_KEY is not configured on the server', 503);
  // Anthropic requires the conversation to start with a user turn.
  while (history.length && history[0].role !== 'user') history = history.slice(1);
  const json = await postJson(
    'https://api.anthropic.com/v1/messages',
    { 'x-api-key': config.ai.anthropicApiKey, 'anthropic-version': '2023-06-01' },
    {
      model: model || config.ai.anthropicModel,
      max_tokens: config.ai.maxTokens,
      system: system || config.ai.systemPrompt,
      messages: history,
    }
  );
  return (json.content || []).filter((b) => b.type === 'text').map((b) => b.text).join('').trim();
}

function mockChat(history) {
  const last = history[history.length - 1]?.content || '';
  return `[mock AI] You said: "${last.slice(0, 200)}"`;
}

/** Chat completion using the configured provider. */
export async function chat(history, opts = {}) {
  const h = trimHistory(history);
  if (!h.length) throw new AiError('Empty conversation', 400);
  switch (config.ai.provider) {
    case 'anthropic':
      return anthropicChat(h, opts);
    case 'mock':
      return mockChat(h);
    case 'openai':
    default:
      return openaiChat(h, opts);
  }
}

/** Ask a question about an image. imageBase64 is raw base64 (no data: prefix). */
export async function vision({ prompt, imageBase64, mediaType = 'image/jpeg' }) {
  if (!imageBase64) throw new AiError('imageBase64 is required', 400);
  const text = prompt?.trim() || 'Describe this image.';
  if (config.ai.provider === 'mock') return `[mock AI] received an image (${imageBase64.length} b64 chars): ${text}`;

  if (config.ai.provider === 'anthropic') {
    if (!config.ai.anthropicApiKey) throw new AiError('ANTHROPIC_API_KEY is not configured on the server', 503);
    const json = await postJson(
      'https://api.anthropic.com/v1/messages',
      { 'x-api-key': config.ai.anthropicApiKey, 'anthropic-version': '2023-06-01' },
      {
        model: config.ai.anthropicModel,
        max_tokens: config.ai.maxTokens,
        system: config.ai.systemPrompt,
        messages: [{
          role: 'user',
          content: [
            { type: 'image', source: { type: 'base64', media_type: mediaType, data: imageBase64 } },
            { type: 'text', text },
          ],
        }],
      }
    );
    return (json.content || []).filter((b) => b.type === 'text').map((b) => b.text).join('').trim();
  }

  if (!config.ai.openaiApiKey) throw new AiError('OPENAI_API_KEY is not configured on the server', 503);
  const json = await postJson(
    `${config.ai.openaiBaseUrl}/chat/completions`,
    { Authorization: `Bearer ${config.ai.openaiApiKey}` },
    {
      model: config.ai.openaiVisionModel,
      max_tokens: config.ai.maxTokens,
      messages: [
        { role: 'system', content: config.ai.systemPrompt },
        {
          role: 'user',
          content: [
            { type: 'text', text },
            { type: 'image_url', image_url: { url: `data:${mediaType};base64,${imageBase64}` } },
          ],
        },
      ],
    }
  );
  return json.choices?.[0]?.message?.content?.trim() || '';
}

/** Generate an image (OpenAI only). Returns a URL. */
export async function generateImage(prompt) {
  if (!prompt?.trim()) throw new AiError('prompt is required', 400);
  if (config.ai.provider === 'mock') return 'https://placehold.co/1024x1024/png?text=mock+image';
  if (!config.ai.openaiApiKey) throw new AiError('Image generation needs OPENAI_API_KEY on the server', 503);
  const json = await postJson(
    `${config.ai.openaiBaseUrl}/images/generations`,
    { Authorization: `Bearer ${config.ai.openaiApiKey}` },
    { model: config.ai.openaiImageModel, prompt, n: 1, size: '1024x1024' }
  );
  return json.data?.[0]?.url || '';
}

/**
 * Modes the client can pick in the GPT screen dropdown. The client only knows these logical
 * ids; the server decides which provider model backs each one.
 */
export function listModels() {
  const p = config.ai.provider;
  const chatModel = p === 'anthropic' ? config.ai.anthropicModel : p === 'mock' ? 'mock' : config.ai.openaiModel;
  const models = [
    { id: 'chat', label: 'Chat with AI', model: chatModel },
    { id: 'vision', label: 'Send an image and get a reply', model: p === 'anthropic' ? config.ai.anthropicModel : config.ai.openaiVisionModel },
  ];
  if (config.ai.openaiApiKey || p === 'mock') {
    models.push({ id: 'image', label: 'Image generation', model: config.ai.openaiImageModel });
  }
  return { provider: p, models };
}

export { AiError };
