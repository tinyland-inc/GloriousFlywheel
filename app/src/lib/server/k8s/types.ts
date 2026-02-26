// Kubernetes API types extracted from client.ts + ARC CRD types

export interface K8sListResponse<T> {
  kind: string;
  items: T[];
  metadata: { resourceVersion?: string };
}

export interface K8sPod {
  metadata: {
    name: string;
    namespace: string;
    labels: Record<string, string>;
    creationTimestamp: string;
  };
  status: {
    phase: string;
    containerStatuses?: Array<{
      name: string;
      ready: boolean;
      restartCount: number;
      state: Record<string, unknown>;
    }>;
  };
}

export interface K8sDeployment {
  metadata: { name: string; namespace: string };
  spec: { replicas: number };
  status: {
    replicas: number;
    readyReplicas: number;
    availableReplicas: number;
    updatedReplicas: number;
  };
}

export interface K8sHPA {
  metadata: { name: string; namespace: string };
  spec: {
    minReplicas: number;
    maxReplicas: number;
    metrics: Array<{
      type: string;
      resource?: {
        name: string;
        target: { type: string; averageUtilization?: number };
      };
    }>;
  };
  status: {
    currentReplicas: number;
    desiredReplicas: number;
    currentMetrics: Array<{
      type: string;
      resource?: {
        name: string;
        current: { averageUtilization?: number; averageValue?: string };
      };
    }>;
  };
}

export interface K8sEvent {
  metadata: { name: string; creationTimestamp: string };
  type: string;
  reason: string;
  message: string;
  involvedObject: { kind: string; name: string };
  count: number;
  lastTimestamp: string;
}

// ARC (Actions Runner Controller) CRD types

export interface K8sAutoScalingRunnerSet {
  metadata: {
    name: string;
    namespace: string;
    labels: Record<string, string>;
    creationTimestamp: string;
  };
  spec: {
    githubConfigUrl: string;
    minRunners?: number;
    maxRunners?: number;
    runnerScaleSetName?: string;
    template?: {
      spec?: {
        containers?: Array<{
          name: string;
          image: string;
        }>;
      };
    };
  };
  status?: {
    currentRunners?: number;
    pendingRunners?: number;
    runningRunners?: number;
    state?: string;
  };
}

export interface K8sEphemeralRunner {
  metadata: {
    name: string;
    namespace: string;
    labels: Record<string, string>;
    creationTimestamp: string;
  };
  status?: {
    phase?: string;
    ready?: boolean;
  };
}
