import { json } from "@sveltejs/kit";
import { k8sClient } from "$lib/server/k8s/client";
import { MOCK_HPA_STATUS } from "$lib/mocks";
import type { RequestHandler } from "./$types";
import type { HPAStatus } from "$lib/types";

export const GET: RequestHandler = async () => {
  const available = await k8sClient.isAvailable();

  if (!available) {
    return json({ available: false, hpas: MOCK_HPA_STATUS });
  }

  try {
    const rawHPAs = await k8sClient.listHPAs();
    const hpas: HPAStatus[] = rawHPAs.map((h) => {
      const cpuMetric = h.status.currentMetrics?.find(
        (m) => m.resource?.name === "cpu",
      );
      const memMetric = h.status.currentMetrics?.find(
        (m) => m.resource?.name === "memory",
      );

      return {
        name: h.metadata.name,
        current_replicas: h.status.currentReplicas,
        desired_replicas: h.status.desiredReplicas,
        min_replicas: h.spec.minReplicas,
        max_replicas: h.spec.maxReplicas,
        cpu_current: cpuMetric?.resource?.current?.averageUtilization ?? 0,
        memory_current: memMetric?.resource?.current?.averageUtilization ?? 0,
        conditions: [],
      };
    });
    return json({ available: true, hpas });
  } catch {
    return json({ available: false, hpas: MOCK_HPA_STATUS });
  }
};
