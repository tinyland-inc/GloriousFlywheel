import { json } from '@sveltejs/kit';
import { k8sClient } from '$lib/server/k8s/client';
import { MOCK_PODS } from '$lib/mocks';
import type { RequestHandler } from './$types';
import type { PodInfo } from '$lib/types';

export const GET: RequestHandler = async () => {
	const available = await k8sClient.isAvailable();

	if (!available) {
		return json({ available: false, pods: MOCK_PODS });
	}

	try {
		const rawPods = await k8sClient.listPods();
		const pods: PodInfo[] = rawPods.map((p) => ({
			name: p.metadata.name,
			status: p.status.phase,
			runner: p.metadata.labels['app.kubernetes.io/name'] ?? 'unknown',
			node: '',
			cpu_usage: '0m',
			memory_usage: '0Mi',
			restarts: p.status.containerStatuses?.[0]?.restartCount ?? 0,
			age: p.metadata.creationTimestamp
		}));
		return json({ available: true, pods });
	} catch {
		return json({ available: false, pods: MOCK_PODS });
	}
};
