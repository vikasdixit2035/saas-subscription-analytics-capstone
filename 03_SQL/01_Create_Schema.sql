CREATE SCHEMA IF NOT EXISTS saas_capstone;
SET search_path TO saas_capstone;

CREATE TABLE dim_accounts (
 account_id VARCHAR(20) PRIMARY KEY, account_name VARCHAR(100), segment VARCHAR(30),
 industry VARCHAR(60), region VARCHAR(60), acquisition_channel VARCHAR(60),
 signup_date DATE, employee_count INTEGER, account_manager_id VARCHAR(20));

CREATE TABLE dim_plans (
 plan_id VARCHAR(20) PRIMARY KEY, plan_name VARCHAR(60), plan_family VARCHAR(40),
 list_price_per_seat_month NUMERIC(12,2), min_seats INTEGER, max_seats INTEGER,
 standard_discount_pct NUMERIC(8,4), premium_support BOOLEAN, plan_rank INTEGER);

CREATE TABLE dim_products (
 product_id VARCHAR(20) PRIMARY KEY, product_name VARCHAR(80), product_type VARCHAR(30),
 price_multiplier_vs_core NUMERIC(8,4));

CREATE TABLE dim_account_managers (
 account_manager_id VARCHAR(20) PRIMARY KEY, manager_name VARCHAR(80), region VARCHAR(60),
 annual_cost_gbp NUMERIC(14,2), portfolio_capacity_arr_gbp NUMERIC(14,2));

CREATE TABLE fact_subscriptions (
 subscription_id VARCHAR(30) PRIMARY KEY, account_id VARCHAR(20), initial_plan_id VARCHAR(20),
 start_date DATE, cancellation_date DATE, subscription_status VARCHAR(30),
 billing_frequency VARCHAR(20), contract_term_months INTEGER,
 initial_discount_pct NUMERIC(8,4), primary_churn_reason VARCHAR(100));

CREATE TABLE fact_monthly_account_snapshot (
 month DATE, account_id VARCHAR(20), subscription_id VARCHAR(30), plan_id VARCHAR(20),
 segment VARCHAR(30), seats INTEGER, active_users INTEGER, weekly_active_users INTEGER,
 seat_utilization NUMERIC(8,4), sessions INTEGER, key_actions INTEGER,
 automation_runs INTEGER, ai_actions INTEGER, analytics_views INTEGER,
 support_tickets INTEGER, critical_tickets INTEGER, avg_resolution_hours NUMERIC(12,2),
 nps_score NUMERIC(8,2), discount_pct NUMERIC(8,4), mrr_gbp NUMERIC(14,2),
 prior_mrr_gbp NUMERIC(14,2), revenue_movement VARCHAR(30), churned_flag INTEGER,
 PRIMARY KEY(month,account_id));

CREATE TABLE fact_invoices (
 invoice_id VARCHAR(30), account_id VARCHAR(20), invoice_month DATE,
 invoice_amount_gbp NUMERIC(14,2), due_date DATE, paid_date DATE,
 payment_status VARCHAR(30), billing_frequency VARCHAR(20), discount_pct NUMERIC(8,4));

CREATE TABLE fact_support_tickets (
 ticket_id VARCHAR(30) PRIMARY KEY, account_id VARCHAR(20), opened_date DATE,
 severity VARCHAR(20), ticket_type VARCHAR(60), resolution_hours NUMERIC(12,2),
 csat_score NUMERIC(8,2), ticket_status VARCHAR(30));

CREATE TABLE fact_nps_surveys (account_id VARCHAR(20), survey_month DATE, nps_score INTEGER);
CREATE TABLE bridge_account_products (account_id VARCHAR(20), product_id VARCHAR(20), active_flag BOOLEAN);
CREATE TABLE fact_marketing_sales_spend (month DATE, acquisition_channel VARCHAR(60), marketing_sales_spend_gbp NUMERIC(14,2));
