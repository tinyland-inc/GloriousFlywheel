<script lang="ts">
	import type { RunnerInfo } from '$lib/types';
	import RunnerTypeBadge from './RunnerTypeBadge.svelte';
	import RunnerStatusIndicator from './RunnerStatusIndicator.svelte';
	import RunnerTagList from './RunnerTagList.svelte';

	let { runner }: { runner: RunnerInfo } = $props();
</script>

<a
	href="/runners/{runner.name}"
	class="block card p-4 bg-surface-100-800 hover:bg-surface-200-700 transition-colors rounded-lg border border-surface-300-600"
>
	<div class="flex items-start justify-between mb-3">
		<div>
			<h3 class="font-semibold text-lg">{runner.name}</h3>
			<RunnerTypeBadge type={runner.type} />
		</div>
		<RunnerStatusIndicator status={runner.status} />
	</div>

	<div class="space-y-2 text-sm">
		<div class="flex justify-between text-surface-500">
			<span>Concurrency</span>
			<span>{runner.config.concurrent_jobs}</span>
		</div>
		<div class="flex justify-between text-surface-500">
			<span>HPA</span>
			<span>
				{runner.config.hpa.min_replicas}-{runner.config.hpa.max_replicas} replicas
			</span>
		</div>
		<div class="mt-2">
			<RunnerTagList tags={runner.tags} />
		</div>
	</div>
</a>
