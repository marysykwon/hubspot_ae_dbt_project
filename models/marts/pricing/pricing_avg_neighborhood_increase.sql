{{
    config(
        materialized = 'table',
    )
}}

-- Set the start and end dates to set the pricing comparison window.
-- These can be adjusted as needed to analyze different time periods.
-- If changing, ensure unit test values are also updated (see schema.yml).
{% set start_date = '2021-07-12' %}
{% set end_date = '2022-07-11' %}

-- Average rental price per neighborhood on the start and end dates
with avg_prices_by_date as (
    select
        l.neighborhood
        , c.availability_date
        , round(avg(c.rental_price_usd), 2) as avg_rental_price_usd
    from {{ ref('stg__calendar') }} as c
    -- Any listing without a neighborhood or rental price will be excluded
    -- from this analysis as these are required key inputs
    inner join {{ ref('stg__listings') }} as l
        on c.listing_id = l.listing_id
    where c.availability_date = '{{ start_date }}'
        or c.availability_date = '{{ end_date }}'
    group by 1, 2
)

-- Pivot to get one row per neighborhood with start and end avg prices as columns
, pivoted as (
    pivot avg_prices_by_date
    on availability_date
    using max(avg_rental_price_usd)
)

select
    neighborhood
    -- Use jinja variable and cast to date to derive the date value for start/end date
    , '{{ start_date }}'::date as price_start_date
    , '{{ end_date }}'::date as price_end_date
    -- Double-quoted to access the column value
    , "{{ start_date }}" as avg_price_on_start_date
    , "{{ end_date }}" as avg_price_on_end_date
    , round(avg_price_on_end_date - avg_price_on_start_date, 2) as avg_price_increase_usd
from pivoted
