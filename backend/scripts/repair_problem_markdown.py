from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / 'src'
if str(SRC) not in sys.path:
    sys.path.insert(0, str(SRC))

from config import Settings
from core.db import get_connection
from services.analysis_service import AnalysisService


def main() -> int:
    parser = argparse.ArgumentParser(description='Repair fragmented math markdown in existing problems.')
    parser.add_argument('--problem-id', type=int, help='Only repair one specific problem id.')
    parser.add_argument('--apply', action='store_true', help='Persist changes to database.')
    args = parser.parse_args()

    settings = Settings()
    service = AnalysisService()
    connection = get_connection(settings.database_url)
    updated = 0

    try:
        with connection, connection.cursor() as cursor:
            if args.problem_id:
                cursor.execute('SELECT id, title, statement_markdown, examples_json FROM problems WHERE id = %s', (args.problem_id,))
            else:
                cursor.execute('SELECT id, title, statement_markdown, examples_json FROM problems ORDER BY id ASC')
            rows = cursor.fetchall()

            for row in rows:
                original = row['statement_markdown']
                repaired = service._repair_fragmented_math_markdown(original)
                _, examples = service._extract_examples_from_markdown(repaired)
                examples_json = json.dumps(examples, ensure_ascii=False)
                if repaired == original and row.get('examples_json') == examples_json:
                    continue

                print(f"[repair] problem #{row['id']} {row['title']}")
                print('--- repaired preview ---')
                print(repaired)
                print('--- end preview ---\n')
                print('--- extracted examples ---')
                print(examples_json)
                print('--- end examples ---\n')

                if args.apply:
                    cursor.execute(
                        'UPDATE problems SET statement_markdown = %s, examples_json = %s WHERE id = %s',
                        (repaired, examples_json, row['id']),
                    )
                updated += 1
    finally:
        connection.close()

    action = 'updated' if args.apply else 'previewed'
    print(f'{action} {updated} problem(s)')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
