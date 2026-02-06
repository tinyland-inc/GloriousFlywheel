export const ENVIRONMENTS = ['beehive', 'rigel'] as const;
export type Environment = (typeof ENVIRONMENTS)[number];

export const ENV_LABELS: Record<Environment, string> = {
	beehive: 'Beehive (Dev)',
	rigel: 'Rigel (Staging/Prod)'
};

export const ENV_DOMAINS: Record<Environment, string> = {
	beehive: 'beehive.bates.edu',
	rigel: 'rigel.bates.edu'
};

export interface EnvironmentConfig {
	name: Environment;
	label: string;
	domain: string;
	namespace: string;
	gitlab_url: string;
	gitlab_project_id: string;
}

export const ENVIRONMENT_CONFIGS: Record<Environment, EnvironmentConfig> = {
	beehive: {
		name: 'beehive',
		label: 'Beehive (Dev)',
		domain: 'beehive.bates.edu',
		namespace: 'bates-ils-runners',
		gitlab_url: 'https://gitlab.com',
		gitlab_project_id: '78189586'
	},
	rigel: {
		name: 'rigel',
		label: 'Rigel (Staging/Prod)',
		domain: 'rigel.bates.edu',
		namespace: 'bates-ils-runners',
		gitlab_url: 'https://gitlab.com',
		gitlab_project_id: '78189586'
	}
};
