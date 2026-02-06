<script lang="ts">
	import { validateResourceString } from '$lib/validation/runner';

	interface Props {
		label: string;
		value: string;
		onchange: (value: string) => void;
		placeholder?: string;
	}

	let { label, value, onchange, placeholder = '100m' }: Props = $props();

	const valid = $derived(value === '' || validateResourceString(value));
</script>

<label class="block text-sm">
	<span class="text-surface-600 dark:text-surface-400">{label}</span>
	<input
		type="text"
		class="mt-1 block w-full rounded border px-3 py-1.5 text-sm font-mono
			{valid
			? 'border-surface-300 dark:border-surface-600 bg-surface-50 dark:bg-surface-800'
			: 'border-error-500 bg-error-50 dark:bg-error-900/20'}"
		{value}
		{placeholder}
		oninput={(e) => onchange(e.currentTarget.value)}
	/>
	{#if !valid}
		<p class="text-error-500 text-xs mt-1">Invalid format (e.g. 100m, 2Gi, 512Mi)</p>
	{/if}
</label>
