import { MOCK_RUNNERS } from '$lib/mocks';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ fetch }) => {
	// Use internal API route which will be swapped to real GitLab API later
	try {
		const response = await fetch('/api/runners');
		if (response.ok) {
			const runners = await response.json();
			return { runners };
		}
	} catch {
		// Fall back to mock data
	}

	return { runners: MOCK_RUNNERS };
};
