---
name: observability
description: Review and apply observability standards including structured logging, metrics collection, distributed tracing, OpenTelemetry integration, and health check endpoints.
---

# Observability Standards

Guidance for implementing observability requirements including logging, metrics, tracing, and monitoring configuration.

## Tooling

> **Available Tools**: If using Claude Code, the `agents:sre-engineer` agent specializes in observability setup and SLO management. The `agents:devops-engineer` agent can help configure monitoring infrastructure.

## Logging Requirements

### Structured Logging (MUST)

All logging MUST use structured format (JSON preferred):

```json
{
  "timestamp": "2024-01-15T10:30:00.000Z",
  "level": "info",
  "message": "Request processed",
  "service": "api-gateway",
  "trace_id": "abc123",
  "span_id": "def456",
  "duration_ms": 45,
  "status_code": 200
}
```

### Log Levels (MUST)

Use consistent log levels with defined semantics:

| Level | Purpose                    | When to Use                       |
| ----- | -------------------------- | --------------------------------- |
| ERROR | Errors requiring attention | Failures, exceptions              |
| WARN  | Potential issues           | Degraded performance, retries     |
| INFO  | Significant events         | Request completion, state changes |
| DEBUG | Detailed information       | Development, troubleshooting      |
| TRACE | Very detailed tracing      | Deep debugging                    |

### Required Log Fields (MUST)

All log entries MUST include:

| Field       | Description                   |
| ----------- | ----------------------------- |
| `timestamp` | ISO 8601 format with timezone |
| `level`     | Log severity level            |
| `message`   | Human-readable description    |
| `service`   | Service/application name      |

### Recommended Log Fields (SHOULD)

Log entries SHOULD include when applicable:

| Field         | Description                        |
| ------------- | ---------------------------------- |
| `trace_id`    | Distributed trace identifier       |
| `span_id`     | Span identifier                    |
| `user_id`     | User identifier (if authenticated) |
| `request_id`  | Request correlation ID             |
| `duration_ms` | Operation duration                 |

### Sensitive Data (MUST NOT)

Logs MUST NOT contain:

- Passwords or secrets
- API keys or tokens
- Personal identifiable information (PII)
- Credit card numbers
- Session tokens

## Metrics Requirements

### Metric Types (MUST)

Implement appropriate metric types:

| Type      | Purpose               | Examples                    |
| --------- | --------------------- | --------------------------- |
| Counter   | Cumulative values     | Request count, errors       |
| Gauge     | Current values        | Queue size, connections     |
| Histogram | Value distributions   | Response time, payload size |
| Summary   | Quantile calculations | P50, P95, P99 latencies     |

### Required Metrics (MUST)

Services MUST expose:

| Metric                     | Type      | Description                       |
| -------------------------- | --------- | --------------------------------- |
| `requests_total`           | Counter   | Total requests by endpoint/status |
| `request_duration_seconds` | Histogram | Request latency                   |
| `errors_total`             | Counter   | Error count by type               |
| `active_connections`       | Gauge     | Current connections               |

### Metric Naming (MUST)

Follow naming conventions:

```
# Format: <namespace>_<name>_<unit>
http_requests_total
http_request_duration_seconds
db_connections_active
cache_hits_total
```

### Metric Labels (SHOULD)

Use consistent label naming:

| Label        | Description          |
| ------------ | -------------------- |
| `service`    | Service name         |
| `endpoint`   | API endpoint         |
| `method`     | HTTP method          |
| `status`     | Response status      |
| `error_type` | Error classification |

## Distributed Tracing

### Tracing Implementation (SHOULD)

Implement distributed tracing using OpenTelemetry:

```yaml
# OpenTelemetry configuration
exporters:
  otlp:
    endpoint: "collector:4317"

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [otlp]
```

### Trace Context (MUST)

When tracing is implemented, propagate context:

| Header         | Standard            |
| -------------- | ------------------- |
| `traceparent`  | W3C Trace Context   |
| `tracestate`   | W3C Trace Context   |
| `X-Request-ID` | Request correlation |

### Span Requirements (SHOULD)

Spans SHOULD include:

- Operation name
- Start/end timestamps
- Status (OK, ERROR)
- Relevant attributes
- Error details (if applicable)

## Health Checks

### Health Endpoints (MUST)

Services MUST expose health endpoints:

| Endpoint        | Purpose         | Response              |
| --------------- | --------------- | --------------------- |
| `/health`       | Basic health    | 200 OK or 503         |
| `/health/live`  | Liveness probe  | 200 if running        |
| `/health/ready` | Readiness probe | 200 if ready to serve |

### Health Response Format (MUST)

```json
{
  "status": "healthy",
  "checks": {
    "database": {
      "status": "healthy",
      "latency_ms": 5
    },
    "cache": {
      "status": "healthy",
      "latency_ms": 1
    }
  },
  "version": "1.2.3",
  "uptime_seconds": 3600
}
```

### Dependency Checks (SHOULD)

Health checks SHOULD verify:

- Database connectivity
- Cache availability
- External service reachability
- Disk space adequacy
- Memory availability

## Alerting

### Alert Configuration (MUST)

Define alerts for critical conditions:

| Condition        | Severity | Response          |
| ---------------- | -------- | ----------------- |
| Service down     | Critical | Immediate page    |
| Error rate > 5%  | High     | Page within 5 min |
| Latency P95 > 1s | Medium   | Notify team       |
| Disk > 80%       | Warning  | Create ticket     |

### Alert Requirements (MUST)

Alerts MUST include:

- Clear description of condition
- Severity level
- Runbook link
- Affected service/component

## Implementation Checklist

- [ ] Configure structured logging
- [ ] Define log level policies
- [ ] Implement required metrics
- [ ] Set up health endpoints
- [ ] Configure distributed tracing (if applicable)
- [ ] Define alerting rules
- [ ] Create runbooks for alerts
- [ ] Verify sensitive data exclusion

## Compliance Verification

```bash
# Verify structured log output
app_command 2>&1 | jq .

# Check health endpoint
curl -s http://localhost:8080/health | jq .

# Verify metrics endpoint
curl -s http://localhost:8080/metrics | grep -E "^(http_|app_)"

# Check for sensitive data in logs
grep -r -i "password\|secret\|token" logs/ | wc -l
# Should be 0
```

## Language-Specific Logging

### Rust (tracing)

```rust
use tracing::{info, instrument};

#[instrument]
fn process_request(id: &str) {
    info!(request_id = %id, "Processing request");
}
```

### TypeScript (pino)

```typescript
import pino from "pino";

const logger = pino({
  level: "info",
  formatters: {
    level: (label) => ({ level: label }),
  },
});

logger.info({ requestId, duration }, "Request processed");
```

### Python (structlog)

```python
import structlog

logger = structlog.get_logger()
logger.info("request_processed", request_id=request_id, duration=duration)
```

## Additional Resources

### Reference Files

- **`references/logging-config.md`** - Logging configuration guide
- **`references/metrics-guide.md`** - Metrics implementation patterns

### Examples

- **`examples/otel-config.yaml`** - OpenTelemetry configuration
- **`examples/alerting-rules.yaml`** - Prometheus alerting rules
