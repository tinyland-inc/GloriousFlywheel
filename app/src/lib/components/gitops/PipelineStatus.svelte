<script lang="ts">
	import StatusDot from '$lib/components/common/StatusDot.svelte';
	import type { PipelineInfo } from '$lib/types';

	interface Props {
		pipeline: PipelineInfo;
	}

	let { pipeline }: Props = $props();

	const statusColor = $derived(
		pipeline.status === 'success'
			? 'online'
			: pipeline.status === 'failed'
				? 'offline'
				: pipeline.status === 'running'
					? 'online'
					: ('stale' as const)
	);
</script>

<div class="flex items-center gap-3 p-3 rounded border border-surface-300 dark:border-surface-600 bg-surface-50 dark:bg-surface-800">
	<StatusDot status={statusColor} />
	<div class="flex-1 min-w-0">
		<div class="flex items-center gap-2">
			<span class="text-sm font-medium">#{pipeline.id}</span>
			<span class="text-xs px-1.5 py-0.5 rounded bg-surface-200 dark:bg-surface-700">
				{pipeline.status}
			</span>
		</div>
		<div class="text-xs text-surface-500 truncate">
			{pipeline.ref} &middot; {pipeline.sha.slice(0, 8)}
		</div>
	</div>
	{#if pipeline.web_url}
		<a
			href={pipeline.web_url}
			target="_blank"
			rel="noopener"
			class="text-xs text-primary-500 hover:underline"
		>
			View
		</a>
	{/if}
</div>
