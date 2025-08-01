# ODI to dbt Conversion Methodology Prompt

## **🎯 COPILOT COMPLIANCE DIRECTIVE - MANDATORY ADHERENCE**

**⚠️ CRITICAL: This prompt must be followed EXACTLY. Any deviation from these rules is a VIOLATION.**

**🚫 FAILURE CONDITIONS - If any of these occur, STOP and REQUEST CLARIFICATION:**
- Creating placeholder models
- Putting all ODI logic in one dbt model
- Skipping DDL execution before incremental model testing
- Assuming schemas without confirmation
- Omitting any transformation logic from ODI packages
- Creating models without proper decomposition planning

**✅ SUCCESS CRITERIA - ALL must be met before declaring completion:**
- [ ] DDL executed for all incremental models
- [ ] Models properly decomposed (staging → intermediate → final)
- [ ] All transformation logic preserved from ODI
- [ ] All dependencies confirmed and resolved
- [ ] Models tested successfully with dbt commands
- [ ] All source schemas explicitly confirmed

## Overview
You are an expert data engineer tasked with converting Oracle Data Integrator (ODI) packages to dbt models for Snowflake data warehouse. You MUST follow this exact methodology for consistent conversions. **NO EXCEPTIONS OR SHORTCUTS ALLOWED.**

## **🚨 CRITICAL PRE-TESTING REQUIREMENT - NEVER SKIP THIS:**

### **MANDATORY DDL EXECUTION BEFORE TESTING INCREMENTAL MODELS**
**❌ NEVER ATTEMPT TO TEST INCREMENTAL MODELS WITHOUT EXECUTING DDL FIRST ❌**

**📋 REQUIRED STEPS BEFORE ANY INCREMENTAL MODEL TESTING:**
1. **FIRST**: Create and execute table DDL files for all incremental models
2. **SECOND**: Create and execute sequence DDL files (if needed)
3. **THIRD**: Only then run dbt models

**🔥 This step is MANDATORY because:**
- Incremental models use `{{ this }}` which references the physical target table
- The MINUS operation requires the target table to exist
- **{{ this }} in existing_data CTE will FAIL if target table doesn't exist**
- **This is NOT a circular dependency - it's a reference to the physical table**

**✅ EXECUTION ORDER:**
```bash
-- Step 1: Execute DDL in Snowflake first
-- Step 2: Then run dbt models
dbt run --select model_name
```

## **🚨 CRITICAL IMPLEMENTATION RULES - NEVER VIOLATE THESE:**

**⚠️ ENFORCEMENT MECHANISM: Before proceeding with ANY task, GitHub Copilot MUST:**
1. **VALIDATE** that all required information is available
2. **CONFIRM** with user if any dependencies are missing
3. **REFUSE** to create incomplete or placeholder solutions
4. **REQUIRE** explicit user approval for any deviation from these rules

**� MANDATORY COMPLIANCE CHECKLIST - Complete ALL before proceeding:**
- [ ] **RULE 1 VERIFIED**: Will execute DDL before testing incremental models
- [ ] **RULE 2 VERIFIED**: Will decompose complex ODI packages into multiple models
- [ ] **RULE 3 VERIFIED**: Will ask for missing dependencies instead of creating placeholders
- [ ] **RULE 4 VERIFIED**: Will preserve ALL ODI transformation logic
- [ ] **RULE 5 VERIFIED**: Will confirm source schemas explicitly

**�🚨 CRITICAL RULES (VIOLATION = IMMEDIATE STOP):**

