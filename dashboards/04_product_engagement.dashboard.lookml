- dashboard: product_engagement
  title: "Product Engagement & Quality"
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "Feature adoption, session analysis, errors, and product quality metrics"

  filters:
    - name: date_range
      title: "Date Range"
      type: field_filter
      default_value: "30 days"
      allow_multiple_values: false
      required: false
      ui_config:
        type: relative_timeframes
        display: inline
      explore: sessions
      field: sessions.started_date

    - name: platform
      title: "Platform"
      type: field_filter
      default_value: ""
      allow_multiple_values: true
      required: false
      ui_config:
        type: checkboxes
        display: inline
      explore: sessions
      field: sessions.platform

  elements:
    # Row 1: Engagement KPIs
    - title: "Total Sessions"
      name: kpi_sessions
      model: flowboard
      explore: sessions
      type: single_value
      fields: [sessions.count]
      listen:
        date_range: sessions.started_date
        platform: sessions.platform
      row: 0
      col: 0
      width: 6
      height: 4

    - title: "Unique Active Users"
      name: kpi_active_users
      model: flowboard
      explore: sessions
      type: single_value
      fields: [sessions.count_distinct_users]
      listen:
        date_range: sessions.started_date
        platform: sessions.platform
      row: 0
      col: 6
      width: 6
      height: 4

    - title: "Avg Session Duration (min)"
      name: kpi_avg_duration
      model: flowboard
      explore: sessions
      type: single_value
      fields: [sessions.average_duration_minutes]
      listen:
        date_range: sessions.started_date
        platform: sessions.platform
      row: 0
      col: 12
      width: 6
      height: 4

    - title: "Total Errors"
      name: kpi_errors
      model: flowboard
      explore: product_errors
      type: single_value
      fields: [product_errors.count]
      listen:
        date_range: product_errors.created_date
        platform: product_errors.platform
      row: 0
      col: 18
      width: 6
      height: 4

    # Row 2: Session Trends
    - title: "Daily Sessions"
      name: daily_sessions
      model: flowboard
      explore: sessions
      type: looker_line
      fields: [sessions.started_date, sessions.count, sessions.count_distinct_users]
      sorts: [sessions.started_date]
      limit: 500
      listen:
        date_range: sessions.started_date
        platform: sessions.platform
      row: 4
      col: 0
      width: 16
      height: 8

    - title: "Sessions by Platform"
      name: sessions_by_platform
      model: flowboard
      explore: sessions
      type: looker_pie
      fields: [sessions.platform, sessions.count]
      sorts: [sessions.count desc]
      limit: 10
      listen:
        date_range: sessions.started_date
      row: 4
      col: 16
      width: 8
      height: 8

    # Row 3: Feature Adoption
    - title: "Feature Usage by Category"
      name: feature_by_category
      model: flowboard
      explore: feature_usage
      type: looker_bar
      fields: [feature_usage.feature_category, feature_usage.count, feature_usage.count_distinct_users]
      sorts: [feature_usage.count desc]
      limit: 15
      listen:
        date_range: feature_usage.created_date
        platform: feature_usage.platform
      row: 12
      col: 0
      width: 12
      height: 8

    - title: "Top Features by Usage"
      name: top_features
      model: flowboard
      explore: feature_usage
      type: table
      fields: [feature_usage.feature_id, feature_usage.count, feature_usage.count_distinct_users, feature_usage.total_actions]
      sorts: [feature_usage.count desc]
      limit: 15
      listen:
        date_range: feature_usage.created_date
        platform: feature_usage.platform
      row: 12
      col: 12
      width: 12
      height: 8

    # Row 4: Templates Magic Feature
    - title: "Templates Adoption Over Time"
      name: templates_trend
      model: flowboard
      explore: feature_usage
      type: looker_line
      fields: [feature_usage.created_week, feature_usage.count_templates_users]
      sorts: [feature_usage.created_week]
      limit: 500
      listen:
        date_range: feature_usage.created_date
        platform: feature_usage.platform
      row: 20
      col: 0
      width: 12
      height: 8
      note_state: expanded
      note_display: below
      note_text: "Templates is a key activation feature - users who adopt it early churn 60% less"

    - title: "Feature Usage by Platform"
      name: feature_by_platform
      model: flowboard
      explore: feature_usage
      type: looker_column
      fields: [feature_usage.platform, feature_usage.count, feature_usage.count_distinct_users]
      sorts: [feature_usage.count desc]
      limit: 10
      listen:
        date_range: feature_usage.created_date
      row: 20
      col: 12
      width: 12
      height: 8

    # Row 5: Error Analysis
    - title: "Errors by Platform Over Time"
      name: errors_by_platform_time
      model: flowboard
      explore: product_errors
      type: looker_line
      fields: [product_errors.created_week, product_errors.platform, product_errors.count]
      pivots: [product_errors.platform]
      sorts: [product_errors.created_week]
      limit: 500
      listen:
        date_range: product_errors.created_date
      row: 28
      col: 0
      width: 16
      height: 8
      note_state: expanded
      note_display: below
      note_text: "Watch for iOS spike in Feb 2026 (sync disaster) and Android 2x error rate"

    - title: "Android vs iOS Error Ratio"
      name: android_ios_ratio
      model: flowboard
      explore: product_errors
      type: single_value
      fields: [product_errors.android_ios_ratio]
      listen:
        date_range: product_errors.created_date
      row: 28
      col: 16
      width: 8
      height: 4
      note_state: expanded
      note_display: below
      note_text: "Should be ~2x (Android has more errors)"

    - title: "Error Severity Distribution"
      name: error_severity
      model: flowboard
      explore: product_errors
      type: looker_pie
      fields: [product_errors.error_severity, product_errors.count]
      sorts: [product_errors.count desc]
      limit: 10
      listen:
        date_range: product_errors.created_date
        platform: product_errors.platform
      row: 32
      col: 16
      width: 8
      height: 8

    # Row 6: Error Impact
    - title: "Errors by Type"
      name: errors_by_type
      model: flowboard
      explore: product_errors
      type: looker_bar
      fields: [product_errors.error_type, product_errors.count, product_errors.count_distinct_users]
      sorts: [product_errors.count desc]
      limit: 15
      listen:
        date_range: product_errors.created_date
        platform: product_errors.platform
      row: 36
      col: 0
      width: 12
      height: 8

    - title: "Monthly Error Trend"
      name: monthly_errors
      model: flowboard
      explore: product_errors
      type: looker_column
      fields: [product_errors.created_month, product_errors.count, product_errors.count_critical]
      sorts: [product_errors.created_month]
      limit: 24
      listen:
        date_range: product_errors.created_date
        platform: product_errors.platform
      row: 36
      col: 12
      width: 12
      height: 8

    # Row 7: Support Impact
    - title: "Support Tickets by Category"
      name: support_by_category
      model: flowboard
      explore: support_tickets
      type: looker_bar
      fields: [support_tickets.category, support_tickets.count, support_tickets.average_satisfaction]
      sorts: [support_tickets.count desc]
      limit: 15
      listen:
        date_range: support_tickets.created_date
      row: 44
      col: 0
      width: 12
      height: 8

    - title: "Support Metrics"
      name: support_metrics
      model: flowboard
      explore: support_tickets
      type: table
      fields: [support_tickets.priority, support_tickets.count, support_tickets.average_first_response_hours, support_tickets.average_resolution_hours, support_tickets.average_satisfaction]
      sorts: [support_tickets.priority_sort]
      limit: 10
      listen:
        date_range: support_tickets.created_date
      row: 44
      col: 12
      width: 12
      height: 8
