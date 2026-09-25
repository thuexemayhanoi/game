#!/usr/bin/env python3
"""Validate the save schema definition (src/data/save_schema.json)."""
import json, os, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SCHEMA = os.path.join(ROOT, 'src', 'data', 'save_schema.json')
REQUIRED = ['save_version','profile','wallet','bikes','upgrades','mission_progress',
            'world_unlocks','settings','achievements','statistics']

def fail(msg):
    print('SAVE FAIL: ' + msg); sys.exit(1)

def main():
    if not os.path.isfile(SCHEMA): fail('missing src/data/save_schema.json')
    with open(SCHEMA, encoding='utf-8') as f:
        s = json.load(f)
    if 'save_version' not in s or not isinstance(s['save_version'], int):
        fail('save_version missing or not int')
    for k in REQUIRED:
        if k not in s: fail('schema missing key: ' + k)
    if not isinstance(s.get('migrations'), list):
        fail('migrations must be a list')
    print('SAVE SCHEMA OK (version %d)' % s['save_version'])

if __name__ == '__main__':
    main()