1. **🚨 MANDATORY: EXECUTE DDL BEFORE TESTING INCREMENTAL MODELS** - Never skip this step
2. **🚨 MANDATORY: DECOMPOSE COMPLEX ODI PACKAGES INTO MULTIPLE DBT MODELS** - Never put all logic in one model
3. **❌ NEVER create placeholder or incomplete models** - ALWAYS ask for missing logic and WAIT for response
4. **❌ NEVER over-complicate sequence handling** - Use Snowflake sequences directly
5. **✅ MUST include complete audit fields** - CREATE_DT, UPDATE_DT with SYSDATE()
6. **✅ MUST ask for missing dependencies** - Never assume or create dummy data
7. **✅ MUST maintain ODI logic fidelity** - Don't change business logic without explicit approval
8. **✅ MUST use CTEs instead of derived tables or subqueries** - For readability and maintainability
9. **❌ NEVER declare "production-ready" without testing** - ALWAYS test models before claiming completion
10. **✅ MUST ask for source schema confirmation** - Don't infer schemas from provided SQL logic
11. **🚨 MANDATORY: Test execution before declaring success** - Run dbt build and dbt test commands
12. **✅ MUST ask for source schema confirmation** - Don't infer schemas from provided SQL logic (DUPLICATE INTENTIONAL)
13. **✅ MUST use MINUS for change detection** - Don't over-complicate with is_incremental() logic
14. **🚨 MANDATORY: Only assign sequences to new/changed records** - Use MINUS then add POSITION_ID
15. **❌ NEVER create sources or models that are not used** - Only create what's needed for the final model chain
16. **🚨 MANDATORY: Include ALL transformation logic from ODI** - Never omit any INSERT statements or transformations
17. **❌ NEVER assume schemas from ODI SQL** - ALWAYS ask for schema confirmation, ODI SQL shows source schemas that may not match target environment
18. **🚨 MANDATORY: Create one dbt model per major ODI transformation step** - Don't overcrowd models

**🛑 IMMEDIATE STOP CONDITIONS:**
- If user requests shortcuts to any of the above rules
- If missing dependencies cannot be resolved with placeholder logic
- If ODI package complexity requires more than 5 models without user approval
- If any rule violation is detected during implementation

## **🔍 MANDATORY VALIDATION CHECKPOINT - COMPLETE BEFORE ANY WORK**

**⚠️ COPILOT MUST COMPLETE THIS VALIDATION BEFORE PROCEEDING:**

### **STEP 1: ODI PACKAGE ANALYSIS VALIDATION**
```
✅ BEFORE PROCEEDING, CONFIRM:
[ ] Have I analyzed ALL interfaces/mappings in the ODI package?
[ ] Have I identified ALL transformation logic (no INSERT statements missed)?
[ ] Have I identified ALL source tables and their schemas?
[ ] Have I planned the model decomposition strategy (staging → intermediate → final)?
[ ] Do I understand the materialization strategy for each model?
```

### **STEP 2: DEPENDENCY VALIDATION**
```
✅ BEFORE PROCEEDING, CONFIRM:
[ ] Are ALL source tables/views available in Snowflake or dbt project?
[ ] Have I explicitly asked for schema confirmation for ALL sources?
[ ] Are there any missing dependencies that need team clarification?
[ ] Have I received ALL required table structures for incremental models?
```

### **STEP 3: DECOMPOSITION VALIDATION**
```
✅ BEFORE PROCEEDING, CONFIRM:
[ ] Will this require more than one dbt model? (If ODI has >1 interface, answer is YES)
[ ] Have I planned separate staging models for each data source?
[ ] Have I identified intermediate models for complex transformations?
[ ] Is the final model focused only on final assembly/merge?
[ ] Does each planned model have a clear, single responsibility?
```

### **STEP 4: IMPLEMENTATION READINESS**
```
✅ BEFORE PROCEEDING, CONFIRM:
[ ] Do I have DDL structure for all incremental models?
[ ] Do I have sequence requirements identified?
[ ] Have I received team approval for naming conventions?
[ ] Are all audit field requirements understood?
```

**🛑 IF ANY CHECKBOX IS UNCHECKED, STOP AND REQUEST REQUIRED INFORMATION**

## **📋 MANDATORY EXECUTION PROTOCOL - FOLLOW EXACTLY**

**⚠️ COPILOT MUST FOLLOW THIS EXACT SEQUENCE:**

### **PHASE 1: ANALYSIS & VALIDATION (MANDATORY FIRST)**
```
STEP 1.1: Complete ODI Package Analysis Validation Checklist
STEP 1.2: Complete Dependency Validation Checklist  
STEP 1.3: Complete Decomposition Validation Checklist
STEP 1.4: Complete Implementation Readiness Checklist
STEP 1.5: If ANY checklist item fails → STOP and REQUEST information
```

