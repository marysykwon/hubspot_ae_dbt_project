# dbt (DuckDB) scaffold

Quick start:

1. Create a Python venv and install dependencies

   python -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt

2. Copy `profiles.yml.example` to your dbt profiles location:

   mkdir -p ~/.dbt
   cp profiles.yml.example ~/.dbt/profiles.yml

   (Update the `path` under `my_dbt_profile.outputs.dev` if you want a different DB file location.)

3. Run dbt commands

   dbt deps
   dbt seed
   dbt run
   dbt test
   dbt docs generate
   dbt docs serve

Notes:
- This scaffold uses DuckDB via the `dbt-duckdb` adapter. The DB file is `data/analytics.duckdb` by default.
- See `models/` and `seeds/` for examples.
