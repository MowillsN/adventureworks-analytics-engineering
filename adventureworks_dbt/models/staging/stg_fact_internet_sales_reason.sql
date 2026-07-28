with source as (

    select * from {{ source('bronze', 'factinternetsalesreason') }}

),

renamed as (

    select
        SalesOrderNumber       as sales_order_number,
        SalesOrderLineNumber   as sales_order_line_number,
        SalesReasonKey         as sales_reason_key

    from source

)

select * from renamed