{{
  config(
    materialized='view',
    tags=['staging', 'customer']
  )
}}

with source_data as (
    select
        customer_id,
        customer_name,
        customer_type,
        registration_date,
        status,
        created_at,
        updated_at
    from {{ source('raw_data', 'customer_info') }}
),

cleaned_data as (
    select
        customer_id,
        trim(upper(customer_name)) as customer_name,
        case 
            when upper(customer_type) in ('INDIVIDUAL', 'IND') then 'INDIVIDUAL'
            when upper(customer_type) in ('CORPORATE', 'CORP', 'BUSINESS') then 'CORPORATE'
            else 'OTHER'
        end as customer_type,
        cast(registration_date as date) as registration_date,
        case 
            when upper(status) in ('ACTIVE', 'A') then 'ACTIVE'
            when upper(status) in ('INACTIVE', 'I') then 'INACTIVE'
            else 'UNKNOWN'
        end as status,
        created_at,
        updated_at,
        
        -- Add audit fields
        current_timestamp() as dbt_loaded_at,
        '{{ invocation_id }}' as dbt_invocation_id
        
    from source_data
    where 
        customer_id is not null
        and customer_name is not null
)

select * from cleaned_data
