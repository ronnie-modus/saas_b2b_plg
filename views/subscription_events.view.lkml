view: subscription_events {
  sql_table_name: @{schema}.subscription_events ;;

  dimension: event_id {
    type: string
    sql: ${TABLE}.event_id ;;
    primary_key: yes
    hidden: yes
  }

  dimension: subscription_id {
    type: string
    sql: ${TABLE}.subscription_id ;;
    hidden: yes
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
    hidden: yes
  }

  dimension: event_type {
    type: string
    sql: ${TABLE}.event_type ;;
    description: "created, upgraded, downgraded, churned"
    html:
      {% if value == 'upgraded' %}
        <span style="background:#22c55e;color:white;padding:2px 8px;border-radius:4px">{{ value }}</span>
      {% elsif value == 'churned' %}
        <span style="background:#ef4444;color:white;padding:2px 8px;border-radius:4px">{{ value }}</span>
      {% elsif value == 'downgraded' %}
        <span style="background:#f59e0b;color:white;padding:2px 8px;border-radius:4px">{{ value }}</span>
      {% else %}
        <span style="background:#3b82f6;color:white;padding:2px 8px;border-radius:4px">{{ value }}</span>
      {% endif %} ;;
  }

  dimension: from_plan_id {
    type: string
    sql: ${TABLE}.from_plan_id ;;
    label: "From Plan"
  }

  dimension: to_plan_id {
    type: string
    sql: ${TABLE}.to_plan_id ;;
    label: "To Plan"
  }

  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}.created_at AS TIMESTAMP) ;;
  }

  dimension: is_before_price_change {
    type: yesno
    sql: ${TABLE}.created_at < '2025-10-01' ;;
    group_label: "Price Change Analysis"
  }

  dimension: price_change_period {
    type: string
    sql: CASE
      WHEN ${TABLE}.created_at < '2025-10-01' THEN 'Before Price Change'
      ELSE 'After Price Change'
    END ;;
    group_label: "Price Change Analysis"
  }

  measure: count {
    type: count
    drill_fields: [event_id, user_id, event_type, from_plan_id, to_plan_id, created_date]
  }

  measure: count_created {
    type: count
    filters: [event_type: "created"]
    label: "New Subscriptions"
  }

  measure: count_upgraded {
    type: count
    filters: [event_type: "upgraded"]
    label: "Upgrades"
  }

  measure: count_downgraded {
    type: count
    filters: [event_type: "downgraded"]
    label: "Downgrades"
  }

  measure: count_churned {
    type: count
    filters: [event_type: "churned"]
    label: "Churns"
  }

  measure: count_paid_upgrades {
    type: count
    filters: [event_type: "upgraded", to_plan_id: "-free"]
    label: "Paid Upgrades"
    description: "Upgrades to a paid plan"
  }

  measure: upgrade_rate {
    type: number
    sql: 1.0 * ${count_upgraded} / NULLIF(${count_created}, 0) ;;
    value_format_name: percent_1
    description: "Upgrades / New Subscriptions"
  }

  measure: churn_rate {
    type: number
    sql: 1.0 * ${count_churned} / NULLIF(${count}, 0) ;;
    value_format_name: percent_1
  }
}
