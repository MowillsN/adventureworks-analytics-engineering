with source as (

    select * from {{ source('bronze', 'factresellersales') }}

),

renamed as (

    select
        ProductKey             as product_key,
        OrderDateKey           as order_date_key,
        DueDateKey             as due_date_key,
        ShipDateKey            as ship_date_key,
        ResellerKey            as reseller_key,
        EmployeeKey            as employee_key,
        PromotionKey           as promotion_key,
        CurrencyKey            as currency_key,
        SalesTerritoryKey      as sales_territory_key,
        SalesOrderNumber       as sales_order_number,
        SalesOrderLineNumber   as sales_order_line_number,
        RevisionNumber         as revision_number,
        OrderQuantity          as order_quantity,
        UnitPrice              as unit_price,
        ExtendedAmount         as extended_amount,
        UnitPriceDiscountPct   as unit_price_discount_pct,
        DiscountAmount         as discount_amount,
        ProductStandardCost    as product_standard_cost,
        TotalProductCost       as total_product_cost,
        SalesAmount            as sales_amount,
        TaxAmt                 as tax_amount,
        Freight                as freight,
        CarrierTrackingNumber  as carrier_tracking_number,
        CustomerPONumber       as customer_po_number,
        OrderDate              as order_date,
        DueDate                as due_date,
        ShipDate               as ship_date

    from source

)

select * from renamed