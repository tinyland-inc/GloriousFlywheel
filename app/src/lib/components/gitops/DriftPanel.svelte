<script lang="ts">
	import type { DriftItem } from '$lib/types';

	interface Props {
		items: DriftItem[];
	}

	let { items }: Props = $props();

	function severityClass(severity: string): string {
		switch (severity) {
			case 'error':
				return 'border-error-500/30 bg-error-500/10 text-error-600 dark:text-error-400';
			case 'warning':
				return 'border-warning-500/30 bg-warning-500/10 text-warning-600 dark:text-warning-400';
			default:
				return 'border-primary-500/30 bg-primary-500/10 text-primary-600 dark:text-primary-400';
		}
	}
</script>

{#if items.length === 0}
	<div class="text-center py-6 text-surface-500 text-sm">
		No configuration drift detected.
	</div>
{:else}
	<div class="space-y-2">
		{#each items as item}
			<div class="rounded border p-3 {severityClass(item.severity)}">
				<div class="flex items-center justify-between">
					<span class="font-medium text-sm">{item.runner}</span>
					<span class="text-xs uppercase font-mono">{item.severity}</span>
				</div>
				<div class="text-xs mt-1">
					<span class="font-mono">{item.field}</span>:
					expected <strong>{item.expected}</strong>, got <strong>{item.actual}</strong>
				</div>
			</div>
		{/each}
	</div>
{/if}
