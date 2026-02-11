{% docs pricing_avg_neighborhood_increase %}

## Overview

Average rental price increase per neighborhood using point-to-point comparison.
Compares the average listing price on the start date vs end date for each neighborhood,
then calculates the dollar difference.

## Methodology

- **Comparison type**: Point-to-point (single day at start vs single day at end)
- **Aggregation**: Average price across all listings in a neighborhood on each date
- **Pivot**: DuckDB `PIVOT` transposes the two date rows into columns per neighborhood
- **Date range**: 2021-07-12 to 2022-07-11 (configurable via Jinja variables in the model)

## Column Classification

### Primary Key

| Column | Type | Description |
|---|---|---|
| `neighborhood` | varchar | Uniquely identifies each row. One row per neighborhood. |

### Attributes

| Column | Type | Description |
|---|---|---|
| `price_start_date` | date | Start date of the comparison period. Derived from Jinja variable, constant across all rows. |
| `price_end_date` | date | End date of the comparison period. Derived from Jinja variable, constant across all rows. |

### Metrics

| Column | Type | Description |
|---|---|---|
| `avg_price_on_start_date` | double | Average nightly rental price (USD) across listings in this neighborhood on the start date. |
| `avg_price_on_end_date` | double | Average nightly rental price (USD) across listings in this neighborhood on the end date. |
| `avg_price_increase_usd` | double | Dollar difference (`end - start`). Positive = increase, negative = decrease. |

## Exclusions

- Listings without a `neighborhood` in `stg__listings` are excluded.
- Listings not present in `stg__calendar` on either the start or end date are excluded.

## Known Limitations

- **Small sample sizes**: Neighborhoods with few listings may have skewed averages.
  For example, South Boston has only 2 listings, so a single listing's $50 price drop
  produces a -$25 neighborhood average.
- **Point-to-point sensitivity**: If a listing has volatile day-to-day pricing, the
  specific start/end dates could produce different results than a period-average approach.
  This dataset has stable pricing (prices hold for months), so this is not a concern here. However, this metholodology can be revisited with the potentially more robust approach using the period-average analysis.

{% enddocs %}