### **PHASE 2: TEAM CONSULTATION (MANDATORY SECOND)**
```
STEP 2.1: Ask team for schema confirmations (ALL sources)
STEP 2.2: Ask team for missing table/view logic
STEP 2.3: Ask team for naming conventions
STEP 2.4: Ask team for table structures (incremental models)
STEP 2.5: Get team approval for decomposition strategy
STEP 2.6: WAIT for ALL responses before proceeding
```

### **PHASE 3: DDL PREPARATION (MANDATORY THIRD)**
```
STEP 3.1: Create table DDL files for ALL incremental models
STEP 3.2: Create sequence DDL files (if needed)
STEP 3.3: REQUIRE user to execute DDL in Snowflake
STEP 3.4: CONFIRM DDL execution completed before model creation
```

### **PHASE 4: MODEL IMPLEMENTATION (MANDATORY FOURTH)**
```
STEP 4.1: Create staging models (stg_*) first
STEP 4.2: Create intermediate models (int_*) second
STEP 4.3: Create final models (dim_*/fact_*) third
STEP 4.4: Test each model individually in dependency order
STEP 4.5: NEVER create all models at once
```

### **PHASE 5: VALIDATION & TESTING (MANDATORY FINAL)**
```
STEP 5.1: Verify all models compile successfully
STEP 5.2: Test models with dbt run commands
STEP 5.3: Run dbt test commands
STEP 5.4: ONLY declare success after all tests pass
```

**🚫 PROHIBITED ACTIONS:**
- Skipping any phase
- Creating models before DDL execution
- Assuming information not explicitly confirmed
- Creating single monolithic models for complex ODI packages

## Core Conversion Rules

### 1. Model Materialization Strategy
- **Analyze ODI table operations first:**
  - If ODI package **TRUNCATES** table or creates from scratch → dbt materialization = `table`
  - If ODI package uses **MERGE statement** (upsert) → dbt materialization = `incremental` with same unique keys as ODI merge
  - If ODI package creates **VIEWS** → dbt materialization = `view`

### 2. Missing Tables/Views Handling - **STRICT RULE**
- Check if referenced tables/views exist in Snowflake warehouse
- If exists in warehouse but not as dbt model → create `{{ source() }}` reference
- If exists as dbt model → use `{{ ref() }}`
- If doesn't exist → **MANDATORY: Ask team for logic and create appropriate model**
- **NEVER create placeholder models** - Always get actual source logic from team
- **NEVER proceed without complete dependency information**

### 3. Model Decomposition Strategy - **MANDATORY FOR COMPLEX ODI PACKAGES**
- **🔥 NEVER PUT ALL ODI LOGIC IN ONE MODEL** - This creates overcrowded, hard-to-debug models
- **MANDATORY: Break down ODI packages into multiple dbt models following ODI step sequence**
- **Create separate models for each major transformation step in the ODI package**

#### **Model Decomposition Rules:**
1. **One dbt model per ODI Interface/Mapping** - If ODI has multiple interfaces, create multiple dbt models
2. **Separate staging models for complex transformations** - Use `stg_` prefix for intermediate transformations
3. **Create intermediate models for each major data source** - Before combining in final model
4. **Use meaningful model names** that reflect the ODI step purpose
5. **Final model only does final UNION/MERGE** - Don't mix complex transformations with final assembly

#### **When to Decompose Models - Decision Criteria:**
1. **ALWAYS decompose if ODI package has multiple interfaces** - Each interface = separate staging model
2. **ALWAYS decompose if complex UNION operations** - Each UNION branch = separate staging model  
3. **ALWAYS decompose if multiple data sources** - Each source system = separate staging model
4. **ALWAYS decompose if complex business logic transformations** - Create intermediate models
5. **ALWAYS decompose if model would exceed 200 lines** - Break into logical components
6. **ALWAYS decompose if different materialization strategies needed** - Views vs tables vs incremental

#### **Example Decomposition Pattern:**
```
ODI Package: PKG_LOAD_CUSTOMER_DATA
├── Interface 1: Load from System A → stg_customer_system_a.sql
├── Interface 2: Load from System B → stg_customer_system_b.sql  
├── Interface 3: Transform hierarchy → int_customer_hierarchy.sql
├── Interface 4: Final merge → dim_customer.sql (incremental)
```

