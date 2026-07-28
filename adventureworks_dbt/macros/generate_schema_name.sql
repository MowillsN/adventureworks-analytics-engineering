{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}

/* if a model specifies a custom schema (which all of ours do, via +schema: in dbt_project.yml),
 use that schema name exactly as-is. If a model doesn't specify one, fall back to the profile's default (gold, in the case of this project).
  */