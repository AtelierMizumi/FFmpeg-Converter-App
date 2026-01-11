-- ============================================================================
-- Pre-built SQL Queries for Metabase Dashboard
-- ============================================================================
-- Purpose: Ready-to-use queries for visualizing analytics data
-- Usage: Copy these queries into Metabase as "Questions"
-- ============================================================================

-- ============================================================================
-- KPI QUERIES (Numbers for dashboard cards)
-- ============================================================================

-- Total Unique Users (Lifetime)
SELECT COUNT(DISTINCT user_id) AS total_users
FROM app_sessions
WHERE
    user_id IS NOT NULL;

-- Total Sessions (Lifetime)
SELECT COUNT(*) AS total_sessions FROM app_sessions;

-- Total Video Conversions (Lifetime)
SELECT COUNT(*) AS total_conversions
FROM app_events
WHERE
    event_name = 'video_conversion';

-- Video Conversion Success Rate (%)
SELECT ROUND(
        100.0 * SUM(
            CASE
                WHEN (
                    event_properties ->> 'success'
                )::boolean THEN 1
                ELSE 0
            END
        ) / COUNT(*), 2
    ) AS success_rate_percent
FROM app_events
WHERE
    event_name = 'video_conversion';

-- Total Errors (Lifetime)
SELECT COUNT(*) AS total_errors FROM app_errors;

-- Error Rate (errors per 100 sessions)
SELECT ROUND(
        100.0 * (
            SELECT COUNT(*)
            FROM app_errors
        ) / NULLIF(
            (
                SELECT COUNT(*)
                FROM app_sessions
            ), 0
        ), 2
    ) AS errors_per_100_sessions;

-- ============================================================================
-- TIME SERIES QUERIES
-- ============================================================================

-- Daily Active Users (Last 30 Days)
SELECT
    server_timestamp::date AS date,
    COUNT(DISTINCT session_id) AS daily_sessions,
    COUNT(DISTINCT user_id) AS daily_unique_users
FROM app_sessions
WHERE
    server_timestamp >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY
    server_timestamp::date
ORDER BY date DESC;

-- Weekly Active Users (Last 12 Weeks)
SELECT DATE_TRUNC('week', server_timestamp) AS week, COUNT(DISTINCT user_id) AS weekly_users
FROM app_sessions
WHERE
    server_timestamp >= CURRENT_DATE - INTERVAL '12 weeks'
GROUP BY
    DATE_TRUNC('week', server_timestamp)
ORDER BY week DESC;

-- Video Conversions Over Time (Daily, Last 30 Days)
SELECT
    server_timestamp::date AS date,
    COUNT(*) AS conversions,
    SUM(
        CASE
            WHEN (
                event_properties ->> 'success'
            )::boolean THEN 1
            ELSE 0
        END
    ) AS successful,
    SUM(
        CASE
            WHEN NOT (
                event_properties ->> 'success'
            )::boolean THEN 1
            ELSE 0
        END
    ) AS failed
FROM app_events
WHERE
    event_name = 'video_conversion'
    AND server_timestamp >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY
    server_timestamp::date
ORDER BY date DESC;

-- Error Rate Over Time (Daily, Last 30 Days)
SELECT
    server_timestamp::date AS date,
    COUNT(*) AS error_count,
    COUNT(DISTINCT session_id) AS affected_sessions
FROM app_errors
WHERE
    server_timestamp >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY
    server_timestamp::date
ORDER BY date DESC;

-- ============================================================================
-- DEVICE & OS DISTRIBUTION
-- ============================================================================

-- Device Model Distribution (Top 10)
SELECT
    device_brand,
    device_model,
    os_version,
    COUNT(*) AS session_count,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM app_sessions
GROUP BY
    device_brand,
    device_model,
    os_version
ORDER BY session_count DESC
LIMIT 10;

-- OS Version Distribution
SELECT
    os_name,
    os_version,
    COUNT(*) AS users,
    ROUND(AVG(app_startup_ms), 0) AS avg_startup_ms,
    ROUND(AVG(memory_usage_mb), 0) AS avg_memory_mb
FROM app_sessions
GROUP BY
    os_name,
    os_version
ORDER BY users DESC;

-- Android API Level Distribution (Android only)
SELECT
    api_level,
    os_version,
    COUNT(*) AS device_count
FROM app_sessions
WHERE
    os_name = 'Android'
    AND api_level IS NOT NULL
GROUP BY
    api_level,
    os_version
ORDER BY api_level DESC;

-- ============================================================================
-- GEOGRAPHIC DISTRIBUTION
-- ============================================================================

-- Users by Country (World Map Data)
SELECT
    country_code,
    country_name,
    COUNT(DISTINCT user_id) AS unique_users,
    COUNT(*) AS total_sessions
FROM app_sessions
WHERE
    country_name IS NOT NULL
GROUP BY
    country_code,
    country_name
ORDER BY total_sessions DESC;

