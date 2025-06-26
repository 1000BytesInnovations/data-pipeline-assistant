{{
  config(
    materialized='table',
    tags=['marts', 'sales', 'finance']
  )
}}

{# This model replicates functionality from Oracle PKG_SALES_REPORTS package #}

with sales_base as (
    select * from {{ ref('stg_sales_data') }}
),

customer_base as (
    select * from {{ ref('stg_customer_info') }}
),

sales_with_customers as (
    select 
        s.transaction_id,
        s.customer_id,
        c.customer_name,
        c.customer_type,
        s.product_id,
        s.transaction_date,
        s.amount,
        
        -- Date dimensions (replacing Oracle date functions)
        extract(year from s.transaction_date) as transaction_year,
        extract(month from s.transaction_date) as transaction_month,
        extract(day from s.transaction_date) as transaction_day,
        extract(quarter from s.transaction_date) as transaction_quarter,
        
        -- Business calculations (replacing Oracle package logic)
        case 
            when c.customer_type = 'CORPORATE' then s.amount * 0.95  -- Corporate discount
            when c.customer_type = 'INDIVIDUAL' then s.amount
            else s.amount * 0.98  -- Other discount
        end as net_amount,
        
        -- Running totals (replacing Oracle window functions)
        sum(s.amount) over (
            partition by s.customer_id 
            order by s.transaction_date 
            rows unbounded preceding
        ) as customer_lifetime_value
        
    from sales_base s
    left join customer_base c on s.customer_id = c.customer_id
    where c.status = 'ACTIVE'
),

final as (
    select 
        *,
        -- Additional metrics (replacing Oracle package calculations)
        case 
            when customer_lifetime_value >= 100000 then 'PLATINUM'
            when customer_lifetime_value >= 50000 then 'GOLD'
            when customer_lifetime_value >= 10000 then 'SILVER'
            else 'BRONZE'
        end as customer_tier,
        
        current_timestamp() as report_generated_at
        
    from sales_with_customers
)

select * from final
