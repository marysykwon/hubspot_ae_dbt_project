{% docs revenue_by_month_ac %}

## Overview

Monthly revenue breakdown by air conditioning availability. Total revenue is calculated along with the percentage split between listings with and without AC, at the monthly grain.

The model uses point-in-time AC status from the amenities changelog to determine AC availability on the actual day of each reservation. Listings without changelog coverage are treated as without AC.

## Column Classification

### Primary Key
- `reservation_month`

### Metrics
- `total_revenue_by_month_usd`
- `pct_revenue_with_ac`
- `pct_revenue_without_ac`

## Configuration

Amenity is parameterized via Jinja variable.
To get revenue breakdown for a different amenity, update the variable at the top of the model.

## Considerations

- **Changelog Coverage**: Listings without an amenities changelog entry are assumed to not have AC.
- **Reservations Only**: Only reserved dates with a status of `is_available = false` are included in revenue calculations. Using `reservation_id` instead to determine revenue must operate on the assumption that `reservation_id` will always be non-null for reserved dates.

{% enddocs %}
