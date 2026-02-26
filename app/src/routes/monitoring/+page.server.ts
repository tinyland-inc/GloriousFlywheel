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

  // Group pods by forge for the UI
  const allPods = podsData?.pods ?? MOCK_PODS;
  const allHpas = hpaData?.hpas ?? MOCK_HPA_STATUS;

  return {
    prometheusAvailable: metricsData?.available ?? false,
    k8sAvailable: hpaData?.available ?? false,
    metrics: metricsData?.metrics ?? MOCK_DASHBOARD_METRICS,
    hpas: allHpas,
    pods: allPods,
    forges: {
      gitlab: {
        pods: allPods.filter((p: { forge?: string }) => (p.forge ?? "gitlab") === "gitlab"),
        hpas: allHpas.filter((h: { forge?: string }) => (h.forge ?? "gitlab") === "gitlab"),
      },
      github: {
        pods: allPods.filter((p: { forge?: string }) => p.forge === "github"),
        hpas: allHpas.filter((h: { forge?: string }) => h.forge === "github"),
      },
    },
  };
};
