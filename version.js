const semver = require('semver');
const fs = require('fs');

const packageJson = fs.readFileSync('package.json');
packageJson.exports = {};
const npmVersion = "$VERSION";
const deno = JSON.parse(fs.readFileSync('deno.json'));
const versions = [];
if (npmVersion) {
  versions.push(npmVersion);
}
deno.workspace.forEach(project => {
  versions.push(JSON.parse(fs.readFileSync(`${project}/deno.json`)).version);
  packageJson.exports[project.replace(/packages\//, '')] = {
    import: "./esm/mod.js",
    require: "./cjs/mod.js",
    types: "./types/mod.d.ts"
  };
});

const maxVersion = semver.maxSatisfying(versions, '*');
packageJson.version = maxVersion;


