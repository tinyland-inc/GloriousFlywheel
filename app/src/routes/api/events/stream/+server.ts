import type { RequestHandler } from './$types';
import { prometheus } from '$lib/server/prometheus/client';
import { QUERIES } from '$lib/server/prometheus/queries';
import { toMetricValue } from '$lib/server/prometheus/transform';
import { MOCK_DASHBOARD_METRICS } from '$lib/mocks';

export const GET: RequestHandler = async () => {
	const encoder = new TextEncoder();

	const stream = new ReadableStream({
		async start(controller) {
			const send = (event: string, data: unknown) => {
				controller.enqueue(encoder.encode(`event: ${event}\ndata: ${JSON.stringify(data)}\n\n`));
			};

			// Send initial connection event
			send('connected', { timestamp: new Date().toISOString() });

			// Poll and push metrics every 30 seconds
			const interval = setInterval(async () => {
				try {
					const available = await prometheus.isAvailable();
					if (!available) {
						send('metrics', { available: false, metrics: MOCK_DASHBOARD_METRICS });
						return;
					}

					const [totalJobs, failedJobs, successRate] = await Promise.all([
						prometheus.instantQuery(QUERIES.totalJobs()),
						prometheus.instantQuery(QUERIES.failedJobs()),
						prometheus.instantQuery(QUERIES.successRate())
					]);

					send('metrics', {
						available: true,
						metrics: {
							total_jobs: toMetricValue(totalJobs),
							failed_jobs: toMetricValue(failedJobs),
							success_rate: toMetricValue(successRate, 1)
						}
					});
				} catch {
					send('metrics', { available: false, metrics: MOCK_DASHBOARD_METRICS });
				}
			}, 30000);

			// Send heartbeat every 15 seconds to keep connection alive
			const heartbeat = setInterval(() => {
				try {
					controller.enqueue(encoder.encode(': heartbeat\n\n'));
				} catch {
					// Connection closed
					clearInterval(interval);
					clearInterval(heartbeat);
				}
			}, 15000);

			// Clean up on close
			const cleanup = () => {
				clearInterval(interval);
				clearInterval(heartbeat);
			};

			// Store cleanup for later
			(controller as unknown as Record<string, unknown>)._cleanup = cleanup;
		},
		cancel() {
			// Called when client disconnects
		}
	});

	return new Response(stream, {
		headers: {
			'Content-Type': 'text/event-stream',
			'Cache-Control': 'no-cache',
			Connection: 'keep-alive'
		}
	});
};
