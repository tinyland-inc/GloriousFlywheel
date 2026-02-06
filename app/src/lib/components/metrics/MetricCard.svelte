<script lang="ts">
	import type { MetricCardData } from '$lib/types';

	let { metric }: { metric: MetricCardData } = $props();

	const trendColors = {
		up: 'text-green-400',
		down: 'text-red-400',
		stable: 'text-surface-500'
	};

	const trendIcons = {
		up: '+',
		down: '-',
		stable: ''
	};
</script>

<div class="card p-4 bg-surface-100-800 rounded-lg border border-surface-300-600">
	<p class="text-sm text-surface-500">{metric.label}</p>
	<div class="flex items-end gap-2 mt-1">
		<p class="text-3xl font-bold">{metric.value}{metric.unit ?? ''}</p>
		{#if metric.trend && metric.change !== undefined}
			<span class="text-sm {trendColors[metric.trend]} mb-1">
				{trendIcons[metric.trend]}{metric.change}
			</span>
		{/if}
	</div>
</div>
