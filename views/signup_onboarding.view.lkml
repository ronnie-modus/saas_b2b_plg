view: signup_events {
  sql_table_name: @{schema}.signup_events ;;

  dimension: event_id {
    type: string
    sql: ${TABLE}.event_id ;;
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
    label: "Signup Channel"
  }

  dimension: campaign_id {
    type: string
    sql: ${TABLE}.campaign_id ;;
  }

  dimension: platform {
    type: string
    sql: ${TABLE}.platform ;;
  }

  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
    map_layer_name: countries
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension: referrer_url {
    type: string
    sql: ${TABLE}.referrer_url ;;
    hidden: yes
  }

  dimension: utm_source {
    type: string
    sql: ${TABLE}.utm_source ;;
    group_label: "UTM Parameters"
  }

  dimension: utm_medium {
    type: string
    sql: ${TABLE}.utm_medium ;;
    group_label: "UTM Parameters"
  }

  dimension: utm_campaign {
    type: string
    sql: ${TABLE}.utm_campaign ;;
    group_label: "UTM Parameters"
  }

  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}.created_at AS TIMESTAMP) ;;
  }

  measure: count {
    type: count
    drill_fields: [event_id, user_id, channel_id, platform, created_date]
    label: "Signups"
  }

  measure: count_distinct_users {
    type: count_distinct
    sql: ${user_id} ;;
  }
}

view: onboarding_checklist_events {
  sql_table_name: @{schema}.onboarding_checklist_events ;;

  dimension: event_id {
    type: string
    sql: ${TABLE}.event_id ;;
    primary_key: yes
    hidden: yes
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
    hidden: yes
  }

  dimension: step_name {
    type: string
    sql: ${TABLE}.step_name ;;
    order_by_field: step_order
  }

  dimension: step_order {
    type: number
    sql: ${TABLE}.step_order ;;
  }

  dimension_group: completed {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: CAST(${TABLE}.completed_at AS TIMESTAMP) ;;
  }

  dimension: is_completed {
    type: yesno
    sql: ${TABLE}.completed_at IS NOT NULL ;;
  }

  measure: count {
    type: count
    drill_fields: [event_id, user_id, step_name, step_order, completed_date]
  }

  measure: count_completed {
    type: count
    filters: [is_completed: "yes"]
  }

  measure: count_distinct_users {
    type: count_distinct
    sql: ${user_id} ;;
    label: "Users"
  }

  measure: completion_rate {
    type: number
    sql: 1.0 * ${count_completed} / NULLIF(${count}, 0) ;;
    value_format_name: percent_1
  }
}
