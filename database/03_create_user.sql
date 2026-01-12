-- ============================================================================
-- Create Dedicated Database User for Cloudflare Worker
-- ============================================================================
-- Purpose: Create a restricted database user with minimal permissions
-- Security: Only INSERT and SELECT permissions, no DELETE or UPDATE
-- Run this AFTER 01_create_tables.sql and 02_create_indexes.sql
-- ============================================================================

-- ============================================================================
-- STEP 1: Generate a strong password
-- ============================================================================
-- IMPORTANT: Replace 'YOUR_STRONG_PASSWORD_HERE' with a secure password
-- Generate one with: openssl rand -base64 32
-- Example: 8kF9mP2nL5qR7wX3vJ6hT4gN1bV0cZ8yA2sD9fK5mL7pQ3wE6rT0

-- ============================================================================
-- STEP 2: Create the role
-- ============================================================================
-- remove the existing role if it exists (for re-running the script)
-- DROP OWNED BY analytics_worker;

-- DROP ROLE analytics_worker;

CREATE ROLE analytics_worker
WITH
    LOGIN PASSWORD 'JbORPer4lr7fl4QIU628eZP6S5YnioPV0bzWZUtBb7I=';

-- ============================================================================
-- STEP 3: Grant permissions
-- ============================================================================

-- Allow INSERT into all analytics tables
GRANT INSERT ON app_sessions TO analytics_worker;

GRANT INSERT ON app_events TO analytics_worker;

GRANT INSERT ON app_errors TO analytics_worker;

-- Allow SELECT for potential Worker queries (optional, for aggregations)
GRANT SELECT ON app_sessions TO analytics_worker;

GRANT SELECT ON app_events TO analytics_worker;

GRANT SELECT ON app_errors TO analytics_worker;

-- Grant sequence usage for auto-incrementing IDs
GRANT USAGE,
SELECT ON ALL SEQUENCES IN SCHEMA public TO analytics_worker;

-- Specifically grant on the BIGSERIAL sequences
GRANT USAGE,
SELECT
    ON SEQUENCE app_sessions_id_seq TO analytics_worker;

GRANT USAGE,
SELECT
    ON SEQUENCE app_events_id_seq TO analytics_worker;

GRANT USAGE,
SELECT
    ON SEQUENCE app_errors_id_seq TO analytics_worker;

-- ============================================================================
-- STEP 4: Revoke dangerous permissions (safety)
-- ============================================================================
-- Ensure the worker cannot delete or modify existing data
REVOKE DELETE,
UPDATE,
TRUNCATE ON app_sessions
FROM analytics_worker;

REVOKE DELETE, UPDATE, TRUNCATE ON app_events FROM analytics_worker;

REVOKE DELETE, UPDATE, TRUNCATE ON app_errors FROM analytics_worker;

-- ============================================================================
-- STEP 5: Set default schema (optional)
-- ============================================================================
ALTER ROLE analytics_worker SET search_path TO public;

-- ============================================================================
-- VERIFICATION
-- ============================================================================
-- Verify permissions with this query:
--
-- SELECT
--     grantee,
--     table_schema,
--     table_name,
--     privilege_type
-- FROM information_schema.role_table_grants
-- WHERE grantee = 'analytics_worker'
-- ORDER BY table_name, privilege_type;

-- ============================================================================
-- CONNECTION STRING FORMAT
-- ============================================================================
-- After running this script, your Cloudflare Worker will use:
--
-- postgresql://analytics_worker:YOUR_STRONG_PASSWORD_HERE@<aiven-host>:<port>/<database>?sslmode=require
--
-- Example:
-- postgresql://analytics_worker:8kF9mP2nL5qR7wX3@ffmpeg-analytics-project.aivencloud.com:12345/defaultdb?sslmode=require
--
-- IMPORTANT: Store this connection string in Cloudflare Workers Secrets:
--   wrangler secret put DATABASE_URL

-- ============================================================================
-- SECURITY NOTES
-- ============================================================================
-- 1. This role can only INSERT and SELECT, not modify or delete data
-- 2. Use a strong, randomly-generated password (32+ characters)
-- 3. Never commit the connection string to Git
-- 4. Rotate the password periodically (every 90 days recommended)
-- 5. Monitor database logs for suspicious activity from this user