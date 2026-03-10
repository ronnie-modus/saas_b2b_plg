view: email_events {
  sql_table_name: @{schema}.email_events ;;

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

  dimension: email_type {
    type: string
    sql: ${TABLE}.email_type ;;
  }

  dimension: email_subject {
    type: string
    sql: ${TABLE}.email_subject ;;
  }

  dimension_group: sent {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}.sent_at AS TIMESTAMP) ;;
  }

  dimension_group: delivered {
    type: time
    timeframes: [raw, time, date]
    sql: CAST(${TABLE}.delivered_at AS TIMESTAMP) ;;
  }

  dimension_group: opened {
    type: time
    timeframes: [raw, time, date]
    sql: CAST(${TABLE}.opened_at AS TIMESTAMP) ;;
  }

  dimension_group: clicked {
    type: time
    timeframes: [raw, time, date]
    sql: CAST(${TABLE}.clicked_at AS TIMESTAMP) ;;
  }

  dimension_group: unsubscribed {
    type: time
    timeframes: [raw, time, date]
    sql: CAST(${TABLE}.unsubscribed_at AS TIMESTAMP) ;;
  }

  dimension: bounced {
    type: yesno
    sql: ${TABLE}.bounced = 'True' ;;
  }

  dimension: is_delivered {
    type: yesno
    sql: ${TABLE}.delivered_at IS NOT NULL ;;
  }

  dimension: is_opened {
    type: yesno
    sql: ${TABLE}.opened_at IS NOT NULL ;;
  }

  dimension: is_clicked {
    type: yesno
    sql: ${TABLE}.clicked_at IS NOT NULL ;;
  }

  dimension: is_unsubscribed {
    type: yesno
    sql: ${TABLE}.unsubscribed_at IS NOT NULL ;;
  }

  measure: count {
    type: count
    drill_fields: [event_id, user_id, email_type, sent_date]
    label: "Emails Sent"
  }

  measure: count_delivered {
    type: count
    filters: [is_delivered: "yes"]
    label: "Delivered"
  }

  measure: count_opened {
    type: count
    filters: [is_opened: "yes"]
    label: "Opened"
  }

  measure: count_clicked {
    type: count
    filters: [is_clicked: "yes"]
    label: "Clicked"
  }

  measure: count_bounced {
    type: count
    filters: [bounced: "yes"]
    label: "Bounced"
  }

  measure: count_unsubscribed {
    type: count
    filters: [is_unsubscribed: "yes"]
    label: "Unsubscribed"
  }

  measure: count_distinct_users {
    type: count_distinct
    sql: ${user_id} ;;
  }

  measure: delivery_rate {
    type: number
    sql: 1.0 * ${count_delivered} / NULLIF(${count}, 0) ;;
    value_format_name: percent_1
  }

  measure: open_rate {
    type: number
    sql: 1.0 * ${count_opened} / NULLIF(${count_delivered}, 0) ;;
    value_format_name: percent_1
  }

  measure: click_rate {
    type: number
    sql: 1.0 * ${count_clicked} / NULLIF(${count_delivered}, 0) ;;
    value_format_name: percent_1
  }

  measure: click_to_open_rate {
    type: number
    sql: 1.0 * ${count_clicked} / NULLIF(${count_opened}, 0) ;;
    value_format_name: percent_1
    label: "Click-to-Open Rate (CTOR)"
  }

  measure: unsubscribe_rate {
    type: number
    sql: 1.0 * ${count_unsubscribed} / NULLIF(${count_delivered}, 0) ;;
    value_format_name: percent_2
  }

  measure: bounce_rate {
    type: number
    sql: 1.0 * ${count_bounced} / NULLIF(${count}, 0) ;;
    value_format_name: percent_2
  }
}

view: notifications {
  sql_table_name: @{schema}.notifications ;;

  dimension: notification_id {
    type: string
    sql: ${TABLE}.notification_id ;;
    primary_key: yes
    hidden: yes
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
    hidden: yes
  }

  dimension: notification_type {
    type: string
    sql: ${TABLE}.notification_type ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}.title ;;
  }

  dimension: is_read {
    type: yesno
    sql: ${TABLE}.is_read = 'True' ;;
  }

  dimension: clicked {
    type: yesno
    sql: ${TABLE}.clicked = 'True' ;;
  }

  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: CAST(${TABLE}.created_at AS TIMESTAMP) ;;
  }

  dimension_group: read {
    type: time
    timeframes: [raw, time, date]
    sql: CAST(${TABLE}.read_at AS TIMESTAMP) ;;
  }

  measure: count {
    type: count
    drill_fields: [notification_id, user_id, notification_type, title, created_date]
    label: "Notifications"
  }

  measure: count_read {
    type: count
    filters: [is_read: "yes"]
  }

  measure: count_clicked {
    type: count
    filters: [clicked: "yes"]
  }

  measure: read_rate {
    type: number
    sql: 1.0 * ${count_read} / NULLIF(${count}, 0) ;;
    value_format_name: percent_1
  }

  measure: click_rate {
    type: number
    sql: 1.0 * ${count_clicked} / NULLIF(${count}, 0) ;;
    value_format_name: percent_1
  }
}

