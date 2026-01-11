import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { DatabaseService } from './services/database';
import { handleSession } from './handlers/sessionHandler';
import { handleEvents } from './handlers/eventHandler';
import { handleError } from './handlers/errorHandler';

// Environment variables interface
interface Env {
  DATABASE_URL: string;
  API_KEY: string;
  IPINFO_TOKEN?: string;
  DB_CA_CERT?: string;
}

// Create Hono app
const app = new Hono<{ Bindings: Env }>();

// Use Cloudflare's bindings directly in development if needed
app.use('*', async (c, next) => {
  // Sometimes in local dev, bindings might be on the global object or accessed differently depending on wrangler version
  // but usually c.env is correct.
  console.log('Checking env vars availability:', {
    hasDbUrl: !!c.env.DATABASE_URL,
    apiKeyExists: !!c.env.API_KEY
  });
  await next();
});

// CORS middleware - allow all origins for analytics
app.use('/*', cors({
  origin: '*',
  allowMethods: ['GET', 'POST', 'OPTIONS'],
  allowHeaders: ['Content-Type', 'Authorization'],
  maxAge: 86400, // 24 hours
}));

// API Key authentication middleware
app.use('/api/*', async (c, next) => {
  const authHeader = c.req.header('Authorization');
  const expectedKey = c.env.API_KEY;

  if (!authHeader) {
    return c.json({ error: 'Missing Authorization header' }, 401);
  }

  // Support both "Bearer <key>" and plain "<key>"
  const providedKey = authHeader.startsWith('Bearer ')
    ? authHeader.substring(7)
    : authHeader;

  if (providedKey !== expectedKey) {
    return c.json({ error: 'Invalid API key' }, 403);
  }

  await next();
});

// Health check endpoint (no auth required)
app.get('/health', async (c) => {
  try {
    // Environment variable check for debugging
    if (!c.env.DATABASE_URL) {
      throw new Error('DATABASE_URL environment variable is not set');
    }

    const db = new DatabaseService({ 
      DATABASE_URL: c.env.DATABASE_URL,
      DB_CA_CERT: c.env.DB_CA_CERT 
    });
    const dbHealthy = await db.healthCheck();

    return c.json({
      status: dbHealthy ? 'healthy' : 'degraded',
      timestamp: new Date().toISOString(),
      database: dbHealthy ? 'connected' : 'disconnected',
      // Adding debug info temporarily (DO NOT USE IN PROD)
      debug_db_url_exists: !!c.env.DATABASE_URL
    });
  } catch (error) {
    return c.json(
      {
        status: 'unhealthy',
        timestamp: new Date().toISOString(),
        error: error instanceof Error ? error.message : 'Unknown error',
      },
      503
    );
  }
});

// Session endpoint - POST /api/session
app.post('/api/session', async (c) => {
  const db = new DatabaseService({ 
    DATABASE_URL: c.env.DATABASE_URL,
    DB_CA_CERT: c.env.DB_CA_CERT 
  });
  return handleSession(c, {
    db,
    ipinfoToken: c.env.IPINFO_TOKEN,
  });
});

// Events endpoint - POST /api/events
app.post('/api/events', async (c) => {
  const db = new DatabaseService({ 
    DATABASE_URL: c.env.DATABASE_URL,
    DB_CA_CERT: c.env.DB_CA_CERT 
  });
  return handleEvents(c, { db });
});

// Errors endpoint - POST /api/errors
app.post('/api/errors', async (c) => {
  const db = new DatabaseService({ 
    DATABASE_URL: c.env.DATABASE_URL,
    DB_CA_CERT: c.env.DB_CA_CERT 
  });
  return handleError(c, { db });
});

// Root endpoint - API info
app.get('/', (c) => {
  return c.json({
    name: 'Flutter Analytics API',
    version: '1.0.0',
    endpoints: {
      health: 'GET /health',
      session: 'POST /api/session',
      events: 'POST /api/events',
      errors: 'POST /api/errors',
    },
    documentation: 'See README.md for usage details',
  });
});

// 404 handler
app.notFound((c) => {
  return c.json({ error: 'Not found' }, 404);
});

// Error handler
app.onError((err, c) => {
  console.error('Unhandled error:', err);
  return c.json(
    {
      error: 'Internal server error',
      message: err.message,
    },
    500
  );
});

export default app;
