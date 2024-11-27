{{ config(materialized='table') }}

with days as (
    {{ dbt.date_spine(
        'day',
        "'2000-01-01'::DATE",
        "'2025-01-01'::DATE"
    ) }}
),

final as (
    select cast(date_day as date) as date_day
    from days
)

select *
from final
where date_day > DATEADD(YEAR, -4, current_date())
  and date_day < DATEADD(DAY, 30, current_date())
