<script lang="ts">
	import { page } from '$app/stores';

	function getCrumbs(pathname: string): { label: string; href: string }[] {
		const segments = pathname.split('/').filter(Boolean);
		const crumbs = [{ label: 'Dashboard', href: '/' }];

		let path = '';
		for (const segment of segments) {
			path += `/${segment}`;
			const label = segment.charAt(0).toUpperCase() + segment.slice(1).replace(/-/g, ' ');
			crumbs.push({ label, href: path });
		}

		return crumbs;
	}
</script>

{#if $page.url.pathname !== '/'}
	<nav class="flex items-center gap-1.5 text-sm text-surface-500 mb-4">
		{#each getCrumbs($page.url.pathname) as crumb, i}
			{#if i > 0}
				<span>/</span>
			{/if}
			{#if i === getCrumbs($page.url.pathname).length - 1}
				<span class="text-surface-900 dark:text-surface-100">{crumb.label}</span>
			{:else}
				<a href={crumb.href} class="hover:text-primary-500 transition-colors">{crumb.label}</a>
			{/if}
		{/each}
	</nav>
{/if}
