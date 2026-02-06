<script lang="ts">
	import type { Snippet } from 'svelte';

	let {
		data,
		columns,
		emptyMessage = 'No data available',
		row
	}: {
		data: Record<string, unknown>[];
		columns: { key: string; label: string; width?: string }[];
		emptyMessage?: string;
		row?: Snippet<[Record<string, unknown>]>;
	} = $props();
</script>

<div class="overflow-x-auto rounded-lg border border-surface-300-600">
	<table class="w-full text-sm">
		<thead>
			<tr class="bg-surface-200-700">
				{#each columns as col}
					<th class="px-4 py-2 text-left font-medium text-surface-500" style:width={col.width}>
						{col.label}
					</th>
				{/each}
			</tr>
		</thead>
		<tbody>
			{#if data.length === 0}
				<tr>
					<td colspan={columns.length} class="px-4 py-8 text-center text-surface-500">
						{emptyMessage}
					</td>
				</tr>
			{:else if row}
				{#each data as item}
					{@render row(item)}
				{/each}
			{:else}
				{#each data as item}
					<tr class="border-t border-surface-300-600 hover:bg-surface-200-700/50">
						{#each columns as col}
							<td class="px-4 py-2">{item[col.key] ?? ''}</td>
						{/each}
					</tr>
				{/each}
			{/if}
		</tbody>
	</table>
</div>
