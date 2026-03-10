view: product_errors {
  sql_table_name: @{schema}.product_errors ;;

  dimension: error_id {
    type: string
    sql: ${TABLE}.error_id ;;
    primary_key: yes
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
  }

  dimension: error_type {
    type: string
    sql: ${TABLE}.error_type ;;
  }

  dimension: error_severity {
    type: string
    sql: ${TABLE}.error_severity ;;
    html:
      {% if value == 'critical' %}
        <span style="background:#ef4444;color:white;padding:2px 8px;border-radius:4px">{{ value }}</span>
      {% elsif value == 'high' %}
        <span style="background:#f59e0b;color:white;padding:2px 8px;border-radius:4px">{{ value }}</span>
      {% elsif value == 'medium' %}
        <span style="background:#3b82f6;color:white;padding:2px 8px;border-radius:4px">{{ value }}</span>
      {% else %}
        <span style="background:#94a3b8;color:white;padding:2px 8px;border-radius:4px">{{ value }}</span>
      {% endif %} ;;
  }

  dimension: error_code {
    type: string
    sql: ${TABLE}.error_code ;;
  }

  dimension: platform {
    type: string
    sql: ${TABLE}.platform ;;
  }

  dimension: resolved {
    type: yesno
    sql: ${TABLE}.resolved = 'True' ;;
  }

  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}.created_at AS TIMESTAMP) ;;
  }

  # iOS Disaster Analysis (Feb 2026)
  dimension: is_feb_2026 {
    type: yesno
    sql: TO_CHAR(CAST(${TABLE}.created_at AS DATE), 'YYYY-MM') = '2026-02' ;;
    group_label: "iOS Disaster Analysis"
  }

  dimension: is_ios_feb_2026 {
    type: yesno
    sql: ${platform} = 'ios' AND TO_CHAR(CAST(${TABLE}.created_at AS DATE), 'YYYY-MM') = '2026-02' ;;
    group_label: "iOS Disaster Analysis"
    description: "iOS errors in Feb 2026 (sync disaster)"
  }

  dimension: is_sync_error {
    type: yesno
    sql: ${TABLE}.error_type = 'sync_error' ;;
    group_label: "iOS Disaster Analysis"
  }

  measure: count {
    type: count
    drill_fields: [error_id, user_id, error_type, error_severity, platform, created_date]
    label: "Errors"
  }

  measure: count_distinct_users {
    type: count_distinct
    sql: ${user_id} ;;
    label: "Affected Users"
  }

  measure: count_critical {
    type: count
    filters: [error_severity: "critical"]
    label: "Critical Errors"
  }

  measure: count_high {
    type: count
    filters: [error_severity: "high"]
    label: "High Severity Errors"
  }

  measure: count_ios {
    type: count
    filters: [platform: "ios"]
    label: "iOS Errors"
  }

  measure: count_android {
    type: count
    filters: [platform: "android"]
    label: "Android Errors"
  }

  measure: count_resolved {
    type: count
    filters: [resolved: "yes"]
    label: "Resolved Errors"
  }

  measure: resolution_rate {
    type: number
    sql: 1.0 * ${count_resolved} / NULLIF(${count}, 0) ;;
    value_format_name: percent_1
  }

  measure: errors_per_user {
    type: number
    sql: 1.0 * ${count} / NULLIF(${count_distinct_users}, 0) ;;
    value_format_name: decimal_2
  }

  measure: android_ios_ratio {
    type: number
    sql: 1.0 * ${count_android} / NULLIF(${count_ios}, 0) ;;
    value_format_name: decimal_2
    description: "Android errors / iOS errors ratio"
  }
}
