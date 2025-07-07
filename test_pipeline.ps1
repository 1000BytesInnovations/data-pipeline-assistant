# Test Script for PKG_SSP_TANK_DETAIL dbt Pipeline
# Date: July 7, 2025

param(
    [switch]$SkipDDL,
    [switch]$FullRefresh,
    [switch]$TestOnly
)

Write-Host "🧪 PKG_SSP_TANK_DETAIL dbt Pipeline Test Script" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green

# Change to dbt project directory
$dbtProjectPath = Join-Path $PSScriptRoot "dbt_project"
Set-Location $dbtProjectPath

Write-Host "📂 Working directory: $dbtProjectPath" -ForegroundColor Gray
Write-Host ""

# Check environment variables
Write-Host "🔍 Checking environment variables..."
$requiredVars = @('SNOWFLAKE_ACCOUNT', 'SNOWFLAKE_USER', 'SNOWFLAKE_PASSWORD')
$missingVars = @()

foreach ($var in $requiredVars) {
    if (-not (Get-Item "env:$var" -ErrorAction SilentlyContinue)) {
        $missingVars += $var
    }
}

if ($missingVars.Count -gt 0) {
    Write-Host "❌ Missing environment variables: $($missingVars -join ', ')" -ForegroundColor Red
    Write-Host "Please run setup_snowflake_env.ps1 first or set these variables manually." -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Environment variables configured" -ForegroundColor Green
Write-Host ""

# Step 1: Parse project
Write-Host "🔍 Step 1: Parsing dbt project..."
$parseResult = & dbt parse --no-version-check 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ dbt parse successful" -ForegroundColor Green
} else {
    Write-Host "❌ dbt parse failed:" -ForegroundColor Red
    Write-Host $parseResult -ForegroundColor Red
    exit 1
}

# Step 2: Test sources
Write-Host "🔍 Step 2: Testing source tables..."
$sourceTestResult = & dbt test --select source:lnd_manual_entry --no-version-check 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Source tests passed" -ForegroundColor Green
} else {
    Write-Host "⚠️  Source tests failed (this is expected if DDL wasn't run):" -ForegroundColor Yellow
    Write-Host $sourceTestResult -ForegroundColor Yellow
}

# Step 3: Run models (if not TestOnly)
if (-not $TestOnly) {
    Write-Host "🚀 Step 3: Running dbt models..."

    $runCommand = "dbt run --models pkg_ssp_tank_detail --no-version-check"
    if ($FullRefresh) {
        $runCommand += " --full-refresh"
        Write-Host "🔄 Running with --full-refresh flag" -ForegroundColor Cyan
    }

    Write-Host "Executing: $runCommand" -ForegroundColor Cyan
    $runResult = Invoke-Expression $runCommand 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ dbt run successful" -ForegroundColor Green
    } else {
        Write-Host "❌ dbt run failed:" -ForegroundColor Red
        Write-Host $runResult -ForegroundColor Red
        exit 1
    }
}

# Step 4: Run tests
Write-Host "🧪 Step 4: Running dbt tests..."
$testResult = & dbt test --models pkg_ssp_tank_detail --no-version-check 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ All dbt tests passed" -ForegroundColor Green
} else {
    Write-Host "❌ Some dbt tests failed:" -ForegroundColor Red
    Write-Host $testResult -ForegroundColor Red
}

# Step 5: Generate documentation
Write-Host "📚 Step 5: Generating documentation..."
$docsResult = & dbt docs generate --no-version-check 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Documentation generated successfully" -ForegroundColor Green
    Write-Host "Run 'dbt docs serve' to view documentation" -ForegroundColor Gray
} else {
    Write-Host "⚠️  Documentation generation failed:" -ForegroundColor Yellow
    Write-Host $docsResult -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎯 Test Summary:" -ForegroundColor Cyan
Write-Host "=================" -ForegroundColor Cyan

# Show model counts
Write-Host "📊 Model execution summary:"
$models = @(
    "stg_ssp_rr_calendar",
    "int_tank_detail_source_validation",
    "int_tank_detail_blend_expression",
    "int_tank_detail_by_application",
    "int_tank_detail_by_variety",
    "oracle_pkg_tank_detail_pipeline",
    "tank_detail_consolidated",
    "tank_detail_bima"
)

foreach ($model in $models) {
    Write-Host "  • $model" -ForegroundColor Gray
}

Write-Host ""
Write-Host "🔍 To inspect results, run:" -ForegroundColor Cyan
Write-Host "  dbt show --select stg_ssp_rr_calendar --limit 5" -ForegroundColor Gray
Write-Host "  dbt show --select tank_detail_consolidated --limit 5" -ForegroundColor Gray
Write-Host ""
Write-Host "📈 To test incremental behavior:" -ForegroundColor Cyan
Write-Host "  1. Run this script again (should process only new data)" -ForegroundColor Gray
Write-Host "  2. Add new data to source tables" -ForegroundColor Gray
Write-Host "  3. Run again to see incremental processing" -ForegroundColor Gray