-- Top 20 Cities
SELECT
    country_name,
    city,
    COUNT(*) AS sessions,
    COUNT(DISTINCT user_id) AS users
FROM app_sessions
WHERE
    city IS NOT NULL
GROUP BY
    country_name,
    city
ORDER BY sessions DESC
LIMIT 20;

-- ============================================================================
-- VIDEO CONVERSION ANALYTICS
-- ============================================================================

-- Video Conversion Summary by Format
SELECT
    event_properties ->> 'input_format' AS input_format,
    event_properties ->> 'output_format' AS output_format,
    COUNT(*) AS total_conversions,
    SUM(
        CASE
            WHEN (
                event_properties ->> 'success'
            )::boolean THEN 1
            ELSE 0
        END
    ) AS successful,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN (
                    event_properties ->> 'success'
                )::boolean THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS success_rate,
    ROUND(
        AVG(
            (
                event_properties ->> 'duration_seconds'
            )::numeric
        ),
        1
    ) AS avg_duration_sec,
    ROUND(
        AVG(
            (
                event_properties ->> 'file_size_mb'
            )::numeric
        ),
        2
    ) AS avg_file_size_mb
FROM app_events
WHERE
    event_name = 'video_conversion'
    AND event_properties IS NOT NULL
GROUP BY
    input_format,
    output_format
ORDER BY total_conversions DESC;

-- Most Popular Input Formats
SELECT
    event_properties ->> 'input_format' AS format,
    COUNT(*) AS usage_count
FROM app_events
WHERE
    event_name = 'video_conversion'
GROUP BY
    format
ORDER BY usage_count DESC;

-- Most Popular Output Formats
SELECT
    event_properties ->> 'output_format' AS format,
    COUNT(*) AS usage_count
FROM app_events
WHERE
    event_name = 'video_conversion'
GROUP BY
    format
ORDER BY usage_count DESC;

-- Failed Conversions with Error Messages
SELECT
    event_properties ->> 'input_format' AS input_format,
    event_properties ->> 'output_format' AS output_format,
    event_properties ->> 'error_message' AS error_message,
    COUNT(*) AS failure_count
FROM app_events
WHERE
    event_name = 'video_conversion'
    AND (
        event_properties ->> 'success'
    )::boolean = false
    AND event_properties ->> 'error_message' IS NOT NULL
GROUP BY
    input_format,
    output_format,
    error_message
ORDER BY failure_count DESC
LIMIT 20;

-- ============================================================================
-- FEATURE USAGE ANALYTICS
-- ============================================================================

-- Most Used Features (Top 10)
SELECT
    event_name,
    event_category,
    COUNT(*) AS usage_count,
    COUNT(DISTINCT session_id) AS unique_users
FROM app_events
WHERE
    event_category IN ('interaction', 'navigation')
GROUP BY
    event_name,
    event_category
ORDER BY usage_count DESC
LIMIT 10;

-- Screen View Frequency
SELECT
    event_properties ->> 'screen_name' AS screen,
    COUNT(*) AS view_count,
    COUNT(DISTINCT session_id) AS unique_viewers
FROM app_events
WHERE
    event_name = 'screen_view'
GROUP BY
    screen
ORDER BY view_count DESC;

-- User Journey: Most Common Screen Transitions
WITH
    ScreenFlow AS (
        SELECT
            session_id,
            event_properties ->> 'screen_name' AS to_screen,
            LAG(
                event_properties ->> 'screen_name'
            ) OVER (
                PARTITION BY
                    session_id
                ORDER BY server_timestamp
            ) AS from_screen
        FROM app_events
        WHERE
            event_name = 'screen_view'
    )
SELECT
    from_screen,
    to_screen,
    COUNT(*) AS transition_count
FROM ScreenFlow
WHERE
    from_screen IS NOT NULL
GROUP BY
    from_screen,
    to_screen
ORDER BY transition_count DESC
LIMIT 20;

-- ============================================================================
-- ERROR ANALYTICS
-- ============================================================================

-- Top 20 Errors by Frequency
SELECT
    error_type,
    LEFT(error_message, 100) AS error_preview,
    COUNT(*) AS occurrences,
    COUNT(DISTINCT session_id) AS affected_sessions,
    MAX(server_timestamp) AS last_occurrence
FROM app_errors
GROUP BY
    error_type,
    error_message
ORDER BY occurrences DESC
LIMIT 20;

-- Errors by Context (Screen/Action)
SELECT
    error_context ->> 'screen' AS screen,
    error_context ->> 'action' AS action,
    error_type,
    COUNT(*) AS error_count
FROM app_errors
WHERE
    error_context IS NOT NULL
GROUP BY
    screen,
    action,
    error_type
ORDER BY error_count DESC
LIMIT 20;

-- Error Rate by App Version
SELECT
    s.app_version,
    COUNT(DISTINCT s.session_id) AS total_sessions,
    COUNT(e.id) AS error_count,
    ROUND(
        100.0 * COUNT(e.id) / COUNT(DISTINCT s.session_id),
        2
    ) AS error_rate_percent
