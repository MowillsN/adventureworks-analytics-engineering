with source as (

    select * from {{ source('bronze', 'dimpromotion') }}

),

renamed as (

    select
        PromotionKey           as promotion_key,
        PromotionAlternateKey  as promotion_alternate_key,
        EnglishPromotionName   as promotion_name,
        DiscountPct            as discount_pct,
        EnglishPromotionType   as promotion_type,
        EnglishPromotionCategory as promotion_category,
        StartDate              as start_date,
        EndDate                as end_date,
        MinQty                 as min_qty,
        MaxQty                 as max_qty

    from source

)

select * from renamed