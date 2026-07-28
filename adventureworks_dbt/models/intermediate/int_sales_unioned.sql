with internet_sales as (

    select
        product_key,
        order_date_key,
        due_date_key,
        ship_date_key,
        promotion_key,
        sales_territory_key,
        sales_order_number,
        sales_order_line_number,
        order_quantity,
        unit_price,
        extended_amount,
        unit_price_discount_pct,
        discount_amount,
        product_standard_cost,
        total_product_cost,
        sales_amount,
        tax_amount,
        freight,
        order_date,
        due_date,
        ship_date,
        'Internet' as sales_channel

    from {{ ref('stg_fact_internet_sales') }}

),

reseller_sales as (

    select
        product_key,
        order_date_key,
        due_date_key,
        ship_date_key,
        promotion_key,
        sales_territory_key,
        sales_order_number,
        sales_order_line_number,
        order_quantity,
        unit_price,
        extended_amount,
        unit_price_discount_pct,
        discount_amount,
        product_standard_cost,
        total_product_cost,
        sales_amount,
        tax_amount,
        freight,
        order_date,
        due_date,
        ship_date,
        'Reseller' as sales_channel

    from {{ ref('stg_fact_reseller_sales') }}

),

unioned as (

    select * from internet_sales
    union all
    select * from reseller_sales

)

select * from unioned