FROM app_sessions s
    LEFT JOIN app_errors e ON s.session_id = e.session_id
GROUP BY
    s.app_version
ORDER BY s.app_version DESC;

-- ============================================================================
-- USER RETENTION & ENGAGEMENT
-- ============================================================================

-- New vs Returning Users (Last 30 Days)
SELECT
    server_timestamp::date AS date,
    SUM(
        CASE
            WHEN is_first_launch THEN 1
            ELSE 0
        END
    ) AS new_users,
    SUM(
        CASE
            WHEN NOT is_first_launch THEN 1
            ELSE 0
        END
    ) AS returning_users
FROM app_sessions
WHERE
    server_timestamp >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY
    server_timestamp::date
ORDER BY date DESC;

-- User Launch Frequency Distribution
SELECT
    CASE
        WHEN lifetime_launch_count = 1 THEN '1 launch'
        WHEN lifetime_launch_count BETWEEN 2 AND 5  THEN '2-5 launches'
        WHEN lifetime_launch_count BETWEEN 6 AND 10  THEN '6-10 launches'
        WHEN lifetime_launch_count BETWEEN 11 AND 20  THEN '11-20 launches'
        ELSE '20+ launches'
    END AS launch_frequency,
    COUNT(DISTINCT user_id) AS user_count
FROM (
        SELECT
            user_id, MAX(lifetime_launch_count) AS lifetime_launch_count
        FROM app_sessions
        WHERE
            user_id IS NOT NULL
        GROUP BY
            user_id
    ) t
GROUP BY
    launch_frequency
ORDER BY MIN(lifetime_launch_count);

-- App Version Adoption Rate
SELECT
    app_version,
    COUNT(DISTINCT user_id) AS users,
    MIN(server_timestamp) AS first_seen,
    MAX(server_timestamp) AS last_seen,
    COUNT(*) AS sessions
FROM app_sessions
GROUP BY
    app_version
ORDER BY MAX(server_timestamp) DESC;

-- ============================================================================
-- PERFORMANCE ANALYTICS
-- ============================================================================

-- Average App Startup Time by Device
SELECT
    device_brand,
    device_model,
    COUNT(*) AS measurement_count,
    ROUND(AVG(app_startup_ms), 0) AS avg_startup_ms,
    ROUND(MIN(app_startup_ms), 0) AS min_startup_ms,
    ROUND(MAX(app_startup_ms), 0) AS max_startup_ms
FROM app_sessions
WHERE
    app_startup_ms IS NOT NULL
GROUP BY
    device_brand,
    device_model
HAVING
    COUNT(*) >= 3
ORDER BY avg_startup_ms DESC
LIMIT 20;

-- Performance by OS Version
SELECT
    os_name,
    os_version,
    ROUND(AVG(app_startup_ms), 0) AS avg_startup_ms,
    ROUND(AVG(memory_usage_mb), 0) AS avg_memory_mb
FROM app_sessions
WHERE
    app_startup_ms IS NOT NULL
    OR memory_usage_mb IS NOT NULL
GROUP BY
    os_name,
    os_version
ORDER BY os_name, os_version DESC;

-- ============================================================================
-- NETWORK ANALYTICS
-- ============================================================================

-- Connection Type Distribution
SELECT
    connection_type,
    COUNT(*) AS session_count,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM app_sessions
WHERE
    connection_type IS NOT NULL
GROUP BY
    connection_type
ORDER BY session_count DESC;

-- ============================================================================
-- COHORT ANALYSIS (Advanced)
-- ============================================================================

-- Cohort: First Launch Date → Retention
WITH
    first_launch AS (
        SELECT user_id, MIN(server_timestamp)::date AS cohort_date
        FROM app_sessions
        WHERE
            user_id IS NOT NULL
        GROUP BY
            user_id
    )
SELECT
    fl.cohort_date,
    COUNT(DISTINCT fl.user_id) AS cohort_size,
    COUNT(
        DISTINCT CASE
            WHEN s.server_timestamp::date = fl.cohort_date THEN s.user_id
        END
    ) AS day_0,
    COUNT(
        DISTINCT CASE
            WHEN s.server_timestamp::date = fl.cohort_date + 1 THEN s.user_id
        END
    ) AS day_1,
    COUNT(
        DISTINCT CASE
            WHEN s.server_timestamp::date = fl.cohort_date + 7 THEN s.user_id
        END
    ) AS day_7,
    COUNT(
        DISTINCT CASE
            WHEN s.server_timestamp::date = fl.cohort_date + 30 THEN s.user_id
        END
    ) AS day_30
FROM
    first_launch fl
    LEFT JOIN app_sessions s ON fl.user_id = s.user_id
WHERE
    fl.cohort_date >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY
    fl.cohort_date
ORDER BY fl.cohort_date DESC;

-- ============================================================================
-- END OF QUERIES
-- ============================================================================
-- These queries are optimized for Metabase visualization
-- Create each as a separate "Question" in Metabase for best results