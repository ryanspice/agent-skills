from __future__ import annotations

import argparse
import tarfile
from pathlib import Path, PurePosixPath


def is_safe_member(name: str) -> bool:
    p = PurePosixPath(name)
    if p.is_absolute():
        return False
    if ".." in p.parts:
        return False
    return True


def main() -> None:
    parser = argparse.ArgumentParser(description="Safely inspect/extract a tar/tar.gz into a target directory.")
    parser.add_argument("archive")
    parser.add_argument("target")
    parser.add_argument("--list", action="store_true", help="List members only")
    parser.add_argument("--extract", action="store_true", help="Extract after validation")
    args = parser.parse_args()

    archive = Path(args.archive).resolve()
    target = Path(args.target).resolve()

    if not archive.exists():
        raise SystemExit(f"archive not found: {archive}")

    with tarfile.open(archive, "r:*") as tf:
        members = tf.getmembers()
        unsafe = [m.name for m in members if not is_safe_member(m.name)]
        if unsafe:
            raise SystemExit("unsafe archive members:\n" + "\n".join(unsafe))

        for m in members:
            print(m.name)

        if args.extract:
            target.mkdir(parents=True, exist_ok=True)
            try:
                tf.extractall(target, filter="data")
            except TypeError:
                tf.extractall(target)
            print(f"Extracted to: {target}")
        elif not args.list:
            print("No extraction performed. Pass --extract to extract after validation.")


if __name__ == "__main__":
    main()
