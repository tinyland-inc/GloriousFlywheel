import { error } from "@sveltejs/kit";
import { MOCK_RUNNER_MAP } from "$lib/mocks";
import type { PageServerLoad } from "./$types";

export const load: PageServerLoad = async ({ params, fetch }) => {
  // Use internal API route which will be swapped to real GitLab API later
  try {
    const response = await fetch(`/api/runners/${params.name}`);
    if (response.ok) {
      const runner = await response.json();
      return { runner };
    }
    if (response.status === 404) {
      error(404, `Runner "${params.name}" not found`);
    }
  } catch (e) {
    // Fall back to mock data
    if (e && typeof e === "object" && "status" in e) throw e;
  }

  const runner = MOCK_RUNNER_MAP[params.name];
  if (!runner) {
    error(404, `Runner "${params.name}" not found`);
  }
  return { runner };
};
