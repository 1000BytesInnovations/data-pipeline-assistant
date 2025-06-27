@echo off
REM Oracle Package to dbt Conversion Helper Script for Windows

echo Oracle Package to dbt Conversion Helper
echo ======================================

REM Create analysis directory
if not exist "analysis\oracle_packages" mkdir analysis\oracle_packages

REM Generate package analysis SQL
echo -- Extract all packages in the schema > analysis\oracle_packages\extract_packages.sql
echo SELECT >> analysis\oracle_packages\extract_packages.sql
echo     object_name as package_name, >> analysis\oracle_packages\extract_packages.sql
echo     status, >> analysis\oracle_packages\extract_packages.sql
echo     created, >> analysis\oracle_packages\extract_packages.sql
echo     last_ddl_time >> analysis\oracle_packages\extract_packages.sql
echo FROM user_objects >> analysis\oracle_packages\extract_packages.sql
echo WHERE object_type = 'PACKAGE' >> analysis\oracle_packages\extract_packages.sql
echo ORDER BY object_name; >> analysis\oracle_packages\extract_packages.sql

echo. >> analysis\oracle_packages\extract_packages.sql
echo -- Extract package procedures and functions >> analysis\oracle_packages\extract_packages.sql
echo SELECT >> analysis\oracle_packages\extract_packages.sql
echo     p.object_name as package_name, >> analysis\oracle_packages\extract_packages.sql
echo     p.procedure_name, >> analysis\oracle_packages\extract_packages.sql
echo     CASE >> analysis\oracle_packages\extract_packages.sql
echo         WHEN a.argument_name IS NULL THEN 'PROCEDURE' >> analysis\oracle_packages\extract_packages.sql
echo         WHEN a.data_type IS NOT NULL AND a.in_out = 'OUT' THEN 'FUNCTION' >> analysis\oracle_packages\extract_packages.sql
echo         ELSE 'PROCEDURE' >> analysis\oracle_packages\extract_packages.sql
echo     END as object_type, >> analysis\oracle_packages\extract_packages.sql
echo     COUNT(a.argument_name) as parameter_count >> analysis\oracle_packages\extract_packages.sql
echo FROM user_procedures p >> analysis\oracle_packages\extract_packages.sql
echo LEFT JOIN user_arguments a ON p.object_name = a.package_name >> analysis\oracle_packages\extract_packages.sql
echo     AND p.procedure_name = a.object_name >> analysis\oracle_packages\extract_packages.sql
echo WHERE p.object_type = 'PACKAGE' >> analysis\oracle_packages\extract_packages.sql
echo GROUP BY p.object_name, p.procedure_name, >> analysis\oracle_packages\extract_packages.sql
echo     CASE >> analysis\oracle_packages\extract_packages.sql
echo         WHEN a.argument_name IS NULL THEN 'PROCEDURE' >> analysis\oracle_packages\extract_packages.sql
echo         WHEN a.data_type IS NOT NULL AND a.in_out = 'OUT' THEN 'FUNCTION' >> analysis\oracle_packages\extract_packages.sql
echo         ELSE 'PROCEDURE' >> analysis\oracle_packages\extract_packages.sql
echo     END >> analysis\oracle_packages\extract_packages.sql
echo ORDER BY p.object_name, p.procedure_name; >> analysis\oracle_packages\extract_packages.sql

echo.
echo Analysis SQL generated in: analysis\oracle_packages\extract_packages.sql
echo Run this SQL file against your Oracle database to extract package information.
echo.

REM Create dbt model template
echo Creating dbt model template...
echo. > analysis\oracle_packages\model_template.sql
echo {{ config( >> analysis\oracle_packages\model_template.sql
echo     materialized='view', >> analysis\oracle_packages\model_template.sql
echo     tags=['oracle_conversion', 'DOMAIN_NAME'], >> analysis\oracle_packages\model_template.sql
echo     meta={ >> analysis\oracle_packages\model_template.sql
echo         'oracle_package': 'ORIGINAL_PACKAGE_NAME', >> analysis\oracle_packages\model_template.sql
echo         'original_procedure': 'ORIGINAL_PROCEDURE_NAME', >> analysis\oracle_packages\model_template.sql
echo         'conversion_notes': 'Description of conversion' >> analysis\oracle_packages\model_template.sql
echo     } >> analysis\oracle_packages\model_template.sql
echo ^) }} >> analysis\oracle_packages\model_template.sql
echo. >> analysis\oracle_packages\model_template.sql
echo /* >> analysis\oracle_packages\model_template.sql
echo     This model converts the Oracle package PACKAGE_NAME.PROCEDURE_NAME >> analysis\oracle_packages\model_template.sql
echo     Original Oracle procedure/function description here >> analysis\oracle_packages\model_template.sql
echo */ >> analysis\oracle_packages\model_template.sql
echo. >> analysis\oracle_packages\model_template.sql
echo with source_data as ( >> analysis\oracle_packages\model_template.sql
echo     select * from {{ ref('staging_model_name') }} >> analysis\oracle_packages\model_template.sql
echo ^), >> analysis\oracle_packages\model_template.sql
echo. >> analysis\oracle_packages\model_template.sql
echo -- Add your conversion logic here >> analysis\oracle_packages\model_template.sql
echo final as ( >> analysis\oracle_packages\model_template.sql
echo     select >> analysis\oracle_packages\model_template.sql
echo         -- Add columns here >> analysis\oracle_packages\model_template.sql
echo         'ORIGINAL_PACKAGE_NAME' as source_package, >> analysis\oracle_packages\model_template.sql
echo         'ORIGINAL_PROCEDURE_NAME' as source_procedure, >> analysis\oracle_packages\model_template.sql
echo         current_timestamp as conversion_timestamp >> analysis\oracle_packages\model_template.sql
echo     from source_data >> analysis\oracle_packages\model_template.sql
echo ^) >> analysis\oracle_packages\model_template.sql
echo. >> analysis\oracle_packages\model_template.sql
echo select * from final >> analysis\oracle_packages\model_template.sql

echo Model template created in: analysis\oracle_packages\model_template.sql
echo.
echo Setup complete! Use the generated files to analyze and convert your Oracle packages.
pause
