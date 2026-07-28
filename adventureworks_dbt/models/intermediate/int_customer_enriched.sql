with customers as (

    select * from {{ ref('stg_dim_customer') }}

),

enriched as (

    select
        customer_key,
        geography_key,
        first_name,
        last_name,
        concat(first_name, ' ', last_name) as full_name,
        birth_date,
        marital_status,
        gender,
        yearly_income,
        total_children,
        number_children_at_home,
        education,
        occupation,
        house_owner_flag,
        date_first_purchase,
        floor(months_between(date_first_purchase, birth_date) / 12) as age_at_first_purchase

    from customers

),

banded as (

    select
        *,
        case
            when age_at_first_purchase < 25 then '18-24'
            when age_at_first_purchase between 25 and 34 then '25-34'
            when age_at_first_purchase between 35 and 44 then '35-44'
            when age_at_first_purchase between 45 and 54 then '45-54'
            when age_at_first_purchase between 55 and 64 then '55-64'
            else '65+'
        end as age_band_at_first_purchase

    from enriched

)

select * from banded