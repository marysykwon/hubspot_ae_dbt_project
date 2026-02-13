{% docs longest_possible_stay_by_amenity %}

## Overview

This model identifies rental listings suitable for long-term stays by guests with specific amenity requirements, Lockbox and First aid kit. It analyzes all availability windows across the full calendar date range. It also compares maximum stay limits imposed during the availability window.

This model uses point-in-time amenity data from the changelog to ensure it only considers availability dates with both amenities present. Listings must have **both** amenities present in the changelog at the same point in time.

## Column Classification

### Primary Key
- `listing_id`

### Attributes
- `amenity_1`
- `amenity_2`
- `stay_start_date`
- `stay_end_date`

### Metrics
- `longest_possible_stay_duration_days`
- `max_nights`
- `exceeds_max_nights`

## Configuration

Amenities are parameterized via Jinja variables.
To analyze different amenity combinations, update these variables at the top of the model.

## Additional Considerations

- **Exceeds Max Nights**: When `exceeds_max_nights = true`, this means the listing has availability open for longer than its booking rules allow — a potential source configuration error. dbt test will flag this as a warning if true.
- **Max Nights Fluctuations**: There could be instances where 'max_nights' can change mid-window. To account for such cases, we take the most restrictive constraint, but this can depend on business decision.

{% enddocs %}
