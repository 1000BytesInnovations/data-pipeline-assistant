#!/usr/bin/env python3
"""
Simple script to fix common markdown issues that are failing pre-commit hooks.
"""

import os
import re
from pathlib import Path

def fix_markdown_file(file_path):
    """Fix common markdown issues in a file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # Fix missing blank lines around headings
    content = re.sub(r'\n(#{1,6} [^\n]+)\n([^#\n])', r'\n\1\n\n\2', content)
    content = re.sub(r'([^#\n])\n(#{1,6} [^\n]+)', r'\1\n\n\2', content)
    
    # Fix missing blank lines around lists
    content = re.sub(r'\n([*-] [^\n]+)', r'\n\n\1', content)
    content = re.sub(r'([*-] [^\n]+)\n([^*\-\n])', r'\1\n\n\2', content)
    
    # Fix missing blank lines around fenced code blocks
    content = re.sub(r'\n(```[^\n]*)\n', r'\n\n\1\n', content)
    content = re.sub(r'\n(```)\n([^`])', r'\n\1\n\n\2', content)
    
    # Remove multiple consecutive blank lines
    content = re.sub(r'\n{3,}', '\n\n', content)
    
    # Remove trailing punctuation from headings (except ? and !)
    content = re.sub(r'(#{1,6} [^:\n]+):(\s*\n)', r'\1\2', content)
    
    # Ensure file ends with single newline
    content = content.rstrip() + '\n'
    
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Fixed: {file_path}")
        return True
    
    return False

def main():
    """Fix markdown files in the repository."""
    repo_root = Path(__file__).parent
    markdown_files = list(repo_root.glob('**/*.md'))
    
    fixed_count = 0
    for md_file in markdown_files:
        if fix_markdown_file(md_file):
            fixed_count += 1
    
    print(f"Fixed {fixed_count} markdown files")

if __name__ == "__main__":
    main()
