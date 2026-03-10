view: companies {
  sql_table_name: @{schema}.companies ;;

  dimension: company_id {
    type: string
    sql: ${TABLE}.company_id ;;
    primary_key: yes
    hidden: yes
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
    label: "Company Name"
  }

  dimension: industry {
    type: string
    sql: ${TABLE}.industry ;;
  }

  dimension: size_category {
    type: string
    sql: ${TABLE}.size_category ;;
    order_by_field: size_category_sort
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

  dimension: employee_count {
    type: number
    sql: ${TABLE}.employee_count ;;
  }

  dimension: employee_tier {
    type: tier
    tiers: [1, 10, 50, 100, 500, 1000]
    style: integer
    sql: ${employee_count} ;;
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

  dimension_group: created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: CAST(${TABLE}.created_at AS TIMESTAMP) ;;
  }

  measure: count {
    type: count
    drill_fields: [company_id, name, industry, size_category, employee_count]
  }

  measure: total_employees {
    type: sum
    sql: ${employee_count} ;;
    value_format_name: large_number
  }

  measure: average_employees {
    type: average
    sql: ${employee_count} ;;
    value_format_name: decimal_0
  }
}
