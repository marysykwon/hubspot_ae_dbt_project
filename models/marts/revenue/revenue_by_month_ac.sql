{{
    config(
        materialized = 'table',
    )
}}

-- Point-in-time AC availability from the amenities changelog.
-- Each row represents whether a listing had AC as of a given changelog timestamp.
with changelog_ac_status as (
    select
        listing_id
        -- Timestamp when the amenities list changed.
        , change_at
        -- Will evaluate to true if any of the amenities at this point in time include 'Air conditioning'
        -- Edge case: What are the expected values of each amenity type? Could there be variations like 'A/C'?
        , max(amenity = 'Air conditioning') as has_ac
    from {{ ref('int_amenities_changelog_json_unnested') }}
    group by 1, 2
)

-- ASOF LEFT JOIN: for each reserved calendar day, find the most recent changelog entry
-- to determine if AC was available on that specific date.
-- Using LEFT join to preserve calendar rows that may not have a changelog match.
, calendar_with_ac as (
    select
        c.listing_id
        , c.availability_date
        , c.rental_price_usd
        , coalesce(ac.has_ac, false) as has_ac
    from {{ ref('stg__calendar') }} as c
    asof left join changelog_ac_status as ac
        on c.listing_id = ac.listing_id
        and c.availability_date >= ac.change_at
    where c.is_available = false
)

select
    date_trunc('month', availability_date) as reservation_month
    -- Total revenue by month
    , sum(rental_price_usd) as total_revenue_by_month_usd
    -- Calculate the percentage of revenue from listings with AC on the day of reservation
    , round(
        sum(case when has_ac then rental_price_usd else 0 end)
        / total_revenue_by_month_usd * 100
      , 2) as pct_revenue_with_ac
    -- Calculate the percentage of revenue from listings without AC on the day of reservation
    , round(
        sum(case when not has_ac then rental_price_usd else 0 end)
        / total_revenue_by_month_usd * 100
      , 2) as pct_revenue_without_ac
from calendar_with_ac
group by 1
