# PowerShell Script to Set Up Snowflake Environment for PKG_SSP_TANK_DETAIL Testing
# Date: July 7, 2025

param(
    [string]$SnowflakeAccount,
    [string]$SnowflakeUser,
    [string]$SnowflakePassword,
    [string]$SnowflakeRole = "TRANSFORMER",
    [string]$SnowflakeDatabase = "ANALYTICS_DEV",
    [string]$SnowflakeWarehouse = "COMPUTE_WH",
    [string]$SnowflakeSchema = "DBT_DEV"
)

Write-Host "🚀 Setting up Snowflake environment for PKG_SSP_TANK_DETAIL testing" -ForegroundColor Green

# Check if parameters are provided
if (-not $SnowflakeAccount -or -not $SnowflakeUser -or -not $SnowflakePassword) {
    Write-Host "❌ Missing required parameters!" -ForegroundColor Red
    Write-Host "Usage: .\setup_snowflake_env.ps1 -SnowflakeAccount 'your_account' -SnowflakeUser 'your_user' -SnowflakePassword 'your_password'" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Optional parameters:" -ForegroundColor Yellow
    Write-Host "  -SnowflakeRole (default: TRANSFORMER)" -ForegroundColor Gray
    Write-Host "  -SnowflakeDatabase (default: ANALYTICS_DEV)" -ForegroundColor Gray
    Write-Host "  -SnowflakeWarehouse (default: COMPUTE_WH)" -ForegroundColor Gray
    Write-Host "  -SnowflakeSchema (default: DBT_DEV)" -ForegroundColor Gray
    exit 1
}

# Set environment variables
Write-Host "🔧 Setting environment variables..."
$env:SNOWFLAKE_ACCOUNT = $SnowflakeAccount
$env:SNOWFLAKE_USER = $SnowflakeUser
$env:SNOWFLAKE_PASSWORD = $SnowflakePassword
$env:SNOWFLAKE_ROLE = $SnowflakeRole
$env:SNOWFLAKE_DATABASE = $SnowflakeDatabase
$env:SNOWFLAKE_WAREHOUSE = $SnowflakeWarehouse
$env:SNOWFLAKE_SCHEMA = $SnowflakeSchema

Write-Host "✅ Environment variables set:" -ForegroundColor Green
Write-Host "  Account: $SnowflakeAccount" -ForegroundColor Gray
Write-Host "  User: $SnowflakeUser" -ForegroundColor Gray
Write-Host "  Role: $SnowflakeRole" -ForegroundColor Gray
Write-Host "  Database: $SnowflakeDatabase" -ForegroundColor Gray
Write-Host "  Warehouse: $SnowflakeWarehouse" -ForegroundColor Gray
Write-Host "  Schema: $SnowflakeSchema" -ForegroundColor Gray

# Check if SnowSQL is available
Write-Host "🔍 Checking for SnowSQL..."
$snowsqlPath = Get-Command snowsql -ErrorAction SilentlyContinue
if ($snowsqlPath) {
    Write-Host "✅ SnowSQL found at: $($snowsqlPath.Source)" -ForegroundColor Green

    # Create connection string
    $connectionString = "--accountname $SnowflakeAccount --username $SnowflakeUser --password $SnowflakePassword --rolename $SnowflakeRole --warehouse $SnowflakeWarehouse --dbname $SnowflakeDatabase --schemaname $SnowflakeSchema"

    Write-Host "🗄️  Running DDL script to create source tables..."

    # Execute the DDL script
    $ddlScript = Join-Path $PSScriptRoot "ddl/create_source_tables.sql"
    if (Test-Path $ddlScript) {
        Write-Host "📄 Executing: $ddlScript" -ForegroundColor Cyan
        & snowsql $connectionString.Split(' ') -f $ddlScript

        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ DDL script executed successfully!" -ForegroundColor Green
        } else {
            Write-Host "❌ DDL script failed with exit code: $LASTEXITCODE" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ DDL script not found at: $ddlScript" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️  SnowSQL not found. Please install SnowSQL or run the DDL manually." -ForegroundColor Yellow
    Write-Host "DDL script location: ddl/create_source_tables.sql" -ForegroundColor Gray
}

Write-Host ""
Write-Host "🎯 Next steps:" -ForegroundColor Cyan
Write-Host "1. Verify source tables were created in Snowflake" -ForegroundColor Gray
Write-Host "2. Run dbt commands:" -ForegroundColor Gray
Write-Host "   cd dbt_project" -ForegroundColor Gray
Write-Host "   dbt run --models pkg_ssp_tank_detail" -ForegroundColor Gray
Write-Host "   dbt test --models pkg_ssp_tank_detail" -ForegroundColor Gray
Write-Host ""
Write-Host "📊 Monitor the incremental behavior:" -ForegroundColor Cyan
Write-Host "   First run: Full refresh (all data processed)" -ForegroundColor Gray
Write-Host "   Subsequent runs: Only new/changed data processed" -ForegroundColor Gray
