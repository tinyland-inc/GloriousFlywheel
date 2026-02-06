import { json } from '@sveltejs/kit';
import { prometheus } from '$lib/server/prometheus/client';
import { QUERIES } from '$lib/server/prometheus/queries';
import { toMetricValue } from '$lib/server/prometheus/transform';
import { cached } from '$lib/server/cache';
import { MOCK_DASHBOARD_METRICS } from '$lib/mocks';
import type { RequestHandler } from './$types';

export const GET: RequestHandler = async () => {
	const available = await prometheus.isAvailable();

	if (!available) {
		return json({
			available: false,
			metrics: MOCK_DASHBOARD_METRICS
		});
	}

	try {
		const metrics = await cached('dashboard-metrics', 30000, async () => {
			const [totalJobs, failedJobs, successRate] = await Promise.all([
				prometheus.instantQuery(QUERIES.totalJobs()),
				prometheus.instantQuery(QUERIES.failedJobs()),
				prometheus.instantQuery(QUERIES.successRate())
			]);

			return {
				total_jobs: toMetricValue(totalJobs),
				failed_jobs: toMetricValue(failedJobs),
				success_rate: toMetricValue(successRate, 1)
			};
		});

		return json({ available: true, metrics });
	} catch {
		return json({
			available: false,
			metrics: MOCK_DASHBOARD_METRICS
		});
	}
};
