{{
    config(
        materialized = 'view'
    )
}}

with source as (
    select * from {{ source('raw_data', 'AMENITIES_CHANGELOG') }}
),

-- Alias uppercase column names so that model contract can be enforced against its raw source schema.
renamed as (
    select
        "LISTING_ID" as listing_id
        , "CHANGE_AT" as change_at
        , "AMENITIES" as amenities
        , current_timestamp::timestamp as _loaded_at
    from source
)

select * from renamed
