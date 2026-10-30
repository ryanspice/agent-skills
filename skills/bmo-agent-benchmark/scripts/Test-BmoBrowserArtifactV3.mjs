import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const [artifactInput, outputInput, playwrightInput] = process.argv.slice(2);
if (!artifactInput || !outputInput || !playwrightInput) {
	throw new Error(
		'Usage: node Test-BmoBrowserArtifactV3.mjs <artifact-root> <output-json> <playwright-module-root>'
	);
}

const artifactRoot = path.resolve(artifactInput);
const outputPath = path.resolve(outputInput);
const playwrightRoot = path.resolve(playwrightInput);
const screenshotRoot = path.join(path.dirname(outputPath), `${path.parse(outputPath).name}-screenshots`);
const viteEntry = path.join(artifactRoot, 'node_modules', 'vite', 'dist', 'node', 'index.js');
const playwrightEntry = path.join(playwrightRoot, 'index.mjs');

function writeJsonAtomic(filePath, value) {
	fs.mkdirSync(path.dirname(filePath), { recursive: true });
	const temporary = `${filePath}.${process.pid}.${Date.now()}.tmp`;
	fs.writeFileSync(temporary, `${JSON.stringify(value, null, 2)}\n`, 'utf8');
	fs.renameSync(temporary, filePath);
}

const report = {
	schemaVersion: 'bmo.browser-evidence.v1',
	status: 'running',
	checkedAt: new Date().toISOString(),
	artifactRoot,
	launchMode: 'hidden-stdio',
	ssr: null,
	viewports: [],
	accessibility: null,
	interaction: null,
	consoleErrors: [],
	externalResourceErrors: [],
	pageErrors: [],
	failedLocalRequests: [],
	verdict: 'ERROR',
	error: ''
};

