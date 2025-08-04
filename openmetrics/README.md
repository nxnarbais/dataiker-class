# OpenMetrics TypeScript Application

A TypeScript application that exposes metrics in OpenMetrics format, compatible with Prometheus and other monitoring systems.

## Features

- **OpenMetrics Format**: Exposes metrics in standard OpenMetrics format
- **Automatic HTTP Metrics**: Automatically collects HTTP request metrics
- **Custom Metrics**: Includes custom counters, gauges, and histograms
- **Memory Monitoring**: Tracks memory usage metrics
- **Health Check**: Built-in health check endpoint
- **Docker Support**: Fully containerized with multi-stage Docker build
- **Prometheus Integration**: Includes Prometheus configuration for testing

## Metrics Exposed

### HTTP Metrics
- `http_requests_total`: Total number of HTTP requests (counter)
- `http_request_duration_seconds`: Duration of HTTP requests (histogram)

### Application Metrics
- `active_connections`: Number of active connections (gauge)
- `custom_operations_total`: Custom operation counters
- `memory_usage_bytes`: Memory usage by type (gauge)

## Quick Start

### Using Docker Compose (Recommended)

1. **Configure Datadog (Optional):**
   ```bash
   # Copy the example environment file
   cp .env.example .env
   
   # Edit .env and add your Datadog API key
   # DD_API_KEY=your-actual-datadog-api-key
   ```

2. **Start the application with monitoring:**
   ```bash
   docker-compose up -d
   ```

3. **Access the application:**
   - Application: http://localhost:3000
   - Metrics: http://localhost:3000/metrics
   - Health: http://localhost:3000/health
   - Prometheus: http://localhost:9090
   - Datadog Agent Status: Check logs with `docker-compose logs datadog-agent`

### Using Docker

1. **Build the image:**
   ```bash
   docker build -t openmetrics-app .
   ```

2. **Run the container:**
   ```bash
   docker run -p 3000:3000 openmetrics-app
   ```

### Local Development

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Run in development mode:**
   ```bash
   npm run dev
   ```

3. **Build and run:**
   ```bash
   npm run build
   npm start
   ```

## API Endpoints

### GET /
Returns application information and available endpoints.

### GET /health
Health check endpoint returning application status.

### GET /metrics
Exposes metrics in OpenMetrics format. This is the main endpoint for monitoring systems.

### GET /demo
Demo endpoint that triggers custom metrics.

### POST /api/data
API endpoint that accepts JSON data and increments custom metrics.

## Testing the Metrics

### Generate Traffic

#### Manual Testing
```bash
# Generate some traffic to see metrics
curl http://localhost:3000/
curl http://localhost:3000/demo
curl -X POST http://localhost:3000/api/data -H "Content-Type: application/json" -d '{"test": "data"}'
```

#### Automated Traffic Generation
Use the included traffic generator script:

```bash
# Basic usage (100 requests with 1-5s intervals)
./generate-traffic.sh

# Custom configuration
./generate-traffic.sh -n 50 -m 2 -M 8

# Different URL
./generate-traffic.sh --url http://myapp:3000 --requests 200

# Show help
./generate-traffic.sh --help
```

**Script Features:**
- ✅ Random endpoint selection
- ✅ Random wait intervals (1-5s by default)
- ✅ Colored output with timestamps
- ✅ Progress tracking
- ✅ Success/error counting
- ✅ Detailed logging to file
- ✅ Connection testing before starting

### View Metrics
```bash
# View raw metrics
curl http://localhost:3000/metrics
```

### Prometheus Queries
Once Prometheus is running, you can query metrics:

- **Total HTTP requests:**
  ```
  http_requests_total
  ```

- **Request duration 95th percentile:**
  ```
  histogram_quantile(0.95, http_request_duration_seconds_bucket)
  ```

- **Memory usage:**
  ```
  memory_usage_bytes
  ```

## Docker Configuration

The application uses a multi-stage Docker build for optimal image size:

- **Builder stage**: Compiles TypeScript to JavaScript
- **Production stage**: Runs the compiled application with minimal dependencies

### Security Features
- Runs as non-root user (nodejs)
- Minimal Alpine Linux base image
- Health checks included
- Graceful shutdown handling

## Environment Variables

- `PORT`: Application port (default: 3000)
- `NODE_ENV`: Environment mode (development/production)

## Monitoring Integration

This application is designed to work with various monitoring systems:

- **Prometheus**: Direct scraping from `/metrics` endpoint
- **Datadog**: Full integration with Datadog Agent for metrics, logs, and APM
- **Grafana**: Can be used as a data source
- **Kubernetes**: Includes proper labels for service discovery

### Datadog Integration

The application includes full Datadog integration:

- **Automatic Discovery**: Uses Docker labels for automatic service discovery
- **OpenMetrics Collection**: Datadog agent scrapes the `/metrics` endpoint
- **Log Collection**: Application logs are automatically collected
- **APM Support**: Application Performance Monitoring enabled
- **Custom Metrics**: All custom metrics are sent to Datadog

#### Datadog Metrics Available:
- `openmetrics_app.http_requests_total` - HTTP request counter
- `openmetrics_app.http_request_duration_seconds` - Request duration histogram
- `openmetrics_app.active_connections` - Active connections gauge
- `openmetrics_app.custom_operations_total` - Custom operation counters
- `openmetrics_app.memory_usage_bytes` - Memory usage metrics

#### Configuration:
1. Set your Datadog API key in the `.env` file
2. The Datadog agent will automatically discover and monitor the application
3. View metrics in your Datadog dashboard

## Development

### Project Structure
```
openmetrics/
├── src/
│   ├── index.ts          # Main application
│   ├── metrics.ts        # Metrics definitions
│   └── middleware.ts     # HTTP metrics middleware
├── Dockerfile            # Multi-stage Docker build
├── docker-compose.yml    # Development environment
├── prometheus.yml        # Prometheus configuration
└── package.json          # Dependencies and scripts
```

### Adding Custom Metrics

To add custom metrics, modify `src/metrics.ts`:

```typescript
export const myCustomMetric = new Counter({
  name: 'my_custom_metric_total',
  help: 'Description of my custom metric',
  labelNames: ['label1', 'label2'],
  registers: [register]
});
```

## Troubleshooting

### Common Issues

1. **Port already in use**: Change the PORT environment variable
2. **Metrics not updating**: Ensure the application is receiving traffic
3. **Docker build fails**: Check that all files are present in the build context

### Logs
```bash
# View application logs
docker-compose logs openmetrics-app

# View Datadog agent logs
docker-compose logs datadog-agent

# View Prometheus logs
docker-compose logs prometheus
```

## License

MIT 