{{
    config(
        materialized = 'view',
    )
}}

-- Materialized as view for easier dev/debugging (maybe can change to ephemeral if not re-used too many times downstream)
select
    listing_id
    , change_at
    , unnest(from_json(amenities, '["VARCHAR"]')) as amenity
from {{ ref('stg__amenities_changelog') }}
where amenities is not null
