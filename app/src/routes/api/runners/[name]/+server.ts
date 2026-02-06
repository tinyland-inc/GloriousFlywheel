import { json, error } from '@sveltejs/kit';
import { MOCK_RUNNER_MAP } from '$lib/mocks';
import type { RequestHandler } from './$types';

export const GET: RequestHandler = async ({ params }) => {
	const runner = MOCK_RUNNER_MAP[params.name];
	if (!runner) {
		error(404, `Runner "${params.name}" not found`);
	}
	return json(runner);
};
