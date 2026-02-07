// Enrollment status types for self-service runner pool monitoring

export type EnrollmentStatus = "active" | "pending" | "expired" | "error";

export interface RunnerEnrollment {
  runner_name: string;
  runner_type: string;
  status: EnrollmentStatus;
  token_expires_at?: string;
  registered_at?: string;
  last_contact?: string;
  job_count_24h: number;
  tags: string[];
}

export interface EnrollmentSummary {
  total_runners: number;
  active_runners: number;
  pending_jobs: number;
  quota_cpu_used: string;
  quota_cpu_total: string;
  quota_memory_used: string;
  quota_memory_total: string;
  quota_pods_used: number;
  quota_pods_total: number;
  namespaces_active: number;
  namespaces_orphaned: number;
}
