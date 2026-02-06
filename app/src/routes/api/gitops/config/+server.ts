import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { parseTfVars } from '$lib/server/gitops/tfvars-parser';
import { readFileSync } from 'fs';
import { resolve } from 'path';

export const GET: RequestHandler = async () => {
	// In development, read from local file; in production, read from GitLab API
	try {
		const tfvarsPath = resolve('..', 'tofu/stacks/bates-ils-runners/beehive.tfvars');
		const content = readFileSync(tfvarsPath, 'utf-8');
		const doc = parseTfVars(content);
		return json({ source: 'local', values: doc.values });
	} catch {
		return json({ source: 'unavailable', values: {} });
	}
};
