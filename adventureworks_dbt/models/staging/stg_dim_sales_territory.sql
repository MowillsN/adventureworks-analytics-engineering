with source as (

    select * from {{ source('bronze', 'dimsalesterritory') }}

),

renamed as (

    select
        SalesTerritoryKey          as sales_territory_key,
        SalesTerritoryAlternateKey as sales_territory_alternate_key,
        SalesTerritoryRegion       as sales_territory_region,
        SalesTerritoryCountry      as sales_territory_country,
        SalesTerritoryGroup        as sales_territory_group

    from source

)

select * from renamed