import express from 'express';
import { getMetrics, activeConnections, customCounter } from './metrics';
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
  // Simulate some work
  setTimeout(() => {
    customCounter.inc({ operation_type: 'demo_request' });
    res.json({ 
      message: 'Demo endpoint called',
      timestamp: new Date().toISOString()
    });
  }, Math.random() * 1000);
});

app.post('/api/data', (req, res) => {
  customCounter.inc({ operation_type: 'data_creation' });
  res.json({ 
    message: 'Data created successfully',
    data: req.body
  });
});

// Simulate active connections
setInterval(() => {
  const connections = Math.floor(Math.random() * 10) + 1;
  activeConnections.set(connections);
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