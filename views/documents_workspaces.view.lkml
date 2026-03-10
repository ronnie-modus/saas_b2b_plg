view: documents {
  sql_table_name: @{schema}.documents ;;

  dimension: document_id {
    type: string
    sql: ${TABLE}.document_id ;;
    primary_key: yes
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
    hidden: yes
  }

  dimension: workspace_id {
    type: string
    sql: ${TABLE}.workspace_id ;;
    hidden: yes
  }

  dimension: title {
    type: string
    sql: ${TABLE}.title ;;
  }

  dimension: document_type {
    type: string
    sql: ${TABLE}.document_type ;;
  }

  dimension: word_count {
    type: number
    sql: ${TABLE}.word_count ;;
  }

  dimension: word_count_tier {
    type: tier
    tiers: [100, 500, 1000, 2000, 5000]
    style: integer
    sql: ${word_count} ;;
  }

  dimension: is_template {
    type: yesno
    sql: ${TABLE}.is_template = 'True' ;;
  }

  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}.created_at AS TIMESTAMP) ;;
  }

  dimension_group: updated {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: CAST(${TABLE}.updated_at AS TIMESTAMP) ;;
  }

  measure: count {
    type: count
    drill_fields: [document_id, title, document_type, word_count, created_date]
    label: "Documents"
  }

  measure: count_distinct_users {
    type: count_distinct
    sql: ${user_id} ;;
    label: "Authors"
  }

  measure: count_templates {
    type: count
    filters: [is_template: "yes"]
  }

  measure: total_word_count {
    type: sum
    sql: ${word_count} ;;
    value_format_name: large_number
  }

  measure: average_word_count {
    type: average
    sql: ${word_count} ;;
    value_format_name: decimal_0
  }

  measure: documents_per_user {
    type: number
    sql: 1.0 * ${count} / NULLIF(${count_distinct_users}, 0) ;;
    value_format_name: decimal_1
  }
}

view: collaborations {
  sql_table_name: @{schema}.collaborations ;;

  dimension: collaboration_id {
    type: string
    sql: ${TABLE}.collaboration_id ;;
    primary_key: yes
    hidden: yes
  }

  dimension: document_id {
    type: string
    sql: ${TABLE}.document_id ;;
    hidden: yes
  }

  dimension: owner_user_id {
    type: string
    sql: ${TABLE}.owner_user_id ;;
    hidden: yes
  }

  dimension: collaborator_user_id {
    type: string
    sql: ${TABLE}.collaborator_user_id ;;
    hidden: yes
  }

  dimension: permission_level {
    type: string
    sql: ${TABLE}.permission_level ;;
  }

  dimension_group: invited {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: CAST(${TABLE}.invited_at AS TIMESTAMP) ;;
  }

  dimension_group: accepted {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: CAST(${TABLE}.accepted_at AS TIMESTAMP) ;;
  }

  dimension_group: last_accessed {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: CAST(${TABLE}.last_accessed_at AS TIMESTAMP) ;;
  }

  dimension: is_accepted {
    type: yesno
    sql: ${TABLE}.accepted_at IS NOT NULL ;;
  }

  measure: count {
    type: count
    drill_fields: [collaboration_id, document_id, permission_level, invited_date]
    label: "Collaborations"
  }

  measure: count_accepted {
    type: count
    filters: [is_accepted: "yes"]
  }

  measure: count_distinct_collaborators {
    type: count_distinct
    sql: ${collaborator_user_id} ;;
    label: "Unique Collaborators"
  }

  measure: count_distinct_documents {
    type: count_distinct
    sql: ${document_id} ;;
    label: "Documents with Collaborators"
  }

  measure: acceptance_rate {
    type: number
    sql: 1.0 * ${count_accepted} / NULLIF(${count}, 0) ;;
    value_format_name: percent_1
  }
}

view: workspaces {
  sql_table_name: @{schema}.workspaces ;;

  dimension: workspace_id {
    type: string
    sql: ${TABLE}.workspace_id ;;
    primary_key: yes
  }

  dimension: owner_user_id {
    type: string
    sql: ${TABLE}.owner_user_id ;;
    hidden: yes
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
    label: "Workspace Name"
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}.company_id ;;
    hidden: yes
  }

  dimension: member_count {
    type: number
    sql: ${TABLE}.member_count ;;
  }

  dimension: member_count_tier {
    type: tier
    tiers: [1, 5, 10, 25, 50, 100]
    style: integer
    sql: ${member_count} ;;
  }

  dimension_group: created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: CAST(${TABLE}.created_at AS TIMESTAMP) ;;
  }

  measure: count {
    type: count
    drill_fields: [workspace_id, name, member_count, created_date]
    label: "Workspaces"
  }

  measure: total_members {
    type: sum
    sql: ${member_count} ;;
    value_format_name: large_number
  }

  measure: average_members {
    type: average
    sql: ${member_count} ;;
    value_format_name: decimal_1
  }
}
