<script lang="ts">
	interface Props {
		connected: boolean;
	}

	let { connected }: Props = $props();
</script>

<div class="flex items-center gap-1.5 text-xs">
	<span
		class="inline-block w-2 h-2 rounded-full {connected
			? 'bg-success-500 animate-pulse'
			: 'bg-surface-400'}"
	></span>
	<span class="text-surface-500">{connected ? 'Live' : 'Disconnected'}</span>
</div>
