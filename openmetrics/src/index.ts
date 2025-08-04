import express from 'express';
import { 
  getMetrics, 
  activeConnections, 
  customCounter, 
  customOperationDuration, 
  dataProcessingTime,
  updateResponseTimeGauge 
} from './metrics';
import { metricsMiddleware } from './middleware';

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(metricsMiddleware);

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// Metrics endpoint (OpenMetrics format)
app.get('/metrics', async (req, res) => {
  try {
    const metrics = await getMetrics();
    res.set('Content-Type', 'text/plain; version=0.0.4; charset=utf-8');
    res.send(metrics);
  } catch (error) {
    console.error('Error generating metrics:', error);
    res.status(500).json({ error: 'Failed to generate metrics' });
  }
});

// Demo endpoints to generate some metrics
app.get('/', (req, res) => {
  res.json({ 
    message: 'OpenMetrics TypeScript App',
    endpoints: {
      health: '/health',
      metrics: '/metrics',
      demo: '/demo'
    }
  });
});

app.get('/demo', (req, res) => {
  // Simulate some work with histogram
  const startTime = Date.now();
  setTimeout(() => {
    const duration = (Date.now() - startTime) / 1000;
    customCounter.inc({ operation_type: 'demo_request' });
    customOperationDuration.observe({ operation_type: 'demo_request' }, duration);
    
    res.json({ 
      message: 'Demo endpoint called',
      timestamp: new Date().toISOString(),
      duration: duration
    });
  }, Math.random() * 1000);
});

app.post('/api/data', (req, res) => {
  const startTime = Date.now();
  
  // Simulate data processing
  setTimeout(() => {
    const processingTime = (Date.now() - startTime) / 1000;
    
    customCounter.inc({ operation_type: 'data_creation' });
    dataProcessingTime.observe({ data_type: 'json' }, processingTime);
    
    res.json({ 
      message: 'Data created successfully',
      data: req.body,
      processing_time: processingTime
    });
  }, Math.random() * 500 + 100); // 100-600ms processing time
});

// Simulate active connections and update response time gauges
setInterval(() => {
  const connections = Math.floor(Math.random() * 10) + 1;
  activeConnections.set(connections);
  
  // Update response time gauges for different endpoints
  updateResponseTimeGauge('health', Math.random() * 0.1);
  updateResponseTimeGauge('metrics', Math.random() * 0.5);
  updateResponseTimeGauge('demo', Math.random() * 1.0);
  updateResponseTimeGauge('api_data', Math.random() * 0.3);
}, 5000);

// Error handling middleware
app.use((err: Error, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 OpenMetrics app listening on port ${PORT}`);
  console.log(`📊 Metrics available at http://localhost:${PORT}/metrics`);
  console.log(`🏥 Health check at http://localhost:${PORT}/health`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully');
  process.exit(0);
}); 