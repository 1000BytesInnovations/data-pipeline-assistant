{{ config(
    materialized='view',
    tags=['oracle_conversion', 'finance'],
    meta={
        'oracle_package': 'PKG_FINANCE_CALC',
        'original_procedure': 'CALCULATE_CUSTOMER_SCORE',
        'conversion_notes': 'Converted Oracle procedure to dbt model with same business logic'
    }
) }}

/*
    This model converts the Oracle package PKG_FINANCE_CALC.CALCULATE_CUSTOMER_SCORE
    Original Oracle procedure calculated customer financial scores based on:
    - Payment history
    - Credit utilization
    - Account age
    - Total transactions
*/

with customer_payments as (
    select
        customer_id,
        count(*) as total_payments,
        sum(case when payment_status = 'ON_TIME' then 1 else 0 end) as on_time_payments,
        avg(payment_amount) as avg_payment_amount,
        max(payment_date) as last_payment_date
    from {{ ref('stg_payments') }}
    where payment_date >= add_months(current_date, -12)
    group by customer_id
),

customer_accounts as (
    select
        customer_id,
        min(account_open_date) as first_account_date,
        count(*) as total_accounts,
        sum(account_balance) as total_balance,
        sum(credit_limit) as total_credit_limit
    from {{ ref('stg_accounts') }}
    where account_status = 'ACTIVE'
    group by customer_id
),

-- Replicating Oracle package calculation logic
financial_score_calculation as (
    select
        c.customer_id,
        
        -- Payment score (40% weight) - matches Oracle logic
        case 
            when p.total_payments = 0 then 0
            else (p.on_time_payments * 1.0 / p.total_payments) * 40
        end as payment_score,
        
        -- Credit utilization score (30% weight) - matches Oracle logic  
        case
            when a.total_credit_limit = 0 then 30
            when (a.total_balance / a.total_credit_limit) <= 0.3 then 30
            when (a.total_balance / a.total_credit_limit) <= 0.7 then 20
            else 10
        end as credit_utilization_score,
        
        -- Account age score (20% weight) - matches Oracle logic
        case
            when months_between(current_date, a.first_account_date) >= 24 then 20
            when months_between(current_date, a.first_account_date) >= 12 then 15
            when months_between(current_date, a.first_account_date) >= 6 then 10
            else 5
        end as account_age_score,
        
        -- Transaction volume score (10% weight) - matches Oracle logic
        case
            when p.avg_payment_amount >= 1000 then 10
            when p.avg_payment_amount >= 500 then 8
            when p.avg_payment_amount >= 100 then 6
            else 3
        end as transaction_score,
        
        current_timestamp as calculation_date,
        'PKG_FINANCE_CALC' as source_package,
        'CALCULATE_CUSTOMER_SCORE' as source_procedure
        
    from {{ ref('stg_customers') }} c
    left join customer_payments p on c.customer_id = p.customer_id
    left join customer_accounts a on c.customer_id = a.customer_id
)

select
    {{ dbt_utils.generate_surrogate_key(['customer_id', 'calculation_date']) }} as calculation_id,
    customer_id,
    'FINANCIAL_SCORE' as calculation_type,
    (payment_score + credit_utilization_score + account_age_score + transaction_score) as calculation_result,
    calculation_date,
    source_package,
    source_procedure,
    
    -- Additional details for transparency
    payment_score,
    credit_utilization_score, 
    account_age_score,
    transaction_score
    
from financial_score_calculation
