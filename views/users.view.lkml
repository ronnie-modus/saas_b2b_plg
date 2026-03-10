view: users {
  sql_table_name: @{schema}.users ;;

  # ============================================================================
  # PRIMARY KEY
  # ============================================================================

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
    primary_key: yes
    hidden: yes
  }

  # ============================================================================
  # IDENTITY DIMENSIONS
  # ============================================================================

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
    group_label: "Identity"
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}.company_id ;;
    hidden: yes
  }

  dimension: referred_by_user_id {
    type: string
    sql: ${TABLE}.referred_by_user_id ;;
    hidden: yes
  }

  dimension: is_referred {
    type: yesno
    sql: ${TABLE}.referred_by_user_id IS NOT NULL ;;
    group_label: "Acquisition"
    description: "User was referred by another user"
  }

  # ============================================================================
  # SEGMENT DIMENSIONS
  # ============================================================================

  dimension: industry {
    type: string
    sql: ${TABLE}.industry ;;
    group_label: "Segments"
  }

  dimension: size_category {
    type: string
    sql: ${TABLE}.size_category ;;
    group_label: "Segments"
    order_by_field: size_category_sort
    description: "Company size: solo, small, medium, growth, large, enterprise"
  }

  dimension: size_category_sort {
    type: number
    sql: CASE ${TABLE}.size_category
      WHEN 'solo' THEN 1
      WHEN 'small' THEN 2
      WHEN 'medium' THEN 3
      WHEN 'growth' THEN 4
      WHEN 'large' THEN 5
      WHEN 'enterprise' THEN 6
      ELSE 7
    END ;;
    hidden: yes
  }

  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
    group_label: "Geography"
    map_layer_name: countries
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
    group_label: "Geography"
  }

  dimension: region {
    type: string
    sql: CASE
      WHEN ${TABLE}.country IN ('UK', 'Germany', 'France', 'Netherlands', 'Spain') THEN 'Europe'
      WHEN ${TABLE}.country = 'US' THEN 'US'
      ELSE 'Other'
    END ;;
    group_label: "Geography"
  }

  # ============================================================================
  # ACQUISITION DIMENSIONS
  # ============================================================================

  dimension: primary_platform {
    type: string
    sql: ${TABLE}.primary_platform ;;
    group_label: "Acquisition"
  }

  dimension: signup_channel_id {
    type: string
    sql: ${TABLE}.signup_channel_id ;;
    group_label: "Acquisition"
    label: "Signup Channel"
  }

  dimension: signup_channel_category {
    type: string
    sql: CASE
      WHEN ${TABLE}.signup_channel_id IN ('paid_search', 'paid_social') THEN 'Paid'
      WHEN ${TABLE}.signup_channel_id IN ('organic_search', 'organic_social', 'content_seo') THEN 'Organic'
      WHEN ${TABLE}.signup_channel_id = 'referral' THEN 'Referral'
      WHEN ${TABLE}.signup_channel_id = 'direct' THEN 'Direct'
      ELSE 'Other'
    END ;;
    group_label: "Acquisition"
  }

  # ============================================================================
  # DATE DIMENSIONS
  # ============================================================================

  dimension_group: signup {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: CAST(${TABLE}.signup_date AS DATE) ;;
    convert_tz: no
    datatype: date
  }

  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}.created_at AS TIMESTAMP) ;;
  }

  dimension: signup_cohort_month {
    type: string
    sql: TO_CHAR(CAST(${TABLE}.signup_date AS DATE), 'YYYY-MM') ;;
    group_label: "Cohorts"
    order_by_field: signup_date
  }

  dimension: signup_cohort_week {
    type: string
    sql: TO_CHAR(DATE_TRUNC('week', CAST(${TABLE}.signup_date AS DATE)), 'YYYY-MM-DD') ;;
    group_label: "Cohorts"
  }

  dimension: days_since_signup {
    type: number
    sql: EXTRACT(DAY FROM CURRENT_DATE - CAST(${TABLE}.signup_date AS DATE)) ;;
    group_label: "Cohorts"
  }

  # ============================================================================
  # STATUS DIMENSIONS
  # ============================================================================

  dimension: is_activated {
    type: yesno
    sql: ${TABLE}.is_activated = 'True' ;;
    group_label: "Status"
  }

  dimension: is_churned {
    type: yesno
    sql: ${TABLE}.is_churned = 'True' ;;
    group_label: "Status"
  }

  dimension: user_status {
    type: string
    sql: CASE
      WHEN ${TABLE}.is_churned = 'True' THEN 'Churned'
      WHEN ${TABLE}.is_activated = 'True' THEN 'Active'
      ELSE 'Pending Activation'
    END ;;
    group_label: "Status"
    html:
      {% if value == 'Active' %}
        <span style="background:#22c55e;color:white;padding:2px 8px;border-radius:4px">{{ value }}</span>
      {% elsif value == 'Churned' %}
        <span style="background:#ef4444;color:white;padding:2px 8px;border-radius:4px">{{ value }}</span>
      {% else %}
        <span style="background:#f59e0b;color:white;padding:2px 8px;border-radius:4px">{{ value }}</span>
      {% endif %} ;;
  }

  # ============================================================================
  # MEASURES
  # ============================================================================

  measure: count {
    type: count
    drill_fields: [user_detail*]
  }

  measure: count_activated {
    type: count
    filters: [is_activated: "yes"]
    drill_fields: [user_detail*]
  }

  measure: count_churned {
    type: count
    filters: [is_churned: "yes"]
    drill_fields: [user_detail*]
  }

  measure: count_referred {
    type: count
    filters: [is_referred: "yes"]
    drill_fields: [user_detail*]
  }

  measure: activation_rate {
    type: number
    sql: 1.0 * ${count_activated} / NULLIF(${count}, 0) ;;
    value_format_name: percent_1
    description: "% of users who activated"
  }

  measure: churn_rate {
    type: number
    sql: 1.0 * ${count_churned} / NULLIF(${count_activated}, 0) ;;
    value_format_name: percent_1
    description: "% of activated users who churned"
  }

  measure: retention_rate {
    type: number
    sql: 1.0 - ${churn_rate} ;;
    value_format_name: percent_1
    description: "% of activated users retained"
  }

  # ============================================================================
  # DRILL SETS
  # ============================================================================

  set: user_detail {
    fields: [
      user_id,
      email,
      signup_date,
      signup_channel_id,
      industry,
      size_category,
      country,
      is_activated,
      is_churned
    ]
  }
}
