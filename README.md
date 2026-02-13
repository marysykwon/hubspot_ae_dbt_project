# Rental Property Analytics (dbt + DuckDB)

A dbt project that models rental property data using DuckDB as an embedded local database. No external database setup required — everything runs locally.

This project models three business problems:

1. **Revenue by AC** — Total revenue and percentage of revenue by month, segmented by whether air conditioning exists on the listing.
2. **Neighborhood Pricing** — Average price increase for each neighborhood from July 12, 2021 to July 11, 2022.
3. **Longest Possible Stay** — Longest possible stay duration for listings that include both a lockbox and first aid kit, considering availability windows and maximum stay limits.

## Project Structure

```
models/
  staging/         -- cleaned source data 
  intermediate/    -- transformation logic
  marts/           -- business entities
    availability/  -- longest possible stay analysis by amenities
    pricing/       -- neighborhood price trends
    revenue/       -- revenue segmented by amenity (AC)
seeds/             -- raw CSV source data (LISTINGS, CALENDAR, AMENITIES_CHANGELOG)
```

## Prerequisites

1. **Python 3.9+** — Required to run dbt-core and dbt-duckdb. Verify with:
   ```bash
   python --version
   ```

2. **DuckDB CLI** — For querying the database directly.
   ```bash
   brew install duckdb
   ```

## Setup

1. **Clone the repo**
   ```bash
   git clone <https://github.com/marysykwon/hubspot_ae_dbt_project.git>
   cd hubspot_ae_dbt_project
   ```

2. **Create a virtual environment and install dependencies**
   ```bash
   python -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt
   ```

3. **Install dbt packages**
   ```bash
   dbt deps
   ```

> **Note on `profiles.yml`:** `profiles.yml` is committed to the repo root, so no need to configure `~/.dbt/profiles.yml`. dbt automatically picks up the root file since it lives within the project scope.

## Running the Project

Run the following commands in order:

```bash
# 1. Load CSV seed data into DuckDB
dbt seed

# 2. Run all models (staging → intermediate → marts)
dbt run

# 3. Run data and unit tests
dbt test

# 4. [Optional] Or do all of the above in DAG order
dbt build
```

The DuckDB database file is generated at `duckdb/rental_property_dev_db.duckdb`. This file is not committed to the repo — it is rebuilt with each dbt execution.

## Querying DuckDB

Connect to the database with the DuckDB CLI:

```bash
duckdb duckdb/rental_property_dev_db.duckdb
```

View available schemas and tables:

```sql
SHOW ALL TABLES;
```

## Generate Documentation

These docs commands will generate and deploy your docs locally at `http://localhost:8080/`.
```bash
dbt docs generate
dbt docs serve
```
