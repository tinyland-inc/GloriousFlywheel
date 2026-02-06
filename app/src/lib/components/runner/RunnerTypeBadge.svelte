<script lang="ts">
	import type { RunnerType } from '$lib/types';
	import { RUNNER_TYPE_LABELS } from '$lib/types';

	let { type }: { type: RunnerType } = $props();

	const colors: Record<RunnerType, string> = {
		docker: 'bg-blue-500/20 text-blue-400',
		dind: 'bg-purple-500/20 text-purple-400',
		rocky8: 'bg-orange-500/20 text-orange-400',
		rocky9: 'bg-amber-500/20 text-amber-400',
		nix: 'bg-cyan-500/20 text-cyan-400'
	};
</script>

<span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium {colors[type]}">
	{RUNNER_TYPE_LABELS[type]}
</span>
