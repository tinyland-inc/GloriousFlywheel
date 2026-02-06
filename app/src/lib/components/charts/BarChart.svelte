<script lang="ts">
	import { onMount, onDestroy } from 'svelte';
	import {
		Chart,
		BarController,
		BarElement,
		CategoryScale,
		LinearScale,
		Title,
		Tooltip
	} from 'chart.js';

	Chart.register(BarController, BarElement, CategoryScale, LinearScale, Title, Tooltip);

	interface Props {
		title: string;
		labels: string[];
		values: number[];
		color?: string;
		yLabel?: string;
		height?: number;
	}

	let {
		title,
		labels,
		values,
		color = 'rgb(59, 130, 246)',
		yLabel = '',
		height = 200
	}: Props = $props();

	let canvas: HTMLCanvasElement;
	let chart: Chart | null = null;

	function buildChart() {
		if (chart) chart.destroy();
		if (!canvas) return;

		chart = new Chart(canvas, {
			type: 'bar',
			data: {
				labels,
				datasets: [
					{
						data: values,
						backgroundColor: color.replace('rgb', 'rgba').replace(')', ', 0.6)'),
						borderColor: color,
						borderWidth: 1,
						borderRadius: 3
					}
				]
			},
			options: {
				responsive: true,
				maintainAspectRatio: false,
				plugins: {
					title: { display: true, text: title, align: 'start', font: { size: 13 } },
					legend: { display: false }
				},
				scales: {
					x: { ticks: { font: { size: 10 } }, grid: { display: false } },
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

	$effect(() => {
		if (labels && values && canvas) {
			buildChart();
		}
	});
</script>

<div style="height: {height}px" class="w-full">
	{#if values.length === 0}
		<div class="flex items-center justify-center h-full text-surface-400 text-sm">
			No data available
		</div>
	{:else}
		<canvas bind:this={canvas}></canvas>
	{/if}
</div>
