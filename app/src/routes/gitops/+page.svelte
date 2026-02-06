<script lang="ts">
	import DriftPanel from '$lib/components/gitops/DriftPanel.svelte';
	import type { DriftItem } from '$lib/types';

	let { data } = $props();

	const drifts = $derived((data.drifts ?? []) as DriftItem[]);

	// Group config values by section
	function getSections() {
		const config = data.config as Record<string, unknown>;
		const groups: { title: string; entries: [string, unknown][] }[] = [
			{
				title: 'Deployment Toggles',
				entries: Object.entries(config).filter(([k]) => k.startsWith('deploy_'))
			},
			{
				title: 'Concurrency',
				entries: Object.entries(config).filter(([k]) => k.endsWith('_concurrent_jobs'))
			},
			{
				title: 'HPA Configuration',
				entries: Object.entries(config).filter(([k]) => k.startsWith('hpa_') || k.includes('_hpa_'))
			},
			{
				title: 'Monitoring',
				entries: Object.entries(config).filter(([k]) =>
					['metrics_enabled', 'service_monitor_enabled'].includes(k)
				)
			}
		];
		return groups.filter((g) => g.entries.length > 0);
	}

	const sections = $derived(getSections());
</script>

<svelte:head>
	<title>GitOps - Runner Dashboard</title>
</svelte:head>

<div class="space-y-6">
	<div class="flex items-center justify-between">
		<h2 class="text-2xl font-bold">GitOps Configuration</h2>
		<div class="flex gap-2">
			<a
				href="/gitops/changes"
				class="px-3 py-1.5 rounded text-sm bg-primary-500 text-white hover:bg-primary-600 transition-colors"
			>
				Propose Changes
			</a>
			<a
				href="/gitops/pipelines"
				class="px-3 py-1.5 rounded text-sm border border-surface-300 dark:border-surface-600 hover:bg-surface-100 dark:hover:bg-surface-700 transition-colors"
			>
				Pipelines
			</a>
		</div>
	</div>

	<!-- Source indicator -->
	<div class="text-sm text-surface-500">
		Config source: <span class="font-mono">{data.configSource}</span>
		{#if data.configSource === 'local'}
			(reading from local file)
		{/if}
	</div>

	<!-- Drift Detection -->
	<div class="card p-6 bg-surface-100-800 rounded-lg border border-surface-300-600">
		<h3 class="font-semibold mb-3">Configuration Drift</h3>
		<DriftPanel items={drifts} />
	</div>

	<!-- Config Values -->
	{#each sections as section}
		<div class="card p-6 bg-surface-100-800 rounded-lg border border-surface-300-600">
			<h3 class="font-semibold mb-3">{section.title}</h3>
			<dl class="grid grid-cols-1 md:grid-cols-2 gap-2 text-sm">
				{#each section.entries as [key, value]}
					<div class="flex justify-between py-1 border-b border-surface-200 dark:border-surface-700">
						<dt class="font-mono text-surface-500">{key}</dt>
						<dd class="font-medium">{String(value)}</dd>
					</div>
				{/each}
			</dl>
		</div>
	{/each}
</div>