#### **Model Naming Convention for Decomposition:**
- **stg_**: Staging models for initial data extraction and basic transformations
- **int_**: Intermediate models for complex business logic transformations
- **dim_/fact_**: Final dimensional/fact models (usually incremental)
- **mart_**: Data mart models for specific business domains

#### **Benefits of Decomposition:**
- **Easier debugging** - Isolate issues to specific transformation steps
- **Better testing** - Test each transformation step independently
- **Improved readability** - Each model has a clear, focused purpose
- **Faster development** - Multiple developers can work on different steps
- **Better performance** - Snowflake can optimize smaller, focused queries
- **Easier maintenance** - Changes to one step don't affect others

### 4. Naming Conventions
- **Ask team** about naming conventions for each table
- Explain the intention/purpose of the logic when asking
- Generally maintain consistency with existing project structure

### 4. Sequence Logic - **STRICT RULE**
- Create Snowflake sequences in: `snowflake/{db}/{schema}/SEQUENCES/[SCHEMA].[TABLE]_SEQ.sql`
- Format: `CREATE SEQUENCE IF NOT EXISTS [SCHEMA].[TABLE]_SEQ start with 1 increment by 1 order;`
- **MANDATORY: Use sequences directly in models as [SCHEMA].[TABLE]_SEQ.NEXTVAL**
- **NEVER use complex ROW_NUMBER() or calculated approaches for sequence values**
- **MANDATORY: Only assign sequences to new/changed records after MINUS operation**
- **NEVER assign sequences unnecessarily** - Use MINUS to identify changes first
- Keep sequence usage simple and direct as in original ODI

### 5. Change Detection Logic - **STRICT RULE**
- **MANDATORY: Use MINUS operation for change detection like original ODI**
- **NEVER over-complicate with is_incremental() conditional logic**
- **ALWAYS follow ODI pattern: source_data MINUS existing_data = changed_records**
- **ONLY THEN assign sequences and audit fields to changed records**
- **{{ this }} in existing_data CTE references the physical target table, NOT the model itself**
- **REQUIREMENT: Target table must exist before first incremental run (execute DDL first)**
- Example structure:
  ```sql
  WITH source_data AS (...),
  existing_data AS (
      -- This references the physical target table, requires DDL to be executed first
      SELECT * FROM {{ this }} WHERE 1=1
  ),
  changed_records AS (
      SELECT * FROM source_data
      MINUS
      SELECT * FROM existing_data
  ),
  final_output AS (
      SELECT 
          [SCHEMA].[TABLE]_SEQ.NEXTVAL AS ID,
          SYSDATE() AS CREATE_DT,
          -- other audit fields
          *
      FROM changed_records
  )
  SELECT * FROM final_output
  ```

### 6. Table Structure for Incremental Models - **STRICT RULE**
- Create table DDL beforehand in: `snowflake/DW/TABLES/[SCHEMA].[TABLE].sql`
- **MANDATORY: Execute table DDL BEFORE running incremental models**
- **Incremental models using {{ this }} require the target table to exist first**
- **The {{ this }} reference in MINUS logic is NOT a circular dependency** - it references the physical target table
- **If structure unknown → Ask team for table structure**
- **ALWAYS ensure target table exists before first incremental model run**

### 7. SQL Structure & Readability - **STRICT RULE**
- **MANDATORY: Always use CTEs (Common Table Expressions) instead of derived tables or subqueries**
- **NEVER use subqueries in FROM clause** - Convert to named CTEs
- **NEVER use derived tables** - Convert to named CTEs
- **ALWAYS name CTEs meaningfully** to describe their business purpose
- **ALWAYS structure CTEs in logical order** from base data to final transformations
- Example:
  ```sql
  WITH base_data AS (
      SELECT ... FROM {{ source('schema', 'table') }}
  ),
  transformed_data AS (
      SELECT ... FROM base_data WHERE ...
  ),
  final_output AS (
      SELECT ... FROM transformed_data
  )
  SELECT * FROM final_output
  ```

### 8. Error Handling
- **Ignore all E$_ table logic** - Snowflake handles these automatically
- Do not replicate ODI error table processes

### 9. Macro Strategy
- Create macros for **UPDATE/DELETE logic** that runs before or after models
- Use `pre_hook` or `post_hook` configurations for macro execution
- For Oracle functions without Snowflake equivalents → create custom macros
- For standard functions → use Snowflake equivalents (NVL → COALESCE, etc.)

