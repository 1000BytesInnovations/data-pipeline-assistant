# Package Mapping Template

## Oracle Package: {PACKAGE_NAME}

### Package Information
- **Original Name**: PKG_EXAMPLE
- **Schema**: PROD
- **Purpose**: Brief description of package functionality
- **Dependencies**: List any dependencies on other packages or tables

### Procedures and Functions

#### Procedure: PROC_EXAMPLE
- **Purpose**: Description of what this procedure does
- **Parameters**: 
  - `p_param1` (VARCHAR2): Description
  - `p_param2` (NUMBER): Description
- **Returns**: Description of return values
- **dbt Model Mapping**: `models/marts/finance/example_report.sql`

#### Function: FN_CALCULATE_EXAMPLE
- **Purpose**: Description of what this function does
- **Parameters**:
  - `p_input` (NUMBER): Description
- **Returns**: NUMBER - Description
- **dbt Implementation**: Converted to macro `calculate_example()`

### Tables and Views Used
- **Source Tables**:
  - `SALES_DATA`: Used for revenue calculations
  - `CUSTOMER_INFO`: Used for customer segmentation
- **Target Tables**:
  - `FINANCIAL_REPORTS`: Output destination

### Conversion Notes
- **Challenges**: Any specific challenges in conversion
- **Modifications**: What was changed during conversion
- **Testing Strategy**: How to validate the conversion

### dbt Model Structure
```
models/
├── staging/
│   ├── stg_sales_data.sql          # From SALES_DATA
│   └── stg_customer_info.sql       # From CUSTOMER_INFO
├── intermediate/
│   └── int_customer_metrics.sql    # Business logic from functions
└── marts/
    └── finance/
        └── example_report.sql      # Final output matching original procedure
```

### SQL Conversion Examples

#### Original Oracle SQL
```sql
-- Original procedure logic
```

#### Converted dbt SQL
```sql
-- Converted dbt model
```

### Testing
- [ ] Data volume validation
- [ ] Business logic validation
- [ ] Performance testing
- [ ] Edge case testing
