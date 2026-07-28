with source as (

    select * from {{ source('bronze', 'dimreseller') }}

),

renamed as (

    select
        ResellerKey           as reseller_key,
        GeographyKey          as geography_key,
        ResellerAlternateKey  as reseller_alternate_key,
        Phone                 as phone,
        BusinessType          as business_type,
        ResellerName          as reseller_name,
        NumberEmployees       as number_employees,
        OrderFrequency        as order_frequency,
        OrderMonth            as order_month,
        FirstOrderYear        as first_order_year,
        LastOrderYear         as last_order_year,
        ProductLine           as product_line,
        AddressLine1          as address_line1,
        AddressLine2          as address_line2,
        AnnualSales           as annual_sales,
        BankName              as bank_name,
        MinPaymentType        as min_payment_type,
        MinPaymentAmount      as min_payment_amount,
        AnnualRevenue         as annual_revenue,
        YearOpened            as year_opened

    from source

)

select * from renamed