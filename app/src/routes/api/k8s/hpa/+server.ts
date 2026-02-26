import { json } from "@sveltejs/kit";
import { k8sClient, RUNNER_NAMESPACES } from "$lib/server/k8s/client";
import { MOCK_HPA_STATUS } from "$lib/mocks";
import type { RequestHandler } from "./$types";
import type { HPAStatus, Forge } from "$lib/types";
import { env } from "$env/dynamic/private";

const ARC_NAMESPACE = env.ARC_NAMESPACE ?? "arc-runners";

function detectForge(ns: string): Forge {
  if (ns.startsWith("arc-")) return "github";
  return "gitlab";
}

export const GET: RequestHandler = async () => {
  const available = await k8sClient.isAvailable();

  if (!available) {
    return json({ available: false, hpas: MOCK_HPA_STATUS });
  }

  try {
    const hpas: HPAStatus[] = [];

    // Fetch HPAs from all runner namespaces (GitLab uses HPAs)
    const rawHPAs = await k8sClient.listAllHPAs(RUNNER_NAMESPACES);
    for (const h of rawHPAs) {
      const cpuMetric = h.status.currentMetrics?.find(
        (m) => m.resource?.name === "cpu",
      );
      const memMetric = h.status.currentMetrics?.find(
        (m) => m.resource?.name === "memory",
      );

      hpas.push({
        name: h.metadata.name,
        forge: detectForge(h.metadata.namespace),
        scaling_model: "hpa",
        current_replicas: h.status.currentReplicas,
        desired_replicas: h.status.desiredReplicas,
        min_replicas: h.spec.minReplicas,
        max_replicas: h.spec.maxReplicas,
        cpu_current: cpuMetric?.resource?.current?.averageUtilization ?? 0,
        memory_current: memMetric?.resource?.current?.averageUtilization ?? 0,
        conditions: [],
      });
    }

    // Fetch ARC AutoScalingRunnerSets (GitHub uses ARC listener-based scaling)
    const arcSets = await k8sClient.listAutoScalingRunnerSets(ARC_NAMESPACE);
    for (const ars of arcSets) {
      hpas.push({
        name: ars.spec.runnerScaleSetName ?? ars.metadata.name,
        forge: "github",
        scaling_model: "arc",
        current_replicas: ars.status?.currentRunners ?? 0,
        desired_replicas:
          (ars.status?.runningRunners ?? 0) +
          (ars.status?.pendingRunners ?? 0),
        min_replicas: ars.spec.minRunners ?? 0,
        max_replicas: ars.spec.maxRunners ?? 0,
        conditions: [],
      });
    }

    return json({ available: true, hpas });
  } catch {
    return json({ available: false, hpas: MOCK_HPA_STATUS });
  }
};
