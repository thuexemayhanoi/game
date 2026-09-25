#!/usr/bin/env python3
"""Baseline tracking of web build size and large files (enforcement later)."""
import json, os, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BASELINE = os.path.join(ROOT, 'docs', 'state', 'build-budget-baseline.json')
LARGE_FILE_LIMIT = 2 * 1024 * 1024  # report files > 2MB

def main():
    large = []
    for dirpath, dirnames, _, in os.walk(ROOT):
        dirnames[:] = [d for d in dirnames if d not in ('.git', '.godot', 'build', 'node_modules')]
        for name in os.listdir(dirpath):
            fp = os.path.join(dirpath, name)
            if os.path.isfile(fp) and os.path.getsize(fp) > LARGE_FILE_LIMIT:
                large.append((os.path.relpath(fp, ROOT), os.path.getsize(fp)))
    web_build = os.path.join(ROOT, 'build', 'web')
    web_size = None
    if os.path.isdir(web_build):
        web_size = sum(os.path.getsize(os.path.join(dp, f)) for dp, _, fs in os.walk(web_build) for f in fs)
    report = {'large_files': [{'path': p, 'bytes': b} for p, b in sorted(large)], 'web_build_bytes': web_size}
    os.makedirs(os.path.dirname(BASELINE), exist_ok=True)
    with open(BASELINE, 'w', encoding='utf-8') as f:
        json.dump(report, f, indent=2)
    print(json.dumps(report, indent=2))
    print('BUDGET OK (baseline mode; enforcement comes in M12)')

if __name__ == '__main__':
    main()
