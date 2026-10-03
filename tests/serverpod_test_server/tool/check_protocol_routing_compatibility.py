"""Exchange wire payloads between a Git baseline and current generated protocols."""

import argparse
import copy
import json
import subprocess
import tarfile
import urllib.parse
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--baseline', required=True, help='Git revision before routing changes')
parser.add_argument('--scratch', type=Path, required=True, help='New output directory')
parser.add_argument('--dart', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parents[3]
scratch = args.scratch.resolve()
scratch.mkdir(parents=True, exist_ok=False)
config_path = root / '.dart_tool/package_config.json'
current = json.loads(config_path.read_text())
archive_paths = []

for package in current['packages']:
    uri = urllib.parse.urljoin(config_path.as_uri(), package['rootUri'])
    package['rootUri'] = uri
    source = Path(urllib.parse.unquote(urllib.parse.urlparse(uri).path))
    if source.is_relative_to(root) and (source / 'lib').is_dir():
        archive_paths.append(str(source.relative_to(root) / 'lib'))

archive = scratch / 'baseline.tar'
with archive.open('wb') as output:
    subprocess.run(
        ['git', 'archive', args.baseline, '--', *archive_paths],
        cwd=root, stdout=output, check=True,
    )
legacy_root = scratch / 'baseline'
legacy_root.mkdir()
with tarfile.open(archive) as source:
    source.extractall(legacy_root, filter='data')
archive.unlink()

legacy = copy.deepcopy(current)
for package in legacy['packages']:
    source = Path(urllib.parse.unquote(urllib.parse.urlparse(package['rootUri']).path))
    if source.is_relative_to(root) and str(source.relative_to(root) / 'lib') in archive_paths:
        package['rootUri'] = (legacy_root / source.relative_to(root)).as_uri()

old_roots = {package['name']: package['rootUri'] for package in legacy['packages']}
new_roots = {package['name']: package['rootUri'] for package in current['packages']}
new_host = copy.deepcopy(current)
old_host = copy.deepcopy(legacy)
for package in new_host['packages']:
    if package['name'] in {'serverpod_test_module_client', 'serverpod_test_module_server'}:
        package['rootUri'] = old_roots[package['name']]
for package in old_host['packages']:
    if package['name'] not in {'serverpod_test_client', 'serverpod_test_server'}:
        package['rootUri'] = new_roots[package['name']]

configs = {'old': legacy, 'new': current, 'new-host-old-module': new_host, 'old-host-new-modules': old_host}
peer = root / 'tests/serverpod_test_server/test/fixtures/protocol_routing_peer.dart'
results = {
    'baseline': subprocess.check_output(['git', 'rev-parse', args.baseline], cwd=root, text=True).strip(),
    'exchanges': [],
}

for version, config in configs.items():
    path = scratch / f'{version}-packages.json'
    path.write_text(json.dumps(config, indent=2) + '\n')
    with (scratch / f'{version}-compile.log').open('w') as log:
        subprocess.run([
            str(args.dart), 'compile', 'kernel', f'--packages={path}',
            str(peer), '-o', str(scratch / f'{version}.dill'),
        ], stdout=log, stderr=subprocess.STDOUT, check=True)


def run(version, side, action, payload):
    result = subprocess.run([
        str(args.dart), str(scratch / f'{version}.dill'), side, action, str(payload),
    ], text=True, capture_output=True)
    results['exchanges'].append({
        'version': version, 'side': side, 'action': action,
        'payload': payload.name, 'exitCode': result.returncode,
        'stdout': result.stdout, 'stderr': result.stderr,
    })
    (scratch / 'results.json').write_text(json.dumps(results, indent=2) + '\n')
    if result.returncode:
        raise RuntimeError(result.stderr)
    print(f'{version}: {side} {action} passed', flush=True)


for version in ('old', 'new'):
    for side in ('client', 'server'):
        run(version, side, 'write', scratch / f'{version}-{side}.json')

for writer, reader in (('old', 'new'), ('new', 'old')):
    run(reader, 'client', 'read', scratch / f'{writer}-server.json')
    run(reader, 'server', 'read', scratch / f'{writer}-client.json')

for version in ('new-host-old-module', 'old-host-new-modules'):
    run(version, 'client', 'read', scratch / 'new-server.json')
    run(version, 'server', 'read', scratch / 'new-client.json')

for side in ('client', 'server'):
    if (scratch / f'old-{side}.json').read_bytes() != (scratch / f'new-{side}.json').read_bytes():
        raise RuntimeError(f'Wire payload changed on the {side}')
results['wirePayloadsByteIdentical'] = True
(scratch / 'results.json').write_text(json.dumps(results, indent=2) + '\n')
print('Both peers emit byte-identical wire payloads.', flush=True)
