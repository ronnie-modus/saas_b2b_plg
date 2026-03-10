- dashboard: revenue_monetization
  title: "Revenue & Monetization"
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "Subscription revenue, pricing analysis, and monetization metrics"

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
      explore: subscription_events
      field: subscription_events.created_date

    - name: plan
      title: "Plan"
      type: field_filter
      default_value: ""
      allow_multiple_values: true
      required: false
      ui_config:
        type: checkboxes
        display: popover
      explore: subscriptions
      field: subscriptions.plan_id

  elements:
    # Row 1: Revenue KPIs
    - title: "Total Revenue"
      name: kpi_revenue
      model: flowboard
      explore: invoices
      type: single_value
      fields: [invoices.total_amount_paid]
      listen:
        date_range: invoices.created_date
      row: 0
      col: 0
      width: 6
      height: 4

    - title: "Paid Subscriptions"
      name: kpi_paid_subs
      model: flowboard
      explore: subscriptions
      type: single_value
      fields: [subscriptions.count_paid]
      filters:
        subscriptions.status: "active"
      listen:
        plan: subscriptions.plan_id
      row: 0
      col: 6
      width: 6
      height: 4

    - title: "Total Upgrades"
      name: kpi_upgrades
      model: flowboard
      explore: subscription_events
      type: single_value
      fields: [subscription_events.count_upgraded]
      listen:
        date_range: subscription_events.created_date
      row: 0
      col: 12
      width: 6
      height: 4

    - title: "Avg Invoice Amount"
      name: kpi_avg_invoice
      model: flowboard
      explore: invoices
      type: single_value
      fields: [invoices.average_invoice_amount]
      listen:
        date_range: invoices.created_date
      row: 0
      col: 18
      width: 6
      height: 4

    # Row 2: Revenue Trends
    - title: "Monthly Revenue"
      name: monthly_revenue
      model: flowboard
      explore: invoices
      type: looker_column
      fields: [invoices.created_month, invoices.total_amount_paid, invoices.count_paid]
      sorts: [invoices.created_month]
      limit: 24
      listen:
        date_range: invoices.created_date
      row: 4
      col: 0
      width: 16
      height: 8

    - title: "Revenue by Status"
      name: revenue_by_status
      model: flowboard
      explore: invoices
      type: looker_pie
      fields: [invoices.status, invoices.total_amount]
      sorts: [invoices.total_amount desc]
      limit: 10
      listen:
        date_range: invoices.created_date
      row: 4
      col: 16
      width: 8
      height: 8

    # Row 3: Subscription Events
    - title: "Subscription Events Over Time"
      name: sub_events_time
      model: flowboard
      explore: subscription_events
      type: looker_line
      fields: [subscription_events.created_month, subscription_events.count_upgraded, subscription_events.count_churned, subscription_events.count_downgraded]
      sorts: [subscription_events.created_month]
      limit: 24
      listen:
        date_range: subscription_events.created_date
      row: 12
      col: 0
      width: 16
      height: 8

    - title: "Event Type Distribution"
      name: event_type_dist
      model: flowboard
      explore: subscription_events
      type: looker_pie
      fields: [subscription_events.event_type, subscription_events.count]
      sorts: [subscription_events.count desc]
      limit: 10
      listen:
        date_range: subscription_events.created_date
      row: 12
      col: 16
      width: 8
      height: 8

    # Row 4: Plan Analysis
    - title: "Active Subscriptions by Plan"
      name: subs_by_plan
      model: flowboard
      explore: subscriptions
      type: looker_bar
      fields: [subscriptions.plan_id, subscriptions.count_active]
      sorts: [subscriptions.count_active desc]
      limit: 10
      listen:
        plan: subscriptions.plan_id
      row: 20
      col: 0
      width: 12
      height: 8

    - title: "Plan Pricing"
      name: plan_pricing
      model: flowboard
      explore: plans
      type: table
      fields: [plans.name, plans.monthly_price, plans.annual_price, plans.max_members, plans.features_tier]
      sorts: [plans.plan_sort]
      limit: 10
      row: 20
      col: 12
      width: 12
      height: 8

    # Row 5: Price Change Analysis (October 2025)
    - title: "Upgrades: Before vs After Price Change (Oct 2025)"
      name: price_change_upgrades
      model: flowboard
      explore: subscription_events
      type: looker_column
      fields: [subscription_events.price_change_period, subscription_events.count_paid_upgrades]
      sorts: [subscription_events.price_change_period]
      limit: 10
      listen:
        date_range: subscription_events.created_date
      row: 28
      col: 0
      width: 12
      height: 8
      note_state: expanded
      note_display: below
      note_text: "Price change in Oct 2025 should show ~14% fewer conversions but higher ARPU"

    - title: "Plan Mix: Before vs After Price Change"
      name: price_change_plan_mix
      model: flowboard
      explore: subscription_events
      type: looker_bar
      fields: [subscription_events.price_change_period, subscription_events.to_plan_id, subscription_events.count]
      pivots: [subscription_events.to_plan_id]
      filters:
        subscription_events.event_type: "upgraded"
        subscription_events.to_plan_id: "-free,-NULL"
      sorts: [subscription_events.price_change_period]
      limit: 10
      listen:
        date_range: subscription_events.created_date
      row: 28
      col: 12
      width: 12
      height: 8
      note_state: expanded
      note_display: below
      note_text: "After price change, expect more Pro/Business, fewer Starter"

    # Row 6: Payments
    - title: "Payment Methods"
      name: payment_methods
      model: flowboard
      explore: payments
      type: looker_pie
      fields: [payments.payment_method, payments.count]
      sorts: [payments.count desc]
      limit: 10
      listen:
        date_range: payments.created_date
      row: 36
      col: 0
      width: 8
      height: 8

    - title: "Monthly Payments"
      name: monthly_payments
      model: flowboard
      explore: payments
      type: looker_line
      fields: [payments.created_month, payments.total_amount, payments.count]
      sorts: [payments.created_month]
      limit: 24
      listen:
        date_range: payments.created_date
      row: 36
      col: 8
      width: 16
      height: 8

    # Row 7: Cancellation Analysis
    - title: "Cancellation Reasons"
      name: cancel_reasons
      model: flowboard
      explore: subscriptions
      type: looker_bar
      fields: [subscriptions.cancel_reason, subscriptions.count_canceled]
      filters:
        subscriptions.is_canceled: "yes"
      sorts: [subscriptions.count_canceled desc]
      limit: 10
      listen:
        plan: subscriptions.plan_id
      row: 44
      col: 0
      width: 12
      height: 8

    - title: "Billing Interval Distribution"
      name: billing_interval
      model: flowboard
      explore: subscriptions
      type: looker_pie
      fields: [subscriptions.billing_interval, subscriptions.count]
      sorts: [subscriptions.count desc]
      limit: 10
      filters:
        subscriptions.is_paid: "yes"
      listen:
        plan: subscriptions.plan_id
      row: 44
      col: 12
      width: 12
      height: 8
