<script lang="ts">
	import type { HPAStatus } from '$lib/types';

	let { hpa }: { hpa: HPAStatus } = $props();

	const cpuPercent = $derived(hpa.cpu_current ?? 0);
	const cpuTarget = $derived(hpa.cpu_target ?? 70);
	const memPercent = $derived(hpa.memory_current ?? 0);
	const memTarget = $derived(hpa.memory_target ?? 80);
	const replicaPercent = $derived(
		((hpa.current_replicas - hpa.min_replicas) / Math.max(hpa.max_replicas - hpa.min_replicas, 1)) * 100
	);

	function barColor(value: number, target: number): string {
		const ratio = value / target;
		if (ratio >= 0.9) return 'bg-red-500';
		if (ratio >= 0.7) return 'bg-yellow-500';
		return 'bg-green-500';
	}
</script>

<div class="card p-4 bg-surface-100-800 rounded-lg border border-surface-300-600">
	<div class="flex items-center justify-between mb-3">
		<h4 class="font-medium">{hpa.name}</h4>
		<span class="text-sm text-surface-500">
			{hpa.current_replicas}/{hpa.max_replicas} replicas
		</span>
	</div>

	<div class="space-y-2">
		<!-- CPU bar -->
		<div>
			<div class="flex justify-between text-xs text-surface-500 mb-0.5">
				<span>CPU</span>
				<span>{cpuPercent}% / {cpuTarget}%</span>
			</div>
			<div class="w-full h-2 bg-surface-300-600 rounded-full overflow-hidden">
				<div
					class="h-full rounded-full transition-all {barColor(cpuPercent, cpuTarget)}"
					style:width="{Math.min(cpuPercent, 100)}%"
				></div>
			</div>
		</div>

		<!-- Memory bar -->
		<div>
			<div class="flex justify-between text-xs text-surface-500 mb-0.5">
				<span>Memory</span>
				<span>{memPercent}% / {memTarget}%</span>
			</div>
			<div class="w-full h-2 bg-surface-300-600 rounded-full overflow-hidden">
				<div
					class="h-full rounded-full transition-all {barColor(memPercent, memTarget)}"
					style:width="{Math.min(memPercent, 100)}%"
				></div>
			</div>
		</div>

		<!-- Replica bar -->
		<div>
			<div class="flex justify-between text-xs text-surface-500 mb-0.5">
				<span>Scale</span>
				<span>{hpa.current_replicas} ({hpa.min_replicas}-{hpa.max_replicas})</span>
			</div>
			<div class="w-full h-2 bg-surface-300-600 rounded-full overflow-hidden">
				<div
					class="h-full rounded-full transition-all bg-primary-500"
					style:width="{Math.min(replicaPercent, 100)}%"
				></div>
			</div>
		</div>
	</div>
</div>
