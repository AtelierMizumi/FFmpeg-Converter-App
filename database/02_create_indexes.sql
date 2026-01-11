-- ============================================================================
-- Performance Indexes for Analytics Queries
-- ============================================================================
-- Purpose: Optimize common dashboard queries and analytics operations
-- Run this AFTER 01_create_tables.sql
-- ============================================================================

-- ============================================================================
-- INDEXES FOR app_sessions
-- ============================================================================

-- Primary lookup indexes
CREATE INDEX IF NOT EXISTS idx_sessions_session_id ON app_sessions (session_id);
CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON app_sessions (user_id);

-- Time-based queries (most common)
CREATE INDEX IF NOT EXISTS idx_sessions_server_timestamp ON app_sessions (server_timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_sessions_client_timestamp ON app_sessions (client_timestamp DESC);

-- Device analytics
CREATE INDEX IF NOT EXISTS idx_sessions_device_model ON app_sessions (device_model);
CREATE INDEX IF NOT EXISTS idx_sessions_device_brand ON app_sessions (device_brand);

-- OS analytics
CREATE INDEX IF NOT EXISTS idx_sessions_os ON app_sessions (os_name, os_version);
CREATE INDEX IF NOT EXISTS idx_sessions_api_level ON app_sessions (api_level) WHERE api_level IS NOT NULL;

-- App version tracking
CREATE INDEX IF NOT EXISTS idx_sessions_app_version ON app_sessions (app_version);

-- Geographic analytics
CREATE INDEX IF NOT EXISTS idx_sessions_country ON app_sessions (country_code);
CREATE INDEX IF NOT EXISTS idx_sessions_city ON app_sessions (country_code, city);

-- First launch tracking (for new user acquisition metrics)
CREATE INDEX IF NOT EXISTS idx_sessions_first_launch ON app_sessions (is_first_launch) WHERE is_first_launch = true;

-- Network type analytics
CREATE INDEX IF NOT EXISTS idx_sessions_connection_type ON app_sessions (connection_type);

-- Composite index for common dashboard query: daily users by country
CREATE INDEX IF NOT EXISTS idx_sessions_date_country ON app_sessions (((server_timestamp AT TIME ZONE 'UTC')::date), country_code);

-- Performance monitoring
CREATE INDEX IF NOT EXISTS idx_sessions_startup_time ON app_sessions (app_startup_ms) WHERE app_startup_ms IS NOT NULL;

-- ============================================================================
-- INDEXES FOR app_events
-- ============================================================================

-- Primary lookup
CREATE INDEX IF NOT EXISTS idx_events_session ON app_events (session_id);

-- Event analytics
CREATE INDEX IF NOT EXISTS idx_events_name ON app_events (event_name);
CREATE INDEX IF NOT EXISTS idx_events_category ON app_events (event_category);

-- Time-based event queries
CREATE INDEX IF NOT EXISTS idx_events_timestamp ON app_events (server_timestamp DESC);

-- JSON property queries (GIN index for JSONB)
CREATE INDEX IF NOT EXISTS idx_events_properties ON app_events USING GIN (event_properties);

-- Composite: events by name and time (common funnel queries)
CREATE INDEX IF NOT EXISTS idx_events_name_time ON app_events (event_name, server_timestamp DESC);

-- ============================================================================
-- INDEXES FOR app_errors
-- ============================================================================

-- Primary lookup
CREATE INDEX IF NOT EXISTS idx_errors_session ON app_errors (session_id);

-- Error analytics
CREATE INDEX IF NOT EXISTS idx_errors_type ON app_errors (error_type);
CREATE INDEX IF NOT EXISTS idx_errors_timestamp ON app_errors (server_timestamp DESC);

-- Error message search (for grouping similar errors)
CREATE INDEX IF NOT EXISTS idx_errors_message ON app_errors USING GIN (to_tsvector('english', error_message));

-- JSON context queries
CREATE INDEX IF NOT EXISTS idx_errors_context ON app_errors USING GIN (error_context);

-- Composite: error rate over time by type
CREATE INDEX IF NOT EXISTS idx_errors_type_time ON app_errors (error_type, ((server_timestamp AT TIME ZONE 'UTC')::date));

-- ============================================================================
-- VERIFY INDEXES
-- ============================================================================
-- Run this query to see all created indexes:
-- 
-- SELECT 
--     tablename, 
--     indexname, 
--     indexdef 
-- FROM pg_indexes 
-- WHERE schemaname = 'public' 
--   AND tablename IN ('app_sessions', 'app_events', 'app_errors')
-- ORDER BY tablename, indexname;
