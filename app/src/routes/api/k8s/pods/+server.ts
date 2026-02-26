import { json } from "@sveltejs/kit";
import { k8sClient, RUNNER_NAMESPACES } from "$lib/server/k8s/client";
import type { K8sPod } from "$lib/server/k8s/types";
import { MOCK_PODS } from "$lib/mocks";
import type { RequestHandler } from "./$types";
import type { PodInfo, Forge } from "$lib/types";

/** Determine forge from namespace. */
function detectForge(ns: string): Forge {
  if (ns.startsWith("arc-")) return "github";
  return "gitlab";
}

/** Extract runner label from pod depending on forge. */
function detectRunner(pod: K8sPod, forge: Forge): string {
  if (forge === "github") {
    // ARC pods use actions.github.com/scale-set-name label
    return (
      pod.metadata.labels["actions.github.com/scale-set-name"] ??
      pod.metadata.labels["app.kubernetes.io/name"] ??
      "unknown"
    );
  }
  // GitLab uses app label or app.kubernetes.io/name
  return (
    pod.metadata.labels["app"] ??
    pod.metadata.labels["app.kubernetes.io/name"] ??
    "unknown"
  );
}

export const GET: RequestHandler = async () => {
  const available = await k8sClient.isAvailable();

  if (!available) {
    return json({ available: false, pods: MOCK_PODS });
  }

  try {
    const rawPods = await k8sClient.listAllRunnerPods(RUNNER_NAMESPACES);
    const pods: PodInfo[] = rawPods.map((p) => {
      const forge = detectForge(p.metadata.namespace);
      return {
        name: p.metadata.name,
        status: p.status.phase,
        runner: detectRunner(p, forge),
        forge,
        node: "",
        cpu_usage: "0m",
        memory_usage: "0Mi",
        restarts: p.status.containerStatuses?.[0]?.restartCount ?? 0,
        age: p.metadata.creationTimestamp,
      };
    });
    return json({ available: true, pods });
  } catch {
    return json({ available: false, pods: MOCK_PODS });
  }
};
