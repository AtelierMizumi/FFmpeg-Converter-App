// Type definitions for Cloudflare Worker environment and analytics data

export interface Env {
  DATABASE_URL: string;
  API_KEY: string;
  IPINFO_TOKEN?: string;
  ENVIRONMENT?: string;
}

// ============================================================================
// SESSION DATA
// ============================================================================
export interface SessionData {
  sessionId: string;
  userId?: string;
  
  // Device
  deviceModel?: string;
  deviceBrand?: string;
  deviceManufacturer?: string;
  isPhysicalDevice?: boolean;
  supportedAbis?: string[];
  
  // OS
  osName: string;
  osVersion?: string;
  apiLevel?: number;
  
  // App
  appVersion?: string;
  buildNumber?: string;
  packageName?: string;
  installSource?: string;
  isFirstLaunch?: boolean;
  lifetimeLaunchCount?: number;
  previousAppVersion?: string;
  
  // Screen
  screenWidth?: number;
  screenHeight?: number;
  pixelDensity?: number;
  
  // Network
  connectionType?: string;
  
  // Locale
  systemLanguage?: string;
  localeCountryCode?: string;
  timezone?: string;
  uses24hourFormat?: boolean;
  currencyCode?: string;
  
  // Performance
  appStartupMs?: number;
  memoryUsageMb?: number;
  appSizeMb?: number;
  
  // Technical
  flutterVersion?: string;
  dartVersion?: string;
  buildMode?: string;
  
  // Timestamps
  clientTimestamp: string;
}

// ============================================================================
// EVENT DATA
// ============================================================================
export interface EventData {
  sessionId: string;
  eventName: string;
  eventCategory?: string;
  eventProperties?: Record<string, any>;
  clientTimestamp: string;
}

// ============================================================================
// ERROR DATA
// ============================================================================
export interface ErrorData {
  sessionId: string;
  errorType?: string;
  errorMessage?: string;
  stackTrace?: string;
  errorContext?: Record<string, any>;
  clientTimestamp: string;
}

// ============================================================================
// GEOLOCATION DATA (from IP)
// ============================================================================
export interface GeoData {
  countryCode?: string;
  countryName?: string;
  city?: string;
  region?: string;
  latitude?: number;
  longitude?: number;
  timezone?: string;
  isp?: string;
}

// ============================================================================
// IPINFO.IO API RESPONSE
// ============================================================================
export interface IpInfoResponse {
  ip: string;
  hostname?: string;
  city?: string;
  region?: string;
  country: string;
  loc?: string; // "latitude,longitude"
  org?: string; // ISP
  postal?: string;
  timezone?: string;
}
