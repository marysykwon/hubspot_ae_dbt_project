{{
    config(
        materialized = 'view',
    )
}}

select
    listing_id
    , change_at
    , unnest(from_json(amenities, '["VARCHAR"]')) as amenity
from {{ ref('stg__amenities_changelog') }}
where amenities is not null
