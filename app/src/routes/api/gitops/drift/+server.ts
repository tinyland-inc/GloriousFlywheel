import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { detectDrift } from '$lib/server/gitops/drift';
import { parseTfVars } from '$lib/server/gitops/tfvars-parser';
import { MOCK_HPA_STATUS } from '$lib/mocks';
import { readFileSync } from 'fs';
import { resolve } from 'path';

export const GET: RequestHandler = async () => {
	try {
		const tfvarsPath = resolve('..', 'tofu/stacks/bates-ils-runners/beehive.tfvars');
		const content = readFileSync(tfvarsPath, 'utf-8');
		const doc = parseTfVars(content);

		// TODO: Replace MOCK_HPA_STATUS with real K8s HPA data
		const drifts = detectDrift(doc, MOCK_HPA_STATUS);

		return json({ drifts });
	} catch {
		return json({ drifts: [] });
	}
};
