#!/usr/bin/env python3
"""
Cleanup script to remove any temporary files created by SQLFluff.
This script removes any .sql files with random suffixes that SQLFluff might create.
"""

import os
import re
import sys


def cleanup_sqlfluff_temp_files(directory="."):
    """
    Find and remove SQLFluff temporary files.

    Args:
        directory: Root directory to search for temp files
    """
    removed_files = []

    # Pattern for SQLFluff temp files: original_file.sql + random_suffix.sql
    temp_pattern = re.compile(r"^(.+\.sql)[a-zA-Z0-9_]+\.sql$")

    for root, dirs, files in os.walk(directory):
        for file in files:
            if temp_pattern.match(file):
                # Check if the original file exists
                original_file = temp_pattern.sub(r"\1", file)
                original_path = os.path.join(root, original_file)
                temp_path = os.path.join(root, file)

                if os.path.exists(original_path):
                    print(f"Removing SQLFluff temp file: {temp_path}")
                    try:
                        os.remove(temp_path)
                        removed_files.append(temp_path)
                    except OSError as e:
                        print(f"Error removing {temp_path}: {e}")

    if removed_files:
        print(f"Cleaned up {len(removed_files)} SQLFluff temporary files")
    else:
        print("No SQLFluff temporary files found")

    return len(removed_files)


if __name__ == "__main__":
    directory = sys.argv[1] if len(sys.argv) > 1 else "."
    cleanup_sqlfluff_temp_files(directory)
