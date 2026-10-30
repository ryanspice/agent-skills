#!/usr/bin/env node

import process from 'node:process';

const META_USER_AGENT = 'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)';

function usage() {
  console.log(`Usage:
  node verify-social-preview.mjs --url https://example.com/page/

Options:
  --image URL                 Override the image URL found in og:image
  --expect-width NUMBER       Expected image width (default: 1200)
  --expect-height NUMBER      Expected image height (default: 630)
  --allow-nonstandard-size    Warn instead of fail on a dimension mismatch
  --user-agent VALUE          meta, default, or a literal user-agent (default: meta)
  --json                      Print machine-readable JSON
  --help                      Show this help
`);
}

function parseArgs(argv) {
  const args = {
    url: '',
    image: '',
    expectWidth: 1200,
    expectHeight: 630,
    allowNonstandardSize: false,
    userAgent: META_USER_AGENT,
    json: false
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    const next = () => argv[++index] ?? '';

    if (arg === '--url') args.url = next();
    else if (arg === '--image') args.image = next();
    else if (arg === '--expect-width') args.expectWidth = Number.parseInt(next(), 10);
    else if (arg === '--expect-height') args.expectHeight = Number.parseInt(next(), 10);
    else if (arg === '--allow-nonstandard-size') args.allowNonstandardSize = true;
    else if (arg === '--user-agent') {
      const value = next();
      args.userAgent = value === 'meta' ? META_USER_AGENT : value === 'default' ? '' : value;
    } else if (arg === '--json') args.json = true;
    else if (arg === '--help' || arg === '-h') args.help = true;
    else throw new Error(`Unknown argument: ${arg}`);
  }

  return args;
}

function parseAttributes(tag) {
  const attributes = {};
  const pattern = /([:\w-]+)\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s>]+))/g;
  for (const match of tag.matchAll(pattern)) {
    attributes[match[1].toLowerCase()] = match[2] ?? match[3] ?? match[4] ?? '';
  }
  return attributes;
}

function decodeEntities(value) {
  return value
    .replaceAll('&amp;', '&')
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'")
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>');
}

function extractMetadata(html) {
  const head = html.match(/<head\b[^>]*>([\s\S]*?)<\/head>/i)?.[1] ?? html;
  const meta = new Map();

  for (const match of head.matchAll(/<meta\b[^>]*>/gi)) {
    const attributes = parseAttributes(match[0]);
    const key = (attributes.property || attributes.name || '').toLowerCase();
    if (!key || attributes.content === undefined) continue;
    const values = meta.get(key) ?? [];
    values.push(decodeEntities(attributes.content));
    meta.set(key, values);
  }

  let canonical = '';
  for (const match of head.matchAll(/<link\b[^>]*>/gi)) {
    const attributes = parseAttributes(match[0]);
    const rels = (attributes.rel || '').toLowerCase().split(/\s+/);
    if (rels.includes('canonical') && attributes.href) {
      canonical = decodeEntities(attributes.href);
      break;
    }
  }

  return {
    canonical,
    get: (key) => meta.get(key.toLowerCase())?.[0] ?? ''
  };
}

function isAbsoluteHttpUrl(value) {
  try {
    const url = new URL(value);
    return url.protocol === 'http:' || url.protocol === 'https:';
  } catch {
    return false;
  }
}

function detectImage(buffer) {
  if (
    buffer.length >= 24 &&
    buffer.subarray(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]))
  ) {
    return {
      format: 'png',
      width: buffer.readUInt32BE(16),
      height: buffer.readUInt32BE(20)
    };
  }

  if (buffer.length >= 4 && buffer[0] === 0xff && buffer[1] === 0xd8) {
    const startOfFrame = new Set([0xc0, 0xc1, 0xc2, 0xc3, 0xc5, 0xc6, 0xc7, 0xc9, 0xca, 0xcb, 0xcd, 0xce, 0xcf]);
    let offset = 2;

    while (offset + 9 < buffer.length) {
      if (buffer[offset] !== 0xff) {
        offset += 1;
        continue;
      }

      while (buffer[offset] === 0xff) offset += 1;
      const marker = buffer[offset];
      const markerStart = offset - 1;
      if (startOfFrame.has(marker)) {
        return {
          format: 'jpeg',
          width: buffer.readUInt16BE(markerStart + 7),
          height: buffer.readUInt16BE(markerStart + 5)
        };
      }

      if (marker === 0xd8 || marker === 0xd9 || (marker >= 0xd0 && marker <= 0xd7)) {
        offset += 1;
        continue;
      }

      if (markerStart + 4 > buffer.length) break;
      const segmentLength = buffer.readUInt16BE(markerStart + 2);
      if (segmentLength < 2) break;
      offset = markerStart + 2 + segmentLength;
    }

    return { format: 'jpeg', width: null, height: null };
  }

  if (buffer.length >= 10 && ['GIF87a', 'GIF89a'].includes(buffer.subarray(0, 6).toString('ascii'))) {
    return {
      format: 'gif',
      width: buffer.readUInt16LE(6),
      height: buffer.readUInt16LE(8)
    };
  }

  return { format: 'unknown', width: null, height: null };
}

