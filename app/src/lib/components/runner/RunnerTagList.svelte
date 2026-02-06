<script lang="ts">
	let { tags, limit = 5 }: { tags: string[]; limit?: number } = $props();

	const visible = $derived(tags.slice(0, limit));
	const overflow = $derived(tags.length - limit);
</script>

<div class="flex flex-wrap gap-1">
	{#each visible as tag}
		<span class="inline-flex items-center px-1.5 py-0.5 rounded bg-surface-200-700 text-xs">
			{tag}
		</span>
	{/each}
	{#if overflow > 0}
		<span class="text-xs text-surface-500">+{overflow} more</span>
	{/if}
</div>
