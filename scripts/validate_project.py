#!/usr/bin/env python3
"""Validate overall project structure, matrices, and state files."""
import json, os, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REQUIRED = [
    'README.md','project.godot','export_presets.cfg','.gitignore',
    'docs/GAME-DESIGN.md','docs/ARCHITECTURE.md','docs/WORKFLOW.md','docs/TESTING.md',
    'docs/PERFORMANCE.md','docs/PLATFORMS.md','docs/SAVE-SYSTEM.md','docs/ASSET-POLICY.md',
    'docs/RELEASE-PLAN.md','docs/AI-AGENT-RULES.md',
    'docs/matrix/game-master-matrix.csv','docs/matrix/test-matrix.csv','docs/matrix/release-matrix.csv',
    'docs/state/active-work.json','docs/state/milestone-status.md',
    'scripts/validate_matrix.py','scripts/validate_assets.py','scripts/validate_save_schema.py',
    'scripts/check_build_budget.py','.github/workflows/ci.yml','.github/workflows/pages.yml',
    'src/core','src/player','src/vehicles','src/world','src/traffic','src/npc','src/police',
    'src/missions','src/economy','src/progression','src/ui','src/audio','src/platform','src/data',
    'tests/unit','tests/integration','tests/smoke','tests/fixtures',
]
ACTIVE_KEYS = ['repository','feature_id','run_id','status','started_at','last_checkpoint',
               'start_commit','checkpoint_commit','attempt','notes']

def fail(msg):
    print('PROJECT FAIL: ' + msg); sys.exit(1)

def main():
    missing = [p for p in REQUIRED if not os.path.exists(os.path.join(ROOT, p))]
    if missing: fail('missing required paths: %s' % ', '.join(missing))
    # active-work schema
    with open(os.path.join(ROOT, 'docs/state/active-work.json'), encoding='utf-8') as f:
        aw = json.load(f)
    for k in ACTIVE_KEYS:
        if k not in aw: fail('active-work.json missing key: ' + k)
    if aw.get('repository') != 'thuexemayhanoi/game': fail('active-work.json wrong repository')
    # run matrix validator
    r = subprocess.run([sys.executable, os.path.join(ROOT, 'scripts/validate_matrix.py')])
    if r.returncode != 0: fail('matrix validation failed')
    # test-matrix feature ids must exist
    import csv
    with open(os.path.join(ROOT, 'docs/matrix/game-master-matrix.csv'), encoding='utf-8') as f:
        game_ids = {row['id'] for row in csv.DictReader(f)}
    with open(os.path.join(ROOT, 'docs/matrix/test-matrix.csv'), encoding='utf-8') as f:
        for row in csv.DictReader(f):
            if row['feature_id'] not in game_ids:
                fail('test-matrix references unknown feature: ' + row['feature_id'])
            if not os.path.isfile(os.path.join(ROOT, row['test_file'])) and row['test_file'] != 'ci.yml':
                fail('test-matrix test_file missing on disk: ' + row['test_file'])
    print('PROJECT OK')

if __name__ == '__main__':
    main()