function normalizedMime(value) {
  return value.split(';')[0].trim().toLowerCase();
}

async function fetchChecked(url, headers) {
  return fetch(url, {
    headers,
    redirect: 'follow',
    cache: 'no-store',
    signal: AbortSignal.timeout(30000)
  });
}

async function run(args) {
  const errors = [];
  const warnings = [];
  const addError = (message) => errors.push(message);
  const addWarning = (message) => warnings.push(message);

  if (!args.url || !isAbsoluteHttpUrl(args.url)) {
    throw new Error('--url must be an absolute HTTP(S) URL.');
  }
  if (!Number.isInteger(args.expectWidth) || args.expectWidth <= 0) {
    throw new Error('--expect-width must be a positive integer.');
  }
  if (!Number.isInteger(args.expectHeight) || args.expectHeight <= 0) {
    throw new Error('--expect-height must be a positive integer.');
  }

  const commonHeaders = {
    accept: 'text/html,application/xhtml+xml,image/avif,image/webp,image/png,image/jpeg,*/*;q=0.8',
    'accept-encoding': 'gzip, deflate'
  };
  if (args.userAgent) commonHeaders['user-agent'] = args.userAgent;

  const pageResponse = await fetchChecked(args.url, commonHeaders);
  if (!pageResponse.ok) addError(`Page request returned HTTP ${pageResponse.status}.`);

  const pageContentType = normalizedMime(pageResponse.headers.get('content-type') ?? '');
  if (pageContentType && !pageContentType.includes('html')) {
    addError(`Page Content-Type is ${pageContentType}, not HTML.`);
  }

  const xRobotsTag = pageResponse.headers.get('x-robots-tag') ?? '';
  if (xRobotsTag) addWarning(`Page emits X-Robots-Tag: ${xRobotsTag}. Confirm crawler compatibility and privacy intent.`);

  const html = await pageResponse.text();
  const metadata = extractMetadata(html);
  const required = ['og:title', 'og:description', 'og:type', 'og:url', 'og:image'];
  for (const property of required) {
    if (!metadata.get(property)) addError(`Missing ${property} in initial HTML.`);
  }
  if (!metadata.canonical) addError('Missing canonical link in initial HTML.');

  const absoluteFields = [
    ['canonical', metadata.canonical],
    ['og:url', metadata.get('og:url')],
    ['og:image', metadata.get('og:image')]
  ];
  for (const [label, value] of absoluteFields) {
    if (value && !isAbsoluteHttpUrl(value)) addError(`${label} must be an absolute HTTP(S) URL: ${value}`);
  }

  if (metadata.canonical && metadata.get('og:url') && metadata.canonical !== metadata.get('og:url')) {
    addWarning(`canonical and og:url differ: ${metadata.canonical} vs ${metadata.get('og:url')}`);
  }
  if (!metadata.get('og:image:alt')) addWarning('Missing og:image:alt.');
  if (!metadata.get('og:image:type')) addWarning('Missing og:image:type.');
  if (!metadata.get('og:image:width') || !metadata.get('og:image:height')) {
    addWarning('Missing declared og:image dimensions.');
  }

  if (metadata.get('twitter:card') !== 'summary_large_image') {
    addError('twitter:card must be summary_large_image.');
  }
  for (const property of ['twitter:title', 'twitter:description', 'twitter:image']) {
    if (!metadata.get(property)) addError(`Missing ${property} in initial HTML.`);
  }
  if (!metadata.get('twitter:image:alt')) addWarning('Missing twitter:image:alt.');

  const robotsMeta = metadata.get('robots');
  if (robotsMeta) addWarning(`HTML robots directive is ${robotsMeta}; this is search policy, not proof of an unfurl failure.`);

  const imageUrl = args.image || metadata.get('og:image');
  let image = null;
  let imageResponseSummary = null;

  if (imageUrl && isAbsoluteHttpUrl(imageUrl)) {
    const imageHeaders = {
      ...commonHeaders,
      accept: 'image/png,image/jpeg,image/*;q=0.8,*/*;q=0.5',
      range: 'bytes=0-1048575'
    };
    const imageResponse = await fetchChecked(imageUrl, imageHeaders);
    if (!imageResponse.ok) addError(`Image request returned HTTP ${imageResponse.status}.`);

    const imageContentType = normalizedMime(imageResponse.headers.get('content-type') ?? '');
    const imageXRobotsTag = imageResponse.headers.get('x-robots-tag') ?? '';
    if (imageXRobotsTag) addWarning(`Image emits X-Robots-Tag: ${imageXRobotsTag}. Confirm crawler compatibility.`);
    if (!['image/png', 'image/jpeg'].includes(imageContentType)) {
      addError(`Share image Content-Type should be image/png or image/jpeg, received ${imageContentType || 'missing'}.`);
    }

    const buffer = Buffer.from(await imageResponse.arrayBuffer());
    image = detectImage(buffer);
    if (!['png', 'jpeg'].includes(image.format)) {
      addError(`Share image bytes are ${image.format}, not PNG or JPEG.`);
    }

    if (image.width && image.height) {
      const matchesExpected = image.width === args.expectWidth && image.height === args.expectHeight;
      if (!matchesExpected) {
        const message = `Share image is ${image.width}x${image.height}; expected ${args.expectWidth}x${args.expectHeight}.`;
        if (args.allowNonstandardSize) addWarning(message);
        else addError(message);
      }

      const declaredWidth = Number.parseInt(metadata.get('og:image:width'), 10);
      const declaredHeight = Number.parseInt(metadata.get('og:image:height'), 10);
      if (Number.isInteger(declaredWidth) && declaredWidth !== image.width) {
        addError(`og:image:width declares ${declaredWidth}, but image bytes are ${image.width}.`);
      }
      if (Number.isInteger(declaredHeight) && declaredHeight !== image.height) {
        addError(`og:image:height declares ${declaredHeight}, but image bytes are ${image.height}.`);
      }
    } else {
      addError('Could not decode share image dimensions from the fetched bytes.');
    }

    const declaredType = normalizedMime(metadata.get('og:image:type'));
    if (declaredType && imageContentType && declaredType !== imageContentType) {
      addError(`og:image:type declares ${declaredType}, but the server returns ${imageContentType}.`);
    }

    imageResponseSummary = {
      requestedUrl: imageUrl,
      finalUrl: imageResponse.url,
      status: imageResponse.status,
      contentType: imageContentType,
      xRobotsTag: imageXRobotsTag || null
    };
  } else if (imageUrl) {
    addError(`Image override or og:image is not an absolute HTTP(S) URL: ${imageUrl}`);
  }

  const result = {
    ok: errors.length === 0,
    crawler: args.userAgent || 'runtime default',
    page: {
      requestedUrl: args.url,
      finalUrl: pageResponse.url,
      status: pageResponse.status,
      contentType: pageContentType,
      xRobotsTag: xRobotsTag || null,
      canonical: metadata.canonical || null,
      ogUrl: metadata.get('og:url') || null,
      ogImage: metadata.get('og:image') || null,
      twitterImage: metadata.get('twitter:image') || null
    },
    image: image
      ? {
          ...imageResponseSummary,
          format: image.format,
          width: image.width,
          height: image.height
        }
      : null,
    errors,
    warnings
  };

  if (args.json) {
    console.log(JSON.stringify(result, null, 2));
  } else {
    console.log(`Social preview verification: ${result.ok ? 'PASS' : 'FAIL'}`);
    console.log(`Page:  ${result.page.status} ${result.page.finalUrl}`);
    if (result.image) {
      console.log(`Image: ${result.image.status} ${result.image.format} ${result.image.width}x${result.image.height} ${result.image.finalUrl}`);
    }
    for (const warning of warnings) console.log(`WARN: ${warning}`);
    for (const error of errors) console.error(`ERROR: ${error}`);
  }

  if (!result.ok) process.exitCode = 1;
}

let args;
try {
  args = parseArgs(process.argv.slice(2));
  if (args.help) {
    usage();
  } else {
    await run(args);
  }
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  usage();
  process.exitCode = 1;
}
