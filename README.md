# FlowBoard PLG SaaS - LookML Project

A comprehensive LookML project for analyzing the FlowBoard B2C PLG SaaS dataset.

## Project Structure

```
lookml_project/
├── manifest.lkml              # Project settings and constants
├── flowboard.model.lkml       # Model file with all explores and joins
├── views/
│   ├── users.view.lkml        # Users with segments and status
│   ├── companies.view.lkml    # Company data
│   ├── plans.view.lkml        # Pricing plans
│   ├── subscriptions.view.lkml
│   ├── subscription_events.view.lkml
│   ├── marketing.view.lkml    # Channels, campaigns, touches
│   ├── signup_onboarding.view.lkml
│   ├── sessions_features.view.lkml
│   ├── product_errors.view.lkml
│   ├── documents_workspaces.view.lkml
│   ├── revenue.view.lkml      # Invoices, payments, referrals
│   └── engagement_support.view.lkml
└── dashboards/
    ├── 01_executive_overview.dashboard.lookml
    ├── 02_growth_acquisition.dashboard.lookml
    ├── 03_retention_churn.dashboard.lookml
    ├── 04_product_engagement.dashboard.lookml
    └── 05_revenue_monetization.dashboard.lookml
```

## Connection

- **Connection Name:** `postgres_saas_b2b_plg`
- **Schema:** `saas_b2b_plg`

## Explores

| Explore | Description | Primary View |
|---------|-------------|--------------|
| `users` | User-level analysis, acquisition, activation | users |
| `subscriptions` | Subscription and revenue analysis | subscriptions |
| `sessions` | Product engagement and behavior | sessions |
| `feature_usage` | Feature adoption analysis | feature_usage |
| `product_errors` | Error tracking and quality | product_errors |
| `documents` | Content creation and collaboration | documents |
| `marketing_touches` | Multi-touch attribution | marketing_touches |
| `support_tickets` | Support and customer success | support_tickets |
| `email_events` | Email engagement | email_events |
| `subscription_events` | Subscription lifecycle | subscription_events |

## Dashboards

### 1. Executive Overview
High-level KPIs including total users, activation rate, churn rate, and trends by channel, size, and geography.

### 2. Growth & Acquisition
- Channel quality analysis (volume vs activation)
- Multi-touch attribution (first touch, last touch, assist)
- Referral program performance
- Signup trends by platform and channel

### 3. Retention & Churn
- Cohort churn analysis
- Churn by segment (company size, industry, geography)
- Channel quality comparison (Paid Social vs Organic)
- Referral retention advantage

### 4. Product Engagement
- Session trends and duration
- Feature adoption by category
- Templates magic feature tracking
- Error analysis by platform (iOS disaster, Android 2x rate)
- Support ticket metrics

### 5. Revenue & Monetization
- Monthly revenue trends
- Subscription events (upgrades, downgrades, churn)
- Plan distribution
- Price change analysis (Oct 2025)
- Payment methods and cancellation reasons

## Embedded Insights to Discover

The dashboards are designed to help discover these insights:

| # | Insight | Where to Find |
|---|---------|---------------|
| 1 | **Channel Quality Paradox** - Paid Social has 7.6x worse activation than Organic Search | Growth & Acquisition, Retention & Churn |
| 2 | **Summer Blast Disaster** - July 2025 cohort has worse retention | Retention & Churn |
| 3 | **Referral Golden Cohort** - Referred users have ~60% lower churn | Growth & Acquisition, Retention & Churn |
| 4 | **Enterprise Stability** - Large/Enterprise accounts churn 2.3x less than SMB | Retention & Churn |
| 5 | **US vs EU Gap** - US users churn ~8% more than European | Retention & Churn |
| 6 | **iOS Sync Disaster** - Feb 2026 iOS errors spike 7.2x | Product Engagement |
| 7 | **Android 2x Errors** - Android has 2.4x more errors than iOS | Product Engagement |
| 8 | **Templates Magic** - Early template adopters churn 58% less | Product Engagement |
| 9 | **Error-Churn Correlation** - Users with 3+ early errors churn 3x more | Product Engagement |
| 10 | **Price Change Impact** - Oct 2025 caused ~14% fewer conversions, +41% ARPU | Revenue & Monetization |

## Notes

- **No PDT Support:** This project does not use persistent derived tables (PDTs). All `persist_with` directives are commented out.
- **PostgreSQL Syntax:** SQL is written for PostgreSQL (not BigQuery).
- **Boolean Handling:** Boolean fields are stored as text ('True'/'False') in the source data.

## Setup

1. Import this project into your Looker instance
2. Configure the connection `postgres_saas_b2b_plg` to point to your PostgreSQL database
3. Ensure the `saas_b2b_plg` schema exists with all tables loaded
4. Validate the project in Looker IDE

## Tables Required

- plans
- companies
- users
- workspaces
- marketing_channels
- marketing_campaigns
- marketing_touches
- signup_events
- onboarding_checklist_events
- subscriptions
- subscription_events
- invoices
- payments
- sessions
- feature_usage
- documents
- collaborations
- product_errors
- email_events
- notifications
- support_tickets
- referrals
