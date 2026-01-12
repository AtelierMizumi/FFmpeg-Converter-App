-- ============================================================================
-- FFmpeg Converter Analytics Database Schema
-- ============================================================================
-- Purpose: Track anonymous usage analytics for app improvement
-- Privacy: No personal identifiable information (PII) collected
-- Retention: Indefinite (for product research)
-- ============================================================================

-- ============================================================================
-- TABLE 1: app_sessions
-- Purpose: Main analytics table - one row per app launch
-- ============================================================================
CREATE TABLE IF NOT EXISTS app_sessions (
    id BIGSERIAL PRIMARY KEY,
    session_id UUID NOT NULL,
    user_id VARCHAR(64),
    device_model VARCHAR(100),
    device_brand VARCHAR(100),
    device_manufacturer VARCHAR(100),
    is_physical_device BOOLEAN,
    supported_abis TEXT [],
    os_name VARCHAR(50) NOT NULL,
    os_version VARCHAR(50),
    api_level INTEGER,
    app_version VARCHAR(20),
    build_number VARCHAR(20),
    package_name VARCHAR(100),
    install_source VARCHAR(50),
    is_first_launch BOOLEAN,
    lifetime_launch_count INTEGER,
    previous_app_version VARCHAR(20),
    screen_width INTEGER,
    screen_height INTEGER,
    pixel_density DECIMAL(5, 2),
    connection_type VARCHAR(20),
    system_language VARCHAR(10),
    locale_country_code CHAR(2),
    timezone VARCHAR(50),
    uses_24hour_format BOOLEAN,
    currency_code CHAR(3),
    app_startup_ms INTEGER,
    memory_usage_mb INTEGER,
    app_size_mb INTEGER,
    flutter_version VARCHAR(20),
    dart_version VARCHAR(20),
    build_mode VARCHAR(20),
    ip_address INET,
    country_code CHAR(2),
    country_name VARCHAR(100),
    city VARCHAR(100),
    region VARCHAR(100),
    latitude DECIMAL(9, 6),
    longitude DECIMAL(9, 6),
    timezone_server VARCHAR(50),
    isp VARCHAR(200),
    user_agent TEXT,
    cloudflare_ray_id VARCHAR(50),
    client_timestamp TIMESTAMPTZ,
    server_timestamp TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_session UNIQUE (session_id, client_timestamp)
);

-- ============================================================================
-- TABLE 2: app_events
-- Purpose: Track in-app user behavior (features used, conversions)
-- ============================================================================
CREATE TABLE IF NOT EXISTS app_events (
    id BIGSERIAL PRIMARY KEY,
    session_id UUID NOT NULL,
    event_name VARCHAR(100) NOT NULL,
    event_category VARCHAR(50),
    event_properties JSONB,
    client_timestamp TIMESTAMPTZ,
    server_timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- TABLE 3: app_errors
-- Purpose: Automatic crash and error reporting for debugging
-- ============================================================================
CREATE TABLE IF NOT EXISTS app_errors (
    id BIGSERIAL PRIMARY KEY,
    session_id UUID NOT NULL,
    error_type VARCHAR(100),
    error_message TEXT,
    stack_trace TEXT,
    error_context JSONB,
    client_timestamp TIMESTAMPTZ,
    server_timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- COMMENTS for documentation
-- ============================================================================
COMMENT ON TABLE app_sessions IS 'Main analytics table - tracks each app launch with device and environment info';

COMMENT ON TABLE app_events IS 'User behavior tracking - features used, video conversions, screen views';

COMMENT ON TABLE app_errors IS 'Automatic error and crash reporting for debugging and stability monitoring';

COMMENT ON COLUMN app_sessions.session_id IS 'Unique session identifier (24h validity on client)';

COMMENT ON COLUMN app_sessions.user_id IS 'Anonymous user identifier (SHA256 hash of device fingerprint)';

COMMENT ON COLUMN app_sessions.is_first_launch IS 'True if this is the first time user opens the app';

COMMENT ON COLUMN app_sessions.lifetime_launch_count IS 'Total number of times user has opened the app';

COMMENT ON COLUMN app_events.event_properties IS 'Flexible JSON field for event-specific data (e.g., video format, file size)';

COMMENT ON COLUMN app_errors.error_context IS 'Additional context for debugging (screen name, user action, environment)';