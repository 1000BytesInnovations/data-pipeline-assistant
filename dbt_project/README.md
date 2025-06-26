# Oracle to dbt (Snowflake) Migration Project

## Overview
This project facilitates the migration of Oracle PL/SQL packages to dbt models running on Snowflake. The structure is designed to support coding assistants and maintain clear separation between different layers of data transformation.

## Project Structure

```
dbt_project/
├── models/                     # dbt models organized by layer
│   ├── staging/               # Raw data cleaning and standardization
│   ├── intermediate/          # Business logic and calculations
│   ├── marts/                # Final business-ready models
│   │   ├── finance/          # Finance domain models
│   │   ├── sales/            # Sales domain models
│   │   └── operations/       # Operations domain models
│   └── oracle_packages/      # Direct Oracle package conversions
├── macros/                   # Reusable SQL functions
│   └── oracle_utils/         # Oracle-to-Snowflake compatibility macros
├── tests/                    # Data quality tests
├── seeds/                    # Static reference data
├── snapshots/               # Slowly changing dimensions
├── analysis/                # Ad-hoc analytical queries
├── dbt_project.yml          # dbt project configuration
├── profiles.yml             # Database connection profiles
├── packages.yml             # dbt package dependencies
└── requirements.txt         # Python dependencies

oracle_packages/
├── source_code/              # Original Oracle package files
├── documentation/            # Package documentation
├── mapping/                 # Oracle-to-dbt mapping files
└── analysis/               # Conversion analysis and notes
```

## Getting Started

### Prerequisites
- Python 3.8+
- Access to Snowflake instance
- Git for version control

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd data-pipeline-assistant
   ```

2. **Set up Python environment**
   ```bash
   python -m venv dbt_env
   source dbt_env/bin/activate  # On Windows: dbt_env\Scripts\activate
   pip install -r dbt_project/requirements.txt
   ```

3. **Configure environment variables**
   ```bash
   cp dbt_project/.env.example dbt_project/.env
   # Edit .env file with your Snowflake credentials
   ```

4. **Install dbt packages**
   ```bash
   cd dbt_project
   dbt deps
   ```

5. **Test connection**
   ```bash
   dbt debug
   ```

6. **Run initial setup**
   ```bash
   dbt seed
   dbt run
   dbt test
   ```

## Oracle Package Conversion Process

### 1. Analysis Phase
- Place Oracle package files in `oracle_packages/source_code/`
- Document package functionality in `oracle_packages/documentation/`
- Create analysis reports in `oracle_packages/analysis/`

### 2. Mapping Phase
- Create mapping documents in `oracle_packages/mapping/`
- Identify source tables and target models
- Plan the conversion strategy

### 3. Implementation Phase
- Create staging models for data extraction
- Build intermediate models for business logic
- Develop mart models for final outputs
- Add appropriate tests and documentation

### 4. Validation Phase
- Compare outputs with original Oracle package results
- Implement data quality tests
- Performance optimization

## Development Workflow

### Branch Strategy
- `main`: Production-ready code
- `develop`: Integration branch
- `feature/*`: Feature development branches

### Making Changes
1. Create feature branch from `develop`
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/oracle-package-conversion
   ```

2. Make your changes and test locally
   ```bash
   dbt run --select +your_model
   dbt test --select +your_model
   ```

3. Commit and push changes
   ```bash
   git add .
   git commit -m "feat: convert Oracle PKG_EXAMPLE to dbt models"
   git push origin feature/oracle-package-conversion
   ```

4. Create Pull Request to `develop` branch

## dbt Commands Reference

```bash
# Install packages
dbt deps

# Run all models
dbt run

# Run specific model and its dependencies
dbt run --select +model_name

# Run all tests
dbt test

# Generate documentation
dbt docs generate
dbt docs serve

# Compile models (useful for debugging)
dbt compile

# Parse project for errors
dbt parse
```

## Snowflake Configuration

### Required Permissions
Your Snowflake user needs:
- `USAGE` on database and schema
- `CREATE TABLE` in target schemas
- `SELECT` on source tables

### Recommended Setup
```sql
-- Create databases
CREATE DATABASE ANALYTICS_DEV;
CREATE DATABASE ANALYTICS_PROD;

-- Create schemas
CREATE SCHEMA ANALYTICS_DEV.RAW_DATA;
CREATE SCHEMA ANALYTICS_DEV.DBT_DEV;
CREATE SCHEMA ANALYTICS_PROD.DBT_PROD;

-- Create warehouse
CREATE WAREHOUSE COMPUTE_WH 
  WITH WAREHOUSE_SIZE = 'SMALL' 
  AUTO_SUSPEND = 300 
  AUTO_RESUME = true;
```

## Coding Assistant Optimization

This project structure is optimized for coding assistants:

1. **Clear naming conventions**: Models, tests, and documentation follow consistent patterns
2. **Modular design**: Separation of concerns across layers
3. **Comprehensive documentation**: Each component is well-documented
4. **Standard dbt patterns**: Follows dbt best practices for assistant recognition

## Contributing

1. Follow the established folder structure
2. Add tests for all new models
3. Document all models and macros
4. Use semantic versioning for releases
5. Update this README for significant changes

## Support

For questions or issues:
1. Check the documentation in `docs/`
2. Review Oracle package mappings in `oracle_packages/mapping/`
3. Consult the conversion analysis in `oracle_packages/analysis/`

## License

[Add your license information here]
