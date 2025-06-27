/*
    Oracle Package Conversion Utilities
    Macros to help convert Oracle-specific functions and procedures to dbt/SQL
*/

{% macro oracle_months_between(date1, date2) %}
    /*
    Replicates Oracle's MONTHS_BETWEEN function
    Returns the number of months between two dates
    */
    {% if target.type == 'oracle' %}
        months_between({{ date1 }}, {{ date2 }})
    {% elif target.type == 'snowflake' %}
        datediff('month', {{ date2 }}, {{ date1 }})
    {% elif target.type == 'bigquery' %}
        date_diff({{ date1 }}, {{ date2 }}, 'month')
    {% elif target.type == 'postgres' %}
        extract(year from age({{ date1 }}, {{ date2 }})) * 12 + extract(month from age({{ date1 }}, {{ date2 }}))
    {% else %}
        -- Default implementation
        (extract(year from {{ date1 }}) - extract(year from {{ date2 }})) * 12 + 
        (extract(month from {{ date1 }}) - extract(month from {{ date2 }}))
    {% endif %}
{% endmacro %}

{% macro oracle_add_months(date_col, months) %}
    /*
    Replicates Oracle's ADD_MONTHS function
    Adds specified number of months to a date
    */
    {% if target.type == 'oracle' %}
        add_months({{ date_col }}, {{ months }})
    {% elif target.type == 'snowflake' %}
        dateadd('month', {{ months }}, {{ date_col }})
    {% elif target.type == 'bigquery' %}
        date_add({{ date_col }}, interval {{ months }} month)
    {% elif target.type == 'postgres' %}
        {{ date_col }} + interval '{{ months }} months'
    {% else %}
        -- Default implementation for most SQL dialects
        {{ date_col }} + interval '{{ months }}' month
    {% endif %}
{% endmacro %}

{% macro oracle_nvl(expr1, expr2) %}
    /*
    Replicates Oracle's NVL function
    Returns expr2 if expr1 is null, otherwise returns expr1
    */
    {% if target.type == 'oracle' %}
        nvl({{ expr1 }}, {{ expr2 }})
    {% else %}
        coalesce({{ expr1 }}, {{ expr2 }})
    {% endif %}
{% endmacro %}

{% macro oracle_decode(expression, search1, result1, search2=none, result2=none, default=none) %}
    /*
    Replicates Oracle's DECODE function
    Simplified version supporting up to 2 search/result pairs
    */
    {% if target.type == 'oracle' %}
        decode({{ expression }}, {{ search1 }}, {{ result1 }}
        {%- if search2 and result2 %}, {{ search2 }}, {{ result2 }}{% endif %}
        {%- if default %}, {{ default }}{% endif %})
    {% else %}
        case 
            when {{ expression }} = {{ search1 }} then {{ result1 }}
            {%- if search2 and result2 %}
            when {{ expression }} = {{ search2 }} then {{ result2 }}
            {%- endif %}
            {%- if default %}
            else {{ default }}
            {%- endif %}
        end
    {% endif %}
{% endmacro %}

{% macro oracle_to_char(date_expr, format_mask='YYYY-MM-DD') %}
    /*
    Replicates Oracle's TO_CHAR function for dates
    */
    {% if target.type == 'oracle' %}
        to_char({{ date_expr }}, '{{ format_mask }}')
    {% elif target.type == 'snowflake' %}
        to_varchar({{ date_expr }}, '{{ format_mask }}')
    {% elif target.type == 'bigquery' %}
        format_datetime('{{ format_mask | replace("YYYY", "%Y") | replace("MM", "%m") | replace("DD", "%d") }}', {{ date_expr }})
    {% elif target.type == 'postgres' %}
        to_char({{ date_expr }}, '{{ format_mask }}')
    {% else %}
        cast({{ date_expr }} as string)
    {% endif %}
{% endmacro %}
