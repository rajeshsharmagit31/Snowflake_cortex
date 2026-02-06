#!/usr/bin/env python3
import json
import sys
from pathlib import Path


def load_json_lines(path: Path):
    items = []
    with path.open() as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            items.append(json.loads(line))
    return items


def to_tf(resources):
    tf = {
        "resource": {
            "snowflake_database_grant": {}
        }
    }

    for idx, r in enumerate(resources):
        role = r["role"].upper()
        database = r["database"].upper()
        privileges = r.get("privileges") or ["USAGE"]

        for p_idx, privilege in enumerate(privileges):
            name = f"grant_{idx}_{p_idx}"
            tf["resource"]["snowflake_database_grant"][name] = {
                "database_name": database,
                "privilege": privilege.upper(),
                "roles": [role],
            }

    return tf


def main():
    if len(sys.argv) != 3:
        print("usage: requests_to_tf.py <approved_requests.json> <output.tf.json>")
        return 2

    src = Path(sys.argv[1])
    dst = Path(sys.argv[2])

    items = load_json_lines(src)
    tf = to_tf(items)

    dst.write_text(json.dumps(tf, indent=2) + "\n")
    print(f"Wrote {dst}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
