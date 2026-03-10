- dashboard: growth_acquisition
  title: "Growth & Acquisition"
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "Channel performance, attribution, and acquisition funnel analysis"

  filters:
    - name: date_range
      title: "Date Range"
      type: field_filter
      default_value: "6 months"
      allow_multiple_values: false
      required: false
      ui_config:
        type: relative_timeframes
        display: inline
      explore: users
      field: users.signup_date

    - name: channel
      title: "Channel"
      type: field_filter
      default_value: ""
      allow_multiple_values: true
      required: false
      ui_config:
        type: tag_list
        display: popover
      explore: users
      field: users.signup_channel_id

  elements:
    # Row 1: Channel KPIs
    - title: "Total Signups"
      name: kpi_signups
      model: flowboard
      explore: signup_events
      type: single_value
      fields: [signup_events.count]
      listen:
        date_range: signup_events.created_date
        channel: signup_events.channel_id
      row: 0
      col: 0
      width: 6
      height: 4

    - title: "Unique Channels"
      name: kpi_channels
      model: flowboard
      explore: marketing_touches
      type: single_value
      fields: [marketing_touches.count_distinct_users]
      listen:
        date_range: marketing_touches.created_date
        channel: marketing_touches.channel_id
      row: 0
      col: 6
      width: 6
      height: 4

    - title: "Avg Touches per User"
      name: kpi_touches_per_user
      model: flowboard
      explore: marketing_touches
      type: single_value
      fields: [marketing_touches.touches_per_user]
      listen:
        date_range: marketing_touches.created_date
        channel: marketing_touches.channel_id
      row: 0
      col: 12
      width: 6
      height: 4

    - title: "Referral Users"
      name: kpi_referrals
      model: flowboard
      explore: users
      type: single_value
      fields: [users.count_referred]
      listen:
        date_range: users.signup_date
      row: 0
      col: 18
      width: 6
      height: 4

    # Row 2: Channel Quality Analysis
    - title: "Channel Quality: Volume vs Activation"
      name: channel_quality
      model: flowboard
      explore: users
      type: looker_scatter
      fields: [users.signup_channel_id, users.count, users.activation_rate]
      sorts: [users.count desc]
      limit: 15
      listen:
        date_range: users.signup_date
      row: 4
      col: 0
      width: 12
      height: 10
      note_state: expanded
      note_display: below
      note_text: "Look for high-volume channels with low activation (quality problem)"

    - title: "Channel Performance Table"
      name: channel_table
      model: flowboard
      explore: users
      type: table
      fields: [users.signup_channel_id, users.count, users.activation_rate, users.churn_rate]
      sorts: [users.count desc]
      limit: 15
      listen:
        date_range: users.signup_date
        channel: users.signup_channel_id
      row: 4
      col: 12
      width: 12
      height: 10

    # Row 3: Attribution Analysis
    - title: "First Touch Attribution"
      name: first_touch_attribution
      model: flowboard
      explore: marketing_touches
      type: looker_pie
      fields: [marketing_touches.channel_id, marketing_touches.count_first_touch]
      filters:
        marketing_touches.touch_type: "first_touch"
      sorts: [marketing_touches.count_first_touch desc]
      limit: 10
      listen:
        date_range: marketing_touches.created_date
      row: 14
      col: 0
      width: 8
      height: 8

    - title: "Last Touch Attribution"
      name: last_touch_attribution
      model: flowboard
      explore: marketing_touches
      type: looker_pie
      fields: [marketing_touches.channel_id, marketing_touches.count_last_touch]
      filters:
        marketing_touches.touch_type: "last_touch"
      sorts: [marketing_touches.count_last_touch desc]
      limit: 10
      listen:
        date_range: marketing_touches.created_date
      row: 14
      col: 8
      width: 8
      height: 8

    - title: "Assist Touches by Channel"
      name: assist_attribution
      model: flowboard
      explore: marketing_touches
      type: looker_bar
      fields: [marketing_touches.channel_id, marketing_touches.count_assist_touch]
      filters:
        marketing_touches.touch_type: "assist_touch"
      sorts: [marketing_touches.count_assist_touch desc]
      limit: 10
      listen:
        date_range: marketing_touches.created_date
      row: 14
      col: 16
      width: 8
      height: 8

    # Row 4: Signup Trends
    - title: "Weekly Signups by Channel"
      name: weekly_signups_channel
      model: flowboard
      explore: signup_events
      type: looker_area
      fields: [signup_events.created_week, signup_events.channel_id, signup_events.count]
      pivots: [signup_events.channel_id]
      sorts: [signup_events.created_week]
      limit: 500
      listen:
        date_range: signup_events.created_date
        channel: signup_events.channel_id
      row: 22
      col: 0
      width: 16
      height: 8

    - title: "Signups by Platform"
      name: signups_by_platform
      model: flowboard
      explore: signup_events
      type: looker_pie
      fields: [signup_events.platform, signup_events.count]
      sorts: [signup_events.count desc]
      limit: 10
      listen:
        date_range: signup_events.created_date
        channel: signup_events.channel_id
      row: 22
      col: 16
      width: 8
      height: 8

    # Row 5: Referral Analysis
    - title: "Referral Program Performance"
      name: referral_performance
      model: flowboard
      explore: referrals
      type: looker_line
      fields: [referrals.created_month, referrals.count, referrals.count_converted, referrals.conversion_rate]
      sorts: [referrals.created_month]
      limit: 500
      listen:
        date_range: referrals.created_date
      row: 30
      col: 0
      width: 12
      height: 8

    - title: "Referred vs Non-Referred Churn"
      name: referral_churn_comparison
      model: flowboard
      explore: users
      type: looker_column
      fields: [users.is_referred, users.churn_rate, users.count_activated]
      sorts: [users.is_referred]
      limit: 10
      listen:
        date_range: users.signup_date
      row: 30
      col: 12
      width: 12
      height: 8
      note_state: expanded
      note_display: below
      note_text: "Referred users should have significantly lower churn"
