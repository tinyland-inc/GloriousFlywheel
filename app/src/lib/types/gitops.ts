import type { RunnerConfig } from "./runner";

export interface RunnerFleetConfig {
  cluster_context: string;
  namespace: string;
  gitlab_url: string;
  runners: Record<string, RunnerConfig>;
  global: {
    hpa_enabled: boolean;
    hpa_cpu_target: number;
    hpa_memory_target: number;
    hpa_scale_up_window: number;
    hpa_scale_down_window: number;
    pdb_enabled: boolean;
    metrics_enabled: boolean;
    service_monitor_enabled: boolean;
  };
}

export interface ConfigDiff {
  key: string;
  old_value?: string;
  new_value?: string;
  type: "added" | "removed" | "changed";
}

export interface DriftItem {
  runner: string;
  field: string;
  expected: string;
  actual: string;
  severity: "info" | "warning" | "error";
}

export interface PipelineInfo {
  id: number;
  status: string;
  ref: string;
  sha: string;
  created_at: string;
  updated_at: string;
  web_url: string;
  source: string;
}

export interface MergeRequestInfo {
  id: number;
  iid: number;
  title: string;
  state: string;
  web_url: string;
  source_branch: string;
  target_branch: string;
  author: string;
  created_at: string;
  pipeline?: PipelineInfo;
}
