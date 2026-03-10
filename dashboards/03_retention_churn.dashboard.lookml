- dashboard: retention_churn
  title: "Retention & Churn Analysis"
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "Cohort retention, churn drivers, and segment analysis"

  filters:
    - name: date_range
      title: "Cohort Date Range"
      type: field_filter
      default_value: "12 months"
      allow_multiple_values: false
      required: false
      ui_config:
        type: relative_timeframes
        display: inline
      explore: users
      field: users.signup_date

    - name: channel
      title: "Signup Channel"
      type: field_filter
      default_value: ""
      allow_multiple_values: true
      required: false
      ui_config:
        type: checkboxes
        display: popover
      explore: users
      field: users.signup_channel_id

  elements:
    # Row 1: Retention KPIs
    - title: "Overall Retention Rate"
      name: kpi_retention
      model: flowboard
      explore: users
      type: single_value
      fields: [users.retention_rate]
      listen:
        date_range: users.signup_date
        channel: users.signup_channel_id
      row: 0
      col: 0
      width: 6
      height: 4

    - title: "Churned Users"
      name: kpi_churned
      model: flowboard
      explore: users
      type: single_value
      fields: [users.count_churned]
      listen:
        date_range: users.signup_date
        channel: users.signup_channel_id
      row: 0
      col: 6
      width: 6
      height: 4

    - title: "Churn Rate"
      name: kpi_churn
      model: flowboard
      explore: users
      type: single_value
      fields: [users.churn_rate]
      listen:
        date_range: users.signup_date
        channel: users.signup_channel_id
      row: 0
      col: 12
      width: 6
      height: 4

    - title: "Active Users"
      name: kpi_active
      model: flowboard
      explore: users
      type: single_value
      fields: [users.count_activated]
      filters:
        users.is_churned: "no"
      listen:
        date_range: users.signup_date
        channel: users.signup_channel_id
      row: 0
      col: 18
      width: 6
      height: 4

    # Row 2: Cohort Analysis
    - title: "Monthly Cohort Churn Rates"
      name: cohort_churn
      model: flowboard
      explore: users
      type: looker_line
      fields: [users.signup_cohort_month, users.churn_rate, users.count_activated]
      sorts: [users.signup_cohort_month]
      limit: 24
      listen:
        date_range: users.signup_date
        channel: users.signup_channel_id
      row: 4
      col: 0
      width: 16
      height: 8
      note_state: expanded
      note_display: below
      note_text: "Look for cohorts with unusually high churn (e.g., July 2025 Summer Blast)"

    - title: "Cohort Size Distribution"
      name: cohort_size
      model: flowboard
      explore: users
      type: looker_column
      fields: [users.signup_cohort_month, users.count]
      sorts: [users.signup_cohort_month]
      limit: 24
      listen:
        date_range: users.signup_date
        channel: users.signup_channel_id
      row: 4
      col: 16
      width: 8
      height: 8

    # Row 3: Segment Analysis
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
        channel: users.signup_channel_id
      row: 12
      col: 0
      width: 12
      height: 8
      note_state: expanded
      note_display: below
      note_text: "Enterprise accounts should have significantly lower churn"

    - title: "Churn by Industry"
      name: churn_by_industry
      model: flowboard
      explore: users
      type: looker_bar
      fields: [users.industry, users.churn_rate, users.count_activated]
      sorts: [users.churn_rate desc]
      limit: 15
      listen:
        date_range: users.signup_date
        channel: users.signup_channel_id
      row: 12
      col: 12
      width: 12
      height: 8

    # Row 4: Geographic Analysis
    - title: "Churn by Region"
      name: churn_by_region
      model: flowboard
      explore: users
      type: looker_column
      fields: [users.region, users.churn_rate, users.retention_rate]
      sorts: [users.churn_rate desc]
      limit: 10
      listen:
        date_range: users.signup_date
        channel: users.signup_channel_id
      row: 20
      col: 0
      width: 12
      height: 8
      note_state: expanded
      note_display: below
      note_text: "US users typically churn more than European users"

    - title: "Churn by Country (Top 10)"
      name: churn_by_country
      model: flowboard
      explore: users
      type: table
      fields: [users.country, users.count_activated, users.count_churned, users.churn_rate]
      sorts: [users.count_activated desc]
      limit: 10
      listen:
        date_range: users.signup_date
        channel: users.signup_channel_id
      row: 20
      col: 12
      width: 12
      height: 8

    # Row 5: Channel Quality
    - title: "Churn by Signup Channel"
      name: churn_by_channel
      model: flowboard
      explore: users
      type: looker_bar
      fields: [users.signup_channel_id, users.churn_rate, users.activation_rate]
      sorts: [users.churn_rate desc]
      limit: 15
      listen:
        date_range: users.signup_date
      row: 28
      col: 0
      width: 12
      height: 8
      note_state: expanded
      note_display: below
      note_text: "Paid Social has high volume but poor retention vs Organic Search"

    - title: "Referred User Retention Advantage"
      name: referral_retention
      model: flowboard
      explore: users
      type: looker_column
      fields: [users.is_referred, users.retention_rate, users.churn_rate]
      sorts: [users.is_referred desc]
      limit: 10
      listen:
        date_range: users.signup_date
        channel: users.signup_channel_id
      row: 28
      col: 12
      width: 12
      height: 8
      note_state: expanded
      note_display: below
      note_text: "Referred users should show significantly better retention"

    # Row 6: Subscription Events
    - title: "Monthly Churn Events"
      name: monthly_churn_events
      model: flowboard
      explore: subscription_events
      type: looker_line
      fields: [subscription_events.created_month, subscription_events.count_churned, subscription_events.count_upgraded]
      sorts: [subscription_events.created_month]
      limit: 24
      listen:
        date_range: subscription_events.created_date
      row: 36
      col: 0
      width: 24
      height: 8
