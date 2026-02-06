import { readFile, createBranch, commitFile, createMergeRequest } from './repository';
import { parseTfVars, serializeTfVars, applyChanges } from './tfvars-parser';
import { computeDiff, unifiedDiff } from './diff';
import type { ConfigDiff } from '$lib/types';

const TFVARS_PATH = 'tofu/stacks/bates-ils-runners/beehive.tfvars';

export interface ChangeRequest {
	changes: Record<string, string | number | boolean>;
	description: string;
}

export interface ChangeResult {
	branch: string;
	mr_url: string;
	mr_iid: number;
	diffs: ConfigDiff[];
	unified_diff: string;
}

/**
 * Read the current tfvars from the repo and return parsed values.
 */
export async function getCurrentConfig(ref: string = 'main') {
	const content = await readFile(TFVARS_PATH, ref);
	return parseTfVars(content);
}

/**
 * Full GitOps flow: read current config, apply changes, create branch + MR.
 */
export async function submitChanges(request: ChangeRequest): Promise<ChangeResult> {
	// 1. Read current config
	const currentContent = await readFile(TFVARS_PATH);
	const currentDoc = parseTfVars(currentContent);

	// 2. Apply changes
	const newDoc = applyChanges(currentDoc, request.changes);
	const newContent = serializeTfVars(newDoc);

	// 3. Compute diffs
	const diffs = computeDiff(currentDoc, newDoc);
	const diff = unifiedDiff(currentContent, newContent);

	// 4. Create branch
	const branch = `dashboard/runner-config-${Date.now()}`;
	await createBranch(branch);

	// 5. Commit changes
	const changedKeys = diffs.map((d) => d.key).join(', ');
	await commitFile(
		TFVARS_PATH,
		newContent,
		`feat(runners): update ${changedKeys}\n\n${request.description}`,
		branch
	);

	// 6. Create MR
	const mrDescription = [
		'## Runner Configuration Changes',
		'',
		'Updated via Runner Dashboard.',
		'',
		'### Changes',
		...diffs.map(
			(d) => `- **${d.key}**: ${d.old_value ?? '(none)'} -> ${d.new_value ?? '(removed)'}`
		),
		'',
		'### Diff',
		'```diff',
		diff,
		'```',
		'',
		request.description
	].join('\n');

	const mr = await createMergeRequest(branch, `Update runner config: ${changedKeys}`, mrDescription);

	return {
		branch,
		mr_url: mr.web_url,
		mr_iid: mr.iid,
		diffs,
		unified_diff: diff
	};
}
