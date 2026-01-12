import type { Context } from 'hono';
import { SessionSchema } from '../services/validator';
import type { DatabaseService } from '../services/database';
import { fetchGeolocation, extractClientIP } from '../services/geolocation';

export interface SessionHandlerDependencies {
  db: DatabaseService;
  ipinfoToken?: string;
}

/**
 * Handle POST /api/session
 * Records a new app session with device, OS, app, network, locale, and performance data
 */
export async function handleSession(
  c: Context,
  deps: SessionHandlerDependencies
): Promise<Response> {
  try {
    const body = await c.req.json();

    // Validate request body
    const validationResult = SessionSchema.safeParse(body);
    if (!validationResult.success) {
      return c.json(
        {
          error: 'Validation failed',
          details: validationResult.error.errors,
        },
        400
      );
    }

    const sessionData = validationResult.data;

    // Extract client IP from request
    const clientIP = extractClientIP(c.req.raw);
    
    // Override IP address with actual client IP (if not provided or different)
    if (clientIP) {
      sessionData.ip_address = clientIP;
    }

    // Fetch geolocation data
    const geoData = clientIP
      ? await fetchGeolocation(
          clientIP,
          { IPINFO_TOKEN: deps.ipinfoToken },
          c.req.raw
        )
      : null;

    // Insert into database
    await deps.db.insertSession(sessionData, geoData);

    return c.json(
      {
        success: true,
        session_id: sessionData.session_id,
        message: 'Session recorded successfully',
      },
      201
    );
  } catch (error) {
    console.error('Session handler error:', error);
    
    return c.json(
      {
        error: 'Internal server error',
        message: error instanceof Error ? error.message : 'Unknown error',
      },
      500
    );
  }
}
