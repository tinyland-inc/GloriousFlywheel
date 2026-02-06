import { gitlab, type GitLabClient } from './client';

interface GitLabPipeline {
	id: number;
	status: string;
	ref: string;
	sha: string;
	created_at: string;
	updated_at: string;
	web_url: string;
	source: string;
}

export async function listPipelines(
	projectId: string,
	params: Record<string, string> = {},
	client: GitLabClient = gitlab
): Promise<GitLabPipeline[]> {
	return client.request<GitLabPipeline[]>(`/projects/${projectId}/pipelines`, {
		params: { per_page: '20', ...params }
	});
}

export async function getPipeline(
	projectId: string,
	pipelineId: number,
	client: GitLabClient = gitlab
): Promise<GitLabPipeline> {
	return client.request<GitLabPipeline>(`/projects/${projectId}/pipelines/${pipelineId}`);
}

export async function triggerPipeline(
	projectId: string,
	ref: string,
	variables: Record<string, string> = {},
	client: GitLabClient = gitlab
): Promise<GitLabPipeline> {
	return client.request<GitLabPipeline>(`/projects/${projectId}/pipeline`, {
		method: 'POST',
		body: {
			ref,
			variables: Object.entries(variables).map(([key, value]) => ({ key, value }))
		}
	});
}

export async function getPipelineStatus(
	projectId: string,
	pipelineId: number,
	client: GitLabClient = gitlab
): Promise<string> {
	const pipeline = await getPipeline(projectId, pipelineId, client);
	return pipeline.status;
}
