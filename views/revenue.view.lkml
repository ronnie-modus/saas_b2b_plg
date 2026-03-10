view: invoices {
  sql_table_name: @{schema}.invoices ;;

  dimension: invoice_id {
    type: string
    sql: ${TABLE}.invoice_id ;;
    primary_key: yes
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

  dimension: amount_cents {
    type: number
    sql: ${TABLE}.amount_cents ;;
    hidden: yes
  }

  dimension: amount {
    type: number
    sql: ${TABLE}.amount_cents / 100.0 ;;
    value_format_name: usd
  }

  dimension: currency {
    type: string
    sql: ${TABLE}.currency ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
    html:
      {% if value == 'paid' %}
        <span style="background:#22c55e;color:white;padding:2px 8px;border-radius:4px">{{ value }}</span>
      {% elsif value == 'overdue' %}
        <span style="background:#ef4444;color:white;padding:2px 8px;border-radius:4px">{{ value }}</span>
      {% else %}
        <span style="background:#f59e0b;color:white;padding:2px 8px;border-radius:4px">{{ value }}</span>
      {% endif %} ;;
  }

  dimension_group: billing_period_start {
    type: time
    timeframes: [raw, date, week, month]
    sql: CAST(${TABLE}.billing_period_start AS DATE) ;;
    convert_tz: no
  }

  dimension_group: billing_period_end {
    type: time
    timeframes: [raw, date, week, month]
    sql: CAST(${TABLE}.billing_period_end AS DATE) ;;
    convert_tz: no
  }

  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}.created_at AS TIMESTAMP) ;;
  }

  dimension_group: paid {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: CAST(${TABLE}.paid_at AS TIMESTAMP) ;;
  }

  dimension: is_paid {
    type: yesno
    sql: ${TABLE}.status = 'paid' ;;
  }

  measure: count {
    type: count
    drill_fields: [invoice_id, user_id, amount, status, created_date]
    label: "Invoices"
  }

  measure: count_paid {
    type: count
    filters: [is_paid: "yes"]
  }

  measure: total_amount {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
    label: "Total Revenue"
  }

  measure: total_amount_paid {
    type: sum
    sql: ${amount} ;;
    filters: [is_paid: "yes"]
    value_format_name: usd
    label: "Total Paid Revenue"
  }

  measure: average_invoice_amount {
    type: average
    sql: ${amount} ;;
    value_format_name: usd
  }

  measure: payment_rate {
    type: number
    sql: 1.0 * ${count_paid} / NULLIF(${count}, 0) ;;
    value_format_name: percent_1
  }
}

view: payments {
  sql_table_name: @{schema}.payments ;;

  dimension: payment_id {
    type: string
    sql: ${TABLE}.payment_id ;;
    primary_key: yes
  }

  dimension: invoice_id {
    type: string
    sql: ${TABLE}.invoice_id ;;
    hidden: yes
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
    hidden: yes
  }

  dimension: amount_cents {
    type: number
    sql: ${TABLE}.amount_cents ;;
    hidden: yes
  }

  dimension: amount {
    type: number
    sql: ${TABLE}.amount_cents / 100.0 ;;
    value_format_name: usd
  }

  dimension: currency {
    type: string
    sql: ${TABLE}.currency ;;
  }

  dimension: payment_method {
    type: string
    sql: ${TABLE}.payment_method ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}.created_at AS TIMESTAMP) ;;
  }

  measure: count {
    type: count
    drill_fields: [payment_id, user_id, amount, payment_method, status, created_date]
    label: "Payments"
  }

  measure: total_amount {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
  }

  measure: average_payment {
    type: average
    sql: ${amount} ;;
    value_format_name: usd
  }

  measure: count_distinct_users {
    type: count_distinct
    sql: ${user_id} ;;
    label: "Paying Users"
  }
}

view: referrals {
  sql_table_name: @{schema}.referrals ;;

  dimension: referral_id {
    type: string
    sql: ${TABLE}.referral_id ;;
    primary_key: yes
  }

  dimension: referrer_user_id {
    type: string
    sql: ${TABLE}.referrer_user_id ;;
    hidden: yes
  }

  dimension: referred_user_id {
    type: string
    sql: ${TABLE}.referred_user_id ;;
    hidden: yes
  }

  dimension: referral_code {
    type: string
    sql: ${TABLE}.referral_code ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
    description: "pending, converted"
  }

  dimension: reward_status {
    type: string
    sql: ${TABLE}.reward_status ;;
  }

  dimension: reward_amount_cents {
    type: number
    sql: ${TABLE}.reward_amount_cents ;;
    hidden: yes
  }

  dimension: reward_amount {
    type: number
    sql: ${TABLE}.reward_amount_cents / 100.0 ;;
    value_format_name: usd
  }

  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}.created_at AS TIMESTAMP) ;;
  }

  dimension_group: converted {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: CAST(${TABLE}.converted_at AS TIMESTAMP) ;;
  }

  dimension: is_converted {
    type: yesno
    sql: ${TABLE}.status = 'converted' ;;
  }

  measure: count {
    type: count
    drill_fields: [referral_id, referrer_user_id, referred_user_id, status, created_date]
    label: "Referrals"
  }

  measure: count_converted {
    type: count
    filters: [is_converted: "yes"]
    label: "Converted Referrals"
  }

  measure: conversion_rate {
    type: number
    sql: 1.0 * ${count_converted} / NULLIF(${count}, 0) ;;
    value_format_name: percent_1
  }

  measure: total_rewards {
    type: sum
    sql: ${reward_amount} ;;
    value_format_name: usd
  }

  measure: count_distinct_referrers {
    type: count_distinct
    sql: ${referrer_user_id} ;;
    label: "Unique Referrers"
  }

  measure: referrals_per_referrer {
    type: number
    sql: 1.0 * ${count} / NULLIF(${count_distinct_referrers}, 0) ;;
    value_format_name: decimal_2
  }
}
