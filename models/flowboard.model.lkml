connection: "postgres_saas_b2b_plg"

include: "/views/*.view.lkml"
include: "/dashboards/*.dashboard.lookml"

# ============================================================================
# DATAGROUPS (Cache Policies)
# ============================================================================
# Note: These require PDT writeback schema. Comment out persist_with if not configured.

datagroup: daily_refresh {
  sql_trigger: SELECT CURRENT_DATE ;;
  max_cache_age: "24 hours"
  description: "Refreshes daily at midnight"
}

datagroup: hourly_refresh {
  sql_trigger: SELECT DATE_TRUNC('hour', CURRENT_TIMESTAMP) ;;
  max_cache_age: "1 hour"
  description: "Refreshes every hour"
}

# ============================================================================
# NAMED VALUE FORMATS
# ============================================================================

named_value_format: usd_cents_to_dollars {
  value_format: "$#,##0.00"
}

named_value_format: large_number {
  value_format: "#,##0"
}

# ============================================================================
# EXPLORE: Users & Growth
# Primary explore for user-level analysis, acquisition, and activation
# ============================================================================

explore: users {
  label: "Users & Growth"
  description: "User-level analysis including signups, activation, channels, and segments"
  # persist_with: daily_refresh  # Uncomment when PDT schema is configured

  join: companies {
    type: left_outer
    sql_on: ${users.company_id} = ${companies.company_id} ;;
    relationship: many_to_one
  }

  join: signup_events {
    type: left_outer
    sql_on: ${users.user_id} = ${signup_events.user_id} ;;
    relationship: one_to_one
  }

  join: marketing_channels {
    type: left_outer
    sql_on: ${users.signup_channel_id} = ${marketing_channels.channel_id} ;;
    relationship: many_to_one
  }

  join: marketing_touches {
    type: left_outer
    sql_on: ${users.user_id} = ${marketing_touches.user_id} ;;
    relationship: one_to_many
  }

  join: marketing_campaigns {
    type: left_outer
    sql_on: ${marketing_touches.campaign_id} = ${marketing_campaigns.campaign_id} ;;
    relationship: many_to_one
  }

  join: onboarding_checklist_events {
    type: left_outer
    sql_on: ${users.user_id} = ${onboarding_checklist_events.user_id} ;;
    relationship: one_to_many
  }

  join: referrals_as_referred {
    from: referrals
    type: left_outer
    sql_on: ${users.user_id} = ${referrals_as_referred.referred_user_id} ;;
    relationship: one_to_one
    view_label: "Referral (As Referred)"
  }

  join: referrals_as_referrer {
    from: referrals
    type: left_outer
    sql_on: ${users.user_id} = ${referrals_as_referrer.referrer_user_id} ;;
    relationship: one_to_many
    view_label: "Referral (As Referrer)"
  }
}

# ============================================================================
# EXPLORE: Subscriptions & Revenue
# Revenue analysis, MRR tracking, plan changes
# ============================================================================

explore: subscriptions {
  label: "Subscriptions & Revenue"
  description: "Subscription-level analysis including MRR, plan changes, and billing"
  # persist_with: daily_refresh

  join: users {
    type: left_outer
    sql_on: ${subscriptions.user_id} = ${users.user_id} ;;
    relationship: many_to_one
  }

  join: companies {
    type: left_outer
    sql_on: ${users.company_id} = ${companies.company_id} ;;
    relationship: many_to_one
  }

  join: plans {
    type: left_outer
    sql_on: ${subscriptions.plan_id} = ${plans.plan_id} ;;
    relationship: many_to_one
  }

  join: subscription_events {
    type: left_outer
    sql_on: ${subscriptions.subscription_id} = ${subscription_events.subscription_id} ;;
    relationship: one_to_many
  }

  join: invoices {
    type: left_outer
    sql_on: ${subscriptions.subscription_id} = ${invoices.subscription_id} ;;
    relationship: one_to_many
  }

  join: payments {
    type: left_outer
    sql_on: ${invoices.invoice_id} = ${payments.invoice_id} ;;
    relationship: one_to_many
  }
}

# ============================================================================
# EXPLORE: Product Engagement
# Sessions, feature usage, documents, collaborations
# ============================================================================

