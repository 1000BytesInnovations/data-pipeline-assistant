#!/usr/bin/env python3
"""
Oracle Function Macro Coverage Checker

This script checks that Oracle functions used in dbt models have corresponding
macros in the macros/oracle_utils directory.
"""

import os
import sys
import re
import glob
from pathlib import Path


def get_oracle_macros():
    """Get list of available Oracle utility macros."""
    macros = {}
    macro_dir = "dbt_project/macros/oracle_utils"
    
    if not os.path.exists(macro_dir):
        return macros
    
    for macro_file in glob.glob(f"{macro_dir}/*.sql"):
        with open(macro_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Extract macro names
        macro_matches = re.findall(r'{%\s*macro\s+(\w+)\s*\(', content, re.IGNORECASE)
        for macro_name in macro_matches:
            macros[macro_name.lower()] = macro_file
    
    return macros


def find_oracle_functions_in_model(file_path):
    """Find Oracle functions used in a dbt model."""
    oracle_functions = []
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception:
        return oracle_functions
    
    # Common Oracle functions that need macro equivalents
    oracle_func_patterns = [
        r'\bNVL\s*\(',
        r'\bNVL2\s*\(',
        r'\bDECODE\s*\(',
        r'\bTO_DATE\s*\(',
        r'\bTO_CHAR\s*\(',
        r'\bTO_NUMBER\s*\(',
        r'\bTRUNC\s*\(',
        r'\bROWNUM\b',
        r'\bSYSDATE\b',
        r'\bSUBSTR\s*\(',
        r'\bINSTR\s*\(',
        r'\bLENGTH\s*\(',
        r'\bLTRIM\s*\(',
        r'\bRTRIM\s*\(',
        r'\bUPPER\s*\(',
        r'\bLOWER\s*\(',
        r'\bCONCAT\s*\(',
        r'\bMOD\s*\(',
        r'\bROUND\s*\(',
        r'\bCEIL\s*\(',
        r'\bFLOOR\s*\(',
        r'\bABS\s*\(',
    ]
    
    for pattern in oracle_func_patterns:
        matches = re.findall(pattern, content, re.IGNORECASE)
        for match in matches:
            func_name = match.replace('(', '').strip()
            if func_name not in oracle_functions:
                oracle_functions.append(func_name.lower())
    
    return oracle_functions


def check_macro_coverage(file_path, available_macros):
    """Check if Oracle functions in the model have macro coverage."""
    errors = []
    oracle_functions = find_oracle_functions_in_model(file_path)
    
    # Map Oracle functions to expected macro names
    function_to_macro = {
        'nvl': 'nvl',
        'nvl2': 'nvl2',
        'decode': 'decode',
        'to_date': 'oracle_to_date',
        'to_char': 'oracle_to_char',
        'to_number': 'oracle_to_number',
        'trunc': 'oracle_trunc',
        'rownum': 'oracle_rownum',
        'sysdate': 'oracle_sysdate',
        'substr': 'oracle_substr',
        'instr': 'oracle_instr',
        'length': 'oracle_length',
        'ltrim': 'oracle_ltrim',
        'rtrim': 'oracle_rtrim',
        'upper': 'oracle_upper',
        'lower': 'oracle_lower',
        'concat': 'oracle_concat',
        'mod': 'oracle_mod',
        'round': 'oracle_round',
        'ceil': 'oracle_ceil',
        'floor': 'oracle_floor',
        'abs': 'oracle_abs',
    }
    
    for func in oracle_functions:
        expected_macro = function_to_macro.get(func)
        if expected_macro and expected_macro not in available_macros:
            errors.append(f"Oracle function '{func.upper()}' used but no corresponding macro '{expected_macro}' found")
        elif not expected_macro:
            errors.append(f"Oracle function '{func.upper()}' found but no macro mapping defined")
    
    return errors


def suggest_macro_creation(missing_functions):
    """Suggest macro creation for missing Oracle functions."""
    suggestions = []
    
    for func in missing_functions:
        suggestions.append(f"""
-- Create macro for {func.upper()}
-- File: dbt_project/macros/oracle_utils/{func.lower()}.sql
{{% macro {func.lower()}(arg1, arg2=None) %}}
  -- Add Snowflake equivalent for Oracle {func.upper()} function
  -- Example implementation needed
{{% endmacro %}}
""")
    
    return suggestions


def main():
    """Main validation function."""
    if len(sys.argv) < 2:
        print("Usage: check_oracle_macro_coverage.py <file_paths...>")
        sys.exit(1)
    
    # Get available macros
    available_macros = get_oracle_macros()
    
    all_errors = []
    missing_functions = set()
    
    for file_path in sys.argv[1:]:
        if file_path.endswith('.sql'):
            coverage_errors = check_macro_coverage(file_path, available_macros)
            all_errors.extend([f"{file_path}: {error}" for error in coverage_errors])
            
            # Extract missing function names for suggestions
            for error in coverage_errors:
                if "no corresponding macro" in error:
                    func_match = re.search(r"function '(\w+)'", error)
                    if func_match:
                        missing_functions.add(func_match.group(1).lower())
    
    if all_errors:
        print("Oracle macro coverage validation failed:")
        for error in all_errors:
            print(f"  ❌ {error}")
        
        if missing_functions:
            print("\n📝 Suggestions for missing macros:")
            suggestions = suggest_macro_creation(missing_functions)
            for suggestion in suggestions:
                print(suggestion)
        
        print(f"\n💡 Available macros: {', '.join(available_macros.keys())}")
        sys.exit(1)
    else:
        print("✅ Oracle macro coverage validation passed")
        if available_macros:
            print(f"📋 Available Oracle utility macros: {', '.join(available_macros.keys())}")
        sys.exit(0)


if __name__ == "__main__":
    main()
