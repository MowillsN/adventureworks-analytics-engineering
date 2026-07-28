with products as (

    select * from {{ ref('stg_dim_product') }}

),

subcategories as (

    select * from {{ ref('stg_dim_product_subcategory') }}

),

categories as (

    select * from {{ ref('stg_dim_product_category') }}

),

joined as (

    select
        products.product_key,
        products.product_alternate_key,
        products.product_name,
        products.standard_cost,
        products.list_price,
        products.dealer_price,
        products.color,
        products.size,
        products.size_range,
        products.weight,
        products.class,
        products.style,
        products.model_name,
        products.description,
        products.product_line,
        products.finished_goods_flag,
        products.start_date,
        products.end_date,
        products.status,
        subcategories.product_subcategory_key,
        subcategories.product_subcategory_name,
        categories.product_category_key,
        categories.product_category_name

    from products
    left join subcategories
        on products.product_subcategory_key = subcategories.product_subcategory_key
    left join categories
        on subcategories.product_category_key = categories.product_category_key

)

select * from joined