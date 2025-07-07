{% macro oracle_concat(arg1, arg2=None) %}
    {%- if arg2 is not none -%}
    {{ arg1 }} || {{ arg2 }}
  {%- else -%}
        {{ arg1 }}
    {%- endif -%}
{% endmacro %}

{#
  Convert Oracle CONCAT function to Snowflake concatenation.
  In Oracle: CONCAT(string1, string2)
  In Snowflake: string1 || string2

  Usage:
  {{ oracle_concat('column1', 'column2') }}

  This macro converts Oracle's CONCAT function to Snowflake's || operator.
  Note: This handles only two arguments. For multiple arguments, use multiple calls
  or modify the macro to handle variable arguments.
#}
