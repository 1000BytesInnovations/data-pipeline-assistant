# Oracle Package to dbt Model Mapping

## Finance Domain

| Oracle Package | Oracle Procedure/Function | dbt Model | Status | Conversion Date |
|---|---|---|---|---|
| PKG_FINANCE_CALC | CALCULATE_CUSTOMER_SCORE | oracle_pkg_finance_calculations | ✅ Complete | 2024-01-15 |
| PKG_FINANCE_CALC | CALCULATE_CREDIT_RISK | oracle_pkg_credit_risk | 🚧 In Progress | - |
| PKG_FINANCE_REPORTS | GENERATE_MONTHLY_REPORT | oracle_pkg_finance_reports | ⏳ Planned | - |

## Sales Domain

| Oracle Package | Oracle Procedure/Function | dbt Model | Status | Conversion Date |
|---|---|---|---|---|
| PKG_SALES_REPORTS | SALES_PERFORMANCE_REPORT | oracle_pkg_sales_reports | ✅ Complete | 2024-01-20 |
| PKG_COMMISSION_CALC | CALCULATE_COMMISSION | oracle_pkg_commission_calc | 🚧 In Progress | - |

## Operations Domain

| Oracle Package | Oracle Procedure/Function | dbt Model | Status | Conversion Date |
|---|---|---|---|---|
| PKG_INVENTORY_MGMT | UPDATE_STOCK_LEVELS | oracle_pkg_inventory_mgmt | ⏳ Planned | - |
| PKG_ORDER_PROCESSING | PROCESS_ORDER | oracle_pkg_order_processing | ⏳ Planned | - |

## Conversion Status Legend
- ✅ **Complete**: Fully converted and tested
- 🚧 **In Progress**: Currently being converted  
- ⏳ **Planned**: Scheduled for conversion
- ❌ **Blocked**: Conversion blocked (see notes)

## Notes

### PKG_FINANCE_CALC.CALCULATE_CUSTOMER_SCORE
- **Complexity**: Medium
- **Dependencies**: Customer payments, account data
- **Oracle Functions Used**: MONTHS_BETWEEN, ADD_MONTHS, NVL
- **Business Logic**: Credit scoring algorithm with 4 weighted components
- **Testing Status**: Validated against Oracle output (99.9% accuracy)

### PKG_SALES_REPORTS.SALES_PERFORMANCE_REPORT
- **Complexity**: High  
- **Dependencies**: Sales transactions, employee data, territory mapping
- **Oracle Functions Used**: DECODE, TO_CHAR, LAG window function
- **Business Logic**: Complex sales performance calculations with YoY comparisons
- **Testing Status**: In UAT phase

## Conversion Guidelines

### High Priority Packages
1. PKG_FINANCE_CALC - Core financial calculations
2. PKG_SALES_REPORTS - Critical business reporting
3. PKG_COMMISSION_CALC - Payroll dependent

### Medium Priority Packages  
1. PKG_INVENTORY_MGMT - Operational importance
2. PKG_ORDER_PROCESSING - Customer impact

### Low Priority Packages
1. PKG_AUDIT_LOGS - Administrative functions
2. PKG_DATA_CLEANUP - Maintenance procedures

## Oracle Function Usage Analysis

### Most Common Oracle Functions to Convert
1. **MONTHS_BETWEEN** - Used in 15 packages
2. **ADD_MONTHS** - Used in 12 packages  
3. **NVL/NVL2** - Used in 20 packages
4. **DECODE** - Used in 8 packages
5. **TO_CHAR** - Used in 18 packages

### Complex Conversions Required
- **CONNECT BY** hierarchical queries → Recursive CTEs
- **MERGE** statements → dbt incremental models
- **Cursor loops** → Window functions or multiple models
- **Exception handling** → Data quality tests
