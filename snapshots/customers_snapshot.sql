{% snapshot customers_snapshot %}
  {%
    set build_incremental_logic = true
  %}

  select
    id as customer_id,
    first_name,
    last_name,
    email,
    current_timestamp() as dbt_valid_from,
    null::timestamp as dbt_valid_to
  from {{ ref('stg_customers') }}

  {% if execute %}
    {% if var('snapshot_start_date', false) %}
      where loaded_at >= '{{ var("snapshot_start_date") }}'
    {% endif %}
  {% endif %}

{% endsnapshot %}
