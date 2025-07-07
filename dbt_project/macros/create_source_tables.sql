
{% macro create_source_tables() %}
    {% set sql = load_file('ddl/create_source_tables.sql') %}
    {% do run_query(sql) %}
    {{ log("Successfully executed create_source_tables.sql", info=True) }}
{% endmacro %}
