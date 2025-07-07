# Quick Test Script for PKG_SSP_TANK_DETAIL Snowflake Setup
# Date: July 7, 2025
# Purpose: Demonstrate how to quickly set up and test the source tables

Write-Host "🚀 PKG_SSP_TANK_DETAIL - Quick Setup & Test" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

# Display available scripts
Write-Host ""
Write-Host "📋 Available Scripts:" -ForegroundColor Cyan
Write-Host "1. create_snowflake_sources.ps1 - Create source tables" -ForegroundColor Gray
Write-Host "2. verify_snowflake_sources.ps1 - Verify tables exist" -ForegroundColor Gray
Write-Host "3. setup_snowflake_env.ps1 - Full environment setup" -ForegroundColor Gray
Write-Host "4. test_pipeline.ps1 - Test dbt pipeline" -ForegroundColor Gray

Write-Host ""
Write-Host "📁 Available DDL Files:" -ForegroundColor Cyan
Write-Host "1. ddl/create_source_tables.sql - Original DDL" -ForegroundColor Gray
Write-Host "2. ddl/create_source_tables_fixed.sql - Enhanced DDL (recommended)" -ForegroundColor Gray

Write-Host ""
Write-Host "🎯 Quick Start Commands:" -ForegroundColor Yellow
Write-Host ""

# Method 1: Using the new script
Write-Host "Method 1 - Using the new creation script:" -ForegroundColor Cyan
Write-Host "# Replace 'your_account', 'your_user', 'your_password' with actual values" -ForegroundColor Gray
Write-Host '.\create_snowflake_sources.ps1 -SnowflakeAccount "your_account" -SnowflakeUser "your_user" -SnowflakePassword "your_password" -UseFixed' -ForegroundColor White

Write-Host ""
Write-Host "Method 2 - Test connection first:" -ForegroundColor Cyan
Write-Host '.\create_snowflake_sources.ps1 -SnowflakeAccount "your_account" -SnowflakeUser "your_user" -SnowflakePassword "your_password" -TestConnection' -ForegroundColor White

Write-Host ""
Write-Host "Method 3 - Verify existing setup:" -ForegroundColor Cyan
Write-Host '.\verify_snowflake_sources.ps1 -SnowflakeAccount "your_account" -SnowflakeUser "your_user" -SnowflakePassword "your_password"' -ForegroundColor White

Write-Host ""
Write-Host "Method 4 - Full pipeline test:" -ForegroundColor Cyan
Write-Host "# First set environment variables:" -ForegroundColor Gray
Write-Host '.\setup_snowflake_env.ps1 -SnowflakeAccount "your_account" -SnowflakeUser "your_user" -SnowflakePassword "your_password"' -ForegroundColor White
Write-Host "# Then run the full test:" -ForegroundColor Gray
Write-Host '.\test_pipeline.ps1' -ForegroundColor White

Write-Host ""
Write-Host "📖 Documentation:" -ForegroundColor Yellow
Write-Host "- SNOWFLAKE_SETUP_GUIDE.md - Complete setup guide" -ForegroundColor Gray
Write-Host "- README.md - Project overview" -ForegroundColor Gray
Write-Host "- AI_ASSISTANT_GUIDE.md - Assistant instructions" -ForegroundColor Gray

Write-Host ""
Write-Host "🔧 What Gets Created:" -ForegroundColor Yellow
Write-Host "Database: ANALYTICS_DEV" -ForegroundColor Gray
Write-Host "Schema: LND_MANUAL_ENTRY" -ForegroundColor Gray
Write-Host "Table: SSP_RR_CALENDAR (36 test records)" -ForegroundColor Gray
Write-Host "  - Years 2023-2025" -ForegroundColor Gray
Write-Host "  - All months (12 per year)" -ForegroundColor Gray
Write-Host "  - 35 active records, 1 inactive (for testing)" -ForegroundColor Gray

Write-Host ""
Write-Host "🧪 dbt Models to Test:" -ForegroundColor Yellow
Write-Host "Staging:" -ForegroundColor Gray
Write-Host "  - stg_ssp_rr_calendar" -ForegroundColor Gray
Write-Host "Intermediate:" -ForegroundColor Gray
Write-Host "  - int_tank_detail_source_validation" -ForegroundColor Gray
Write-Host "  - int_tank_detail_blend_expression" -ForegroundColor Gray
Write-Host "  - int_tank_detail_by_application" -ForegroundColor Gray
Write-Host "  - int_tank_detail_by_variety" -ForegroundColor Gray
Write-Host "Oracle Package:" -ForegroundColor Gray
Write-Host "  - oracle_pkg_tank_detail_pipeline" -ForegroundColor Gray
Write-Host "Marts:" -ForegroundColor Gray
Write-Host "  - tank_detail_consolidated" -ForegroundColor Gray
Write-Host "  - tank_detail_bima" -ForegroundColor Gray

Write-Host ""
Write-Host "⚡ Quick Test After Setup:" -ForegroundColor Yellow
Write-Host "cd dbt_project" -ForegroundColor White
Write-Host "dbt debug" -ForegroundColor White
Write-Host "dbt run --models pkg_ssp_tank_detail" -ForegroundColor White
Write-Host "dbt test --models pkg_ssp_tank_detail" -ForegroundColor White

Write-Host ""
Write-Host "🤝 Need Help?" -ForegroundColor Yellow
Write-Host "1. Check SNOWFLAKE_SETUP_GUIDE.md for detailed instructions" -ForegroundColor Gray
Write-Host "2. Use -TestConnection parameter to verify your credentials" -ForegroundColor Gray
Write-Host "3. Review error messages for specific troubleshooting" -ForegroundColor Gray
Write-Host "4. Ensure you have proper Snowflake permissions" -ForegroundColor Gray

Write-Host ""
Write-Host "🎉 Ready to get started? Pick a method above and replace the placeholder values!" -ForegroundColor Green
