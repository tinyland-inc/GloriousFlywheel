<script lang="ts">
	import RunnerCard from '$lib/components/runner/RunnerCard.svelte';
	import { RUNNER_TYPES, RUNNER_TYPE_LABELS, type RunnerInfo } from '$lib/types';

	let { data } = $props();

	let filterType = $state<string>('all');

	const runners = $derived(data.runners as RunnerInfo[]);
	const filtered = $derived(
		filterType === 'all' ? runners : runners.filter((r) => r.type === filterType)
	);
</script>

<svelte:head>
	<title>Runners - Runner Dashboard</title>
</svelte:head>

<div class="space-y-6">
	<div class="flex items-center justify-between">
		<h2 class="text-2xl font-bold">Runners</h2>
		<div class="flex gap-2">
			<button
				onclick={() => (filterType = 'all')}
				class="px-3 py-1 rounded text-sm transition-colors"
				class:bg-primary-500={filterType === 'all'}
				class:text-white={filterType === 'all'}
				class:bg-surface-200-700={filterType !== 'all'}
			>
				All
			</button>
			{#each RUNNER_TYPES as type}
				<button
					onclick={() => (filterType = type)}
					class="px-3 py-1 rounded text-sm transition-colors"
					class:bg-primary-500={filterType === type}
					class:text-white={filterType === type}
					class:bg-surface-200-700={filterType !== type}
				>
					{RUNNER_TYPE_LABELS[type]}
				</button>
			{/each}
		</div>
	</div>

	<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
		{#each filtered as runner (runner.name)}
			<RunnerCard {runner} />
		{/each}
	</div>

	{#if filtered.length === 0}
		<p class="text-center text-surface-500 py-8">No runners match the selected filter.</p>
	{/if}
</div>
