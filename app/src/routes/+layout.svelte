<script lang="ts">
	import '../app.css';
	import type { Snippet } from 'svelte';
	import Sidebar from '$lib/components/nav/Sidebar.svelte';
	import Breadcrumb from '$lib/components/nav/Breadcrumb.svelte';

	let { children }: { children: Snippet } = $props();
</script>

<div class="h-full flex">
	<Sidebar />

	<main class="flex-1 overflow-auto p-6">
		<Breadcrumb />
		{@render children()}
	</main>
</div>
