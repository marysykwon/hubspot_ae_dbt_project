{{
    config(
        materialized = 'table',
    )
}}

{% set amenity = 'Air conditioning' %}

-- Point-in-time AC availability from the amenities changelog.
-- Each row represents whether a listing had AC as of a given changelog timestamp.
with changelog_amenity_status as (
    select
        listing_id
        , change_at
        -- Will evaluate to true if any of the amenities at this point in time include 'Air conditioning'
        -- Edge cases: What are the expected values of each amenity type? Could there be variations like 'A/C'?
        -- Should we have an accepted values test for the amenity values?
        , max(amenity = 'Air conditioning') as has_amenity
    from {{ ref('int_amenities_changelog_json_unnested') }}
    group by 1, 2
)

-- For each reserved calendar day, find the most recent changelog entry
-- to determine if AC was available on that specific date.
-- Using LEFT join to preserve calendar rows that may not have a changelog match.

-- Mid-month changes in AC availability are handled naturally since this join is at
-- the day grain before aggregation in the final select.
, calendar_with_amenity as (
    select
        c.listing_id
        , c.availability_date
        , c.rental_price_usd
        -- Handle null cases (no AC status entry in changlog, assume no AC)
        , coalesce(cas.has_amenity, false) as has_amenity
    from {{ ref('stg__calendar') }} as c
    asof left join changelog_amenity_status as cas
        on c.listing_id = cas.listing_id
        and c.availability_date >= cas.change_at
    -- Does the business want to use reservation_id instead to determine the reservation date?
    -- Will need to ensure that reservation_id is consistently populated.
    where c.is_available = false
)

select
    date_trunc('month', availability_date) as reservation_month
    -- Total revenue by month
    , sum(rental_price_usd) as total_revenue_by_month_usd
    -- Calculate the percentage of revenue from listings with AC on the day of reservation
    , round(
        sum(case when has_amenity then rental_price_usd else 0 end)
        / total_revenue_by_month_usd * 100
      , 2) as pct_revenue_with_ac
    -- Calculate the percentage of revenue from listings without AC on the day of reservation
    , round(
        sum(case when not has_amenity then rental_price_usd else 0 end)
        / total_revenue_by_month_usd * 100
      , 2) as pct_revenue_without_ac
from calendar_with_amenity
group by 1
