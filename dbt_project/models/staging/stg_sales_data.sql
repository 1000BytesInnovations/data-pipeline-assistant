{{
  config(
    materialized='view',
    tags=['staging', 'sales']
  )
}}

with source_data as (
    select
        transaction_id,
        customer_id,
        product_id,
        transaction_date,
        amount,
        created_at,
        updated_at
    from {{ source('raw_data', 'sales_data') }}
),

cleaned_data as (
    select
        transaction_id,
        customer_id,
        product_id,
        cast(transaction_date as date) as transaction_date,
        cast(amount as decimal(15,2)) as amount,
        created_at,
        updated_at,
        
        -- Add audit fields
        current_timestamp() as dbt_loaded_at,
        '{{ invocation_id }}' as dbt_invocation_id
        
    from source_data
    where 
        transaction_id is not null
        and customer_id is not null
        and transaction_date is not null
        and amount >= 0
)

select * from cleaned_data
