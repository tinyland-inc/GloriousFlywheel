import { RUNNER_TYPES, type RunnerType, type RunnerConfig } from "$lib/types";

export interface ValidationError {
  field: string;
  message: string;
}

const K8S_RESOURCE_RE = /^(\d+)(m|Mi|Gi|Ki|Ti)?$/;

export function validateResourceString(value: string): boolean {
  return K8S_RESOURCE_RE.test(value);
}

export function validateRunnerConfig(
  config: Partial<RunnerConfig>,
): ValidationError[] {
  const errors: ValidationError[] = [];

  if (config.type && !RUNNER_TYPES.includes(config.type as RunnerType)) {
    errors.push({
      field: "type",
      message: `Must be one of: ${RUNNER_TYPES.join(", ")}`,
    });
  }

  if (config.concurrent_jobs !== undefined) {
    if (config.concurrent_jobs < 1 || config.concurrent_jobs > 50) {
      errors.push({
        field: "concurrent_jobs",
        message: "Must be between 1 and 50",
      });
    }
  }

  if (config.hpa) {
    if (config.hpa.min_replicas < 0) {
      errors.push({ field: "hpa.min_replicas", message: "Must be >= 0" });
    }
    if (config.hpa.max_replicas < 1) {
      errors.push({ field: "hpa.max_replicas", message: "Must be >= 1" });
    }
    if (config.hpa.min_replicas > config.hpa.max_replicas) {
      errors.push({
        field: "hpa.min_replicas",
        message: "Must be <= max_replicas",
      });
    }
    if (config.hpa.cpu_target < 1 || config.hpa.cpu_target > 100) {
      errors.push({
        field: "hpa.cpu_target",
        message: "Must be between 1 and 100",
      });
    }
    if (config.hpa.memory_target < 1 || config.hpa.memory_target > 100) {
      errors.push({
        field: "hpa.memory_target",
        message: "Must be between 1 and 100",
      });
    }
  }

  // Validate resource strings
  for (const key of [
    "cpu_request",
    "cpu_limit",
    "memory_request",
    "memory_limit",
  ] as const) {
    if (
      config.manager_resources?.[key] &&
      !validateResourceString(config.manager_resources[key])
    ) {
      errors.push({
        field: `manager_resources.${key}`,
        message: "Invalid K8s resource format",
      });
    }
    if (
      config.job_resources?.[key] &&
      !validateResourceString(config.job_resources[key])
    ) {
      errors.push({
        field: `job_resources.${key}`,
        message: "Invalid K8s resource format",
      });
    }
  }

  return errors;
}
