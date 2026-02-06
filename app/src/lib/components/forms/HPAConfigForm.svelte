<script lang="ts">
	import type { HPAConfig } from '$lib/types';

	interface Props {
		config: HPAConfig;
		onchange: (config: HPAConfig) => void;
	}

	let { config, onchange }: Props = $props();

	function update<K extends keyof HPAConfig>(key: K, value: HPAConfig[K]) {
		onchange({ ...config, [key]: value });
	}

	const minMaxError = $derived(config.min_replicas > config.max_replicas);
</script>

<div class="space-y-4">
	<label class="flex items-center gap-2">
		<input
			type="checkbox"
			checked={config.enabled}
			onchange={(e) => update('enabled', e.currentTarget.checked)}
			class="rounded"
		/>
		<span class="text-sm font-medium">Enable HPA</span>
	</label>

	{#if config.enabled}
		<div class="grid grid-cols-2 gap-4">
			<label class="block text-sm">
				<span class="text-surface-600 dark:text-surface-400">Min Replicas</span>
				<input
					type="number"
					min="0"
					max="50"
					class="mt-1 block w-full rounded border border-surface-300 dark:border-surface-600 bg-surface-50 dark:bg-surface-800 px-3 py-1.5 text-sm"
					value={config.min_replicas}
					oninput={(e) => update('min_replicas', parseInt(e.currentTarget.value) || 0)}
				/>
			</label>
			<label class="block text-sm">
				<span class="text-surface-600 dark:text-surface-400">Max Replicas</span>
				<input
					type="number"
					min="1"
					max="50"
					class="mt-1 block w-full rounded border border-surface-300 dark:border-surface-600 bg-surface-50 dark:bg-surface-800 px-3 py-1.5 text-sm"
					value={config.max_replicas}
					oninput={(e) => update('max_replicas', parseInt(e.currentTarget.value) || 1)}
				/>
			</label>
		</div>
		{#if minMaxError}
			<p class="text-error-500 text-xs">Min replicas must be &lt;= max replicas</p>
		{/if}

		<div class="space-y-3">
			<label class="block text-sm">
				<span class="text-surface-600 dark:text-surface-400">CPU Target: {config.cpu_target}%</span>
				<input
					type="range"
					min="1"
					max="100"
					value={config.cpu_target}
					oninput={(e) => update('cpu_target', parseInt(e.currentTarget.value))}
					class="w-full mt-1"
				/>
			</label>
			<label class="block text-sm">
				<span class="text-surface-600 dark:text-surface-400">Memory Target: {config.memory_target}%</span>
				<input
					type="range"
					min="1"
					max="100"
					value={config.memory_target}
					oninput={(e) => update('memory_target', parseInt(e.currentTarget.value))}
					class="w-full mt-1"
				/>
			</label>
		</div>

		<div class="grid grid-cols-2 gap-4">
			<label class="block text-sm">
				<span class="text-surface-600 dark:text-surface-400">Scale Up Window (s)</span>
				<input
					type="number"
					min="0"
					class="mt-1 block w-full rounded border border-surface-300 dark:border-surface-600 bg-surface-50 dark:bg-surface-800 px-3 py-1.5 text-sm"
					value={config.scale_up_window}
					oninput={(e) => update('scale_up_window', parseInt(e.currentTarget.value) || 0)}
				/>
			</label>
			<label class="block text-sm">
				<span class="text-surface-600 dark:text-surface-400">Scale Down Window (s)</span>
				<input
					type="number"
					min="0"
					class="mt-1 block w-full rounded border border-surface-300 dark:border-surface-600 bg-surface-50 dark:bg-surface-800 px-3 py-1.5 text-sm"
					value={config.scale_down_window}
					oninput={(e) => update('scale_down_window', parseInt(e.currentTarget.value) || 0)}
				/>
			</label>
		</div>
	{/if}
</div>
