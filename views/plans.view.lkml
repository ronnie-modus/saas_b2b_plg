view: plans {
  sql_table_name: @{schema}.plans ;;

  dimension: plan_id {
    type: string
    sql: ${TABLE}.plan_id ;;
    primary_key: yes
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
    label: "Plan Name"
    order_by_field: plan_sort
  }

  dimension: plan_sort {
    type: number
    sql: CASE ${TABLE}.plan_id
      WHEN 'free' THEN 1
      WHEN 'starter' THEN 2
      WHEN 'pro' THEN 3
      WHEN 'business' THEN 4
      WHEN 'enterprise' THEN 5
      ELSE 6
    END ;;
    hidden: yes
  }

  dimension: monthly_price_cents {
    type: number
    sql: ${TABLE}.monthly_price_cents ;;
    hidden: yes
  }

  dimension: monthly_price {
    type: number
    sql: ${TABLE}.monthly_price_cents / 100.0 ;;
    value_format_name: usd
    label: "Monthly Price ($)"
  }

  dimension: annual_price_cents {
    type: number
    sql: ${TABLE}.annual_price_cents ;;
    hidden: yes
  }

  dimension: annual_price {
    type: number
    sql: ${TABLE}.annual_price_cents / 100.0 ;;
    value_format_name: usd
    label: "Annual Price ($)"
  }

  dimension: max_members {
    type: number
    sql: ${TABLE}.max_members ;;
  }

  dimension: features_tier {
    type: string
    sql: ${TABLE}.features_tier ;;
  }

  dimension: is_active {
    type: yesno
    sql: ${TABLE}.is_active = 'True' ;;
  }

  dimension: is_paid {
    type: yesno
    sql: ${TABLE}.plan_id != 'free' ;;
  }

  dimension_group: created {
    type: time
    timeframes: [raw, date, week, month]
    sql: CAST(${TABLE}.created_at AS TIMESTAMP) ;;
  }

  measure: count {
    type: count
    drill_fields: [plan_id, name, monthly_price, features_tier]
  }
}
