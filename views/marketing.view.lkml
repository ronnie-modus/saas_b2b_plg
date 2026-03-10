view: marketing_channels {
  sql_table_name: @{schema}.marketing_channels ;;

  dimension: channel_id {
    type: string
    sql: ${TABLE}.channel_id ;;
    primary_key: yes
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
    label: "Channel Name"
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
    label: "Channel Category"
  }

  dimension: is_paid {
    type: yesno
    sql: ${TABLE}.category = 'paid' ;;
  }

  measure: count {
    type: count
    drill_fields: [channel_id, name, category]
  }
}

view: marketing_campaigns {
  sql_table_name: @{schema}.marketing_campaigns ;;

  dimension: campaign_id {
    type: string
    sql: ${TABLE}.campaign_id ;;
    primary_key: yes
  }

  dimension: channel_id {
    type: string
    sql: ${TABLE}.channel_id ;;
    hidden: yes
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
    label: "Campaign Name"
  }

  dimension_group: start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: CAST(${TABLE}.start_date AS DATE) ;;
    convert_tz: no
  }

  dimension_group: end {
    type: time
    timeframes: [raw, date, week, month]
    sql: CAST(${TABLE}.end_date AS DATE) ;;
    convert_tz: no
  }

  dimension: budget_cents {
    type: number
    sql: ${TABLE}.budget_cents ;;
    hidden: yes
  }

  dimension: budget {
    type: number
    sql: ${TABLE}.budget_cents / 100.0 ;;
    value_format_name: usd_0
    label: "Budget ($)"
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: target_audience {
    type: string
    sql: ${TABLE}.target_audience ;;
  }

  dimension: is_summer_blast {
    type: yesno
    sql: ${TABLE}.name LIKE '%Summer%' OR ${TABLE}.campaign_id = 'camp_00045' ;;
    description: "July 2025 Summer Blast campaign"
  }

  dimension_group: created {
    type: time
    timeframes: [raw, date, week, month]
    sql: CAST(${TABLE}.created_at AS TIMESTAMP) ;;
  }

  measure: count {
    type: count
    drill_fields: [campaign_id, name, channel_id, budget, status]
  }

  measure: total_budget {
    type: sum
    sql: ${budget} ;;
    value_format_name: usd_0
  }

  measure: average_budget {
    type: average
    sql: ${budget} ;;
    value_format_name: usd_0
  }
}

view: marketing_touches {
  sql_table_name: @{schema}.marketing_touches ;;

  dimension: touch_id {
    type: string
    sql: ${TABLE}.touch_id ;;
    primary_key: yes
    hidden: yes
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
    hidden: yes
  }

  dimension: channel_id {
    type: string
    sql: ${TABLE}.channel_id ;;
  }

  dimension: campaign_id {
    type: string
    sql: ${TABLE}.campaign_id ;;
  }

  dimension: touch_type {
    type: string
    sql: ${TABLE}.touch_type ;;
    description: "first_touch, assist_touch, last_touch"
  }

  dimension: is_first_touch {
    type: yesno
    sql: ${TABLE}.touch_type = 'first_touch' ;;
  }

  dimension: is_last_touch {
    type: yesno
    sql: ${TABLE}.touch_type = 'last_touch' ;;
  }

  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}.created_at AS TIMESTAMP) ;;
  }

  measure: count {
    type: count
    drill_fields: [touch_id, user_id, channel_id, touch_type, created_date]
  }

  measure: count_first_touch {
    type: count
    filters: [touch_type: "first_touch"]
    label: "First Touches"
  }

  measure: count_last_touch {
    type: count
    filters: [touch_type: "last_touch"]
    label: "Last Touches"
  }

  measure: count_assist_touch {
    type: count
    filters: [touch_type: "assist_touch"]
    label: "Assist Touches"
  }

  measure: count_distinct_users {
    type: count_distinct
    sql: ${user_id} ;;
    label: "Unique Users"
  }

  measure: touches_per_user {
    type: number
    sql: 1.0 * ${count} / NULLIF(${count_distinct_users}, 0) ;;
    value_format_name: decimal_2
    description: "Average touches per user"
  }
}
