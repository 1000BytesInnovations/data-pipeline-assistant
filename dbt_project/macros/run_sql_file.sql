
{% macro run_sql_file(file_path) %}
    {% set sql = load_file(file_path) %}
    {% do run_query(sql) %}
    {{ log("Successfully executed SQL from " ~ file_path, info=True) }}
{% endmacro %}