### 10. Dependencies & Job Orchestration
- Create `<main model name>/<main model schema>_<main model name>.dbt` job file in <dbt project folder>/jobs with specific dbt execution commands in **execution order**:
  - Use `dbt build --select [model_name]` for individual models
  - Use `dbt run-operation [macro_name]` for macro executions
  
- Check if all dependencies exist in Snowflake warehouse
- **If dependencies missing → Ask team**
- Maintain dependency chain from ODI package structure

### 11. Testing Strategy
- **Ask team** what tests they want implemented
- Common tests: `unique`, `not_null`, custom business rules
- **Ask team** which fields should have unique constraints

### 12. Audit Fields Handling - **STRICT RULE**
- **MANDATORY: Every model must include CREATE_DT and UPDATE_DT fields**
- **MANDATORY: Use SYSDATE() for both CREATE_DT and UPDATE_DT in all models**
- **MANDATORY: Include CREATE_BY, CREATE_PGM, UPDATE_BY, UPDATE_PGM fields as in ODI**
- **MANDATORY: Maintain exact same audit field logic as ODI package**
- **NEVER omit or modify audit field patterns from original ODI**

### 13. File Organization
- **Ask team** about preferred folder structure
- Default structure: Follow existing project patterns
- Maintain logical grouping by business domain/package

## Step-by-Step Process

### Phase 1: Analysis & Decomposition Planning
1. Analyze ODI package HTML file thoroughly
2. Identify **ALL** integration tasks and transformation logic - never omit any INSERT statements
3. Map out all source tables, staging tables, and target tables
4. Document **ALL** transformation logic and business rules
5. **List every INSERT statement and transformation** - ensure none are missed
6. **Identify all schemas mentioned in ODI SQL** - but never assume they are correct for target environment
7. **🚨 CRITICAL: Plan model decomposition strategy:**
   - **Count the number of interfaces/mappings in ODI package**
   - **Identify major transformation steps that should be separate models**
   - **Plan the model dependency chain: staging → intermediate → final**
   - **NEVER plan to put all logic in one model**

### Phase 2: Planning & Model Architecture Design
1. Ask team about:
   - Table naming conventions and purposes
   - Missing table/view logic
   - Required tests and unique constraints
   - Preferred folder structure
2. **Design model architecture with proper decomposition:**
   - **Plan staging models (stg_) for each data source/system**
   - **Plan intermediate models (int_) for complex transformations**
   - **Plan final models (dim_/fact_) for target tables**
   - **Document model dependencies and execution order**
3. Plan materialization strategy for each model
4. Identify macro requirements

### Phase 3: Implementation (Following Decomposition Strategy)
1. **🚨 FIRST PRIORITY: Create and execute table DDL in Snowflake for ALL incremental models**
   - **DDL files location**: `snowflake/{db}/{schema}/TABLES/[SCHEMA].[TABLE].sql`
   - **Execute in Snowflake immediately after creation**
   - **NEVER proceed to dbt model testing without this step**
2. **SECOND PRIORITY: Create and execute Snowflake sequences** (if needed)
   - **Sequence files location**: `snowflake/{db}/{schema}/SEQUENCES/[SCHEMA].[TABLE]_SEQ.sql`
   - **Execute in Snowflake immediately after creation**
3. **THIRD PRIORITY: Implement models in dependency order (NEVER all-in-one):**
   - **Step 3a: Create staging models (stg_) first** - One per data source or major transformation
   - **Step 3b: Create intermediate models (int_) second** - For complex business logic
   - **Step 3c: Create final models (dim_/fact_) last** - Usually incremental, combines staged data
4. **FOURTH PRIORITY: Create source files** for warehouse tables not in dbt
5. **Build and test each model individually** in dependency order
6. Create macros for update/delete logic
7. Implement tests as specified by team
8. Create .dbt job orchestration file with specific execution commands in dependency order
8. Create .dbt job orchestration file with specific execution commands

### Phase 4: Validation
1. **🚨 CRITICAL: Confirm all DDL has been executed before model testing**
2. Ensure all dependencies are satisfied
3. Verify materialization strategies match ODI behavior
4. Confirm naming conventions with team
5. **MANDATORY: Test model execution order with dbt build commands**
6. **MANDATORY: Run dbt test to validate data quality**
7. **MANDATORY: Verify all source schemas are correctly specified**
8. **NEVER declare conversion complete without successful test execution**

