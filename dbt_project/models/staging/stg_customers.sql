{{ config(
    materialized='view',
    tags=['staging', 'customers']
) }}

with source_data as (
    select
        customer_id,
        customer_name,
        customer_email,
        customer_phone,
        customer_address,
        customer_city,
        customer_state,
        customer_country,
        customer_postal_code,
        customer_status,
        created_date,
        updated_date
    from {{ source('oracle_source', 'customers') }}
),

transformed as (
    select
        {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_key,
        customer_id,
        upper(trim(customer_name)) as customer_name,
        lower(trim(customer_email)) as customer_email,
        customer_phone,
        customer_address,
        customer_city,
        customer_state,
        customer_country,
        customer_postal_code,
        case 
            when customer_status = 'A' then true
            when customer_status = 'I' then false
            else null
        end as is_active,
        created_date as created_at,
        coalesce(updated_date, created_date) as updated_at
    from source_data
)

select * from transformed
