import { z } from 'zod';

// Device Info Schema
export const DeviceInfoSchema = z.object({
  device_model: z.string().optional(),
  device_brand: z.string().optional(),
  device_manufacturer: z.string().optional(),
  device_id_hash: z.string().optional(),
  screen_width: z.number().int().optional(),
  screen_height: z.number().int().optional(),
  screen_density: z.number().optional(),
  supported_abis: z.array(z.string()).optional(),
});

// OS Info Schema
export const OSInfoSchema = z.object({
  os_name: z.string().optional(),
  os_version: z.string().optional(),
  api_level: z.number().int().optional(),
  kernel_version: z.string().optional(),
});

// App Info Schema
export const AppInfoSchema = z.object({
  app_version: z.string().optional(),
  app_build_number: z.string().optional(),
  package_name: z.string().optional(),
  is_first_launch: z.boolean().optional(),
  install_source: z.string().optional(),
  launch_count: z.number().int().optional(),
});

// Network Info Schema
export const NetworkInfoSchema = z.object({
  network_type: z.string().optional(), // wifi, mobile, none
  carrier_name: z.string().optional(),
  ip_address: z.string().optional(),
});

// Locale Info Schema
export const LocaleInfoSchema = z.object({
  locale_language: z.string().optional(),
  locale_country: z.string().optional(),
  timezone: z.string().optional(),
  timezone_offset: z.number().optional(),
  currency: z.string().optional(),
});

// Performance Info Schema
export const PerformanceInfoSchema = z.object({
  startup_time_ms: z.number().int().optional(),
  memory_usage_mb: z.number().optional(),
  available_storage_gb: z.number().optional(),
});

// Session Schema (complete)
export const SessionSchema = z.object({
  session_id: z.string().uuid(),
  user_id_hash: z.string(),
  timestamp: z.string().datetime(),
  
  // Device info (flattened)
  device_model: z.string().optional(),
  device_brand: z.string().optional(),
  device_manufacturer: z.string().optional(),
  device_id_hash: z.string().optional(),
  screen_width: z.number().int().optional(),
  screen_height: z.number().int().optional(),
  screen_density: z.number().optional(),
  supported_abis: z.array(z.string()).optional(),
  
  // OS info
  os_name: z.string().optional(),
  os_version: z.string().optional(),
  api_level: z.number().int().optional(),
  kernel_version: z.string().optional(),
  
  // App info
  app_version: z.string().optional(),
  app_build_number: z.string().optional(),
  package_name: z.string().optional(),
  is_first_launch: z.boolean().optional(),
  install_source: z.string().optional(),
  launch_count: z.number().int().optional(),
  
  // Network info
  network_type: z.string().optional(),
  carrier_name: z.string().optional(),
  ip_address: z.string().optional(),
  
  // Locale info
  locale_language: z.string().optional(),
  locale_country: z.string().optional(),
  timezone: z.string().optional(),
  timezone_offset: z.number().optional(),
  currency: z.string().optional(),
  
  // Performance info
  startup_time_ms: z.number().int().optional(),
  memory_usage_mb: z.number().optional(),
  available_storage_gb: z.number().optional(),
});

// Event Schema
export const EventSchema = z.object({
  session_id: z.string().uuid(),
  event_type: z.string(),
  event_name: z.string(),
  timestamp: z.string().datetime(),
  properties: z.record(z.any()).optional(),
});

// Batch Events Schema
export const BatchEventsSchema = z.object({
  session_id: z.string().uuid(),
  events: z.array(EventSchema),
});

// Error Schema
export const ErrorSchema = z.object({
  session_id: z.string().uuid(),
  timestamp: z.string().datetime(),
  error_type: z.string(),
  error_message: z.string(),
  stack_trace: z.string().optional(),
  context: z.record(z.any()).optional(),
});

// Export type inference
export type SessionData = z.infer<typeof SessionSchema>;
export type EventData = z.infer<typeof EventSchema>;
export type BatchEventsData = z.infer<typeof BatchEventsSchema>;
export type ErrorData = z.infer<typeof ErrorSchema>;
