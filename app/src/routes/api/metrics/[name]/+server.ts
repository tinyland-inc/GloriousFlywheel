import { json, error } from '@sveltejs/kit';
import { prometheus } from '$lib/server/prometheus/client';
import { QUERIES, TIME_WINDOWS, type TimeWindow } from '$lib/server/prometheus/queries';
import { toTimeSeries, toMetricValue } from '$lib/server/prometheus/transform';
import { MOCK_RUNNER_MAP } from '$lib/mocks';
import type { RequestHandler } from './$types';

export const GET: RequestHandler = async ({ params, url }) => {
	const runner = MOCK_RUNNER_MAP[params.name];
	if (!runner) {
		error(404, `Runner "${params.name}" not found`);
	}

	const window = (url.searchParams.get('window') ?? '1h') as TimeWindow;
	const config = TIME_WINDOWS[window] ?? TIME_WINDOWS['1h'];

	const available = await prometheus.isAvailable();

	if (!available) {
		return json({
			available: false,
			runner: params.name,
			window,
			timeSeries: { cpu: [], memory: [], jobs: [] },
			current: { totalJobs: 0, failedJobs: 0, jobsPerMinute: 0 }
		});
	}

	try {
		const now = Math.floor(Date.now() / 1000);
		const start = now - config.seconds;

		const [cpuSeries, memorySeries, jobsSeries, totalJobs, failedJobs, jpm] = await Promise.all([
			prometheus.rangeQuery(QUERIES.cpuUsage(params.name), start, now, config.step),
			prometheus.rangeQuery(QUERIES.memoryUsage(params.name), start, now, config.step),
			prometheus.rangeQuery(QUERIES.jobsPerMinute(params.name), start, now, config.step),
			prometheus.instantQuery(QUERIES.totalJobs(params.name)),
			prometheus.instantQuery(QUERIES.failedJobs(params.name)),
			prometheus.instantQuery(QUERIES.jobsPerMinute(params.name))
		]);

		return json({
			available: true,
			runner: params.name,
			window,
			timeSeries: {
				cpu: toTimeSeries(cpuSeries),
				memory: toTimeSeries(memorySeries),
				jobs: toTimeSeries(jobsSeries)
			},
			current: {
				totalJobs: toMetricValue(totalJobs).value,
				failedJobs: toMetricValue(failedJobs).value,
				jobsPerMinute: toMetricValue(jpm).value
			}
		});
	} catch {
		return json({
			available: false,
			runner: params.name,
			window,
			timeSeries: { cpu: [], memory: [], jobs: [] },
			current: { totalJobs: 0, failedJobs: 0, jobsPerMinute: 0 }
		});
	}
};
