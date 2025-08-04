import { Registry, Counter, Histogram, Gauge } from 'prom-client';

// Create a metrics registry
export const register = new Registry();

// Define metrics
export const httpRequestsTotal = new Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status'],
  registers: [register]
});

export const httpRequestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route'],
  buckets: [0.1, 0.5, 1, 2, 5],
  registers: [register]
});

export const activeConnections = new Gauge({
  name: 'active_connections',
  help: 'Number of active connections',
  registers: [register]
});

export const customCounter = new Counter({
  name: 'custom_operations_total',
  help: 'Total number of custom operations',
  labelNames: ['operation_type'],
  registers: [register]
});

export const memoryUsage = new Gauge({
  name: 'memory_usage_bytes',
  help: 'Memory usage in bytes',
  labelNames: ['type'],
  registers: [register]
});

// Function to update memory metrics
export function updateMemoryMetrics(): void {
  const memUsage = process.memoryUsage();
  memoryUsage.labels('rss').set(memUsage.rss);
  memoryUsage.labels('heapTotal').set(memUsage.heapTotal);
  memoryUsage.labels('heapUsed').set(memUsage.heapUsed);
  memoryUsage.labels('external').set(memUsage.external);
}

// Function to get metrics in OpenMetrics format
export async function getMetrics(): Promise<string> {
  updateMemoryMetrics();
  return await register.metrics();
} 