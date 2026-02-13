

### Areas of AI asssistance:
    - Initialization of dbt project; Prompted AI to scaffold a dbt-duckdb project

    - Provided "official" documentation of tables (2 PDF files with table descriptions) to AI to prompt `schema.yml` generation of seed files, listing resources in alphabetical order. This includes column, data_type, and description. Ran `dbt seed` and manually validated schema was correct with `describe <table_name>`

    - Prompted AI to create staging models for each seed table using dbt best practices. Manually validated each transformation and made modifications as necessary
        - modified column names, cateogrize attributes
        - Added further in-line commentary as needed. 

    - Prompted to enforce model contracts in the staging models. Validated that data types were correctly inferred.

    - Prompted: what is the best way to unpack and query the "amenities" fields which seems to be a list array? I think this should be a staging model transformation but look at best dbt practices to inform your design and recommendation.

    - During validation of `revenue_by_month_ac`, I found that 4-5% of revenue was consistently missing. Prompted AI to debug and attributed to edge cases where `has_ac` is null because of missing data in listings table.

    - Documentation and testing. Copilot tends to err on side of providing too much information when generating docs so my job to review and slim down to relevant and meaningful info. For tests, copilot also tends to over-do tests, like implementing non-null for every single column. Data tests should catch things that actually could go wrong, not validate sql behavior


### Sources:
- duckdb does not have a `nullstr` config; `reservation_id` in Calendar` table to ingested as varchar to preserve raw data; nullif casting to be done in staging layer

### Intermediate:

- unnesting of json array done in intermediate layer; staging models should maintain same grain as source; any changes to grain is structural reshaping the dataset and belongs in the intermediate layer

### Additional commments / Questions
- Why does calendar.date schema description say `datetime` when all values are truncated to date? Is there a use-case to preserve this as a datetime type? Similarly, `listings.host_since` is also a datetime but time values are 00:00:00.000000000. I've decided to enforce `date` type to these column rather than datetime.

- `Calendar.reservation_id` is suppposedly a foreign key according to docs - what is it a foreign key to? `reservation_id` not found in any other table.

- `listings.list_price_usd` schema description says "The price of this listing as of the start of the date range in CALENDAR" -- should there be custom relationship test to ensure that this list price usd value is correctly reflected from the date range in the CALENDAR table?

-- `listings.bathrooms_text` some values are regular bath, some are shared, some are private. If a bath is not described as either private or shared, what is the default type?

-- For Long stay / picky renter problem, do we care about factoring in already reserved stays to determine the longest possible stay? Operating on assumpion of NO because the problem did not specifically indicate so.

### Gaps / Inconsistencies
-- JSON array in listings and amentities_changelog could potentially be unreliable; what do we know about the data entry process there? e.g will "Air conditioning" always have the same value or could there be variations like "A/C"?

-- Data Quality Issue: Relationship test cases failing where a `listing_id` from calendar table does not have a record in the listings table.

### Takeaways and Personal Learnings 

- model contracts are case-sensitive, ensure model definition can "match" exactly what's defined in the contract. Source systems containing uppercase columns would require aliasing if the intention is to adhere to lower casing best practices

- asof join

- duckdb treats pivot as a first-class operation and can standalone therefore is not wrapped in a select unlike Snowflake or SQL Server syntax