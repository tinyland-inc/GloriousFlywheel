import { json } from '@sveltejs/kit';
import { MOCK_RUNNERS } from '$lib/mocks';
import type { RequestHandler } from './$types';

export const GET: RequestHandler = async () => {
	// TODO: Replace with real GitLab API call when auth is configured
	return json(MOCK_RUNNERS);
};