view: support_tickets {
  sql_table_name: @{schema}.support_tickets ;;

  dimension: ticket_id {
    type: string
    sql: ${TABLE}.ticket_id ;;
    primary_key: yes
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
    hidden: yes
  }

  dimension: related_error_id {
    type: string
    sql: ${TABLE}.related_error_id ;;
    hidden: yes
  }

  dimension: has_related_error {
    type: yesno
    sql: ${TABLE}.related_error_id IS NOT NULL ;;
    description: "Ticket is linked to a product error"
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: priority {
    type: string
    sql: ${TABLE}.priority ;;
    order_by_field: priority_sort
    html:
      {% if value == 'urgent' %}
        <span style="background:#ef4444;color:white;padding:2px 8px;border-radius:4px">{{ value }}</span>
      {% elsif value == 'high' %}
        <span style="background:#f59e0b;color:white;padding:2px 8px;border-radius:4px">{{ value }}</span>
      {% elsif value == 'medium' %}
        <span style="background:#3b82f6;color:white;padding:2px 8px;border-radius:4px">{{ value }}</span>
      {% else %}
        <span style="background:#94a3b8;color:white;padding:2px 8px;border-radius:4px">{{ value }}</span>
      {% endif %} ;;
  }

  dimension: priority_sort {
    type: number
    sql: CASE ${TABLE}.priority
      WHEN 'urgent' THEN 1
      WHEN 'high' THEN 2
      WHEN 'medium' THEN 3
      ELSE 4
    END ;;
    hidden: yes
  }

  dimension: subject {
    type: string
    sql: ${TABLE}.subject ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: satisfaction_score {
    type: number
    sql: ${TABLE}.satisfaction_score ;;
  }

  dimension: satisfaction_tier {
    type: string
    sql: CASE
      WHEN ${satisfaction_score} >= 4 THEN 'Satisfied'
      WHEN ${satisfaction_score} >= 3 THEN 'Neutral'
      ELSE 'Dissatisfied'
    END ;;
  }

  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}.created_at AS TIMESTAMP) ;;
  }

  dimension_group: first_response {
    type: time
    timeframes: [raw, time, date]
    sql: CAST(${TABLE}.first_response_at AS TIMESTAMP) ;;
  }

  dimension_group: resolved {
    type: time
    timeframes: [raw, time, date]
    sql: CAST(${TABLE}.resolved_at AS TIMESTAMP) ;;
  }

  dimension: is_resolved {
    type: yesno
    sql: ${TABLE}.resolved_at IS NOT NULL ;;
  }

  dimension: first_response_time_hours {
    type: number
    sql: EXTRACT(EPOCH FROM (CAST(${TABLE}.first_response_at AS TIMESTAMP) - CAST(${TABLE}.created_at AS TIMESTAMP))) / 3600.0 ;;
    value_format_name: decimal_1
    label: "First Response Time (hours)"
  }

  dimension: resolution_time_hours {
    type: number
    sql: EXTRACT(EPOCH FROM (CAST(${TABLE}.resolved_at AS TIMESTAMP) - CAST(${TABLE}.created_at AS TIMESTAMP))) / 3600.0 ;;
    value_format_name: decimal_1
    label: "Resolution Time (hours)"
  }

  measure: count {
    type: count
    drill_fields: [ticket_id, user_id, category, priority, status, created_date]
    label: "Tickets"
  }

  measure: count_resolved {
    type: count
    filters: [is_resolved: "yes"]
  }

  measure: count_urgent {
    type: count
    filters: [priority: "urgent"]
  }

  measure: count_high {
    type: count
    filters: [priority: "high"]
  }

  measure: resolution_rate {
    type: number
    sql: 1.0 * ${count_resolved} / NULLIF(${count}, 0) ;;
    value_format_name: percent_1
  }

  measure: average_satisfaction {
    type: average
    sql: ${satisfaction_score} ;;
    value_format_name: decimal_2
    label: "Avg CSAT Score"
  }

  measure: average_first_response_hours {
    type: average
    sql: ${first_response_time_hours} ;;
    value_format_name: decimal_1
    label: "Avg First Response Time (hrs)"
  }

  measure: average_resolution_hours {
    type: average
    sql: ${resolution_time_hours} ;;
    value_format_name: decimal_1
    label: "Avg Resolution Time (hrs)"
  }

  measure: count_distinct_users {
    type: count_distinct
    sql: ${user_id} ;;
    label: "Users with Tickets"
  }
}
