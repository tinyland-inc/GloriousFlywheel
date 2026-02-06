import { MOCK_DASHBOARD_METRICS, MOCK_HPA_STATUS, MOCK_PODS } from "$lib/mocks";
import type { PageServerLoad } from "./$types";

export const load: PageServerLoad = async ({ fetch }) => {
  // Fetch from internal API routes (which handle Prometheus/K8s fallback)
  const [metricsRes, hpaRes, podsRes] = await Promise.all([
    fetch("/api/metrics").catch(() => null),
    fetch("/api/k8s/hpa").catch(() => null),
    fetch("/api/k8s/pods").catch(() => null),
  ]);

  const metricsData = metricsRes?.ok ? await metricsRes.json() : null;
  const hpaData = hpaRes?.ok ? await hpaRes.json() : null;
  const podsData = podsRes?.ok ? await podsRes.json() : null;

  return {
    prometheusAvailable: metricsData?.available ?? false,
    k8sAvailable: hpaData?.available ?? false,
    metrics: metricsData?.metrics ?? MOCK_DASHBOARD_METRICS,
    hpas: hpaData?.hpas ?? MOCK_HPA_STATUS,
    pods: podsData?.pods ?? MOCK_PODS,
  };
};
