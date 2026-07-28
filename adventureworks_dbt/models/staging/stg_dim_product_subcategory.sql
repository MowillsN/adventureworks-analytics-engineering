with source as (

    select * from {{ source('bronze', 'dimproductsubcategory') }}

),

renamed as (

    select
        ProductSubcategoryKey        as product_subcategory_key,
        ProductSubcategoryAlternateKey as product_subcategory_alternate_key,
        EnglishProductSubcategoryName as product_subcategory_name,
        ProductCategoryKey            as product_category_key

    from source

)

select * from renamed