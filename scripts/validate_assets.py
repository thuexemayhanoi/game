#!/usr/bin/env python3
"""Check assets for missing files, huge sizes, risky paths, case collisions."""
import os, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSET_DIRS = ['assets/placeholder','assets/ui','assets/audio','assets/vehicles','assets/world']
HUGE_LIMIT = 25 * 1024 * 1024  # 25 MB single-file baseline
BAD_EXT = {'.exe','.dll','.so','.dylib','.psd','.blend','.rar','.zip','.7z'}

def fail(msg):
    print('ASSETS FAIL: ' + msg); sys.exit(1)

def main():
    for d in ASSET_DIRS:
        p = os.path.join(ROOT, d)
        if not os.path.isdir(p): fail('missing asset dir: ' + d)
    problems = []
    seen = {}
    for d in ASSET_DIRS:
        for dirpath, _, files in os.walk(os.path.join(ROOT, d)):
            for name in files:
                fp = os.path.join(dirpath, name)
                rel = os.path.relpath(fp, ROOT)
                ext = os.path.splitext(name)[1].lower()
                if ext in BAD_EXT: problems.append('unsupported file: ' + rel)
                if os.path.getsize(fp) > HUGE_LIMIT: problems.append('huge asset (>25MB): ' + rel)
                key = rel.lower()
                if key in seen: problems.append('case collision: %s vs %s' % (rel, seen[key]))
                else: seen[key] = rel
    if problems:
        for p_ in problems: print('ASSETS FAIL: ' + p_)
        sys.exit(1)
    print('ASSETS OK')

if __name__ == '__main__':
    main()
