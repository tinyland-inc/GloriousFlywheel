import type { PageServerLoad } from "./$types";

export const load: PageServerLoad = async ({ fetch }) => {
  const [configRes, driftRes] = await Promise.all([
    fetch("/api/gitops/config").catch(() => null),
    fetch("/api/gitops/drift").catch(() => null),
  ]);

  const configData = configRes?.ok ? await configRes.json() : null;
  const driftData = driftRes?.ok ? await driftRes.json() : null;

  return {
    config: configData?.values ?? {},
    configSource: configData?.source ?? "unavailable",
    drifts: driftData?.drifts ?? [],
  };
};
