# Create Snowflake Source Tables for PKG_SSP_TANK_DETAIL Testing
# Date: July 7, 2025
# Purpose: Set up source tables in Snowflake for testing the dbt models

param(
    [string]$SnowflakeAccount,
    [string]$SnowflakeUser,
    [string]$SnowflakePassword,
    [string]$SnowflakeRole = "TRANSFORMER",
    [string]$SnowflakeDatabase = "ANALYTICS_DEV",
    [string]$SnowflakeWarehouse = "COMPUTE_WH",
    [switch]$UseFixed = $false,
    [switch]$TestConnection = $false
)

Write-Host "🗄️  Creating Snowflake Source Tables for PKG_SSP_TANK_DETAIL" -ForegroundColor Green
Write-Host "=============================================================" -ForegroundColor Green

# Check if parameters are provided
if (-not $SnowflakeAccount -or -not $SnowflakeUser -or -not $SnowflakePassword) {
    Write-Host "❌ Missing required parameters!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\create_snowflake_sources.ps1 -SnowflakeAccount 'your_account' -SnowflakeUser 'your_user' -SnowflakePassword 'your_password'" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Optional parameters:" -ForegroundColor Yellow
    Write-Host "  -SnowflakeRole (default: TRANSFORMER)" -ForegroundColor Gray
    Write-Host "  -SnowflakeDatabase (default: ANALYTICS_DEV)" -ForegroundColor Gray
    Write-Host "  -SnowflakeWarehouse (default: COMPUTE_WH)" -ForegroundColor Gray
    Write-Host "  -UseFixed (use create_source_tables_fixed.sql instead of create_source_tables.sql)" -ForegroundColor Gray
    Write-Host "  -TestConnection (just test connection without running DDL)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Example:" -ForegroundColor Yellow
    Write-Host "  .\create_snowflake_sources.ps1 -SnowflakeAccount 'abc123.snowflakecomputing.com' -SnowflakeUser 'myuser' -SnowflakePassword 'mypass' -UseFixed" -ForegroundColor Cyan
    exit 1
}

# Display configuration
Write-Host "📋 Configuration:" -ForegroundColor Cyan
Write-Host "  Account: $SnowflakeAccount" -ForegroundColor Gray
Write-Host "  User: $SnowflakeUser" -ForegroundColor Gray
Write-Host "  Role: $SnowflakeRole" -ForegroundColor Gray
Write-Host "  Database: $SnowflakeDatabase" -ForegroundColor Gray
Write-Host "  Warehouse: $SnowflakeWarehouse" -ForegroundColor Gray
Write-Host "  DDL Script: $(if ($UseFixed) { 'create_source_tables_fixed.sql' } else { 'create_source_tables.sql' })" -ForegroundColor Gray
Write-Host ""

# Check if SnowSQL is available
Write-Host "🔍 Checking for SnowSQL..."
$snowsqlPath = Get-Command snowsql -ErrorAction SilentlyContinue
if (-not $snowsqlPath) {
    Write-Host "❌ SnowSQL not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install SnowSQL:" -ForegroundColor Yellow
    Write-Host "1. Download from: https://developers.snowflake.com/snowsql/" -ForegroundColor Gray
    Write-Host "2. Install and add to PATH" -ForegroundColor Gray
    Write-Host "3. Run this script again" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Alternatively, run the DDL manually in Snowflake:" -ForegroundColor Yellow
    Write-Host "  DDL file: $PSScriptRoot\ddl\$(if ($UseFixed) { 'create_source_tables_fixed.sql' } else { 'create_source_tables.sql' })" -ForegroundColor Gray
    exit 1
}

Write-Host "✅ SnowSQL found at: $($snowsqlPath.Source)" -ForegroundColor Green

# Build connection parameters
$connectionParams = @(
    "--accountname", $SnowflakeAccount,
    "--username", $SnowflakeUser,
    "--password", $SnowflakePassword,
    "--rolename", $SnowflakeRole,
    "--warehouse", $SnowflakeWarehouse,
    "--dbname", $SnowflakeDatabase
)

# Test connection if requested
if ($TestConnection) {
    Write-Host "🔌 Testing connection to Snowflake..."
    $testQuery = "SELECT CURRENT_DATABASE(), CURRENT_SCHEMA(), CURRENT_ROLE(), CURRENT_USER(), CURRENT_WAREHOUSE();"
    $testResult = & snowsql @connectionParams --query $testQuery 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Connection successful!" -ForegroundColor Green
        Write-Host $testResult -ForegroundColor Gray
    } else {
        Write-Host "❌ Connection failed!" -ForegroundColor Red
        Write-Host $testResult -ForegroundColor Red
    }
    exit $LASTEXITCODE
}

# Select DDL script
$ddlScript = if ($UseFixed) { "ddl/create_source_tables_fixed.sql" } else { "ddl/create_source_tables.sql" }
$ddlPath = Join-Path $PSScriptRoot $ddlScript

if (-not (Test-Path $ddlPath)) {
    Write-Host "❌ DDL script not found at: $ddlPath" -ForegroundColor Red
    exit 1
}

Write-Host "📄 Using DDL script: $ddlScript" -ForegroundColor Cyan

# Execute the DDL script
Write-Host "🚀 Executing DDL script..."
$ddlResult = & snowsql @connectionParams -f $ddlPath 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ DDL script executed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🎯 Created source tables:" -ForegroundColor Green
    Write-Host "  - LND_MANUAL_ENTRY.SSP_RR_CALENDAR (with 36 test records)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🔍 Next steps:" -ForegroundColor Cyan
    Write-Host "1. Verify data in Snowflake:" -ForegroundColor Gray
    Write-Host "   SELECT * FROM LND_MANUAL_ENTRY.SSP_RR_CALENDAR LIMIT 10;" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Test dbt models:" -ForegroundColor Gray
    Write-Host "   cd dbt_project" -ForegroundColor Gray
    Write-Host "   dbt run --models pkg_ssp_tank_detail" -ForegroundColor Gray
    Write-Host "   dbt test --models pkg_ssp_tank_detail" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. Test incremental behavior:" -ForegroundColor Gray
    Write-Host "   # First run processes all data" -ForegroundColor Gray
    Write-Host "   dbt run --models oracle_pkg_tank_detail_pipeline" -ForegroundColor Gray
    Write-Host "   # Add new records to source table" -ForegroundColor Gray
    Write-Host "   # Second run processes only new/changed data" -ForegroundColor Gray
    Write-Host "   dbt run --models oracle_pkg_tank_detail_pipeline" -ForegroundColor Gray

} else {
    Write-Host "❌ DDL script failed with exit code: $LASTEXITCODE" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error details:" -ForegroundColor Red
    Write-Host $ddlResult -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Check your Snowflake credentials" -ForegroundColor Gray
    Write-Host "2. Verify account name format (e.g., 'abc123.snowflakecomputing.com')" -ForegroundColor Gray
    Write-Host "3. Ensure you have permissions to create databases and schemas" -ForegroundColor Gray
    Write-Host "4. Test connection: .\create_snowflake_sources.ps1 -SnowflakeAccount 'xxx' -SnowflakeUser 'xxx' -SnowflakePassword 'xxx' -TestConnection" -ForegroundColor Gray
}

exit $LASTEXITCODE
