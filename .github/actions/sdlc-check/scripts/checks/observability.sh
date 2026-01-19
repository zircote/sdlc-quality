#!/usr/bin/env bash
# SDLC Check: Observability
# Validates logging, metrics, and monitoring configuration

check_observability() {
  local score=10
  local project_type
  project_type=$(detect_project_type)

  # Determine if this is a service/application vs library
  local is_service=false

  # Heuristics for service detection
  if [[ -f "Dockerfile" ]] || [[ -f "docker-compose.yml" ]] || [[ -f "docker-compose.yaml" ]]; then
    is_service=true
  fi
  if [[ -d "cmd" ]] && [[ "$project_type" == "go" ]]; then
    is_service=true
  fi
  if grep -qE "flask|django|fastapi|express|actix|rocket" "$(find . -name '*.toml' -o -name '*.json' -o -name '*.txt' 2>/dev/null | head -5 | tr '\n' ' ')" 2>/dev/null; then
    is_service=true
  fi

  # Check for structured logging (SHOULD for services, MAY for libraries)
  local has_structured_logging=false

  case "$project_type" in
    rust)
      if grep -rq "tracing\|slog\|log4rs" Cargo.toml 2>/dev/null; then
        has_structured_logging=true
      fi
      ;;
    typescript|javascript)
      if grep -qE "winston|pino|bunyan|structlog" package.json 2>/dev/null; then
        has_structured_logging=true
      fi
      ;;
    python)
      if grep -rqE "structlog|python-json-logger|loguru" pyproject.toml requirements*.txt 2>/dev/null; then
        has_structured_logging=true
      fi
      ;;
    go)
      if grep -rqE "zap|zerolog|logrus" go.mod 2>/dev/null; then
        has_structured_logging=true
      fi
      ;;
    java-maven|java-gradle)
      if grep -rqE "logback|log4j2|slf4j" pom.xml build.gradle* 2>/dev/null; then
        has_structured_logging=true
      fi
      ;;
  esac

  if [[ "$is_service" == "true" ]] && [[ "$has_structured_logging" == "false" ]]; then
    add_finding "observability" "$SEVERITY_SHOULD" "No structured logging library detected for service"
    ((score -= 2))
  elif [[ "$is_service" == "false" ]] && [[ "$has_structured_logging" == "false" ]]; then
    add_finding "observability" "$SEVERITY_MAY" "Consider adding structured logging support"
  fi

  # Check for health endpoints (MUST for services)
  if [[ "$is_service" == "true" ]]; then
    local has_health=false

    # Search for health endpoint patterns
    if grep -rqE "health|readiness|liveness|/health|/ready|/live" --include="*.rs" --include="*.go" --include="*.py" --include="*.ts" --include="*.js" --include="*.java" . 2>/dev/null; then
      has_health=true
    fi

    # Check for Kubernetes probes
    if grep -rqE "livenessProbe|readinessProbe" --include="*.yaml" --include="*.yml" . 2>/dev/null; then
      has_health=true
    fi

    if [[ "$has_health" == "false" ]]; then
      add_finding "observability" "$SEVERITY_SHOULD" "Service should expose health check endpoints (/health, /ready)"
      ((score -= 2))
    fi
  fi

  # Check for metrics exposure (SHOULD for services)
  if [[ "$is_service" == "true" ]]; then
    local has_metrics=false

    case "$project_type" in
      rust)
        if grep -rqE "prometheus|metrics|opentelemetry" Cargo.toml 2>/dev/null; then
          has_metrics=true
        fi
        ;;
      typescript|javascript)
        if grep -qE "prom-client|prometheus|opentelemetry" package.json 2>/dev/null; then
          has_metrics=true
        fi
        ;;
      python)
        if grep -rqE "prometheus_client|opentelemetry" pyproject.toml requirements*.txt 2>/dev/null; then
          has_metrics=true
        fi
        ;;
      go)
        if grep -rqE "prometheus|opentelemetry" go.mod 2>/dev/null; then
          has_metrics=true
        fi
        ;;
      java-maven|java-gradle)
        if grep -rqE "micrometer|prometheus|opentelemetry" pom.xml build.gradle* 2>/dev/null; then
          has_metrics=true
        fi
        ;;
    esac

    if [[ "$has_metrics" == "false" ]]; then
      add_finding "observability" "$SEVERITY_SHOULD" "Consider adding metrics exposure (Prometheus, OpenTelemetry)"
      ((score -= 2))
    fi
  fi

  # Check for tracing (MAY for services)
  if [[ "$is_service" == "true" ]]; then
    local has_tracing=false

    if grep -rqE "opentelemetry|jaeger|zipkin|datadog.*tracing" . --include="*.toml" --include="*.json" --include="*.yml" 2>/dev/null; then
      has_tracing=true
    fi

    if [[ "$has_tracing" == "false" ]]; then
      add_finding "observability" "$SEVERITY_MAY" "Consider adding distributed tracing (OpenTelemetry, Jaeger)"
    fi
  fi

  # Check for error tracking (MAY)
  local has_error_tracking=false

  if grep -rqE "sentry|bugsnag|rollbar|honeybadger" . --include="*.toml" --include="*.json" --include="*.yml" 2>/dev/null; then
    has_error_tracking=true
  fi

  if [[ "$is_service" == "true" ]] && [[ "$has_error_tracking" == "false" ]]; then
    add_finding "observability" "$SEVERITY_MAY" "Consider adding error tracking (Sentry, Bugsnag)"
  fi

  # Check for log level configuration (SHOULD)
  local has_log_config=false

  # Check for environment variable patterns
  if grep -rqE "LOG_LEVEL|RUST_LOG|DEBUG|LOGGING" . --include="*.env*" --include="*.toml" --include="*.yml" --include="*.json" 2>/dev/null; then
    has_log_config=true
  fi

  # Check for logging configuration files
  if [[ -f "log4j2.xml" ]] || [[ -f "logback.xml" ]] || [[ -f "logging.yaml" ]] || [[ -f "logging.json" ]]; then
    has_log_config=true
  fi

  if [[ "$is_service" == "true" ]] && [[ "$has_log_config" == "false" ]]; then
    add_finding "observability" "$SEVERITY_SHOULD" "Consider adding configurable log levels (LOG_LEVEL env var)"
    ((score -= 1))
  fi

  # For libraries, check for optional tracing support (MAY)
  if [[ "$is_service" == "false" ]]; then
    case "$project_type" in
      rust)
        if ! grep -q "tracing" Cargo.toml 2>/dev/null; then
          add_finding "observability" "$SEVERITY_MAY" "Consider adding tracing instrumentation for library observability"
        fi
        ;;
    esac
  fi

  # If not a service, adjust expectations
  if [[ "$is_service" == "false" ]]; then
    # Libraries have lower observability requirements
    # Reset score if we over-penalized
    [[ $score -lt 7 ]] && score=7
  fi

  # Ensure score is not negative
  [[ $score -lt 0 ]] && score=0

  set_domain_score "observability" "$score"
}
