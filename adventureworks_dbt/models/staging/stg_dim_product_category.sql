with source as (

    select * from {{ source('bronze', 'dimproductcategory') }}

),

renamed as (

    select
        ProductCategoryKey        as product_category_key,
        ProductCategoryAlternateKey as product_category_alternate_key,
        EnglishProductCategoryName as product_category_name

    from source

)

select * from renamed