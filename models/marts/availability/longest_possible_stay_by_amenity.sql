{{
    config(
        materialized = 'table',
    )
}}

-- Set the start and end dates to set amenity criteria
-- These can be adjusted as needed to analyze different occupancy durations based on different amenities.
{% set amenity_1 = 'Lockbox' %}
{% set amenity_2 = 'First aid kit' %}

with find_listings_with_amenity_criteria as (
    select
        listing_id
        , change_at
    from {{ ref('int_amenities_changelog_json_unnested') }}
    where amenity in ('{{ amenity_1 }}', '{{ amenity_2 }}')
    group by 1, 2
    -- Filter listings that have both amenities available at time of changelog entry
    having count(distinct amenity) = 2
)

-- Calendar dates where the listing had both amenities at that point in time
, calendar_with_amenities as (
    select
        c.listing_id
        , c.availability_date
        , c.is_available
        , c.max_nights
    from {{ ref('stg__calendar') }} as c
    asof inner join find_listings_with_amenity_criteria as a
        on c.listing_id = a.listing_id
        and c.availability_date >= a.change_at
    where c.is_available = true
)

-- Gaps & Islands approach to identify windows of consecutive available dates
-- Identify windows with consecutive available dates and assign a unique window_id 
, available_windows as (
    select
        listing_id
        , availability_date
        , max_nights
        -- Difference between availability date and row_number creates a unique window_id for consecutive groupings
        , availability_date - row_number() over (
            partition by listing_id
            order by availability_date
        )::int as temp_window_id -- Natural key grouping of consectutive available dates; INT cast for date arithmetic
    from calendar_with_amenities
)

-- Longest availability window per listing, grouped by artificial key temp_window_id
, longest_available_window as (
    select
        listing_id
        , temp_window_id
        -- We take the min here to account for scenarios where max_nights changes mid-window
        -- Business assumption: We want to apply the most restictive contraint during that window
        -- Alternative is that we group by max_nights as well, but we risk splitting consecutive windows (operates on assumption that max_nights are constant)
        -- Cases where max_nights changes mid-window (only 1 instance for listing 863788)
        , min(max_nights) as max_nights
        , min(availability_date) as stay_start_date
        , max(availability_date) as stay_end_date
        , count(*) as stay_length_days
        , row_number() over (
            partition by listing_id
            order by count(*) desc
        ) as available_window_rank
    from available_windows
    group by listing_id, temp_window_id
    -- Filter for longest available window per listing
    qualify available_window_rank = 1
)

select
    listing_id
    , '{{ amenity_1 }}' as amenity_1
    , '{{ amenity_2 }}' as amenity_2
    , stay_start_date
    , stay_end_date
    , stay_length_days as longest_possible_stay_duration_days
    , max_nights
    , stay_length_days > max_nights as exceeds_max_nights
from longest_available_window
