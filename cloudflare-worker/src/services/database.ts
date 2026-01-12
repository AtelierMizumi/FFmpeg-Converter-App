import { neon } from '@neondatabase/serverless';
import type { SessionData, EventData, ErrorData } from './validator';
import type { GeolocationData } from './geolocation';

export interface DatabaseConfig {
  DATABASE_URL: string;
}

export class DatabaseService {
  private sql: ReturnType<typeof neon>;

  constructor(config: DatabaseConfig) {
    console.log('Initializing Neon DatabaseService');
    
    // Neon's serverless driver is designed for edge environments
    // It uses HTTP fetch under the hood, making it perfect for Cloudflare Workers
    this.sql = neon(config.DATABASE_URL);
  }

  /**
   * Insert a new session record with geolocation data
   */
  async insertSession(session: SessionData, geo: GeolocationData | null): Promise<void> {
    await this.sql`
      INSERT INTO app_sessions (
        session_id, user_id, client_timestamp,
        device_model, device_brand, device_manufacturer,
        screen_width, screen_height, pixel_density, supported_abis,
        os_name, os_version, api_level,
        app_version, build_number, package_name, is_first_launch, install_source, lifetime_launch_count,
        connection_type, ip_address,
        system_language, locale_country_code, timezone, currency_code,
        app_startup_ms, memory_usage_mb,
        country_code, region, city, latitude, longitude
      ) VALUES (
        ${session.session_id}, ${session.user_id_hash}, ${session.timestamp},
        ${session.device_model}, ${session.device_brand}, ${session.device_manufacturer},
        ${session.screen_width}, ${session.screen_height}, ${session.screen_density}, ${session.supported_abis},
        ${session.os_name}, ${session.os_version}, ${session.api_level},
        ${session.app_version}, ${session.app_build_number}, ${session.package_name}, ${session.is_first_launch}, ${session.install_source}, ${session.launch_count},
        ${session.network_type}, ${session.ip_address},
        ${session.locale_language}, ${session.locale_country}, ${session.timezone}, ${session.currency},
        ${session.startup_time_ms}, ${session.memory_usage_mb},
        ${geo?.country ?? null}, ${geo?.region ?? null}, ${geo?.city ?? null}, ${geo?.latitude ?? null}, ${geo?.longitude ?? null}
      )
    `;
  }

  /**
   * Batch insert events
   */
  async insertEvents(events: EventData[]): Promise<void> {
    if (events.length === 0) return;

    // Insert events one by one to match existing schema
    for (const event of events) {
      await this.sql`
        INSERT INTO app_events (session_id, event_name, event_category, event_properties, client_timestamp)
        VALUES (
          ${event.session_id}, 
          ${event.event_name}, 
          ${event.event_type},
          ${event.properties ? JSON.stringify(event.properties) : null},
          ${event.timestamp}
        )
      `;
    }
  }

  /**
   * Insert a single error record
   */
  async insertError(error: ErrorData): Promise<void> {
    await this.sql`
      INSERT INTO app_errors (
        session_id, client_timestamp, error_type, error_message, stack_trace, error_context
      ) VALUES (
        ${error.session_id}, ${error.timestamp}, ${error.error_type}, ${error.error_message}, ${error.stack_trace}, ${error.context ? JSON.stringify(error.context) : null}
      )
    `;
  }

  /**
   * Health check - test database connection
   */
  async healthCheck(): Promise<boolean> {
    try {
      console.log('Starting health check...');
      const result = await this.sql`SELECT 1 as health`;
      console.log('Health check query result:', result);
      return true;
    } catch (error) {
      console.error('Database health check failed:', error);
      console.error('Error details:', {
        message: error instanceof Error ? error.message : 'Unknown error',
        stack: error instanceof Error ? error.stack : undefined,
        cause: error instanceof Error ? error.cause : undefined
      });
      return false;
    }
  }
}
