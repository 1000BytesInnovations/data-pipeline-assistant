#!/usr/bin/env python3
"""
Oracle Package Structure Validator

This script validates that Oracle package conversions follow the expected structure
and maintain proper documentation for the data pipeline assistant.
"""

import os
import sys
import yaml
import glob
from pathlib import Path


def validate_oracle_structure(oracle_packages_dir):
    """Validate Oracle package structure and documentation."""
    errors = []
    
    # Check if README.md exists
    readme_path = os.path.join(oracle_packages_dir, "README.md")
    if not os.path.exists(readme_path):
        errors.append("Missing README.md in oracle_packages directory")
    
    # Check for source_code directory
    source_code_dir = os.path.join(oracle_packages_dir, "source_code")
    if not os.path.exists(source_code_dir):
        errors.append("Missing source_code directory in oracle_packages")
    
    # Check for analysis directory
    analysis_dir = os.path.join(oracle_packages_dir, "analysis")
    if not os.path.exists(analysis_dir):
        errors.append("Missing analysis directory in oracle_packages")
    
    # Check for views directory
    views_dir = os.path.join(oracle_packages_dir, "views")
    if not os.path.exists(views_dir):
        errors.append("Missing views directory in oracle_packages")
    else:
        views_readme = os.path.join(views_dir, "README.md")
        if not os.path.exists(views_readme):
            errors.append("Missing README.md in oracle_packages/views directory")
    
    # Check if analysis has conversion summary
    if os.path.exists(analysis_dir):
        conversion_summary = os.path.join(analysis_dir, "conversion_summary.md")
        if not os.path.exists(conversion_summary):
            errors.append("Missing conversion_summary.md in analysis directory")
    
    return errors


def validate_package_files():
    """Validate Oracle package files have proper structure."""
    errors = []
    
    # Find all Oracle package files
    package_files = glob.glob("oracle_packages/**/*.sql", recursive=True)
    
    for package_file in package_files:
        with open(package_file, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Check if file has header comment
        if not content.strip().startswith('--'):
            errors.append(f"Oracle package {package_file} missing header comment")
            
        # Check for basic Oracle keywords that should be documented
        if 'PACKAGE' in content.upper() and 'PROCEDURE' in content.upper():
            if '-- Purpose:' not in content and '-- Description:' not in content:
                errors.append(f"Oracle package {package_file} missing purpose/description comment")
    
    return errors


def main():
    """Main validation function."""
    if len(sys.argv) < 2:
        print("Usage: validate_oracle_structure.py <file_paths...>")
        sys.exit(1)
    
    all_errors = []
    
    # Get the oracle_packages directory
    oracle_packages_dir = "oracle_packages"
    if os.path.exists(oracle_packages_dir):
        structure_errors = validate_oracle_structure(oracle_packages_dir)
        all_errors.extend(structure_errors)
    
    # Validate package files
    package_errors = validate_package_files()
    all_errors.extend(package_errors)
    
    if all_errors:
        print("Oracle package structure validation failed:")
        for error in all_errors:
            print(f"  ❌ {error}")
        sys.exit(1)
    else:
        print("✅ Oracle package structure validation passed")
        sys.exit(0)


if __name__ == "__main__":
    main()
