export interface GeolocationData {
  country: string;
  region: string;
  city: string;
  latitude: number;
  longitude: number;
}

export interface GeolocationConfig {
  IPINFO_TOKEN?: string;
}

/**
 * Fetches geolocation data from ipinfo.io API
 * Falls back to Cloudflare's CF-IPCountry header if API fails
 * @param ipAddress - Client IP address
 * @param config - API configuration (optional token)
 * @param request - Cloudflare request object for CF headers fallback
 */
export async function fetchGeolocation(
  ipAddress: string,
  config: GeolocationConfig,
  request?: Request
): Promise<GeolocationData | null> {
  // Skip private/local IPs
  if (isPrivateIP(ipAddress)) {
    return getFallbackGeo(request);
  }

  // Try ipinfo.io API
  try {
    const token = config.IPINFO_TOKEN;
    const url = token
      ? `https://ipinfo.io/${ipAddress}?token=${token}`
      : `https://ipinfo.io/${ipAddress}/json`;

    const response = await fetch(url, {
      headers: {
        'Accept': 'application/json',
      },
      signal: AbortSignal.timeout(3000), // 3 second timeout
    });

    if (!response.ok) {
      console.warn(`ipinfo.io API failed with status ${response.status}`);
      return getFallbackGeo(request);
    }

    const data = await response.json() as any;

    // Parse location data
    const [latitude, longitude] = (data.loc || '0,0').split(',').map(Number);

    return {
      country: data.country || 'Unknown',
      region: data.region || 'Unknown',
      city: data.city || 'Unknown',
      latitude,
      longitude,
    };
  } catch (error) {
    console.error('Geolocation lookup failed:', error);
    return getFallbackGeo(request);
  }
}

/**
 * Fallback to Cloudflare's CF-IPCountry header
 */
function getFallbackGeo(request?: Request): GeolocationData | null {
  if (!request) return null;

  const country = request.headers.get('CF-IPCountry');
  if (!country || country === 'XX') return null;

  return {
    country: country,
    region: 'Unknown',
    city: 'Unknown',
    latitude: 0,
    longitude: 0,
  };
}

/**
 * Check if IP is private/local (skip geolocation for these)
 */
function isPrivateIP(ip: string): boolean {
  // IPv4 private ranges
  if (ip.startsWith('10.')) return true;
  if (ip.startsWith('192.168.')) return true;
  if (ip.match(/^172\.(1[6-9]|2[0-9]|3[0-1])\./)) return true;
  if (ip.startsWith('127.')) return true;
  if (ip === 'localhost') return true;

  // IPv6 private ranges
  if (ip.startsWith('::1')) return true;
  if (ip.startsWith('fc00:')) return true;
  if (ip.startsWith('fd00:')) return true;
  if (ip.startsWith('fe80:')) return true;

  return false;
}

/**
 * Extract client IP from request headers
 * Checks Cloudflare headers, then common proxy headers
 */
export function extractClientIP(request: Request): string | null {
  // Cloudflare-specific header (most reliable)
  const cfIP = request.headers.get('CF-Connecting-IP');
  if (cfIP) return cfIP;

  // Common proxy headers (fallback)
  const xForwardedFor = request.headers.get('X-Forwarded-For');
  if (xForwardedFor) {
    // Take first IP in the list
    return xForwardedFor.split(',')[0].trim();
  }

  const xRealIP = request.headers.get('X-Real-IP');
  if (xRealIP) return xRealIP;

  return null;
}
