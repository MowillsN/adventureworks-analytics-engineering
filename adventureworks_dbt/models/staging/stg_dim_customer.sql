with source as (

    select * from {{ source('bronze', 'dimcustomer') }}

),

renamed as (

    select
        CustomerKey            as customer_key,
        GeographyKey           as geography_key,
        CustomerAlternateKey   as customer_alternate_key,
        FirstName              as first_name,
        LastName               as last_name,
        BirthDate              as birth_date,
        MaritalStatus          as marital_status,
        Suffix                 as suffix,
        Gender                 as gender,
        EmailAddress           as email_address,
        YearlyIncome           as yearly_income,
        TotalChildren          as total_children,
        NumberChildrenAtHome   as number_children_at_home,
        EnglishEducation       as education,
        EnglishOccupation      as occupation,
        HouseOwnerFlag         as house_owner_flag,
        NumberCarsOwned        as number_cars_owned,
        DateFirstPurchase      as date_first_purchase,
        CommuteDistance        as commute_distance

    from source

)

select * from renamed