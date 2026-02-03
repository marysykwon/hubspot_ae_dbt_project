{{ config(materialized='view') }}

select
  id as customer_id,
  first_name,
  last_name,
  {{ normalize_email('email') }} as email,
  current_timestamp() as loaded_at
from {{ ref('customers') }}
