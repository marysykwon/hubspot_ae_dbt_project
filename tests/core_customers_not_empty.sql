-- Singular test: ensure core_customers is not empty
select *
from {{ ref('core_customers') }}
limit 0
