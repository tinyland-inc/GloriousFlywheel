<script lang="ts">
	import PipelineStatus from '$lib/components/gitops/PipelineStatus.svelte';
	import type { PipelineInfo } from '$lib/types';

	// Mock pipeline data until GitLab API is wired
	const pipelines: PipelineInfo[] = [
		{
			id: 1234,
			status: 'success',
			ref: 'main',
			sha: 'a1b2c3d4e5f6789012345678',
			created_at: new Date(Date.now() - 3600000).toISOString(),
			updated_at: new Date(Date.now() - 3000000).toISOString(),
			web_url: '#',
			source: 'push'
		},
		{
			id: 1233,
			status: 'success',
			ref: 'dashboard/runner-config-1706000000',
			sha: 'b2c3d4e5f678901234567890',
			created_at: new Date(Date.now() - 86400000).toISOString(),
			updated_at: new Date(Date.now() - 85800000).toISOString(),
			web_url: '#',
			source: 'merge_request_event'
		},
		{
			id: 1232,
			status: 'failed',
			ref: 'dashboard/runner-config-1705900000',
			sha: 'c3d4e5f6789012345678901',
			created_at: new Date(Date.now() - 172800000).toISOString(),
			updated_at: new Date(Date.now() - 172200000).toISOString(),
			web_url: '#',
			source: 'merge_request_event'
		}
	];
</script>

<svelte:head>
	<title>Pipelines - Runner Dashboard</title>
</svelte:head>

<div class="space-y-6">
	<div class="flex items-center justify-between">
		<h2 class="text-2xl font-bold">Pipelines</h2>
		<a
			href="/gitops"
			class="px-3 py-1.5 rounded text-sm border border-surface-300 dark:border-surface-600 hover:bg-surface-100 dark:hover:bg-surface-700 transition-colors"
		>
			Back to GitOps
		</a>
	</div>

	<div class="space-y-3">
		{#each pipelines as pipeline}
			<PipelineStatus {pipeline} />
		{/each}
	</div>

	<p class="text-xs text-surface-500 text-center">
		Showing recent pipelines. Connect to GitLab API for live data.
	</p>
</div>
