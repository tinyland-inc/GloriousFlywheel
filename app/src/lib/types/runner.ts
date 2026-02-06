// Runner types mirroring tofu/modules/gitlab-runner/variables.tf

export const RUNNER_TYPES = [
  "docker",
  "dind",
  "rocky8",
  "rocky9",
  "nix",
] as const;
export type RunnerType = (typeof RUNNER_TYPES)[number];

export const RUNNER_TYPE_LABELS: Record<RunnerType, string> = {
  docker: "Docker",
  dind: "Docker-in-Docker",
  rocky8: "Rocky Linux 8",
  rocky9: "Rocky Linux 9",
  nix: "Nix",
};

export const RUNNER_TYPE_DEFAULT_TAGS: Record<RunnerType, string[]> = {
  docker: ["docker", "linux", "amd64"],
  dind: ["docker", "dind", "privileged"],
  rocky8: ["rocky8", "rhel8", "linux"],
  rocky9: ["rocky9", "rhel9", "linux"],
  nix: ["nix", "flakes"],
};

export const RUNNER_TYPE_DEFAULT_IMAGES: Record<RunnerType, string> = {
  docker: "alpine:3.21",
  dind: "docker:27-dind",
  rocky8: "rockylinux:8",
  rocky9: "rockylinux:9",
  nix: "docker.nix-community.org/nixpkgs/nix-flakes:nixos-unstable",
};

export type RunnerStatus = "online" | "offline" | "paused" | "stale";

export interface ResourceSpec {
  cpu_request: string;
  memory_request: string;
  cpu_limit: string;
  memory_limit: string;
}

export interface HPAConfig {
  enabled: boolean;
  min_replicas: number;
  max_replicas: number;
  cpu_target: number;
  memory_target: number;
  scale_up_window: number;
  scale_down_window: number;
}

export interface RunnerConfig {
  name: string;
  type: RunnerType;
  tags: string[];
  concurrent_jobs: number;
  run_untagged: boolean;
  protected: boolean;
  default_image: string;
  privileged: boolean;
  manager_resources: ResourceSpec;
  job_resources: ResourceSpec;
  hpa: HPAConfig;
  pdb_enabled: boolean;
  pdb_min_available: number;
  metrics_enabled: boolean;
  service_monitor_enabled: boolean;
}

export interface RunnerInfo {
  id: number;
  name: string;
  type: RunnerType;
  status: RunnerStatus;
  tags: string[];
  config: RunnerConfig;
  version?: string;
  ip_address?: string;
  contacted_at?: string;
}

export interface RunnerJob {
  id: number;
  status: string;
  pipeline_id: number;
  project_name: string;
  ref: string;
  stage: string;
  name: string;
  started_at?: string;
  finished_at?: string;
  duration?: number;
}
