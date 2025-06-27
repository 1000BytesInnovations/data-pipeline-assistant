{#
  Macro to handle Oracle date formatting in Snowflake
  Usage: {{ oracle_to_date('date_string', 'format') }}
#}

{% macro oracle_to_date(date_string, format='YYYY-MM-DD') %}
  {% set snowflake_format = format
      .replace('YYYY', 'YYYY')  # Year
      .replace('MM', 'MM')      # Month (numeric)
      .replace('MON', 'MON')    # Month (abbreviated name)
      .replace('MONTH', 'MONTH') # Month (full name)
      .replace('DD', 'DD')      # Day (numeric)
      .replace('DY', 'DY')      # Day (abbreviated name)
      .replace('DAY', 'DAY')    # Day (full name)
      .replace('HH24', 'HH24')  # Hour (24-hour format)
      .replace('MI', 'MI')      # Minute
      .replace('SS', 'SS')      # Second
  %}
  to_date({{ date_string }}, '{{ snowflake_format }}')
{% endmacro %}