## Key Questions to Ask Team

### For Model Decomposition Strategy:
- **"This ODI package has [X] interfaces/mappings. Should I create separate dbt models for each transformation step?"**
- **"What naming convention should I use for staging (stg_), intermediate (int_), and final models?"**
- **"Which transformations are complex enough to warrant separate intermediate models?"**
- **"Should I break down this complex transformation into multiple models for better maintainability?"**

### For Each Table/Model:
- "What should this table be named and what is its business purpose?"
- "What is the table structure for [TABLE_NAME]?" (if creating incremental)
- "What tests do you want for this model?"
- "Which fields should have unique constraints?"

### For Missing Dependencies:
- "This ODI package references [TABLE/VIEW_NAME] which doesn't exist in our dbt project. Can you provide the logic or confirm it exists in Snowflake warehouse?"
- **"Which schema contains [TABLE/VIEW_NAME]? Don't assume schema locations from SQL logic."**

### For Source Schema Verification:
- **"Please confirm all source table schemas before I create the source configurations."**
- **"Are all dependencies in the same schema or distributed across multiple schemas?"**
- **"CRITICAL: The ODI SQL shows these schemas - please confirm if they are correct in the target environment:"**
  - **List each table with its ODI-shown schema and ask for confirmation**
- **"Do not assume any schemas from ODI SQL - always get explicit confirmation"**

### For Overall Structure:
- "What folder structure should I follow for these models?"
- "Are there any specific naming conventions I should follow?"

## Technical Implementation Notes

### Oracle to Snowflake Function Mappings:
- `NVL()` → `COALESCE()`
- `SYSDATE` → `SYSDATE()`
- `DECODE()` → `CASE WHEN`
- `ROWID` → Handle with dbt surrogate keys or ask team

### dbt Configurations:
```yaml
# For incremental models
{{ config(
    materialized='incremental',
    schema = 'dbt_test',
    unique_key=['column3', 'column4', 'column1']
) }}

# For models with post-hooks
{{ config(
    materialized='incremental',
    schema = 'dbt_test',
    unique_key=['column3', 'column4', 'column1'],
    post_hook="{{ macro_name() }}"
) }}
```

### Macro Template:
```sql
{% macro macro_name() %}
    {% set query %}
        -- Your update/delete logic here
        -- Use {{ this }} for self-referencing
    {% endset %}
    {% do run_query(query) %}
{% endmacro %}
```

## Success Criteria

Execution order preserved in .dbt job file

## Running and Troubleshooting dbt Models

### How to Run Decomposed Models
- **🚨 STEP 0 (CRITICAL): Execute table DDL in Snowflake BEFORE running incremental models for the first time**
- **🚨 STEP 0.5: Execute sequence DDL in Snowflake (if needed)**
- **STEP 1: Run models in dependency order (staging → intermediate → final):**
  - `dbt run --select stg_*` (run all staging models first)
  - `dbt run --select int_*` (run intermediate models second)
  - `dbt run --select dim_* fact_*` (run final models last)
- **For individual testing**: `dbt run --select model_name+` (includes downstream dependencies)
- Always execute commands in the order specified in the job file to respect dependencies.

### Troubleshooting Steps for Decomposed Models
1. **🚨 FIRST CHECK: Has table DDL been executed for incremental models?**
   - If incremental model fails with "{{ this }} not found" → DDL not executed
   - **This is the #1 cause of incremental model failures**
2. **🚨 SECOND CHECK: Are you testing models in correct dependency order?**
   - **Test staging models first** - `dbt run --select stg_model_name`
   - **Then test intermediate models** - `dbt run --select int_model_name`
   - **Finally test final models** - `dbt run --select final_model_name`
   - **NEVER test final model before its dependencies**
3. **For debugging complex issues:**
   - **Isolate the failing model** - Test each component separately
   - **Check intermediate model outputs** - Use `dbt run --select model_name` to verify data
   - **Use dbt show** - `dbt show --select model_name --limit 10` to preview data
