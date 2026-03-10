- dashboard: executive_overview
  title: "Executive Overview"
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "High-level KPIs and trends for FlowBoard"

  filters:
    - name: date_range
      title: "Date Range"
      type: field_filter
      default_value: "12 months"
      allow_multiple_values: false
      required: false
      ui_config:
        type: relative_timeframes
        display: inline
      explore: users
      field: users.signup_date

    - name: size_category
      title: "Company Size"
      type: field_filter
      default_value: ""
      allow_multiple_values: true
      required: false
      ui_config:
        type: checkboxes
        display: popover
      explore: users
      field: users.size_category

  elements:
    # Row 1: KPI Cards
    - title: "Total Users"
      name: kpi_total_users
      model: flowboard
      explore: users
      type: single_value
      fields: [users.count]
      listen:
        date_range: users.signup_date
        size_category: users.size_category
      row: 0
      col: 0
      width: 6
      height: 4

    - title: "Activated Users"
      name: kpi_activated_users
      model: flowboard
      explore: users
      type: single_value
      fields: [users.count_activated]
      listen:
        date_range: users.signup_date
        size_category: users.size_category
      row: 0
      col: 6
      width: 6
      height: 4

    - title: "Activation Rate"
      name: kpi_activation_rate
      model: flowboard
      explore: users
      type: single_value
      fields: [users.activation_rate]
      listen:
        date_range: users.signup_date
        size_category: users.size_category
      row: 0
      col: 12
      width: 6
      height: 4

    - title: "Churn Rate"
      name: kpi_churn_rate
      model: flowboard
      explore: users
      type: single_value
      fields: [users.churn_rate]
      listen:
        date_range: users.signup_date
        size_category: users.size_category
      row: 0
      col: 18
      width: 6
      height: 4

    # Row 2: Signups Over Time
    - title: "Monthly Signups"
      name: monthly_signups
      model: flowboard
      explore: users
      type: looker_line
      fields: [users.signup_month, users.count, users.count_activated]
      sorts: [users.signup_month]
      limit: 500
      listen:
        date_range: users.signup_date
        size_category: users.size_category
      row: 4
      col: 0
      width: 12
      height: 8

    - title: "Activation by Channel"
      name: activation_by_channel
      model: flowboard
      explore: users
      type: looker_column
      fields: [users.signup_channel_id, users.count, users.activation_rate]
      sorts: [users.count desc]
      limit: 10
      listen:
        date_range: users.signup_date
        size_category: users.size_category
      row: 4
      col: 12
      width: 12
      height: 8

    # Row 3: Churn and Retention
    - title: "Monthly Churn Trend"
      name: monthly_churn
      model: flowboard
      explore: users
      type: looker_line
      fields: [users.signup_month, users.churn_rate, users.retention_rate]
      sorts: [users.signup_month]
      limit: 500
      listen:
        date_range: users.signup_date
        size_category: users.size_category
      row: 12
      col: 0
      width: 12
      height: 8

    - title: "Churn by Company Size"
      name: churn_by_size
      model: flowboard
      explore: users
      type: looker_bar
      fields: [users.size_category, users.churn_rate, users.count_activated]
      sorts: [users.size_category_sort]
      limit: 10
      listen:
        date_range: users.signup_date
      row: 12
      col: 12
      width: 12
      height: 8

    # Row 4: Geography
    - title: "Users by Country"
      name: users_by_country
      model: flowboard
      explore: users
      type: looker_pie
      fields: [users.country, users.count]
      sorts: [users.count desc]
      limit: 10
      listen:
        date_range: users.signup_date
        size_category: users.size_category
      row: 20
      col: 0
      width: 12
      height: 8

    - title: "Churn Rate by Region"
      name: churn_by_region
      model: flowboard
      explore: users
      type: looker_bar
      fields: [users.region, users.churn_rate, users.count_activated]
      sorts: [users.count_activated desc]
      limit: 10
      listen:
        date_range: users.signup_date
        size_category: users.size_category
      row: 20
      col: 12
      width: 12
      height: 8
