import { Request, Response, NextFunction } from 'express';
import { httpRequestsTotal, httpRequestDuration, updateResponseTimeGauge } from './metrics';

export function metricsMiddleware(req: Request, res: Response, next: NextFunction): void {
  const start = Date.now();
  
  // Override res.end to capture response status
  const originalEnd = res.end;
  res.end = function(chunk?: any, encoding?: any): Response {
    const duration = (Date.now() - start) / 1000; // Convert to seconds
    const status = res.statusCode.toString();
    const route = req.route?.path || req.path;
    
    // Record metrics
    httpRequestsTotal.inc({ method: req.method, route, status });
    httpRequestDuration.observe({ method: req.method, route }, duration);
    
    // Update response time gauge
    updateResponseTimeGauge(route, duration);
    
    // Call original end method
    return originalEnd.call(this, chunk, encoding);
  };
  
  next();
} 