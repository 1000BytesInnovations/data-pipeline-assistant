#!/usr/bin/env python3
"""
dbt Model Naming Convention Validator

This script validates that dbt models follow the established naming conventions
for the Oracle to dbt migration project.
"""

import os
import sys
import re
from pathlib import Path


def validate_model_naming(file_path):
    """Validate dbt model naming conventions."""
    errors = []
    
    # Get the model name and directory
    model_path = Path(file_path)
    model_name = model_path.stem
    directory = model_path.parent.name
    
    # Naming conventions based on directory
    naming_rules = {
        'staging': {
            'pattern': r'^stg_[a-z0-9_]+$',
            'description': 'Staging models should start with "stg_" followed by lowercase letters, numbers, and underscores'
        },
        'intermediate': {
            'pattern': r'^int_[a-z0-9_]+$',
            'description': 'Intermediate models should start with "int_" followed by lowercase letters, numbers, and underscores'
        },
        'marts': {
            'pattern': r'^[a-z0-9_]+$',
            'description': 'Mart models should use lowercase letters, numbers, and underscores (no prefix)'
        },
        'oracle_packages': {
            'pattern': r'^oracle_pkg_[a-z0-9_]+$',
            'description': 'Oracle package models should start with "oracle_pkg_" followed by lowercase letters, numbers, and underscores'
        }
    }
    
    # Check if directory has naming rules
    if directory in naming_rules:
        rule = naming_rules[directory]
        if not re.match(rule['pattern'], model_name):
            errors.append(f"Model '{model_name}' in '{directory}' directory violates naming convention: {rule['description']}")
    
    # General naming rules
    if not model_name.islower():
        errors.append(f"Model name '{model_name}' should be lowercase")
    
    if ' ' in model_name:
        errors.append(f"Model name '{model_name}' should not contain spaces")
    
    if model_name.startswith('_') or model_name.endswith('_'):
        errors.append(f"Model name '{model_name}' should not start or end with underscore")
    
    if '__' in model_name:
        errors.append(f"Model name '{model_name}' should not contain double underscores")
    
    # Check for reserved keywords
    reserved_words = ['select', 'from', 'where', 'group', 'order', 'having', 'union', 'join']
    if model_name.lower() in reserved_words:
        errors.append(f"Model name '{model_name}' conflicts with SQL reserved word")
    
    return errors


def validate_file_content(file_path):
    """Validate the content structure of dbt models."""
    errors = []
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        errors.append(f"Could not read file {file_path}: {e}")
        return errors
    
    # Check for basic dbt patterns
    if '{{ ref(' not in content and '{{ source(' not in content:
        # Skip this check for oracle_packages as they might be conversion templates
        if 'oracle_packages' not in file_path:
            errors.append(f"Model should use {{ ref() }} or {{ source() }} for dependencies")
    
    # Check for config block for materialization
    if 'marts' in file_path and '{{ config(' not in content:
        errors.append(f"Mart models should have {{ config() }} block for materialization")
    
    # Check for proper Jinja formatting
    jinja_blocks = re.findall(r'{{.*?}}', content, re.DOTALL)
    for block in jinja_blocks:
        if not block.strip().startswith('{{') or not block.strip().endswith('}}'):
            errors.append(f"Malformed Jinja block found: {block[:50]}...")
    
    return errors


def main():
    """Main validation function."""
    if len(sys.argv) < 2:
        print("Usage: validate_dbt_naming.py <file_paths...>")
        sys.exit(1)
    
    all_errors = []
    
    for file_path in sys.argv[1:]:
        if file_path.endswith('.sql'):
            # Validate naming conventions
            naming_errors = validate_model_naming(file_path)
            all_errors.extend([f"{file_path}: {error}" for error in naming_errors])
            
            # Validate file content
            content_errors = validate_file_content(file_path)
            all_errors.extend([f"{file_path}: {error}" for error in content_errors])
    
    if all_errors:
        print("dbt model naming validation failed:")
        for error in all_errors:
            print(f"  ❌ {error}")
        sys.exit(1)
    else:
        print("✅ dbt model naming validation passed")
        sys.exit(0)


if __name__ == "__main__":
    main()
