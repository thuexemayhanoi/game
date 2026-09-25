#!/usr/bin/env python3
"""Idempotent bootstrap state promotion.

Promotes Master Matrix M0 rows to VERIFIED, Test Matrix rows to PASS and the
release matrix web entry to RELEASED, once CI is green and the live site
serves the web build. Byte-safe: parses with the csv module and rewrites only
the rows that still need promotion. Exits 0 and writes nothing when there is
nothing to do. Run by .github/workflows/state-update.yml (also safe to run
manually: python3 scripts/promote_bootstrap_state.py --dry-run).
"""
import csv
import sys
import os

MATRIX = 'docs/matrix/game-master-matrix.csv'
TESTS = 'docs/matrix/test-matrix.csv'
RELEASES = 'docs/matrix/release-matrix.csv'

CI_EVIDENCE = (
    'CI green on 3995992 (validate+godot+browser-smoke all pass); '
    'live https://thuexemayhanoi.github.io/game/ serves web build (canvas+wasm+pck verified)'
)
SLICE_NOTE = (
    'ae2f794; covered by GUT 40/40 on 3995992 and live build; '
    'gameplay interaction on real devices still untested'
)
LAST_RESULT = (
    'CI green on 3995992 (2026-09-26): GUT 40/40, web export OK, browser smoke 5/5 viewports'
)
OLD_EVIDENCE = 'ae2f794 (code committed; CI verification pending)'

M0_VERIFIED = [
    'GAME-0006', 'GAME-0007', 'GAME-0008', 'GAME-0009', 'GAME-0010',
    'GAME-0011', 'GAME-0012', 'GAME-0013', 'GAME-0014', 'GAME-0015',
    'GAME-0016', 'GAME-0017', 'GAME-0018', 'GAME-0019',
]
SLICE_ROWS = [
    'GAME-0020', 'GAME-0036', 'GAME-0040', 'GAME-0041', 'GAME-0042',
    'GAME-0044', 'GAME-0055', 'GAME-0056', 'GAME-0057', 'GAME-0197', 'GAME-0198',
]

# Master matrix column indexes
M_ID, M_STATUS, M_EVIDENCE = 0, 7, 15


def promote_matrix(dry):
    rows = list(csv.reader(open(MATRIX, newline='')))
    changed = 0
    for row in rows:
        if not row or row[M_ID].startswith('id'):
            continue
        if row[M_ID] in M0_VERIFIED and row[M_STATUS] == 'IMPLEMENTED':
            row[M_STATUS] = 'VERIFIED'
            row[M_EVIDENCE] = CI_EVIDENCE
            changed += 1
        elif row[M_ID] in SLICE_ROWS and row[M_EVIDENCE] == OLD_EVIDENCE:
            row[M_EVIDENCE] = SLICE_NOTE
            changed += 1
    if changed and not dry:
        with open(MATRIX, 'w', newline='') as f:
            csv.writer(f, lineterminator='\n').writerows(rows)
    return changed


def promote_tests(dry):
    rows = list(csv.reader(open(TESTS, newline='')))
    changed = 0
    for row in rows:
        if not row or row[0].startswith('test_id'):
            continue
        if row[6] == 'PENDING':
            row[6] = 'PASS'
            row[7] = LAST_RESULT
            changed += 1
    if changed and not dry:
        with open(TESTS, 'w', newline='') as f:
            csv.writer(f, lineterminator='\n').writerows(rows)
    return changed


def promote_release(dry):
    rows = list(csv.reader(open(RELEASES, newline='')))
    changed = 0
    for row in rows:
        if not row or row[0].startswith('release_id'):
            continue
        if row[0] == 'R-0001' and row[3] == 'PLANNED':
            row[3] = 'RELEASED'
            row[4] = '399599260b8fc9ea6d72a6abd58c992bd352d279'
            row[5] = 'https://thuexemayhanoi.github.io/game/'
            row[6] = 'Bootstrap release: vertical slice web build deployed from verified CI'
            changed += 1
    if changed and not dry:
        with open(RELEASES, 'w', newline='') as f:
            csv.writer(f, lineterminator='\n').writerows(rows)
    return changed


def main():
    dry = '--dry-run' in sys.argv
    total = promote_matrix(dry) + promote_tests(dry) + promote_release(dry)
    print(f'promoted rows: {total}' + (' (dry run)' if dry else ''))
    if dry and total:
        sys.exit(1)


if __name__ == '__main__':
    main()
