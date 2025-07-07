# Verify Snowflake Source Tables for PKG_SSP_TANK_DETAIL
# Date: July 7, 2025
# Purpose: Check if source tables exist and contain expected data

param(
    [string]$SnowflakeAccount,
    [string]$SnowflakeUser,
    [string]$SnowflakePassword,
    [string]$SnowflakeRole = "TRANSFORMER",
    [string]$SnowflakeDatabase = "ANALYTICS_DEV",
    [string]$SnowflakeWarehouse = "COMPUTE_WH"
)

Write-Host "🔍 Verifying Snowflake Source Tables for PKG_SSP_TANK_DETAIL" -ForegroundColor Green
Write-Host "=============================================================" -ForegroundColor Green

# Check if parameters are provided
if (-not $SnowflakeAccount -or -not $SnowflakeUser -or -not $SnowflakePassword) {
    Write-Host "❌ Missing required parameters!" -ForegroundColor Red
    Write-Host "Usage: .\verify_snowflake_sources.ps1 -SnowflakeAccount 'your_account' -SnowflakeUser 'your_user' -SnowflakePassword 'your_password'" -ForegroundColor Yellow
    exit 1
}

# Check if SnowSQL is available
$snowsqlPath = Get-Command snowsql -ErrorAction SilentlyContinue
if (-not $snowsqlPath) {
    Write-Host "❌ SnowSQL not found. Please install SnowSQL first." -ForegroundColor Red
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

Write-Host ""
Write-Host "🔗 Testing connection to Snowflake..."
$testQuery = "SELECT CURRENT_DATABASE(), CURRENT_SCHEMA(), CURRENT_ROLE(), CURRENT_USER();"
$testResult = & snowsql @connectionParams --query $testQuery 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Connection failed!" -ForegroundColor Red
    Write-Host $testResult -ForegroundColor Red
    exit 1
}

Write-Host "✅ Connection successful!" -ForegroundColor Green

# Check if database exists
Write-Host ""
Write-Host "🗄️  Checking database and schemas..."
$dbQuery = "SHOW DATABASES LIKE '$SnowflakeDatabase';"
$dbResult = & snowsql @connectionParams --query $dbQuery 2>&1

if ($dbResult -match $SnowflakeDatabase) {
    Write-Host "✅ Database '$SnowflakeDatabase' exists" -ForegroundColor Green
} else {
    Write-Host "❌ Database '$SnowflakeDatabase' not found" -ForegroundColor Red
    Write-Host "Run create_snowflake_sources.ps1 to create the database and tables" -ForegroundColor Yellow
    exit 1
}

# Check if LND_MANUAL_ENTRY schema exists
$schemaQuery = "SHOW SCHEMAS IN DATABASE $SnowflakeDatabase LIKE 'LND_MANUAL_ENTRY';"
$schemaResult = & snowsql @connectionParams --query $schemaQuery 2>&1

if ($schemaResult -match "LND_MANUAL_ENTRY") {
    Write-Host "✅ Schema 'LND_MANUAL_ENTRY' exists" -ForegroundColor Green
} else {
    Write-Host "❌ Schema 'LND_MANUAL_ENTRY' not found" -ForegroundColor Red
    Write-Host "Run create_snowflake_sources.ps1 to create the schema and tables" -ForegroundColor Yellow
    exit 1
}

# Check if SSP_RR_CALENDAR table exists
Write-Host ""
Write-Host "📋 Checking source tables..."
$tableQuery = "SHOW TABLES IN SCHEMA LND_MANUAL_ENTRY LIKE 'SSP_RR_CALENDAR';"
$tableResult = & snowsql @connectionParams --query $tableQuery 2>&1

if ($tableResult -match "SSP_RR_CALENDAR") {
    Write-Host "✅ Table 'LND_MANUAL_ENTRY.SSP_RR_CALENDAR' exists" -ForegroundColor Green
} else {
    Write-Host "❌ Table 'LND_MANUAL_ENTRY.SSP_RR_CALENDAR' not found" -ForegroundColor Red
    Write-Host "Run create_snowflake_sources.ps1 to create the table" -ForegroundColor Yellow
    exit 1
}

# Check table structure
Write-Host ""
Write-Host "🔍 Verifying table structure..."
$descQuery = "DESC TABLE LND_MANUAL_ENTRY.SSP_RR_CALENDAR;"
$descResult = & snowsql @connectionParams --query $descQuery 2>&1

$expectedColumns = @("CALENDAR_YEAR", "CALENDAR_MONTH", "ACTIVE_FLG", "CREATE_DT", "CREATE_BY", "CREATE_PGM")
$allColumnsFound = $true

foreach ($column in $expectedColumns) {
    if ($descResult -match $column) {
        Write-Host "✅ Column '$column' found" -ForegroundColor Green
    } else {
        Write-Host "❌ Column '$column' missing" -ForegroundColor Red
        $allColumnsFound = $false
    }
}

if (-not $allColumnsFound) {
    Write-Host "❌ Table structure is incorrect" -ForegroundColor Red
    exit 1
}

# Check data count
Write-Host ""
Write-Host "📊 Verifying data..."
$countQuery = "SELECT COUNT(*) as record_count FROM LND_MANUAL_ENTRY.SSP_RR_CALENDAR;"
$countResult = & snowsql @connectionParams --query $countQuery 2>&1

if ($countResult -match "(\d+)") {
    $recordCount = $matches[1]
    if ([int]$recordCount -gt 0) {
        Write-Host "✅ Found $recordCount records in SSP_RR_CALENDAR" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Table exists but contains no data" -ForegroundColor Yellow
        Write-Host "Run create_snowflake_sources.ps1 to populate with test data" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ Could not determine record count" -ForegroundColor Red
}

# Check active/inactive distribution
$statusQuery = @"
SELECT
    active_flg,
    COUNT(*) as count
FROM LND_MANUAL_ENTRY.SSP_RR_CALENDAR
GROUP BY active_flg
ORDER BY active_flg;
"@

$statusResult = & snowsql @connectionParams --query $statusQuery 2>&1

Write-Host ""
Write-Host "📈 Active/Inactive distribution:" -ForegroundColor Cyan
Write-Host $statusResult -ForegroundColor Gray

# Sample data check
$sampleQuery = @"
SELECT
    calendar_year,
    calendar_month,
    active_flg,
    create_dt
FROM LND_MANUAL_ENTRY.SSP_RR_CALENDAR
WHERE calendar_year = 2025
ORDER BY calendar_month
LIMIT 5;
"@

Write-Host ""
Write-Host "📋 Sample data (2025):" -ForegroundColor Cyan
$sampleResult = & snowsql @connectionParams --query $sampleQuery 2>&1
Write-Host $sampleResult -ForegroundColor Gray

# Summary
Write-Host ""
Write-Host "🎯 Verification Summary:" -ForegroundColor Green
Write-Host "✅ Database: $SnowflakeDatabase" -ForegroundColor Gray
Write-Host "✅ Schema: LND_MANUAL_ENTRY" -ForegroundColor Gray
Write-Host "✅ Table: SSP_RR_CALENDAR" -ForegroundColor Gray
Write-Host "✅ Data: $recordCount records" -ForegroundColor Gray

Write-Host ""
Write-Host "🚀 Ready to test dbt models!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. cd dbt_project" -ForegroundColor Gray
Write-Host "2. dbt debug" -ForegroundColor Gray
Write-Host "3. dbt run --models pkg_ssp_tank_detail" -ForegroundColor Gray
Write-Host "4. dbt test --models pkg_ssp_tank_detail" -ForegroundColor Gray
