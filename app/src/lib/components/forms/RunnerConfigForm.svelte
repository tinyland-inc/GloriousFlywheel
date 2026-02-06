<script lang="ts">
	import {
		RUNNER_TYPES,
		RUNNER_TYPE_LABELS,
		RUNNER_TYPE_DEFAULT_IMAGES,
		type RunnerConfig,
		type RunnerType,
		type ResourceSpec
	} from '$lib/types';
	import { validateRunnerConfig, type ValidationError } from '$lib/validation/runner';
	import ResourceInput from './ResourceInput.svelte';
	import TagInput from './TagInput.svelte';
	import HPAConfigForm from './HPAConfigForm.svelte';

	interface Props {
		config: RunnerConfig;
		onsubmit: (config: RunnerConfig) => void;
		oncancel?: () => void;
		disabled?: boolean;
	}

	let { config: initial, onsubmit, oncancel, disabled = false }: Props = $props();

	let draft = $state<RunnerConfig>({ ...initial });
	const errors = $derived(validateRunnerConfig(draft));
	const hasErrors = $derived(errors.length > 0);

	function errorFor(field: string): string | undefined {
		return errors.find((e: ValidationError) => e.field === field)?.message;
	}

	function updateResources(section: 'manager_resources' | 'job_resources', key: keyof ResourceSpec, value: string) {
		draft = {
			...draft,
			[section]: { ...draft[section], [key]: value }
		};
	}

	function handleSubmit(e: SubmitEvent) {
		e.preventDefault();
		if (!hasErrors) {
			onsubmit(draft);
		}
	}
</script>

