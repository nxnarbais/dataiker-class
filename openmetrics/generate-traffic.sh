#!/bin/bash

# Traffic Generator for OpenMetrics App
# Generates traffic on all endpoints with random intervals

# Configuration
BASE_URL="${BASE_URL:-http://localhost:3000}"
MAX_WAIT="${MAX_WAIT:-5}"
MIN_WAIT="${MIN_WAIT:-1}"
TOTAL_REQUESTS="${TOTAL_REQUESTS:-100}"
LOG_FILE="${LOG_FILE:-traffic.log}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to log with timestamp
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

# Function to make a request and log the result
make_request() {
    local endpoint=$1
    local method=${2:-GET}
    local data=${3:-""}
    
    local url="$BASE_URL$endpoint"
    local response_code
    local response_time
    
    if [ "$method" = "POST" ]; then
        response_time=$(curl -s -w "%{http_code}:%{time_total}" -X POST \
            -H "Content-Type: application/json" \
            -d "$data" \
            "$url" -o /dev/null)
    else
        response_time=$(curl -s -w "%{http_code}:%{time_total}" "$url" -o /dev/null)
    fi
    
    response_code=$(echo "$response_time" | cut -d: -f1)
    response_time=$(echo "$response_time" | cut -d: -f2)
    
    if [ "$response_code" -ge 200 ] && [ "$response_code" -lt 300 ]; then
        log "${GREEN}✓${NC} $method $endpoint - ${BLUE}$response_code${NC} (${YELLOW}${response_time}s${NC})"
    else
        log "${RED}✗${NC} $method $endpoint - ${RED}$response_code${NC} (${YELLOW}${response_time}s${NC})"
    fi
}

# Function to generate random wait time
random_wait() {
    local min=${1:-$MIN_WAIT}
    local max=${2:-$MAX_WAIT}
    awk -v min="$min" -v max="$max" 'BEGIN{srand(); print min + rand() * (max - min)}'
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -u, --url URL        Base URL (default: http://localhost:3000)"
    echo "  -n, --requests NUM   Total number of requests (default: 100)"
    echo "  -m, --min-wait SEC   Minimum wait between requests (default: 1)"
    echo "  -M, --max-wait SEC   Maximum wait between requests (default: 5)"
    echo "  -l, --log-file FILE  Log file (default: traffic.log)"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Environment variables:"
    echo "  BASE_URL, TOTAL_REQUESTS, MIN_WAIT, MAX_WAIT, LOG_FILE"
    echo ""
    echo "Examples:"
    echo "  $0"
    echo "  $0 -n 50 -m 2 -M 8"
    echo "  $0 --url http://myapp:3000 --requests 200"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--url)
            BASE_URL="$2"
            shift 2
            ;;
        -n|--requests)
            TOTAL_REQUESTS="$2"
            shift 2
            ;;
        -m|--min-wait)
            MIN_WAIT="$2"
            shift 2
            ;;
        -M|--max-wait)
            MAX_WAIT="$2"
            shift 2
            ;;
        -l|--log-file)
            LOG_FILE="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Check if curl is available
if ! command -v curl &> /dev/null; then
    echo -e "${RED}Error: curl is not installed${NC}"
    exit 1
fi

# Check if the application is reachable
log "${BLUE}Testing connection to $BASE_URL...${NC}"
if ! curl -s --connect-timeout 5 "$BASE_URL" > /dev/null; then
    log "${RED}Error: Cannot connect to $BASE_URL${NC}"
    log "${YELLOW}Make sure the application is running and accessible${NC}"
    exit 1
fi

# Define endpoints to test
declare -a endpoints=(
    "/"
    "/health"
    "/metrics"
    "/demo"
    "/api/data"
)

# Define POST data for API endpoint
POST_DATA='{"test": "data", "timestamp": "'$(date -Iseconds)'", "random": "'$RANDOM'"}'

# Start traffic generation
log "${BLUE}Starting traffic generation...${NC}"
log "${BLUE}Configuration:${NC}"
log "  Base URL: $BASE_URL"
log "  Total requests: $TOTAL_REQUESTS"
log "  Wait interval: ${MIN_WAIT}s - ${MAX_WAIT}s"
log "  Log file: $LOG_FILE"
log ""

# Initialize counters
request_count=0
success_count=0
error_count=0

# Main loop
while [ $request_count -lt $TOTAL_REQUESTS ]; do
    # Select random endpoint
    endpoint=${endpoints[$RANDOM % ${#endpoints[@]}]}
    
    # Make request based on endpoint
    case $endpoint in
        "/api/data")
            make_request "$endpoint" "POST" "$POST_DATA"
            ;;
        *)
            make_request "$endpoint" "GET"
            ;;
    esac
    
    # Update counters
    ((request_count++))
    if [ "$response_code" -ge 200 ] && [ "$response_code" -lt 300 ]; then
        ((success_count++))
    else
        ((error_count++))
    fi
    
    # Show progress
    if [ $((request_count % 10)) -eq 0 ]; then
        log "${BLUE}Progress: $request_count/$TOTAL_REQUESTS requests completed${NC}"
    fi
    
    # Random wait between requests (except for the last request)
    if [ $request_count -lt $TOTAL_REQUESTS ]; then
        wait_time=$(random_wait "$MIN_WAIT" "$MAX_WAIT")
        log "${YELLOW}Waiting ${wait_time}s before next request...${NC}"
        sleep "$wait_time"
    fi
done

# Final summary
log ""
log "${BLUE}=== Traffic Generation Complete ===${NC}"
log "Total requests: $request_count"
log "Successful: $success_count"
log "Failed: $error_count"
log "Success rate: $((success_count * 100 / request_count))%"
log "Log file: $LOG_FILE"
log "${BLUE}===============================${NC}"

# Show metrics endpoint info
log ""
log "${YELLOW}To view current metrics:${NC}"
log "curl $BASE_URL/metrics"
log ""
log "${YELLOW}To view metrics in Prometheus format:${NC}"
log "curl $BASE_URL/metrics | grep -E '(http_requests_total|custom_operations_total)'" 