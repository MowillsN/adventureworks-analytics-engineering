with source as (

    select * from {{ source('bronze', 'dimgeography') }}

),

renamed as (

    select
        GeographyKey           as geography_key,
        City                   as city,
        StateProvinceCode      as state_province_code,
        StateProvinceName      as state_province_name,
        CountryRegionCode      as country_region_code,
        EnglishCountryRegionName as country_region_name,
        PostalCode             as postal_code,
        SalesTerritoryKey      as sales_territory_key

    from source

)

select * from renamed