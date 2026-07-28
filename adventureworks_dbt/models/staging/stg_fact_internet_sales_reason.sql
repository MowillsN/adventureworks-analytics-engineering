with source as (

    select * from {{ source('bronze', 'factinternetsalesreason') }}

),

renamed as (

    select
        concat(SalesOrderNumber, '-', cast(SalesOrderLineNumber as string)) as sales_order_line_key,
        SalesOrderNumber       as sales_order_number,
        SalesOrderLineNumber   as sales_order_line_number,
        SalesReasonKey         as sales_reason_key

    from source

)

select * from renamed