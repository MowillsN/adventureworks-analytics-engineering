with source as (

    select * from {{ source('bronze', 'dimdate') }}

),

renamed as (

    select
        DateKey                as date_key,
        FullDateAlternateKey   as full_date,
        DayNumberOfWeek        as day_number_of_week,
        EnglishDayNameOfWeek   as day_name,
        SpanishDayNameOfWeek   as day_name_spanish,
        FrenchDayNameOfWeek    as day_name_french,
        DayNumberOfMonth       as day_number_of_month,
        DayNumberOfYear        as day_number_of_year,
        WeekNumberOfYear       as week_number_of_year,
        EnglishMonthName       as month_name,
        SpanishMonthName       as month_name_spanish,
        FrenchMonthName        as month_name_french,
        MonthNumberOfYear      as month_number_of_year,
        CalendarQuarter        as calendar_quarter,
        CalendarYear           as calendar_year,
        CalendarSemester       as calendar_semester,
        FiscalQuarter          as fiscal_quarter,
        FiscalYear             as fiscal_year,
        FiscalSemester         as fiscal_semester

    from source

)

select * from renamed