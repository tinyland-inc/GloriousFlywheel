#!/usr/bin/env node

/**
 * Generates llms.txt and llms-full.txt from docs/ content at build time.
 *
 * Per the llms.txt spec (https://llmstxt.org/):
 *   - llms.txt: Structured index with title, description, section headings, and links
 *   - llms-full.txt: Full concatenated documentation content
 *
 * Both are written to static/ for Pages deployment.
 */

import { readdir, readFile, stat, writeFile, mkdir } from 'fs/promises';
import { join, relative, basename, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const DOCS_DIR = join(__dirname, '..', '..', 'docs');
const STATIC_DIR = join(__dirname, '..', 'static');
const OUTPUT_INDEX = join(STATIC_DIR, 'llms.txt');
const OUTPUT_FULL = join(STATIC_DIR, 'llms-full.txt');

const SITE_URL = 'https://jesssullivan.github.io/attic-iac';

function stripFrontmatter(content) {
	const match = content.match(/^---\n[\s\S]*?\n---\n([\s\S]*)$/);
	return match ? match[1].trim() : content.trim();
}

function extractTitle(content) {
	const stripped = stripFrontmatter(content);
	const match = stripped.match(/^#\s+(.+)$/m);
	return match ? match[1].trim() : null;
}

function extractFrontmatterTitle(content) {
	const match = content.match(/^---\n([\s\S]*?)\n---/);
	if (!match) return null;
	const titleMatch = match[1].match(/^title:\s*(.+)$/m);
	return titleMatch ? titleMatch[1].trim() : null;
}

async function collectFiles(dir, base) {
	const results = [];
	let entries;
	try {
		entries = await readdir(dir);
	} catch {
		return results;
	}

	for (const entry of entries.sort()) {
		const fullPath = join(dir, entry);
		const s = await stat(fullPath);

		if (s.isDirectory()) {
			results.push(...(await collectFiles(fullPath, base)));
		} else if (entry.endsWith('.md')) {
			const rel = relative(base, fullPath);
			const content = await readFile(fullPath, 'utf-8');
			results.push({ path: rel, content, stripped: stripFrontmatter(content) });
		}
	}
	return results;
}

/** Group files by their top-level directory */
function groupBySection(files) {
	const sections = new Map();
	for (const file of files) {
		const parts = file.path.split('/');
		const section = parts.length > 1 ? parts[0] : '_root';
		if (!sections.has(section)) sections.set(section, []);
		sections.get(section).push(file);
	}
	return sections;
}

/** Pretty-print a directory name as a section heading */
function sectionTitle(dir) {
	const titles = {
		architecture: 'Architecture',
		'build-system': 'Build System',
		'ci-cd': 'CI/CD',
		dashboard: 'Dashboard',
		guides: 'Guides',
		infrastructure: 'Infrastructure',
		'k8s-reference': 'Kubernetes Reference',
		monitoring: 'Monitoring',
		reference: 'Reference',
		research: 'Research',
		runners: 'Runners',
		_root: 'Overview'
	};
	return titles[dir] || dir;
}

/** Build the docs site URL for a given file path */
function docUrl(filePath) {
	// Convert docs/runners/README.md -> /runners, docs/index.md -> /
	const withoutExt = filePath.replace(/\.md$/, '');
	const withoutReadme = withoutExt.replace(/\/README$/, '').replace(/^index$/, '');
	return `${SITE_URL}/${withoutReadme}`;
}

async function main() {
	const files = await collectFiles(DOCS_DIR, DOCS_DIR);

	// Read README for the header
	let readme = '';
	try {
		readme = await readFile(join(DOCS_DIR, '..', 'README.md'), 'utf-8');
	} catch {
		// no readme
	}

	await mkdir(STATIC_DIR, { recursive: true });

	// --- Generate llms.txt (structured index) ---
	const indexSections = [];

	indexSections.push('# GloriousFlywheel');
	indexSections.push(
		'> Cross-forge CI/CD runner pool infrastructure for GitLab CI and GitHub Actions'
	);
	indexSections.push('');
	indexSections.push(`> Source: https://github.com/Jesssullivan/attic-iac`);
	indexSections.push(`> Docs: ${SITE_URL}`);
	indexSections.push('> License: Zlib');
	indexSections.push('');

	const grouped = groupBySection(files);
	for (const [section, sectionFiles] of grouped) {
		indexSections.push(`## ${sectionTitle(section)}`);
		for (const file of sectionFiles) {
			const title =
				extractFrontmatterTitle(file.content) || extractTitle(file.content) || file.path;
			const url = docUrl(file.path);
			// Extract first non-heading, non-empty line as description
			const lines = file.stripped.split('\n').filter((l) => l.trim() && !l.startsWith('#'));
			const desc = lines.length > 0 ? lines[0].trim().slice(0, 120) : '';
			indexSections.push(`- [${title}](${url}): ${desc}`);
		}
		indexSections.push('');
	}

	const indexOutput = indexSections.join('\n');
	await writeFile(OUTPUT_INDEX, indexOutput, 'utf-8');

	const indexKb = (Buffer.byteLength(indexOutput, 'utf-8') / 1024).toFixed(1);
	console.log(`Generated ${OUTPUT_INDEX} (${files.length} docs, ${indexKb} KB)`);

	// --- Generate llms-full.txt (full content) ---
	const fullSections = [];

	fullSections.push('# attic-iac');
	fullSections.push('');
	fullSections.push('> Source: https://github.com/Jesssullivan/attic-iac');
	fullSections.push(`> Docs: ${SITE_URL}`);
	fullSections.push('> License: Zlib');
	fullSections.push('');

	if (readme) {
		fullSections.push(stripFrontmatter(readme));
		fullSections.push('');
		fullSections.push('---');
		fullSections.push('');
	}

	fullSections.push('# Full Documentation');
	fullSections.push('');

	for (const file of files) {
		fullSections.push(`## docs/${file.path}`);
		fullSections.push('');
		fullSections.push(file.stripped);
		fullSections.push('');
		fullSections.push('---');
		fullSections.push('');
	}

	const fullOutput = fullSections.join('\n');
	await writeFile(OUTPUT_FULL, fullOutput, 'utf-8');

	const fullKb = (Buffer.byteLength(fullOutput, 'utf-8') / 1024).toFixed(1);
	console.log(`Generated ${OUTPUT_FULL} (${files.length} docs, ${fullKb} KB)`);
}

main().catch((err) => {
	console.error('Failed to generate llms.txt:', err);
	process.exit(1);
});
