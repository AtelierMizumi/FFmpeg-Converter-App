import { neon } from '@neondatabase/serverless';
import type { SessionData, EventData, ErrorData } from './validator';
import type { GeolocationData } from './geolocation';

export interface DatabaseConfig {
  DATABASE_URL: string;
}

export class DatabaseService {
  private sql: ReturnType<typeof neon>;

  constructor(config: DatabaseConfig) {
    this.sql = neon(config.DATABASE_URL);
  }

  /**
   * Insert a new session record with geolocation data
   */
  async insertSession(session: SessionData, geo: GeolocationData | null): Promise<void> {
    const query = `
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
        $1, $2, $3,
        $4, $5, $6, $7,
        $8, $9, $10, $11,
        $12, $13, $14, $15,
        $16, $17, $18, $19, $20, $21,
        $22, $23, $24,
        $25, $26, $27, $28, $29,
        $30, $31, $32,
        $33, $34, $35, $36, $37
      )
    `;

    await this.sql(query, [
      session.session_id,
      session.user_id_hash,
      session.timestamp,
      // Device
      session.device_model,
      session.device_brand,
      session.device_manufacturer,
      session.device_id_hash,
      session.screen_width,
      session.screen_height,
      session.screen_density,
      session.supported_abis,
      // OS
      session.os_name,
      session.os_version,
      session.api_level,
      session.kernel_version,
      // App
      session.app_version,
      session.app_build_number,
      session.package_name,
      session.is_first_launch,
      session.install_source,
      session.launch_count,
      // Network
      session.network_type,
      session.carrier_name,
      session.ip_address,
      // Locale
      session.locale_language,
      session.locale_country,
      session.timezone,
      session.timezone_offset,
      session.currency,
      // Performance
      session.startup_time_ms,
      session.memory_usage_mb,
      session.available_storage_gb,
      // Geolocation
      geo?.country,
      geo?.region,
      geo?.city,
      geo?.latitude,
      geo?.longitude,
    ]);
  }

  /**
   * Batch insert events
   */
  async insertEvents(events: EventData[]): Promise<void> {
    if (events.length === 0) return;

    // Build parameterized query for batch insert
    const values: any[] = [];
    const placeholders: string[] = [];
    let paramIndex = 1;

    events.forEach((event) => {
      placeholders.push(
        `($${paramIndex}, $${paramIndex + 1}, $${paramIndex + 2}, $${paramIndex + 3}, $${paramIndex + 4})`
      );
      values.push(
        event.session_id,
        event.event_type,
        event.event_name,
        event.timestamp,
        event.properties ? JSON.stringify(event.properties) : null
      );
      paramIndex += 5;
    });

    const query = `
      INSERT INTO app_events (session_id, event_type, event_name, timestamp, properties)
      VALUES ${placeholders.join(', ')}
    `;

    await this.sql(query, values);
  }

  /**
   * Insert a single error record
   */
  async insertError(error: ErrorData): Promise<void> {
    const query = `
      INSERT INTO app_errors (
        session_id, timestamp, error_type, error_message, stack_trace, context
      ) VALUES (
        $1, $2, $3, $4, $5, $6
      )
    `;

    await this.sql(query, [
      error.session_id,
      error.timestamp,
      error.error_type,
      error.error_message,
      error.stack_trace,
      error.context ? JSON.stringify(error.context) : null,
    ]);
  }

  /**
   * Health check - test database connection
   */
  async healthCheck(): Promise<boolean> {
    try {
      await this.sql('SELECT 1');
      return true;
    } catch (error) {
      console.error('Database health check failed:', error);
      return false;
    }
  }
}
