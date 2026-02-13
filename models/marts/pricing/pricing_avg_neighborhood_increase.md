{% docs pricing_avg_neighborhood_increase %}

## Overview

This model calculates the average rental price increase per neighborhood using point-to-point comparison.
Compares the average listing price on the start date vs end date for each neighborhood then calculates the dollar difference.

## Column Classification

### Primary Key
- `neighborhood`

### Attribute keys
- `price_start_date` 
- `price_end_date`

### Metrics
- `avg_price_on_start_date`
- `avg_price_on_end_date`
- `avg_price_increase_usd`

## Configuration

`start_date` and `end_date` is parameterized via Jinja variables.
To look at different price comparion dates, update the variables at the top of the model.

## Exclusions

- Listings with NULL `neighborhood` in `stg__listings` are excluded.
- Listings NULL in `stg__calendar` on either the start or end date are excluded.

## Known Limitations

- **Small sample sizes**: Neighborhoods with too few listings may have skewed averages. For example, South Boston has only 2 listings, so a single listing's $50 price drop produces a -$25 neighborhood average.
- **Point-to-point sensitivity**: If a listing has volatile day-to-day pricing, the specific start/end dates could produce different results than a period-average approach. However, this metholodology can be revisited with a potentially more robust approach using period-average analysis instead.

{% enddocs %}
