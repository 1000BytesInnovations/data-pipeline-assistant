{% macro oracle_to_date(date_string, format_string=None) %}
    {% if format_string %}
    to_date({{ date_string }}, '{{ format_string }}')
  {% else %}
    to_date({{ date_string }})
  {% endif %}
{% endmacro %}