let previewServer;
let browser;
try {
	for (const required of [artifactRoot, viteEntry, playwrightEntry]) {
		if (!fs.existsSync(required)) {
			throw new Error(`Required browser-probe input is missing: ${required}`);
		}
	}

	const vite = await import(pathToFileURL(viteEntry).href);
	const { chromium } = await import(pathToFileURL(playwrightEntry).href);
	previewServer = await vite.preview({
		root: artifactRoot,
		logLevel: 'silent',
		preview: {
			host: '127.0.0.1',
			port: 0,
			strictPort: false
		}
	});

	const address = previewServer.httpServer.address();
	if (!address || typeof address === 'string') {
		throw new Error('Vite preview did not expose a TCP address.');
	}
	const origin = `http://127.0.0.1:${address.port}`;
	const response = await fetch(`${origin}/`, { redirect: 'follow' });
	const html = await response.text();
	report.ssr = {
		url: `${origin}/`,
		status: response.status,
		ok: response.ok,
		contentType: response.headers.get('content-type') ?? '',
		hasReferenceDemoBoundary: /REFERENCE\s+DEMO/i.test(html),
		hasHtmlDocument: /<html[\s>]/i.test(html),
		bytes: Buffer.byteLength(html)
	};

	browser = await chromium.launch({ headless: true });
	fs.mkdirSync(screenshotRoot, { recursive: true });
	const viewportCases = [
		{ name: 'mobile', width: 390, height: 844 },
		{ name: 'tablet', width: 768, height: 1024 },
		{ name: 'desktop', width: 1440, height: 1000 }
	];

	let interaction = { status: 'not-detected', selector: '', changed: false };
	let aggregateAccessibility = {
		headingsLevelOne: 0,
		mainLandmarks: 0,
		navigationLandmarks: 0,
		unnamedButtons: 0,
		unnamedLinks: 0,
		imagesMissingAlt: 0,
		duplicateIds: []
	};

	for (const viewport of viewportCases) {
		const context = await browser.newContext({
			viewport: { width: viewport.width, height: viewport.height },
			reducedMotion: 'reduce',
			colorScheme: 'light'
		});
		const page = await context.newPage();
		page.on('console', (message) => {
			if (message.type() === 'error') {
				const location = message.location();
				const locationUrl = location?.url ?? '';
				const entry = {
					viewport: viewport.name,
					text: message.text().slice(0, 1000),
					url: locationUrl
				};
				const isExternalResourceFailure =
					/failed to load resource/i.test(entry.text) &&
					locationUrl &&
					!locationUrl.startsWith(origin);
				if (isExternalResourceFailure) {
					report.externalResourceErrors.push(entry);
				} else {
					report.consoleErrors.push(entry);
				}
			}
		});
		page.on('pageerror', (error) => {
			report.pageErrors.push({ viewport: viewport.name, text: String(error.message).slice(0, 1000) });
		});
		page.on('requestfailed', (request) => {
			if (request.url().startsWith(origin)) {
				report.failedLocalRequests.push({
					viewport: viewport.name,
					url: request.url(),
					error: request.failure()?.errorText ?? 'unknown'
				});
			}
		});

		await page.goto(`${origin}/`, { waitUntil: 'domcontentloaded', timeout: 30_000 });
		await page.waitForLoadState('networkidle', { timeout: 10_000 }).catch(() => {});
		const metrics = await page.evaluate(() => {
			const accessibleName = (element) => {
				const labelledBy = (element.getAttribute('aria-labelledby') || '')
					.split(/\s+/)
					.filter(Boolean)
					.map((id) => document.getElementById(id)?.textContent || '')
					.join(' ')
					.trim();
				const descendantImageAlt = [...element.querySelectorAll('img[alt]')]
					.map((image) => image.getAttribute('alt') || '')
					.join(' ')
					.trim();
				return (
					element.getAttribute('aria-label') ||
					labelledBy ||
					element.getAttribute('title') ||
					element.textContent ||
					descendantImageAlt ||
					''
				).trim();
			};
			const duplicateIds = [...document.querySelectorAll('[id]')]
				.map((element) => element.id)
				.filter((id, index, ids) => id && ids.indexOf(id) !== index)
				.filter((id, index, ids) => ids.indexOf(id) === index);
			return {
				documentWidth: document.documentElement.scrollWidth,
				viewportWidth: document.documentElement.clientWidth,
				horizontalOverflow:
					document.documentElement.scrollWidth > document.documentElement.clientWidth + 2,
				headingsLevelOne: document.querySelectorAll('h1').length,
				mainLandmarks: document.querySelectorAll('main,[role="main"]').length,
				navigationLandmarks: document.querySelectorAll('nav,[role="navigation"]').length,
				unnamedButtons: [...document.querySelectorAll('button')].filter(
					(element) => !accessibleName(element)
				).length,
				unnamedLinks: [...document.querySelectorAll('a[href]')].filter(
					(element) => !accessibleName(element)
				).length,
				imagesMissingAlt: [...document.querySelectorAll('img')].filter(
					(element) => !element.hasAttribute('alt')
				).length,
				duplicateIds,
				hasReferenceDemoBoundary: /REFERENCE\s+DEMO/i.test(document.body.innerText),
				bodyCharacters: document.body.innerText.length
			};
		});

		if (viewport.name === 'desktop') {
			aggregateAccessibility = {
				headingsLevelOne: metrics.headingsLevelOne,
				mainLandmarks: metrics.mainLandmarks,
				navigationLandmarks: metrics.navigationLandmarks,
				unnamedButtons: metrics.unnamedButtons,
				unnamedLinks: metrics.unnamedLinks,
				imagesMissingAlt: metrics.imagesMissingAlt,
				duplicateIds: metrics.duplicateIds
			};
			const candidate = page.locator('[role="tab"][aria-selected="false"]').first();
			if ((await candidate.count()) > 0 && (await candidate.isVisible())) {
				const selector = await candidate.evaluate((element) => {
					const role = element.getAttribute('role');
					const controls = element.getAttribute('aria-controls');
					return role ? `[role="${role}"]` : `button[aria-controls="${controls}"]`;
				});
				const before = await page.locator('body').innerText();
				await candidate.click();
				await page.waitForTimeout(100);
				const after = await page.locator('body').innerText();
				interaction = { status: 'exercised', selector, changed: before !== after };
			}
		}

		const screenshotPath = path.join(screenshotRoot, `${viewport.name}.png`);
		await page.screenshot({ path: screenshotPath, fullPage: true });
		report.viewports.push({
			...viewport,
			...metrics,
			screenshotPath
		});
		await context.close();
	}

	report.interaction = interaction;
	report.accessibility = {
		scope: 'deterministic structural signals, not a complete WCAG audit',
		...aggregateAccessibility,
		passed:
			aggregateAccessibility.headingsLevelOne === 1 &&
			aggregateAccessibility.mainLandmarks >= 1 &&
			aggregateAccessibility.navigationLandmarks >= 1 &&
			aggregateAccessibility.unnamedButtons === 0 &&
			aggregateAccessibility.unnamedLinks === 0 &&
			aggregateAccessibility.imagesMissingAlt === 0 &&
			aggregateAccessibility.duplicateIds.length === 0
	};

	const responsivePassed = report.viewports.every(
		(viewport) => !viewport.horizontalOverflow && viewport.hasReferenceDemoBoundary
	);
	const runtimePassed =
		report.consoleErrors.length === 0 &&
		report.pageErrors.length === 0 &&
		report.failedLocalRequests.length === 0;
	const interactionPassed = interaction.status === 'exercised' && interaction.changed;
	report.status = 'completed';
	report.verdict =
		report.ssr.ok &&
		report.ssr.hasHtmlDocument &&
		report.ssr.hasReferenceDemoBoundary &&
		responsivePassed &&
		report.accessibility.passed &&
		runtimePassed &&
		interactionPassed
			? 'PASS'
			: 'FAIL';
	report.responsivePassed = responsivePassed;
	report.runtimePassed = runtimePassed;
	report.interactionPassed = interactionPassed;
} catch (error) {
	report.status = 'infrastructure-error';
	report.verdict = 'ERROR';
	report.error = String(error?.stack || error);
	process.exitCode = 2;
} finally {
	if (browser) {
		await browser.close().catch(() => {});
	}
	if (previewServer?.httpServer) {
		await new Promise((resolve) => previewServer.httpServer.close(resolve));
	}
	report.checkedAt = new Date().toISOString();
	writeJsonAtomic(outputPath, report);
	process.stdout.write(`${JSON.stringify(report)}\n`);
}
