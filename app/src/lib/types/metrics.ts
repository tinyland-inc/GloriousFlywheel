export interface MetricValue {
  timestamp: string;
  value: number;
}

export interface TimeSeriesData {
  label: string;
  timestamps: string[];
  values: number[];
}

export interface MetricCardData {
  label: string;
  value: string | number;
  unit?: string;
  change?: number;
  trend?: "up" | "down" | "stable";
}

export type Forge = "gitlab" | "github";
export type ScalingModel = "hpa" | "arc";

export interface HPAStatus {
  name: string;
  runner_type?: string;
  forge?: Forge;
  scaling_model?: ScalingModel;
  current_replicas: number;
  desired_replicas: number;
  min_replicas: number;
  max_replicas: number;
  cpu_current?: number;
  cpu_target?: number;
  memory_current?: number;
  memory_target?: number;
  conditions: HPACondition[];
}

export interface HPACondition {
  type: string;
  status: string;
  reason: string;
  message: string;
  last_transition: string;
}

export interface PodInfo {
  name: string;
  status: string;
  runner: string;
  forge?: Forge;
  node: string;
  cpu_usage?: string;
  memory_usage?: string;
  restarts: number;
  age: string;
}

export interface K8sEvent {
  type: "Normal" | "Warning";
  reason: string;
  message: string;
  source: string;
  first_seen: string;
  last_seen: string;
  count: number;
}
