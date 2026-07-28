-- Sourced from int_customer_enriched; testing CI pipeline
select * from {{ ref('int_customer_enriched') }}