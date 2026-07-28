-- This test fails if any rows are returned.
-- It checks that fct_sales (the unioned mart) has exactly as many rows
-- as fct_internet_sales + fct_reseller_sales combined — validating that
-- our UNION ALL in int_sales_unioned neither dropped nor duplicated rows.

with internet_count as (
    select count(*) as row_count from {{ ref('fct_internet_sales') }}
),

reseller_count as (
    select count(*) as row_count from {{ ref('fct_reseller_sales') }}
),

unioned_count as (
    select count(*) as row_count from {{ ref('fct_sales') }}
),

validation as (
    select
        internet_count.row_count as internet_rows,
        reseller_count.row_count as reseller_rows,
        unioned_count.row_count as unioned_rows,
        (internet_count.row_count + reseller_count.row_count) as expected_rows
    from internet_count, reseller_count, unioned_count
)

select *
from validation
where unioned_rows != expected_rows