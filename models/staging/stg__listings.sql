{{
    config(
        materialized = 'view'
    )
}}

with source as (
    select * from {{ source('raw_data', 'LISTINGS') }}
),

-- Alias uppercase column names so that model contract can be enforced against its raw source schema.
renamed as (
    select
        "ID" as listing_id
        , "NAME" as listing_name
        , "HOST_ID" as host_id
        , "HOST_NAME" as host_name
        -- Time portion of datetime is always 00:00:00 in raw data, so ingesting as date
        , "HOST_SINCE"::date as host_since
        , "HOST_LOCATION" as host_location
        , "HOST_VERIFICATIONS" as host_verifications
        , "NEIGHBORHOOD" as neighborhood
        , "PROPERTY_TYPE" as property_type
        , "ROOM_TYPE" as room_type
        , "ACCOMMODATES" as max_guests
        -- Extract numeric portion from bathrooms_text (e.g. "1.5 baths") and cast to decimal.
        -- Used google to find regex pattern for extracting numeric portion of string.
        , nullif(trim(regexp_extract("BATHROOMS_TEXT", '\d+(\.\d+)?')), '')::decimal(4,1) as num_bathrooms
        -- Classify bathroom type from text; if not specified either private or shared then default to null
        , case
            when bathrooms_text is null
                then null
            when lower(bathrooms_text) like '%shared%'
                then 'shared'
            when lower(bathrooms_text) like '%private%'
                then 'private'
            else null
          end as bathroom_type
        -- Convert from varchar to integer with null handling 
        , nullif("BEDROOMS", '')::integer as num_bedrooms
        , "BEDS" as num_beds
        , "AMENITIES" as amenities 
        -- Convert from varchar to decimal after removing $ sign
        , replace("PRICE", '$', '')::decimal(10,2) as list_price_usd
        , "NUMBER_OF_REVIEWS" as num_reviews
        , "FIRST_REVIEW"::date as first_review_date
        , "LAST_REVIEW"::date as last_review_date
        -- Convert from varchar to decimal with null handling
        , nullif("REVIEW_SCORES_RATING", '')::decimal(3,2) as avg_review_score_rating
        , current_timestamp::timestamp as _loaded_at
    from source
)

select * from renamed
