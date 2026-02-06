import { error } from "@sveltejs/kit";
import { MOCK_RUNNER_MAP } from "$lib/mocks";
import type { PageServerLoad } from "./$types";

export const load: PageServerLoad = async ({ params, fetch, url }) => {
  const runner = MOCK_RUNNER_MAP[params.name];
  if (!runner) {
    error(404, `Runner "${params.name}" not found`);
  }

  const window = url.searchParams.get("window") ?? "1h";

  try {
    const response = await fetch(
      `/api/metrics/${params.name}?window=${window}`,
    );
    if (response.ok) {
      const metricsData = await response.json();
      return { runner, metricsData, window };
    }
  } catch {
    // Fall through to defaults
  }

  return {
    runner,
    metricsData: {
      available: false,
      runner: params.name,
      window,
      timeSeries: { cpu: [], memory: [], jobs: [] },
      current: { totalJobs: 0, failedJobs: 0, jobsPerMinute: 0 },
    },
    window,
  };
};
