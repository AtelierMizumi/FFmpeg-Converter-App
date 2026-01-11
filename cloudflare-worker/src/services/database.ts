import postgres from 'postgres';
import type { SessionData, EventData, ErrorData } from './validator';
import type { GeolocationData } from './geolocation';

export interface DatabaseConfig {
  DATABASE_URL: string;
  DB_CA_CERT?: string;
}

export class DatabaseService {
  private sql: postgres.Sql;

  constructor(config: DatabaseConfig) {
    const sslOptions: any = {
      rejectUnauthorized: false
    };

    if (config.DB_CA_CERT) {
      sslOptions.ca = config.DB_CA_CERT;
      sslOptions.rejectUnauthorized = true;
    }

    this.sql = postgres(config.DATABASE_URL, {
      ssl: sslOptions,
      // Postgres.js specific options for serverless
      max: 1, // Max 1 connection for serverless env
      idle_timeout: 3, // Close idle connection quickly
      connect_timeout: 10,
    });
  }

  /**
   * Insert a new session record with geolocation data
   */
  async insertSession(session: SessionData, geo: GeolocationData | null): Promise<void> {
    await this.sql`
      INSERT INTO app_sessions (
        session_id, user_id_hash, timestamp,
        device_model, device_brand, device_manufacturer, device_id_hash,
        screen_width, screen_height, screen_density, supported_abis,
        os_name, os_version, api_level, kernel_version,
        app_version, app_build_number, package_name, is_first_launch, install_source, launch_count,
        network_type, carrier_name, ip_address,
        locale_language, locale_country, timezone, timezone_offset, currency,
        startup_time_ms, memory_usage_mb, available_storage_gb,
        geo_country, geo_region, geo_city, geo_latitude, geo_longitude
      ) VALUES (
        ${session.session_id}, ${session.user_id_hash}, ${session.timestamp},
        ${session.device_model}, ${session.device_brand}, ${session.device_manufacturer}, ${session.device_id_hash},
        ${session.screen_width}, ${session.screen_height}, ${session.screen_density}, ${session.supported_abis},
        ${session.os_name}, ${session.os_version}, ${session.api_level}, ${session.kernel_version},
        ${session.app_version}, ${session.app_build_number}, ${session.package_name}, ${session.is_first_launch}, ${session.install_source}, ${session.launch_count},
        ${session.network_type}, ${session.carrier_name}, ${session.ip_address},
        ${session.locale_language}, ${session.locale_country}, ${session.timezone}, ${session.timezone_offset}, ${session.currency},
        ${session.startup_time_ms}, ${session.memory_usage_mb}, ${session.available_storage_gb},
        ${geo?.country ?? null}, ${geo?.region ?? null}, ${geo?.city ?? null}, ${geo?.latitude ?? null}, ${geo?.longitude ?? null}
      )
    `;
  }

  /**
   * Batch insert events
   */
  async insertEvents(events: EventData[]): Promise<void> {
    if (events.length === 0) return;

    // Use postgres.js internal mapper for arrays
    const formattedEvents = events.map(event => ({
        session_id: event.session_id,
        event_type: event.event_type,
        event_name: event.event_name,
        timestamp: event.timestamp,
        properties: event.properties ? JSON.stringify(event.properties) : null
    }));

    await this.sql`
      INSERT INTO app_events ${this.sql(formattedEvents, 'session_id', 'event_type', 'event_name', 'timestamp', 'properties')}
    `;
  }

  /**
   * Insert a single error record
   */
  async insertError(error: ErrorData): Promise<void> {
    await this.sql`
      INSERT INTO app_errors (
        session_id, timestamp, error_type, error_message, stack_trace, context
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
      await this.sql`SELECT 1`;
      return true;
    } catch (error) {
      console.error('Database health check failed:', error);
      return false;
    }
  }
}


