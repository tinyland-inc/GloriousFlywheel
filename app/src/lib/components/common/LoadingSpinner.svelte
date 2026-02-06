<script lang="ts">
	let { size = 'md', message = '' }: { size?: 'sm' | 'md' | 'lg'; message?: string } = $props();

	const sizes = {
		sm: 'w-4 h-4',
		md: 'w-8 h-8',
		lg: 'w-12 h-12'
	};
</script>

<div class="flex items-center gap-3" role="status">
	<div
		class="animate-spin rounded-full border-2 border-surface-300 border-t-primary-500 {sizes[size]}"
	></div>
	{#if message}
		<span class="text-surface-500 text-sm">{message}</span>
	{/if}
</div>
