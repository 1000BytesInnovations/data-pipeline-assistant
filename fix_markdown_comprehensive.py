#!/usr/bin/env python3
"""
Comprehensive markdown formatting fix script for all markdown files in the project.
This script addresses common markdownlint issues:
- MD031: Fenced code blocks should be surrounded by blank lines
- MD032: Lists should be surrounded by blank lines
- MD040: Fenced code blocks should have a language specified
- MD036: Emphasis used instead of a heading
- MD013: Line length
- MD034: Bare URLs
"""

import os
import re
import sys
from pathlib import Path

def fix_markdown_file(file_path):
    """Fix markdown formatting issues in a single file."""
    
    print(f"Processing {file_path}...")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # Fix MD031: Fenced code blocks should be surrounded by blank lines
    # Add blank line before code blocks
    content = re.sub(r'([^\n])\n(```)', r'\1\n\n\2', content)
    # Add blank line after code blocks
    content = re.sub(r'(```[^\n]*)\n([^\n`])', r'\1\n\n\2', content)
    
    # Fix MD032: Lists should be surrounded by blank lines
    # Add blank line before lists
    content = re.sub(r'([^\n])\n(\d+\.\s)', r'\1\n\n\2', content)
    content = re.sub(r'([^\n])\n([*-]\s)', r'\1\n\n\2', content)
    # Add blank line after lists
    content = re.sub(r'(\d+\.\s[^\n]*)\n([^\n\d*-])', r'\1\n\n\2', content)
    content = re.sub(r'([*-]\s[^\n]*)\n([^\n*-])', r'\1\n\n\2', content)
    
    # Fix MD040: Add language to fenced code blocks without language
    # Pattern: ```\n followed by content (not another ```)
    content = re.sub(r'```\n(?!```)', r'```bash\n', content)
    
    # Fix MD036: Convert emphasis to headings where appropriate
    # Convert **text** at start of line to ### text
    content = re.sub(r'^(\*\*([^*]+)\*\*)$', r'### \2', content, flags=re.MULTILINE)
    
    # Fix MD034: Bare URLs - wrap in angle brackets
    # Find URLs not already in brackets or markdown links
    url_pattern = r'(?<!\[)(?<!\()https?://[^\s\)]+(?!\))'
    content = re.sub(url_pattern, r'<\g<0>>', content)
    
    # Fix MD013: Line length - break long lines at reasonable points
    lines = content.split('\n')
    fixed_lines = []
    
    for line in lines:
        if len(line) > 120 and not line.strip().startswith('#') and not line.strip().startswith('|'):
            # Try to break at reasonable points
            if ' - ' in line:
                # Break at list separators
                parts = line.split(' - ')
                if len(parts) > 1:
                    fixed_lines.append(parts[0])
                    for part in parts[1:]:
                        fixed_lines.append('  - ' + part)
                else:
                    fixed_lines.append(line)
            else:
                fixed_lines.append(line)
        else:
            fixed_lines.append(line)
    
    content = '\n'.join(fixed_lines)
    
    # Clean up multiple blank lines
    content = re.sub(r'\n\n\n+', '\n\n', content)
    
    # Ensure file ends with single newline
    content = content.rstrip() + '\n'
    
    # Only write if content changed
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"  ✓ Fixed {file_path}")
        return True
    else:
        print(f"  - No changes needed for {file_path}")
        return False

def main():
    """Main function to process all markdown files."""
    
    # Get the project root directory
    project_root = Path(__file__).parent
    
    # Find all markdown files
    md_files = []
    for root, dirs, files in os.walk(project_root):
        # Skip .git directories
        dirs[:] = [d for d in dirs if d != '.git']
        
        for file in files:
            if file.endswith('.md'):
                md_files.append(os.path.join(root, file))
    
    print(f"Found {len(md_files)} markdown files to process")
    
    fixed_count = 0
    for md_file in md_files:
        if fix_markdown_file(md_file):
            fixed_count += 1
    
    print(f"\nProcessing complete!")
    print(f"Fixed {fixed_count} out of {len(md_files)} files")

if __name__ == '__main__':
    main()
