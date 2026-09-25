#!/usr/bin/env python3
"""Validate docs/matrix/game-master-matrix.csv (schema, IDs, statuses, deps, cycles)."""
import csv, sys, os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MATRIX = os.path.join(ROOT, 'docs', 'matrix', 'game-master-matrix.csv')
REQUIRED_COLS = ['id','milestone','system','feature','description','priority','dependencies',
                 'status','platforms','acceptance','test_required','performance_risk',
                 'save_impact','web_risk','mobile_risk','evidence','notes']
ALLOWED_STATUS = {'PLANNED','READY','IN_PROGRESS','IMPLEMENTED','QA_FAILED','BLOCKED','VERIFIED','DONE'}
ALLOWED_PRIO = {'P0','P1','P2','P3'}

def fail(msg):
    print('MATRIX FAIL: ' + msg); sys.exit(1)

def main():
    if not os.path.isfile(MATRIX): fail('matrix file missing: ' + MATRIX)
    with open(MATRIX, newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        if reader.fieldnames != REQUIRED_COLS: fail('columns mismatch: %r' % reader.fieldnames)
        rows = list(reader)
    if len(rows) < 250: fail('matrix has %d rows, need >= 250' % len(rows))
    ids, ids_set, errors = [], set(), []
    for r in rows:
        i = r['id']
        if not i.startswith('GAME-') or len(i) != 9 or not i[5:].isdigit():
            errors.append('bad id format: ' + i)
        if i in ids_set: errors.append('duplicate id: ' + i)
        ids.append(i); ids_set.add(i)
        if r['status'] not in ALLOWED_STATUS: errors.append('%s: bad status %s' % (i, r['status']))
        if r['priority'] not in ALLOWED_PRIO: errors.append('%s: bad priority %s' % (i, r['priority']))
        if not r['acceptance'].strip(): errors.append('%s: missing acceptance criteria' % i)
        if not r['platforms'].strip(): errors.append('%s: missing platforms' % i)
        if r['test_required'] not in ('yes','no'): errors.append('%s: bad test_required' % i)
        if not r['feature'].strip() or not r['description'].strip(): errors.append('%s: empty feature/description' % i)
    for r in rows:
        for d in filter(None, r['dependencies'].split(';')):
            if d not in ids_set: errors.append('%s: dependency %s does not exist' % (r['id'], d))
    # dependency ordering + cycle detection
    prev = {}
    for r in rows:
        for d in filter(None, r['dependencies'].split(';')):
            if d in prev and prev[d] > ids.index(r['id']):
                errors.append('forward dependency %s -> %s (possible cycle)' % (r['id'], d))
            prev[d] = ids.index(r['id'])
    if errors:
        for e in errors[:40]: print('MATRIX FAIL: ' + e)
        sys.exit(1)
    print('MATRIX OK: %d rows, unique ids, valid statuses, deps acyclic' % len(rows))

if __name__ == '__main__':
    main()