explore: sessions {
  label: "Product Engagement"
  description: "Session-level analysis including feature usage and user behavior"
  # persist_with: hourly_refresh

  join: users {
    type: left_outer
    sql_on: ${sessions.user_id} = ${users.user_id} ;;
    relationship: many_to_one
  }

  join: companies {
    type: left_outer
    sql_on: ${users.company_id} = ${companies.company_id} ;;
    relationship: many_to_one
  }

  join: feature_usage {
    type: left_outer
    sql_on: ${sessions.session_id} = ${feature_usage.session_id} ;;
    relationship: one_to_many
  }

  join: product_errors {
    type: left_outer
    sql_on: ${sessions.session_id} = ${product_errors.session_id} ;;
    relationship: one_to_many
  }
}

# ============================================================================
# EXPLORE: Feature Usage
# Direct feature usage analysis
# ============================================================================

explore: feature_usage {
  label: "Feature Adoption"
  description: "Feature-level usage analysis for product analytics"
  # persist_with: hourly_refresh

  join: users {
    type: left_outer
    sql_on: ${feature_usage.user_id} = ${users.user_id} ;;
    relationship: many_to_one
  }

  join: companies {
    type: left_outer
    sql_on: ${users.company_id} = ${companies.company_id} ;;
    relationship: many_to_one
  }

  join: sessions {
    type: left_outer
    sql_on: ${feature_usage.session_id} = ${sessions.session_id} ;;
    relationship: many_to_one
  }
}

# ============================================================================
# EXPLORE: Product Errors
# Error analysis and quality monitoring
# ============================================================================

explore: product_errors {
  label: "Product Errors & Quality"
  description: "Error tracking and product quality analysis"
  # persist_with: hourly_refresh

  join: users {
    type: left_outer
    sql_on: ${product_errors.user_id} = ${users.user_id} ;;
    relationship: many_to_one
  }

  join: companies {
    type: left_outer
    sql_on: ${users.company_id} = ${companies.company_id} ;;
    relationship: many_to_one
  }

  join: sessions {
    type: left_outer
    sql_on: ${product_errors.session_id} = ${sessions.session_id} ;;
    relationship: many_to_one
  }

  join: support_tickets {
    type: left_outer
    sql_on: ${product_errors.error_id} = ${support_tickets.related_error_id} ;;
    relationship: one_to_many
  }
}

# ============================================================================
# EXPLORE: Documents & Collaboration
# Content creation and collaboration patterns
# ============================================================================

explore: documents {
  label: "Documents & Collaboration"
  description: "Content creation and collaboration analysis"
  # persist_with: daily_refresh

  join: users {
    type: left_outer
    sql_on: ${documents.user_id} = ${users.user_id} ;;
    relationship: many_to_one
    view_label: "Document Owner"
  }

  join: companies {
    type: left_outer
    sql_on: ${users.company_id} = ${companies.company_id} ;;
    relationship: many_to_one
  }

  join: workspaces {
    type: left_outer
    sql_on: ${documents.workspace_id} = ${workspaces.workspace_id} ;;
    relationship: many_to_one
  }

  join: collaborations {
    type: left_outer
    sql_on: ${documents.document_id} = ${collaborations.document_id} ;;
    relationship: one_to_many
  }
}

# ============================================================================
# EXPLORE: Marketing Attribution
# Multi-touch attribution and campaign analysis
# ============================================================================

explore: marketing_touches {
  label: "Marketing Attribution"
  description: "Multi-touch attribution and campaign performance"
  # persist_with: daily_refresh

  join: users {
    type: left_outer
    sql_on: ${marketing_touches.user_id} = ${users.user_id} ;;
    relationship: many_to_one
  }

  join: marketing_channels {
    type: left_outer
    sql_on: ${marketing_touches.channel_id} = ${marketing_channels.channel_id} ;;
    relationship: many_to_one
  }

  join: marketing_campaigns {
    type: left_outer
    sql_on: ${marketing_touches.campaign_id} = ${marketing_campaigns.campaign_id} ;;
    relationship: many_to_one
  }
}

# ============================================================================
# EXPLORE: Support & Customer Success
# Support tickets and customer health
# ============================================================================

explore: support_tickets {
  label: "Support & Customer Success"
  description: "Support ticket analysis and customer health monitoring"
  # persist_with: daily_refresh

  join: users {
    type: left_outer
    sql_on: ${support_tickets.user_id} = ${users.user_id} ;;
    relationship: many_to_one
  }

  join: companies {
    type: left_outer
    sql_on: ${users.company_id} = ${companies.company_id} ;;
    relationship: many_to_one
  }

  join: product_errors {
    type: left_outer
    sql_on: ${support_tickets.related_error_id} = ${product_errors.error_id} ;;
    relationship: many_to_one
  }
}

# ============================================================================
# EXPLORE: Email Engagement
# Email performance and engagement
# ============================================================================

