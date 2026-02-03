-- Generic test: check that core_customers has no duplicates
select
  customer_id,
  count(*) as record_count
from {{ ref('core_customers') }}
group by customer_id
having count(*) > 1
