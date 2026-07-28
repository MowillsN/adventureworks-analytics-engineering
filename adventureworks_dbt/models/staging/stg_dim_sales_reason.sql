with source as (

    select * from {{ source('bronze', 'dimsalesreason') }}

),

renamed as (

    select
        SalesReasonKey       as sales_reason_key,
        SalesReasonAlternateKey as sales_reason_alternate_key,
        SalesReasonName       as sales_reason_name,
        SalesReasonReasonType as sales_reason_type

    from source

)

select * from renamed