#!/bin/bash

# Oracle Package Analysis Script
# This script helps analyze Oracle packages for dbt conversion

echo "Oracle Package Analysis Tool"
echo "============================"

# Set Oracle connection details
read -p "Enter Oracle host: " ORACLE_HOST
read -p "Enter Oracle port (default 1521): " ORACLE_PORT
ORACLE_PORT=${ORACLE_PORT:-1521}
read -p "Enter Oracle database: " ORACLE_DATABASE
read -p "Enter Oracle username: " ORACLE_USER
read -s -p "Enter Oracle password: " ORACLE_PASSWORD
echo
read -p "Enter Oracle schema: " ORACLE_SCHEMA

# Create analysis directory
mkdir -p analysis/oracle_packages

# SQL to extract package information
cat > analysis/oracle_packages/extract_packages.sql << EOF
-- Extract all packages in the schema
SELECT
    object_name as package_name,
    status,
    created,
    last_ddl_time
FROM user_objects
WHERE object_type = 'PACKAGE'
ORDER BY object_name;

-- Extract package procedures and functions
SELECT
    p.object_name as package_name,
    p.procedure_name,
    CASE
        WHEN a.argument_name IS NULL THEN 'PROCEDURE'
        WHEN a.data_type IS NOT NULL AND a.in_out = 'OUT' THEN 'FUNCTION'
        ELSE 'PROCEDURE'
    END as object_type,
    COUNT(a.argument_name) as parameter_count
FROM user_procedures p
LEFT JOIN user_arguments a ON p.object_name = a.package_name
    AND p.procedure_name = a.object_name
WHERE p.object_type = 'PACKAGE'
GROUP BY p.object_name, p.procedure_name,
    CASE
        WHEN a.argument_name IS NULL THEN 'PROCEDURE'
        WHEN a.data_type IS NOT NULL AND a.in_out = 'OUT' THEN 'FUNCTION'
        ELSE 'PROCEDURE'
    END
ORDER BY p.object_name, p.procedure_name;

-- Extract package dependencies
SELECT
    name as package_name,
    referenced_name as depends_on,
    referenced_type as dependency_type
FROM user_dependencies
WHERE type = 'PACKAGE BODY'
    AND referenced_type IN ('TABLE', 'VIEW', 'PACKAGE', 'FUNCTION', 'PROCEDURE')
ORDER BY name, referenced_name;
EOF

echo "Analysis complete! SQL scripts generated in analysis/oracle_packages/"
echo "Run the extract_packages.sql script against your Oracle database to get package information."