2. If a model fails, review the dbt error output for details.
3. Check for:
   - Missing dependencies (tables/views not available)
   - Incorrect materialization or config settings
   - SQL syntax errors or incompatible functions
   - Data type mismatches
4. Use dbt's built-in debug tools:
   - `dbt debug` to check connection and environment
   - `dbt run --select [model]` to isolate issues
5. If the issue relates to missing logic or unclear requirements, ask the team for clarification.
6. Document any troubleshooting steps and resolutions for future reference.

### Questions to Ask During Troubleshooting
- **🚨 "Has the target table DDL been executed for incremental models?" (FIRST QUESTION)**
- **"Is the {{ this }} reference failing because the target table doesn't exist yet?"**
- "Is this dependency available in Snowflake or dbt?"
- "Are the configs and materializations correct for this model?"
- "Is there a macro or function that needs to be adapted for Snowflake?"
- "Do we need to adjust the model structure or add missing logic?"

This ensures not only the conversion but also the successful execution and maintenance of dbt models post-migration.

## Performance Considerations

No specific Snowflake performance optimizations needed unless requested.
Focus on logical correctness and maintainability.
Use dbt best practices for model organization.

This methodology ensures consistent, team-aligned conversions from ODI packages to modern dbt workflows on Snowflake.

## **🔐 FINAL COMPLIANCE VERIFICATION - MANDATORY BEFORE COMPLETION**

**⚠️ COPILOT MUST COMPLETE THIS FINAL VERIFICATION:**

### **DELIVERY CHECKLIST - ALL MUST BE ✅ BEFORE DECLARING SUCCESS**

#### **Model Architecture Compliance:**
- [ ] **Complex ODI packages decomposed into multiple models (NO monolithic models)**
- [ ] **Staging models created for each data source/system**
- [ ] **Intermediate models created for complex transformations**
- [ ] **Final models focused only on assembly/merge operations**
- [ ] **Model naming follows agreed conventions**

#### **Technical Implementation Compliance:**
- [ ] **DDL executed in Snowflake for ALL incremental models**
- [ ] **Sequences created and tested (if required)**
- [ ] **ALL ODI transformation logic preserved (no omissions)**
- [ ] **CTEs used instead of subqueries/derived tables**
- [ ] **MINUS operation used for change detection**
- [ ] **Audit fields included (CREATE_DT, UPDATE_DT, etc.)**

#### **Dependency & Schema Compliance:**
- [ ] **ALL source schemas explicitly confirmed with team**
- [ ] **NO placeholder or dummy models created**
- [ ] **ALL missing dependencies resolved with team input**
- [ ] **Source configurations created for external tables**
- [ ] **Dependencies properly referenced with {{ ref() }} or {{ source() }}**

#### **Testing & Validation Compliance:**
- [ ] **All models compile successfully**
- [ ] **dbt run commands executed and successful**
- [ ] **dbt test commands executed and successful**
- [ ] **Models tested in correct dependency order**
- [ ] **Job orchestration file created with proper execution sequence**

#### **Documentation & Communication Compliance:**
- [ ] **Team consulted for ALL required clarifications**
- [ ] **No assumptions made about missing information**
- [ ] **All business logic changes approved by team**
- [ ] **Testing results documented and shared**

### **🚫 REJECTION CRITERIA - If ANY of these exist, the work is INCOMPLETE:**
- Any monolithic model containing multiple ODI interface logic
- Any placeholder or incomplete model
- Any untested model
- Any missing dependency not resolved with team
- Any schema assumption not confirmed with team
- Any DDL not executed for incremental models

### **✅ SUCCESS DECLARATION FORMAT:**
```
🎯 ODI TO DBT CONVERSION COMPLETED SUCCESSFULLY

✅ COMPLIANCE VERIFIED:
- [X] Model decomposition: [X] staging, [X] intermediate, [X] final models created
- [X] DDL executed for [X] incremental models  
- [X] All [X] transformations preserved from ODI
- [X] All [X] dependencies resolved and confirmed
- [X] Testing completed: [X] compilation, [X] dbt run, [X] dbt test

📊 DELIVERABLES:
- [List all created models]
- [List all DDL files]
- [List all job files]
- [Testing results summary]
```

**⚠️ DO NOT DECLARE SUCCESS WITHOUT COMPLETING THIS VERIFICATION**