explore: email_events {
  label: "Email Engagement"
  description: "Email campaign performance and user engagement"
  # persist_with: daily_refresh

  join: users {
    type: left_outer
    sql_on: ${email_events.user_id} = ${users.user_id} ;;
    relationship: many_to_one
  }

  join: companies {
    type: left_outer
    sql_on: ${users.company_id} = ${companies.company_id} ;;
    relationship: many_to_one
  }
}

# ============================================================================
# EXPLORE: Subscription Events
# Detailed subscription lifecycle events
# ============================================================================

explore: subscription_events {
  label: "Subscription Lifecycle"
  description: "Detailed subscription events including upgrades, downgrades, and churn"
  # persist_with: daily_refresh

  join: subscriptions {
    type: left_outer
    sql_on: ${subscription_events.subscription_id} = ${subscriptions.subscription_id} ;;
    relationship: many_to_one
  }

  join: users {
    type: left_outer
    sql_on: ${subscription_events.user_id} = ${users.user_id} ;;
    relationship: many_to_one
  }

  join: companies {
    type: left_outer
    sql_on: ${users.company_id} = ${companies.company_id} ;;
    relationship: many_to_one
  }

  join: from_plan {
    from: plans
    type: left_outer
    sql_on: ${subscription_events.from_plan_id} = ${from_plan.plan_id} ;;
    relationship: many_to_one
    view_label: "From Plan"
  }

  join: to_plan {
    from: plans
    type: left_outer
    sql_on: ${subscription_events.to_plan_id} = ${to_plan.plan_id} ;;
    relationship: many_to_one
    view_label: "To Plan"
  }
}

# ============================================================================
# EXPLORE: Signup Events
# Signup funnel analysis
# ============================================================================

explore: signup_events {
  label: "Signup Events"
  description: "Signup event analysis with channel and campaign attribution"
  # persist_with: daily_refresh

  join: users {
    type: left_outer
    sql_on: ${signup_events.user_id} = ${users.user_id} ;;
    relationship: many_to_one
  }

  join: marketing_channels {
    type: left_outer
    sql_on: ${signup_events.channel_id} = ${marketing_channels.channel_id} ;;
    relationship: many_to_one
  }

  join: marketing_campaigns {
    type: left_outer
    sql_on: ${signup_events.campaign_id} = ${marketing_campaigns.campaign_id} ;;
    relationship: many_to_one
  }
}

# ============================================================================
# EXPLORE: Invoices
# Invoice and billing analysis
# ============================================================================

explore: invoices {
  label: "Invoices & Billing"
  description: "Invoice-level revenue analysis"
  # persist_with: daily_refresh

  join: subscriptions {
    type: left_outer
    sql_on: ${invoices.subscription_id} = ${subscriptions.subscription_id} ;;
    relationship: many_to_one
  }

  join: users {
    type: left_outer
    sql_on: ${invoices.user_id} = ${users.user_id} ;;
    relationship: many_to_one
  }

  join: companies {
    type: left_outer
    sql_on: ${users.company_id} = ${companies.company_id} ;;
    relationship: many_to_one
  }

  join: payments {
    type: left_outer
    sql_on: ${invoices.invoice_id} = ${payments.invoice_id} ;;
    relationship: one_to_many
  }
}

# ============================================================================
# EXPLORE: Payments
# Payment analysis
# ============================================================================

explore: payments {
  label: "Payments"
  description: "Payment transaction analysis"
  # persist_with: daily_refresh

  join: invoices {
    type: left_outer
    sql_on: ${payments.invoice_id} = ${invoices.invoice_id} ;;
    relationship: many_to_one
  }

  join: users {
    type: left_outer
    sql_on: ${payments.user_id} = ${users.user_id} ;;
    relationship: many_to_one
  }
}

# ============================================================================
# EXPLORE: Plans
# Plan catalog
# ============================================================================

explore: plans {
  label: "Plans"
  description: "Pricing plan catalog"
}

# ============================================================================
# EXPLORE: Referrals
# Referral program analysis
# ============================================================================

explore: referrals {
  label: "Referrals"
  description: "Referral program performance"
  # persist_with: daily_refresh

  join: referrer {
    from: users
    type: left_outer
    sql_on: ${referrals.referrer_user_id} = ${referrer.user_id} ;;
    relationship: many_to_one
    view_label: "Referrer"
  }

  join: referred {
    from: users
    type: left_outer
    sql_on: ${referrals.referred_user_id} = ${referred.user_id} ;;
    relationship: many_to_one
    view_label: "Referred User"
  }
}
