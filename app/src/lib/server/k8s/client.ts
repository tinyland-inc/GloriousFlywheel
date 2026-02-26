import { env } from "$env/dynamic/private";
import type {
  K8sListResponse,
  K8sPod,
  K8sDeployment,
  K8sHPA,
  K8sEvent,
  K8sAutoScalingRunnerSet,
} from "./types";

// Re-export types for backward compatibility
export type { K8sPod, K8sDeployment, K8sHPA, K8sEvent } from "./types";

/**
 * Runner namespaces to query, read from K8S_RUNNER_NAMESPACES env var.
 * Comma-separated list, defaults to "gitlab-runners,arc-runners".
 */
export const RUNNER_NAMESPACES: string[] = (
  env.K8S_RUNNER_NAMESPACES ?? "gitlab-runners,arc-runners"
)
  .split(",")
  .map((s) => s.trim())
  .filter(Boolean);

/**
 * Lightweight K8s API client.
 * In-cluster: uses service account token and CA from mounted paths.
 * Development: uses KUBECONFIG or kubectl proxy.
 */
export class K8sClient {
  private baseUrl: string;
  private token: string | null;
  private available: boolean | null = null;
  private namespace: string;

  constructor(namespace?: string) {
    // Get namespace from parameter, environment variable, or default
    this.namespace = namespace ?? env.K8S_NAMESPACE ?? "gitlab-runners";
    const inCluster = env.KUBERNETES_SERVICE_HOST;
    if (inCluster) {
      this.baseUrl = `https://${env.KUBERNETES_SERVICE_HOST}:${env.KUBERNETES_SERVICE_PORT}`;
      // Token will be read lazily
      this.token = null;
    } else {
      // Development: assume kubectl proxy on localhost:8001
      this.baseUrl = env.K8S_PROXY_URL ?? "http://localhost:8001";
      this.token = null;
    }
  }

  async isAvailable(): Promise<boolean> {
    if (this.available !== null) return this.available;
    try {
      const response = await this.fetch("/api/v1/namespaces/" + this.namespace);
      this.available = response.ok;
    } catch {
      this.available = false;
    }
    return this.available;
  }

  getNamespace(): string {
    return this.namespace;
  }

  resetAvailability() {
    this.available = null;
  }

  private async getToken(): Promise<string | null> {
    if (this.token) return this.token;
    try {
      // In-cluster: read from mounted service account
      const fs = await import("fs/promises");
      this.token = (
        await fs.readFile(
          "/var/run/secrets/kubernetes.io/serviceaccount/token",
          "utf-8",
        )
      ).trim();
      return this.token;
    } catch {
      return null;
    }
  }

  private async fetch(path: string): Promise<Response> {
    const headers: Record<string, string> = {};
    const token = await this.getToken();
    if (token) {
      headers["Authorization"] = `Bearer ${token}`;
    }
    return globalThis.fetch(`${this.baseUrl}${path}`, {
      headers,
      signal: AbortSignal.timeout(10000),
    });
  }

  private async request<T>(path: string): Promise<T> {
    const response = await this.fetch(path);
    if (!response.ok) {
      throw new Error(
        `K8s API error: ${response.status} ${response.statusText}`,
      );
    }
    return response.json() as Promise<T>;
  }

  // --- Single-namespace methods (backward compatible) ---

  async listPods(): Promise<K8sPod[]> {
    const data = await this.request<K8sListResponse<K8sPod>>(
      `/api/v1/namespaces/${this.namespace}/pods`,
    );
    return data.items;
  }

  async listDeployments(): Promise<K8sDeployment[]> {
    const data = await this.request<K8sListResponse<K8sDeployment>>(
      `/apis/apps/v1/namespaces/${this.namespace}/deployments`,
    );
    return data.items;
  }

  async listHPAs(): Promise<K8sHPA[]> {
    const data = await this.request<K8sListResponse<K8sHPA>>(
      `/apis/autoscaling/v2/namespaces/${this.namespace}/horizontalpodautoscalers`,
    );
    return data.items;
  }

  async listEvents(limit: number = 50): Promise<K8sEvent[]> {
    const data = await this.request<K8sListResponse<K8sEvent>>(
      `/api/v1/namespaces/${this.namespace}/events?limit=${limit}&fieldSelector=type!=Normal`,
    );
    return data.items;
  }

  // --- Multi-namespace methods ---

  async listPodsInNamespace(ns: string): Promise<K8sPod[]> {
    const data = await this.request<K8sListResponse<K8sPod>>(
      `/api/v1/namespaces/${ns}/pods`,
    );
    return data.items;
  }

  async listHPAsInNamespace(ns: string): Promise<K8sHPA[]> {
    const data = await this.request<K8sListResponse<K8sHPA>>(
      `/apis/autoscaling/v2/namespaces/${ns}/horizontalpodautoscalers`,
    );
    return data.items;
  }

  /**
   * Fetch pods from multiple namespaces in parallel.
   * Each pod is tagged with its source namespace via metadata.namespace.
   */
  async listAllRunnerPods(namespaces: string[]): Promise<K8sPod[]> {
    const results = await Promise.allSettled(
      namespaces.map((ns) => this.listPodsInNamespace(ns)),
    );
    const pods: K8sPod[] = [];
    for (const result of results) {
      if (result.status === "fulfilled") {
        pods.push(...result.value);
      }
    }
    return pods;
  }

  /**
   * Fetch HPAs from multiple namespaces in parallel.
   */
  async listAllHPAs(namespaces: string[]): Promise<K8sHPA[]> {
    const results = await Promise.allSettled(
      namespaces.map((ns) => this.listHPAsInNamespace(ns)),
    );
    const hpas: K8sHPA[] = [];
    for (const result of results) {
      if (result.status === "fulfilled") {
        hpas.push(...result.value);
      }
    }
    return hpas;
  }

  // --- ARC CRD queries ---

  /**
   * List AutoScalingRunnerSets from a namespace (ARC custom resource).
   */
  async listAutoScalingRunnerSets(
    ns: string,
  ): Promise<K8sAutoScalingRunnerSet[]> {
    try {
      const data = await this.request<
        K8sListResponse<K8sAutoScalingRunnerSet>
      >(
        `/apis/actions.github.com/v1alpha1/namespaces/${ns}/autoscalingrunnersets`,
      );
      return data.items;
    } catch {
      // CRD may not be installed — return empty
      return [];
    }
  }
}

export const k8sClient = new K8sClient();
