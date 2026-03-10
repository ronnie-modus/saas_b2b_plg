view: sessions {
  sql_table_name: @{schema}.sessions ;;

  dimension: session_id {
    type: string
    sql: ${TABLE}.session_id ;;
    primary_key: yes
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
    hidden: yes
  }

  dimension: platform {
    type: string
    sql: ${TABLE}.platform ;;
  }

  dimension: device_type {
    type: string
    sql: ${TABLE}.device_type ;;
  }

  dimension: duration_seconds {
    type: number
    sql: ${TABLE}.duration_seconds ;;
    hidden: yes
  }

  dimension: duration_minutes {
    type: number
    sql: ${TABLE}.duration_seconds / 60.0 ;;
    value_format_name: decimal_1
  }

  dimension: duration_tier {
    type: tier
    tiers: [1, 5, 15, 30, 60]
    style: integer
    sql: ${duration_minutes} ;;
    label: "Duration (minutes)"
  }

  dimension: pages_viewed {
    type: number
    sql: ${TABLE}.pages_viewed ;;
  }

  dimension: pages_viewed_tier {
    type: tier
    tiers: [1, 5, 10, 20, 50]
    style: integer
    sql: ${pages_viewed} ;;
  }

  dimension_group: started {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year, day_of_week, hour_of_day]
    sql: CAST(${TABLE}.started_at AS TIMESTAMP) ;;
  }

  dimension_group: ended {
    type: time
    timeframes: [raw, time, date]
    sql: CAST(${TABLE}.ended_at AS TIMESTAMP) ;;
  }

  measure: count {
    type: count
    drill_fields: [session_id, user_id, platform, duration_minutes, pages_viewed, started_date]
    label: "Sessions"
  }

  measure: count_distinct_users {
    type: count_distinct
    sql: ${user_id} ;;
    label: "Unique Users"
  }

  measure: total_duration_minutes {
    type: sum
    sql: ${duration_minutes} ;;
    value_format_name: decimal_0
  }

  measure: total_duration_hours {
    type: sum
    sql: ${duration_seconds} / 3600.0 ;;
    value_format_name: decimal_1
  }

  measure: average_duration_minutes {
    type: average
    sql: ${duration_minutes} ;;
    value_format_name: decimal_1
  }

  measure: total_pages_viewed {
    type: sum
    sql: ${pages_viewed} ;;
    value_format_name: large_number
  }

  measure: average_pages_per_session {
    type: average
    sql: ${pages_viewed} ;;
    value_format_name: decimal_1
  }

  measure: sessions_per_user {
    type: number
    sql: 1.0 * ${count} / NULLIF(${count_distinct_users}, 0) ;;
    value_format_name: decimal_2
  }
}

view: feature_usage {
  sql_table_name: @{schema}.feature_usage ;;

  dimension: usage_id {
    type: string
    sql: ${TABLE}.usage_id ;;
    primary_key: yes
    hidden: yes
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
    hidden: yes
  }

  dimension: session_id {
    type: string
    sql: ${TABLE}.session_id ;;
    hidden: yes
  }

  dimension: feature_id {
    type: string
    sql: ${TABLE}.feature_id ;;
    label: "Feature"
  }

  dimension: feature_category {
    type: string
    sql: ${TABLE}.feature_category ;;
  }

  dimension: is_templates_feature {
    type: yesno
    sql: ${TABLE}.feature_id = 'templates' ;;
    description: "Templates feature - key activation indicator"
  }

  dimension: action_count {
    type: number
    sql: ${TABLE}.action_count ;;
  }

  dimension: duration_seconds {
    type: number
    sql: ${TABLE}.duration_seconds ;;
    hidden: yes
  }

  dimension: duration_minutes {
    type: number
    sql: ${TABLE}.duration_seconds / 60.0 ;;
    value_format_name: decimal_1
  }

  dimension: platform {
    type: string
    sql: ${TABLE}.platform ;;
  }

  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}.created_at AS TIMESTAMP) ;;
  }

  measure: count {
    type: count
    drill_fields: [usage_id, user_id, feature_id, action_count, created_date]
    label: "Usage Events"
  }

  measure: count_distinct_users {
    type: count_distinct
    sql: ${user_id} ;;
    label: "Unique Users"
  }

  measure: count_distinct_features {
    type: count_distinct
    sql: ${feature_id} ;;
    label: "Features Used"
  }

  measure: total_actions {
    type: sum
    sql: ${action_count} ;;
    value_format_name: large_number
  }

  measure: total_duration_minutes {
    type: sum
    sql: ${duration_minutes} ;;
    value_format_name: decimal_0
  }

  measure: average_actions_per_session {
    type: average
    sql: ${action_count} ;;
    value_format_name: decimal_1
  }

  measure: count_templates_usage {
    type: count
    filters: [is_templates_feature: "yes"]
    label: "Templates Usage Events"
  }

  measure: count_templates_users {
    type: count_distinct
    sql: ${user_id} ;;
    filters: [is_templates_feature: "yes"]
    label: "Users Who Used Templates"
  }
}
