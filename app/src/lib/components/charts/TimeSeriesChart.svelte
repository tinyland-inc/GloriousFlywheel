<script lang="ts">
	import { onMount, onDestroy } from 'svelte';
	import {
		Chart,
		LineController,
		LineElement,
		PointElement,
		LinearScale,
		TimeScale,
		Title,
		Tooltip,
		Legend,
		Filler
	} from 'chart.js';
	import type { TimeSeriesData } from '$lib/types';

	Chart.register(
		LineController,
		LineElement,
		PointElement,
		LinearScale,
		TimeScale,
		Title,
		Tooltip,
		Legend,
		Filler
	);

	interface Props {
		title: string;
		data: TimeSeriesData[];
		yLabel?: string;
		height?: number;
	}

	let { title, data, yLabel = '', height = 200 }: Props = $props();

	let canvas: HTMLCanvasElement;
	let chart: Chart | null = null;

	const COLORS = [
		'rgb(59, 130, 246)', // blue
		'rgb(16, 185, 129)', // green
		'rgb(249, 115, 22)', // orange
		'rgb(139, 92, 246)', // purple
		'rgb(236, 72, 153)' // pink
	];

	function buildChart() {
		if (chart) chart.destroy();
		if (!canvas) return;

		const datasets = data.map((series, i) => ({
			label: series.label,
			data: series.values.map((v, j) => ({
				x: new Date(series.timestamps[j]).getTime(),
				y: v
			})),
			borderColor: COLORS[i % COLORS.length],
			backgroundColor: COLORS[i % COLORS.length].replace('rgb', 'rgba').replace(')', ', 0.1)'),
			borderWidth: 1.5,
			pointRadius: 0,
			fill: true,
			tension: 0.3
		}));

		chart = new Chart(canvas, {
			type: 'line',
			data: { datasets },
			options: {
				responsive: true,
				maintainAspectRatio: false,
				interaction: { intersect: false, mode: 'index' },
				plugins: {
					title: { display: true, text: title, align: 'start', font: { size: 13 } },
					legend: { display: datasets.length > 1, position: 'bottom', labels: { boxWidth: 12 } },
					tooltip: { enabled: true }
				},
				scales: {
					x: {
						type: 'linear',
						ticks: {
							callback: (value) => {
								const d = new Date(value as number);
								return d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
							},
							maxTicksLimit: 8,
							font: { size: 10 }
						},
						grid: { display: false }
					},
					y: {
						title: { display: !!yLabel, text: yLabel, font: { size: 11 } },
						beginAtZero: true,
						ticks: { font: { size: 10 } },
						grid: { color: 'rgba(128, 128, 128, 0.1)' }
					}
				}
			}
		});
	}

	onMount(() => {
		buildChart();
	});

	onDestroy(() => {
		chart?.destroy();
	});

	// Rebuild chart when data changes
	$effect(() => {
		if (data && canvas) {
			buildChart();
		}
	});
</script>

<div style="height: {height}px" class="w-full">
	{#if data.length === 0}
		<div class="flex items-center justify-center h-full text-surface-400 text-sm">
			No data available
		</div>
	{:else}
		<canvas bind:this={canvas}></canvas>
	{/if}
</div>