<form onsubmit={handleSubmit} class="space-y-6">
	<!-- Runner Type -->
	<div>
		<label class="block text-sm">
			<span class="text-surface-600 dark:text-surface-400 font-medium">Runner Type</span>
			<select
				class="mt-1 block w-full rounded border border-surface-300 dark:border-surface-600 bg-surface-50 dark:bg-surface-800 px-3 py-1.5 text-sm"
				value={draft.type}
				onchange={(e) => {
					const type = e.currentTarget.value as RunnerType;
					draft = {
						...draft,
						type,
						default_image: RUNNER_TYPE_DEFAULT_IMAGES[type]
					};
				}}
				{disabled}
			>
				{#each RUNNER_TYPES as type}
					<option value={type}>{RUNNER_TYPE_LABELS[type]}</option>
				{/each}
			</select>
		</label>
		{#if errorFor('type')}
			<p class="text-error-500 text-xs mt-1">{errorFor('type')}</p>
		{/if}
	</div>

	<!-- Basic Settings -->
	<div class="grid grid-cols-2 gap-4">
		<label class="block text-sm">
			<span class="text-surface-600 dark:text-surface-400">Default Image</span>
			<input
				type="text"
				class="mt-1 block w-full rounded border border-surface-300 dark:border-surface-600 bg-surface-50 dark:bg-surface-800 px-3 py-1.5 text-sm font-mono"
				value={draft.default_image}
				oninput={(e) => (draft = { ...draft, default_image: e.currentTarget.value })}
				{disabled}
			/>
		</label>
		<label class="block text-sm">
			<span class="text-surface-600 dark:text-surface-400">Concurrent Jobs</span>
			<input
				type="number"
				min="1"
				max="50"
				class="mt-1 block w-full rounded border border-surface-300 dark:border-surface-600 bg-surface-50 dark:bg-surface-800 px-3 py-1.5 text-sm"
				value={draft.concurrent_jobs}
				oninput={(e) =>
					(draft = { ...draft, concurrent_jobs: parseInt(e.currentTarget.value) || 1 })}
				{disabled}
			/>
			{#if errorFor('concurrent_jobs')}
				<p class="text-error-500 text-xs mt-1">{errorFor('concurrent_jobs')}</p>
			{/if}
		</label>
	</div>

	<!-- Toggles -->
	<div class="flex gap-6">
		<label class="flex items-center gap-2 text-sm">
			<input
				type="checkbox"
				checked={draft.privileged}
				onchange={(e) => (draft = { ...draft, privileged: e.currentTarget.checked })}
				{disabled}
				class="rounded"
			/>
			Privileged
		</label>
		<label class="flex items-center gap-2 text-sm">
			<input
				type="checkbox"
				checked={draft.run_untagged}
				onchange={(e) => (draft = { ...draft, run_untagged: e.currentTarget.checked })}
				{disabled}
				class="rounded"
			/>
			Run Untagged
		</label>
		<label class="flex items-center gap-2 text-sm">
			<input
				type="checkbox"
				checked={draft.protected}
				onchange={(e) => (draft = { ...draft, protected: e.currentTarget.checked })}
				{disabled}
				class="rounded"
			/>
			Protected
		</label>
	</div>

	<!-- Tags -->
	<div>
		<span class="block text-sm text-surface-600 dark:text-surface-400 font-medium mb-1">Tags</span>
		<TagInput
			tags={draft.tags}
			onchange={(tags) => (draft = { ...draft, tags })}
			runnerType={draft.type}
		/>
	</div>

	<!-- Manager Resources -->
	<fieldset class="space-y-3">
		<legend class="text-sm font-medium">Manager Pod Resources</legend>
		<div class="grid grid-cols-2 gap-3">
			<ResourceInput
				label="CPU Request"
				value={draft.manager_resources.cpu_request}
				onchange={(v) => updateResources('manager_resources', 'cpu_request', v)}
				placeholder="100m"
			/>
			<ResourceInput
				label="CPU Limit"
				value={draft.manager_resources.cpu_limit}
				onchange={(v) => updateResources('manager_resources', 'cpu_limit', v)}
				placeholder="500m"
			/>
			<ResourceInput
				label="Memory Request"
				value={draft.manager_resources.memory_request}
				onchange={(v) => updateResources('manager_resources', 'memory_request', v)}
				placeholder="128Mi"
			/>
			<ResourceInput
				label="Memory Limit"
				value={draft.manager_resources.memory_limit}
				onchange={(v) => updateResources('manager_resources', 'memory_limit', v)}
				placeholder="512Mi"
			/>
		</div>
	</fieldset>

	<!-- Job Resources -->
	<fieldset class="space-y-3">
		<legend class="text-sm font-medium">Job Pod Resources</legend>
		<div class="grid grid-cols-2 gap-3">
			<ResourceInput
				label="CPU Request"
				value={draft.job_resources.cpu_request}
				onchange={(v) => updateResources('job_resources', 'cpu_request', v)}
				placeholder="100m"
			/>
			<ResourceInput
				label="CPU Limit"
				value={draft.job_resources.cpu_limit}
				onchange={(v) => updateResources('job_resources', 'cpu_limit', v)}
				placeholder="2"
			/>
			<ResourceInput
				label="Memory Request"
				value={draft.job_resources.memory_request}
				onchange={(v) => updateResources('job_resources', 'memory_request', v)}
				placeholder="256Mi"
			/>
			<ResourceInput
				label="Memory Limit"
				value={draft.job_resources.memory_limit}
				onchange={(v) => updateResources('job_resources', 'memory_limit', v)}
				placeholder="2Gi"
			/>
		</div>
	</fieldset>

	<!-- HPA Configuration -->
	<fieldset class="space-y-3">
		<legend class="text-sm font-medium">Horizontal Pod Autoscaler</legend>
		<HPAConfigForm
			config={draft.hpa}
			onchange={(hpa) => (draft = { ...draft, hpa })}
		/>
	</fieldset>

	<!-- Actions -->
	<div class="flex gap-3 pt-2">
		<button
			type="submit"
			class="px-4 py-2 rounded bg-primary-500 text-white text-sm font-medium hover:bg-primary-600 disabled:opacity-50 disabled:cursor-not-allowed"
			disabled={hasErrors || disabled}
		>
			Save Configuration
		</button>
		{#if oncancel}
			<button
				type="button"
				class="px-4 py-2 rounded border border-surface-300 dark:border-surface-600 text-sm hover:bg-surface-100 dark:hover:bg-surface-700"
				onclick={oncancel}
			>
				Cancel
			</button>
		{/if}
	</div>
</form>
