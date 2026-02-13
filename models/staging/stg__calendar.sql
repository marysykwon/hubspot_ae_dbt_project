{{
    config(
        materialized = 'view'
    )
}}

with source as (
    select * from {{ source('raw_data', 'CALENDAR') }}
),

-- Alias uppercase column names (for re-used columns) so that model contract can be enforced against its raw source schema.
renamed as (
    select
        "LISTING_ID" as listing_id
        , "DATE"::date as availability_date
        -- Cast to boolean based on 't'/'f' string values in raw data
        , case
            when "AVAILABLE" = 't'
                then true
            else false
          end as is_available
        -- Ingested as varchar due to 'NULL' strings; nullify these values and cast to integer
        , nullif("RESERVATION_ID", 'NULL')::integer as reservation_id
        -- Convert to decimal after removing $ sign
        , replace("PRICE", '$', '')::decimal(10,2) as rental_price_usd
        , "MINIMUM_NIGHTS" as min_nights
        , "MAXIMUM_NIGHTS" as max_nights
        , current_timestamp::timestamp as _loaded_at
    from source
)

select * from renamed
