<script lang="ts">
	import { RUNNER_TYPE_DEFAULT_TAGS, type RunnerType } from '$lib/types';

	interface Props {
		tags: string[];
		onchange: (tags: string[]) => void;
		runnerType?: RunnerType;
	}

	let { tags, onchange, runnerType }: Props = $props();
	let input = $state('');

	const suggestions = $derived(
		runnerType ? RUNNER_TYPE_DEFAULT_TAGS[runnerType].filter((t) => !tags.includes(t)) : []
	);

	function addTag(tag: string) {
		const trimmed = tag.trim().toLowerCase();
		if (trimmed && !tags.includes(trimmed)) {
			onchange([...tags, trimmed]);
		}
		input = '';
	}

	function removeTag(tag: string) {
		onchange(tags.filter((t) => t !== tag));
	}

	function handleKeydown(e: KeyboardEvent) {
		if (e.key === 'Enter' || e.key === ',') {
			e.preventDefault();
			addTag(input);
		}
		if (e.key === 'Backspace' && input === '' && tags.length > 0) {
			removeTag(tags[tags.length - 1]);
		}
	}
</script>

<div class="space-y-2">
	<div class="flex flex-wrap gap-1.5 p-2 rounded border border-surface-300 dark:border-surface-600 bg-surface-50 dark:bg-surface-800 min-h-[42px]">
		{#each tags as tag}
			<span class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-300 text-xs">
				{tag}
				<button
					type="button"
					class="hover:text-error-500 leading-none"
					onclick={() => removeTag(tag)}
				>
					&times;
				</button>
			</span>
		{/each}
		<input
			type="text"
			class="flex-1 min-w-[80px] bg-transparent border-none outline-none text-sm"
			placeholder={tags.length === 0 ? 'Add tags...' : ''}
			bind:value={input}
			onkeydown={handleKeydown}
		/>
	</div>
	{#if suggestions.length > 0}
		<div class="flex gap-1 flex-wrap">
			<span class="text-xs text-surface-500">Suggested:</span>
			{#each suggestions as suggestion}
				<button
					type="button"
					class="text-xs px-1.5 py-0.5 rounded bg-surface-200 dark:bg-surface-700 hover:bg-primary-100 dark:hover:bg-primary-900/30 transition-colors"
					onclick={() => addTag(suggestion)}
				>
					+{suggestion}
				</button>
			{/each}
		</div>
	{/if}
</div>
