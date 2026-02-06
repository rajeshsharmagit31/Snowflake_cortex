#!/usr/bin/env python3
import json
import gzip
import sys
from pathlib import Path


def load_json_lines(path: Path):
    items = []
    opener = path.open
    mode = "rt"
    # SnowSQL GET may download gzipped content with .json extension.
    with path.open("rb") as probe:
        magic = probe.read(2)
        if magic == b"\x1f\x8b":
            opener = gzip.open
            mode = "rt"

    with opener(path, mode) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            items.append(json.loads(line))
    return items


def to_tf(resources):
    tf = {
        "resource": {
            "snowflake_role": {},
            "snowflake_schema_grant": {}
        }
    }

    for idx, r in enumerate(resources):
        role_raw = r.get("role") or r.get("create_role")
        if not role_raw:
            raise ValueError("Missing role/create_role in approved request")
        role = role_raw.upper()
        database = r["database"].upper()
        schema_name = (r.get("schema_name") or "PUBLIC").upper()
        privileges = r.get("privileges") or ["USAGE"]

        create_role = r.get("create_role")
        if create_role:
            role_name = create_role.upper()
            tf["resource"]["snowflake_role"][f"role_{idx}"] = {
                "name": role_name
            }
            # If role to grant wasn't provided explicitly, use the created role.
            if not r.get("role"):
                role = role_name

        for p_idx, privilege in enumerate(privileges):
            name = f"schema_grant_{idx}_{p_idx}"
            tf["resource"]["snowflake_schema_grant"][name] = {
                "database_name": database,
                "schema_name": schema_name,
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
