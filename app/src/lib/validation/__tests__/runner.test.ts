import { describe, it, expect } from "vitest";
import { validateResourceString, validateRunnerConfig } from "../runner";
import type { RunnerConfig } from "$lib/types";

describe("validateResourceString", () => {
  it("should accept valid CPU values", () => {
    expect(validateResourceString("100m")).toBe(true);
    expect(validateResourceString("500m")).toBe(true);
    expect(validateResourceString("2")).toBe(true);
    expect(validateResourceString("4")).toBe(true);
  });

  it("should accept valid memory values", () => {
    expect(validateResourceString("128Mi")).toBe(true);
    expect(validateResourceString("512Mi")).toBe(true);
    expect(validateResourceString("1Gi")).toBe(true);
    expect(validateResourceString("2Gi")).toBe(true);
    expect(validateResourceString("8Gi")).toBe(true);
  });

  it("should accept Ki and Ti suffixes", () => {
    expect(validateResourceString("1024Ki")).toBe(true);
    expect(validateResourceString("1Ti")).toBe(true);
  });

  it("should reject invalid formats", () => {
    expect(validateResourceString("abc")).toBe(false);
    expect(validateResourceString("100X")).toBe(false);
    expect(validateResourceString("")).toBe(false);
    expect(validateResourceString("m100")).toBe(false);
  });
});

describe("validateRunnerConfig", () => {
  const validConfig: Partial<RunnerConfig> = {
    type: "docker",
    concurrent_jobs: 8,
    hpa: {
      enabled: true,
      min_replicas: 1,
      max_replicas: 5,
      cpu_target: 70,
      memory_target: 80,
      scale_up_window: 15,
      scale_down_window: 300,
    },
    manager_resources: {
      cpu_request: "100m",
      memory_request: "128Mi",
      cpu_limit: "500m",
      memory_limit: "512Mi",
    },
    job_resources: {
      cpu_request: "100m",
      memory_request: "256Mi",
      cpu_limit: "2",
      memory_limit: "2Gi",
    },
  };

  it("should return no errors for valid config", () => {
    const errors = validateRunnerConfig(validConfig);
    expect(errors).toHaveLength(0);
  });

  it("should reject invalid runner type", () => {
    const errors = validateRunnerConfig({ type: "invalid" as never });
    expect(errors).toHaveLength(1);
    expect(errors[0].field).toBe("type");
  });

  it("should reject out-of-range concurrent_jobs", () => {
    expect(validateRunnerConfig({ concurrent_jobs: 0 })).toHaveLength(1);
    expect(validateRunnerConfig({ concurrent_jobs: 51 })).toHaveLength(1);
    expect(validateRunnerConfig({ concurrent_jobs: 1 })).toHaveLength(0);
    expect(validateRunnerConfig({ concurrent_jobs: 50 })).toHaveLength(0);
  });

  it("should reject min_replicas > max_replicas", () => {
    const errors = validateRunnerConfig({
      hpa: { ...validConfig.hpa!, min_replicas: 10, max_replicas: 5 },
    });
    expect(errors.some((e) => e.field === "hpa.min_replicas")).toBe(true);
  });

  it("should reject invalid CPU target", () => {
    const errors = validateRunnerConfig({
      hpa: { ...validConfig.hpa!, cpu_target: 0 },
    });
    expect(errors.some((e) => e.field === "hpa.cpu_target")).toBe(true);
  });

  it("should reject invalid resource strings", () => {
    const errors = validateRunnerConfig({
      manager_resources: {
        cpu_request: "invalid",
        memory_request: "128Mi",
        cpu_limit: "500m",
        memory_limit: "512Mi",
      },
    });
    expect(
      errors.some((e) => e.field === "manager_resources.cpu_request"),
    ).toBe(true);
  });
});
