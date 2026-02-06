<script lang="ts">
	type Status = 'online' | 'offline' | 'paused' | 'stale' | 'warning' | 'error';

	let { status, size = 'md' }: { status: Status; size?: 'sm' | 'md' | 'lg' } = $props();

	const colors: Record<Status, string> = {
		online: 'bg-green-500',
		offline: 'bg-red-500',
		paused: 'bg-yellow-500',
		stale: 'bg-gray-400',
		warning: 'bg-orange-500',
		error: 'bg-red-600'
	};

	const sizes = {
		sm: 'w-2 h-2',
		md: 'w-3 h-3',
		lg: 'w-4 h-4'
	};
</script>

<span
	class="inline-block rounded-full {colors[status]} {sizes[size]}"
	class:animate-pulse={status === 'online'}
	title={status}
></span>
