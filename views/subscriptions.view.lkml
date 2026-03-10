view: subscriptions {
  sql_table_name: @{schema}.subscriptions ;;

  dimension: subscription_id {
    type: string
    sql: ${TABLE}.subscription_id ;;
    primary_key: yes
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
    hidden: yes
  }

  dimension: plan_id {
    type: string
    sql: ${TABLE}.plan_id ;;
  }

  dimension: billing_interval {
    type: string
    sql: ${TABLE}.billing_interval ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
    html:
      {% if value == 'active' %}
        <span style="background:#22c55e;color:white;padding:2px 8px;border-radius:4px">{{ value }}</span>
      {% elsif value == 'canceled' %}
        <span style="background:#ef4444;color:white;padding:2px 8px;border-radius:4px">{{ value }}</span>
      {% else %}
        <span style="background:#94a3b8;color:white;padding:2px 8px;border-radius:4px">{{ value }}</span>
      {% endif %} ;;
  }

  dimension: is_paid {
    type: yesno
    sql: ${TABLE}.plan_id != 'free' ;;
  }

  dimension: cancel_reason {
    type: string
    sql: ${TABLE}.cancel_reason ;;
  }

  dimension_group: current_period_start {
    type: time
    timeframes: [raw, date, week, month]
    sql: CAST(${TABLE}.current_period_start AS DATE) ;;
    convert_tz: no
  }

  dimension_group: current_period_end {
    type: time
    timeframes: [raw, date, week, month]
    sql: CAST(${TABLE}.current_period_end AS DATE) ;;
    convert_tz: no
  }

  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}.created_at AS TIMESTAMP) ;;
  }

  dimension_group: canceled {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}.canceled_at AS TIMESTAMP) ;;
  }

  dimension: is_canceled {
    type: yesno
    sql: ${TABLE}.canceled_at IS NOT NULL ;;
  }

  measure: count {
    type: count
    drill_fields: [subscription_id, user_id, plan_id, status, created_date]
  }

  measure: count_active {
    type: count
    filters: [status: "active"]
  }

  measure: count_paid {
    type: count
    filters: [is_paid: "yes"]
  }

  measure: count_canceled {
    type: count
    filters: [is_canceled: "yes"]
  }
}
