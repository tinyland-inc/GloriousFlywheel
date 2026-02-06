<script lang="ts">
	let {
		message,
		details = '',
		onretry
	}: { message: string; details?: string; onretry?: () => void } = $props();
</script>

<div class="rounded-lg border border-red-500/30 bg-red-500/10 p-4">
	<div class="flex items-start gap-3">
		<span class="text-red-500 text-lg">!</span>
		<div class="flex-1">
			<p class="font-medium text-red-400">{message}</p>
			{#if details}
				<p class="text-sm text-red-400/70 mt-1">{details}</p>
			{/if}
		</div>
		{#if onretry}
			<button onclick={onretry} class="text-sm text-red-400 hover:text-red-300 underline">
				Retry
			</button>
		{/if}
	</div>
</div>
