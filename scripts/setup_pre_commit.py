#!/usr/bin/env python3
"""
Pre-commit Setup Script for Data Pipeline Assistant

This script sets up pre-commit hooks for the Oracle to dbt migration project.
"""

import os
import subprocess
import sys


def run_command(command, description):
    """Run a command and handle errors."""
    print(f"🔄 {description}...")
    try:
        result = subprocess.run(
            command, shell=True, check=True, capture_output=True, text=True
        )
        print(f"✅ {description} completed successfully")
        if result.stdout:
            print(f"   Output: {result.stdout.strip()}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ {description} failed")
        print(f"   Error: {e.stderr.strip()}")
        return False


def check_python_version():
    """Check if Python version is compatible."""
    version = sys.version_info
    if version.major < 3 or (version.major == 3 and version.minor < 8):
        print("❌ Python 3.8 or higher is required for pre-commit")
        return False
    print(f"✅ Python {version.major}.{version.minor}.{version.micro} is compatible")
    return True


def install_pre_commit():
    """Install pre-commit if not already installed."""
    try:
        subprocess.run(["pre-commit", "--version"], check=True, capture_output=True)
        print("✅ pre-commit is already installed")
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("📦 Installing pre-commit...")
        return run_command("pip install pre-commit", "Installing pre-commit")


def setup_pre_commit_hooks():
    """Set up pre-commit hooks."""
    commands = [
        ("pre-commit install", "Installing pre-commit hooks"),
        (
            "pre-commit install --hook-type commit-msg",
            "Installing commit message hooks",
        ),
        ("pre-commit autoupdate", "Updating hook repositories"),
    ]

    for command, description in commands:
        if not run_command(command, description):
            return False

    return True


def validate_configuration():
    """Validate pre-commit configuration."""
    if not os.path.exists(".pre-commit-config.yaml"):
        print("❌ .pre-commit-config.yaml not found")
        return False

    print("🔍 Validating pre-commit configuration...")
    return run_command("pre-commit validate-config", "Validating configuration")


def run_initial_check():
    """Run pre-commit on all files for initial setup."""
    print("🧪 Running initial pre-commit check on all files...")
    print("   (This may take a while for the first run as it downloads dependencies)")

    # Run with --all-files but don't fail if there are issues
    result = subprocess.run(
        ["pre-commit", "run", "--all-files"], capture_output=True, text=True
    )

    if result.returncode == 0:
        print("✅ All pre-commit checks passed!")
    else:
        print(
            "⚠️  Some pre-commit checks found issues (this is normal for initial setup)"
        )
        print("   The hooks will fix many issues automatically on commit")
        if result.stdout:
            print(f"   Output: {result.stdout[-500:]}")  # Show last 500 chars

    return True


def create_git_hooks_info():
    """Create information about git hooks."""
    info_content = """# Pre-commit Hooks Information

This project uses pre-commit hooks to ensure code quality and consistency.

## What happens on commit:

1. **Code Formatting**: Automatically formats Python, SQL, and Markdown files
2. **Linting**: Checks for code quality issues and best practices
3. **dbt Validation**: Ensures dbt models follow naming conventions and have proper documentation
4. **Oracle Migration Checks**: Validates Oracle package structure and macro coverage

## Manual Commands:

- Run hooks on all files: `pre-commit run --all-files`
- Run specific hook: `pre-commit run <hook-name>`
- Update hook versions: `pre-commit autoupdate`
- Skip hooks for a commit: `git commit --no-verify`

## Installed Hooks:

- General: trailing-whitespace, end-of-file-fixer, check-yaml, check-json
- SQL: SQLFluff linting and formatting (Snowflake dialect)
- Python: Black formatting, isort imports, Flake8 linting
- dbt: Model validation, documentation checks, compilation tests
- Markdown: MarkdownLint formatting
- Oracle: Package structure validation, naming conventions, macro coverage

## Configuration Files:

- `.pre-commit-config.yaml`: Main pre-commit configuration
- `.sqlfluff`: SQL linting rules for dbt/Snowflake
- `.markdownlint.json`: Markdown formatting rules
- `scripts/validate_*.py`: Custom validation scripts for Oracle migration

## Troubleshooting:

If hooks fail:
1. Review the error messages - many issues are auto-fixed
2. Run `git add .` to stage auto-fixes, then commit again
3. For persistent issues, check the specific tool documentation
4. Use `git commit --no-verify` only as a last resort

The hooks are designed to maintain high code quality for Oracle to dbt migrations.
"""

    with open(".git-hooks-info.md", "w") as f:
        f.write(info_content)

    print("📝 Created .git-hooks-info.md with usage information")


def main():
    """Main setup function."""
    print("🚀 Setting up pre-commit hooks for Data Pipeline Assistant")
    print("=" * 60)

    # Check prerequisites
    if not check_python_version():
        sys.exit(1)

    # Install pre-commit
    if not install_pre_commit():
        sys.exit(1)

    # Validate configuration
    if not validate_configuration():
        sys.exit(1)

    # Setup hooks
    if not setup_pre_commit_hooks():
        sys.exit(1)

    # Run initial check
    run_initial_check()

    # Create information file
    create_git_hooks_info()

    print("\n" + "=" * 60)
    print("🎉 Pre-commit hooks setup completed successfully!")
    print("\nNext steps:")
    print("1. Review any auto-fixed files and commit them")
    print("2. Read .git-hooks-info.md for usage information")
    print("3. The hooks will now run automatically on every commit")
    print("\n💡 Tip: Run 'pre-commit run --all-files' to test all hooks now")


if __name__ == "__main__":
    main()
