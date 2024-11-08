FROM denoland/deno

# Including git
RUN apt update
RUN apt install -y git jq curl
RUN apt clean
RUN rm -rf /var/apt/lists/*

## nvm
ENV NODE_VERSION=v20.11.1
ENV NVM_DIR=/root/.nvm

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
RUN [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
RUN [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

RUN . $NVM_DIR/nvm.sh

RUN echo "source $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default && \
    npm install typescript tsc -g" | bash

# build nostrify
RUN git clone https://gitlab.com/soapbox-pub/nostrify/

WORKDIR /nostrify
RUN deno install

RUN echo '\n\
import * as esbuild from "npm:esbuild";\n\
import { denoPlugins } from "jsr:@luca/esbuild-deno-loader";\n\
\n\
const outputDir = "./dist/lib";\n\
const entryPoints = [\n\
  "./packages/db/mod.ts",\n\
  "./packages/denokv/mod.ts",\n\
  "./packages/nostrify/mod.ts",\n\
  "./packages/policies/mod.ts",\n\
  "./packages/types/mod.ts",\n\
  "./packages/welshman/mod.ts"\n\
];\n\
\n\
const buildConfig = {\n\
  plugins: [...denoPlugins()],\n\
  entryPoints: entryPoints,\n\
  outdir: `dist`,\n\
  bundle: true,\n\
  minify: true,\n\
  sourcemap: true,\n\
  external: [\n\
    "@scure/base", "@scure/bip32", "@scure/bip39",\n\
    "lru-cache", "mock-socket", "nostr-tools",\n\
    "websocket-ts", "zod", "@std/assert",\n\
    "@std/crypto", "@std/encoding", "@std/testing"\n\
  ]\n\
};\n\
await esbuild.build({ ...buildConfig, format: "esm", outdir: `dist/esm` });\n\
await esbuild.build({ ...buildConfig, format: "cjs", outdir: `dist/cjs` });\n\
\n\
esbuild.stop();\n\
' > ./build.ts

RUN deno run --allow-run --allow-env --allow-read --allow-write --unstable build.ts

RUN echo '\n\
{\n\
  "compilerOptions": {\n\
    "declaration": true,\n\
    "outDir": "./dist/types",\n\
    "module": "ESNext",\n\
    "target": "ESNext"\n\
  },\n\
  "include": ["./packages/**/*.ts"]\n\
}\n\
' > ./tsconfig.json

RUN echo tsc --project tsconfig.json

RUN echo '\n\
{\n\
  "type": "module",\n\
  "name": "@belomonte/nostrify",\n\
  "version": "",\n\
  "description": "Framework for Nostr on Deno and web. 🛸",\n\
  "repository": {\n\
    "type": "git",\n\
    "url": "https://gitlab.com/soapbox-pub/nostrify"\n\
  },\n\
  "files": [\n\
    "lib"\n\
  ],\n\
  "sideEffects": false,\n\
  "module": "./esm/mod.js",\n\
  "main": "./cjs/mod.js",\n\
  "types": "./types/mod.d.ts",\n\
  "exports": {\n\
    ".": {\n\
      "import": "./esm/mod.js",\n\
      "require": "./cjs/mod.js",\n\
      "types": "./types/mod.d.ts"\n\
    },\n\
    "./db": {\n\
      "import": "./esm/mod.js",\n\
      "require": "./cjs/mod.js",\n\
      "types": "./types/mod.d.ts"\n\
    },\n\
    "./denokv": {\n\
      "import": "./esm/mod.js",\n\
      "require": "./cjs/mod.js",\n\
      "types": "./types/mod.d.ts"\n\
    },\n\
    "./nostrify": {\n\
      "import": "./esm/mod.js",\n\
      "require": "./cjs/mod.js",\n\
      "types": "./types/mod.d.ts"\n\
    },\n\
    "./policies": {\n\
      "import": "./esm/mod.js",\n\
      "require": "./cjs/mod.js",\n\
      "types": "./types/mod.d.ts"\n\
    },\n\
    "./types": {\n\
      "import": "./esm/mod.js",\n\
      "require": "./cjs/mod.js",\n\
      "types": "./types/mod.d.ts"\n\
    },\n\
    "./welshman": {\n\
      "import": "./esm/mod.js",\n\
      "require": "./cjs/mod.js",\n\
      "types": "./types/mod.d.ts"\n\
    }\n\
  },\n\
  "license": "LICENSE",\n\
  "peerDependencies": {\n\
    "nostr-tools": ">=2.7.0"\n\
  }\n\
}\n\
' > ./dist/package.json

CMD [ "/bin/bash" ]