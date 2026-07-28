with source as (

    select * from {{ source('bronze', 'dimproduct') }}

),

renamed as (

    select
        ProductKey              as product_key,
        ProductAlternateKey     as product_alternate_key,
        ProductSubcategoryKey   as product_subcategory_key,
        WeightUnitMeasureCode   as weight_unit_measure_code,
        SizeUnitMeasureCode     as size_unit_measure_code,
        EnglishProductName      as product_name,
        StandardCost            as standard_cost,
        FinishedGoodsFlag       as finished_goods_flag,
        Color                   as color,
        SafetyStockLevel        as safety_stock_level,
        ReorderPoint            as reorder_point,
        ListPrice               as list_price,
        Size                    as size,
        SizeRange               as size_range,
        Weight                  as weight,
        DaysToManufacture       as days_to_manufacture,
        ProductLine             as product_line,
        DealerPrice             as dealer_price,
        Class                   as class,
        Style                   as style,
        ModelName               as model_name,
        EnglishDescription      as description,
        StartDate               as start_date,
        EndDate                 as end_date,
        Status                  as status

    from source

)

select * from renamed