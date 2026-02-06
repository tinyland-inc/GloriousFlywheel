<script lang="ts">
	import type { RunnerStatus } from '$lib/types';
	import StatusDot from '$lib/components/common/StatusDot.svelte';

	let { status }: { status: RunnerStatus } = $props();

	const labels: Record<RunnerStatus, string> = {
		online: 'Online',
		offline: 'Offline',
		paused: 'Paused',
		stale: 'Stale'
	};
</script>

<span class="inline-flex items-center gap-1.5">
	<StatusDot {status} size="sm" />
	<span class="text-sm">{labels[status]}</span>
</span>
