<svelte:head>
	<title>Logged Out - Runner Dashboard</title>
</svelte:head>

<div class="flex items-center justify-center h-full">
	<div class="text-center space-y-4">
		<h1 class="text-2xl font-bold">Logged out</h1>
		<p class="text-surface-400">Your session has been cleared.</p>
		<a
			href="/auth/login"
			class="inline-block px-4 py-2 rounded bg-primary-500 hover:bg-primary-600 text-white transition-colors"
		>
			Log in again
		</a>
	</div>
</div>
