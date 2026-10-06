SET search_path TO saas_capstone;

-- Q01
SELECT segment,industry,region,acquisition_channel,COUNT(*) accounts FROM dim_accounts GROUP BY 1,2,3,4 ORDER BY accounts DESC;

-- Q02
WITH lm AS (SELECT MAX(month) m FROM fact_monthly_account_snapshot) SELECT COUNT(DISTINCT account_id) FILTER(WHERE churned_flag=0) active_logos, SUM(mrr_gbp) FILTER(WHERE churned_flag=0) mrr_gbp, 12*SUM(mrr_gbp) FILTER(WHERE churned_flag=0) arr_gbp FROM fact_monthly_account_snapshot f,lm WHERE f.month=lm.m;

-- Q03
WITH lm AS (SELECT MAX(month)m FROM fact_monthly_account_snapshot) SELECT segment,SUM(mrr_gbp)/NULLIF(COUNT(DISTINCT account_id),0) arpa_mrr FROM fact_monthly_account_snapshot f,lm WHERE f.month=lm.m AND churned_flag=0 GROUP BY 1 ORDER BY arpa_mrr DESC;

-- Q04
WITH lm AS (SELECT MAX(month)m FROM fact_monthly_account_snapshot) SELECT segment,plan_id,AVG(seat_utilization) avg_utilization FROM fact_monthly_account_snapshot f,lm WHERE f.month=lm.m GROUP BY 1,2 ORDER BY 1,3;

-- Q05
WITH lm AS (SELECT MAX(month)m FROM fact_monthly_account_snapshot) SELECT account_id,segment,plan_id,seats,active_users,seat_utilization,mrr_gbp*12 arr_gbp FROM fact_monthly_account_snapshot f,lm WHERE f.month=lm.m AND seat_utilization<0.35 ORDER BY arr_gbp DESC;

-- Q06
SELECT month,AVG(churned_flag::numeric) logo_churn_event_rate FROM fact_monthly_account_snapshot GROUP BY 1 ORDER BY 1;

-- Q07
SELECT month,SUM(CASE WHEN revenue_movement='Churn' THEN mrr_gbp ELSE 0 END)/NULLIF(SUM(prior_mrr_gbp),0) mrr_churn_rate FROM fact_monthly_account_snapshot GROUP BY 1 ORDER BY 1;

-- Q08
WITH x AS (
SELECT c.month,c.account_id,p.mrr_gbp opening_mrr,c.mrr_gbp closing_mrr
FROM fact_monthly_account_snapshot c JOIN fact_monthly_account_snapshot p
ON c.account_id=p.account_id AND p.month=(c.month-INTERVAL '1 month')::date),
b AS (SELECT month,SUM(opening_mrr) opening,
SUM(GREATEST(closing_mrr-opening_mrr,0)) expansion,
SUM(CASE WHEN closing_mrr>0 THEN GREATEST(opening_mrr-closing_mrr,0) ELSE 0 END) contraction,
SUM(CASE WHEN closing_mrr=0 THEN opening_mrr ELSE 0 END) churn FROM x WHERE opening_mrr>0 GROUP BY 1) SELECT month,(opening-contraction-churn)/NULLIF(opening,0) grr FROM b ORDER BY 1;

-- Q09
WITH x AS (
SELECT c.month,c.account_id,p.mrr_gbp opening_mrr,c.mrr_gbp closing_mrr
FROM fact_monthly_account_snapshot c JOIN fact_monthly_account_snapshot p
ON c.account_id=p.account_id AND p.month=(c.month-INTERVAL '1 month')::date),
b AS (SELECT month,SUM(opening_mrr) opening,
SUM(GREATEST(closing_mrr-opening_mrr,0)) expansion,
SUM(CASE WHEN closing_mrr>0 THEN GREATEST(opening_mrr-closing_mrr,0) ELSE 0 END) contraction,
SUM(CASE WHEN closing_mrr=0 THEN opening_mrr ELSE 0 END) churn FROM x WHERE opening_mrr>0 GROUP BY 1) SELECT month,(opening-contraction-churn+expansion)/NULLIF(opening,0) nrr FROM b ORDER BY 1;

-- Q10
SELECT month,SUM(CASE WHEN revenue_movement='New' THEN mrr_gbp ELSE 0 END) new_mrr,SUM(CASE WHEN revenue_movement='Expansion' THEN GREATEST(mrr_gbp-prior_mrr_gbp,0) ELSE 0 END) expansion_mrr,SUM(CASE WHEN revenue_movement='Contraction' THEN GREATEST(prior_mrr_gbp-mrr_gbp,0) ELSE 0 END) contraction_mrr,SUM(CASE WHEN revenue_movement='Churn' THEN mrr_gbp ELSE 0 END) churned_mrr,SUM(mrr_gbp) closing_mrr FROM fact_monthly_account_snapshot GROUP BY 1 ORDER BY 1;

-- Q11
WITH lm AS (SELECT MAX(month)m FROM fact_monthly_account_snapshot) SELECT segment,SUM(mrr_gbp)*12 arr_gbp FROM fact_monthly_account_snapshot f,lm WHERE f.month=lm.m AND churned_flag=0 GROUP BY 1 ORDER BY 2 DESC;

-- Q12
SELECT a.industry,SUM(f.mrr_gbp)*12 churned_arr FROM fact_monthly_account_snapshot f JOIN dim_accounts a USING(account_id) WHERE f.revenue_movement='Churn' AND f.month>=(SELECT MAX(month)-INTERVAL '11 month' FROM fact_monthly_account_snapshot) GROUP BY 1 ORDER BY 2 DESC;

-- Q13
SELECT s.billing_frequency,AVG(f.churned_flag::numeric) churn_rate FROM fact_monthly_account_snapshot f JOIN fact_subscriptions s USING(account_id) GROUP BY 1;

-- Q14
SELECT s.contract_term_months,AVG(f.churned_flag::numeric) churn_rate FROM fact_monthly_account_snapshot f JOIN fact_subscriptions s USING(account_id) GROUP BY 1 ORDER BY 1;

-- Q15
SELECT CASE WHEN discount_pct<0.05 THEN '<5%' WHEN discount_pct<0.10 THEN '5-10%' WHEN discount_pct<0.20 THEN '10-20%' ELSE '20%+' END discount_band,AVG(churned_flag::numeric) churn_rate FROM fact_monthly_account_snapshot GROUP BY 1 ORDER BY 1;

-- Q16
WITH lm AS(SELECT MAX(month)m FROM fact_monthly_account_snapshot) SELECT f.account_id,f.plan_id,f.discount_pct,p.standard_discount_pct FROM fact_monthly_account_snapshot f JOIN dim_plans p USING(plan_id),lm WHERE f.month=lm.m AND f.discount_pct>p.standard_discount_pct ORDER BY f.discount_pct-p.standard_discount_pct DESC;

-- Q17
WITH lm AS(SELECT MAX(month)m FROM fact_monthly_account_snapshot) SELECT SUM(f.seats*p.list_price_per_seat_month*GREATEST(f.discount_pct-p.standard_discount_pct,0)*12) annual_leakage FROM fact_monthly_account_snapshot f JOIN dim_plans p USING(plan_id),lm WHERE f.month=lm.m;

-- Q18
SELECT CASE WHEN nps_score<=6 THEN 'Detractor' WHEN nps_score<=8 THEN 'Passive' ELSE 'Promoter' END nps_group,COUNT(*) surveys FROM fact_nps_surveys GROUP BY 1 ORDER BY 1;

-- Q19
WITH n AS(SELECT DISTINCT ON(account_id) account_id,nps_score FROM fact_nps_surveys ORDER BY account_id,survey_month DESC), c AS(SELECT account_id,MAX(churned_flag) churned FROM fact_monthly_account_snapshot GROUP BY 1) SELECT CASE WHEN nps_score<=6 THEN 'Detractor' WHEN nps_score>=9 THEN 'Promoter' ELSE 'Passive' END nps_group,AVG(churned::numeric) churn_rate FROM n JOIN c USING(account_id) GROUP BY 1;

-- Q20
WITH t AS(SELECT account_id,MAX((severity='Critical')::int) has_critical FROM fact_support_tickets GROUP BY 1),c AS(SELECT account_id,MAX(churned_flag) churned FROM fact_monthly_account_snapshot GROUP BY 1) SELECT COALESCE(has_critical,0) has_critical,AVG(churned::numeric) churn_rate FROM c LEFT JOIN t USING(account_id) GROUP BY 1;

-- Q21
SELECT ticket_type,AVG(resolution_hours) avg_resolution_hours,AVG(csat_score) avg_csat,COUNT(*) tickets FROM fact_support_tickets GROUP BY 1 ORDER BY tickets DESC;

-- Q22
WITH lm AS(SELECT MAX(month)m FROM fact_monthly_account_snapshot),x AS(SELECT f.account_id,f.mrr_gbp*12 arr,a.account_manager_id,f.seat_utilization FROM fact_monthly_account_snapshot f JOIN dim_accounts a USING(account_id),lm WHERE f.month=lm.m) SELECT account_manager_id,SUM(arr) FILTER(WHERE seat_utilization<0.5) arr_at_risk_proxy FROM x GROUP BY 1 ORDER BY 2 DESC;

-- Q23
SELECT p.product_name,COUNT(DISTINCT b.account_id) accounts,COUNT(DISTINCT b.account_id)::numeric/(SELECT COUNT(*) FROM dim_accounts) attach_rate FROM bridge_account_products b JOIN dim_products p USING(product_id) WHERE p.product_type='Add-on' AND b.active_flag GROUP BY 1 ORDER BY 3 DESC;

-- Q24
WITH pc AS(SELECT account_id,COUNT(*) products FROM bridge_account_products WHERE active_flag GROUP BY 1),c AS(SELECT account_id,MAX(churned_flag) churned FROM fact_monthly_account_snapshot GROUP BY 1) SELECT CASE WHEN products=1 THEN '1' WHEN products=2 THEN '2' ELSE '3+' END product_count_band,1-AVG(churned::numeric) retention_proxy FROM pc JOIN c USING(account_id) GROUP BY 1 ORDER BY 1;

-- Q25
SELECT a.segment,COUNT(DISTINCT b.account_id)::numeric/COUNT(DISTINCT a.account_id) ai_attach_rate FROM dim_accounts a LEFT JOIN bridge_account_products b ON a.account_id=b.account_id AND b.product_id='PRD_AI' GROUP BY 1 ORDER BY 2 DESC;

-- Q26
WITH lm AS(SELECT MAX(month)m FROM fact_monthly_account_snapshot) SELECT account_id,segment,mrr_gbp*12 arr,seats,seat_utilization FROM fact_monthly_account_snapshot f,lm WHERE f.month=lm.m AND churned_flag=0 AND seat_utilization>=0.80 ORDER BY arr DESC;

-- Q27
WITH lm AS(SELECT MAX(month)m FROM fact_monthly_account_snapshot) SELECT account_id,segment,mrr_gbp*12 arr,seat_utilization,mrr_gbp-prior_mrr_gbp mrr_change FROM fact_monthly_account_snapshot f,lm WHERE f.month=lm.m AND seat_utilization<0.40 AND mrr_gbp<prior_mrr_gbp ORDER BY arr DESC;

-- Q28
SELECT account_id,AVG(seat_utilization) avg_utilization,AVG(nps_score) avg_nps,SUM(critical_tickets) critical_tickets,SUM(support_tickets) tickets,MAX(mrr_gbp)*12 arr FROM fact_monthly_account_snapshot GROUP BY 1 ORDER BY arr DESC;

-- Q29
SELECT a.segment,AVG((i.payment_status='Failed')::int::numeric) failed_rate,AVG((i.payment_status='Late')::int::numeric) late_rate FROM fact_invoices i JOIN dim_accounts a USING(account_id) GROUP BY 1;

-- Q30
WITH c AS(SELECT account_id,MAX(churned_flag) churned FROM fact_monthly_account_snapshot GROUP BY 1) SELECT a.acquisition_channel,AVG(c.churned::numeric) churn_rate FROM dim_accounts a JOIN c USING(account_id) GROUP BY 1 ORDER BY 2 DESC;

-- Q31
WITH n AS(SELECT DATE_TRUNC('month',signup_date)::date month,acquisition_channel,COUNT(*) new_customers FROM dim_accounts GROUP BY 1,2) SELECT s.month,s.acquisition_channel,s.marketing_sales_spend_gbp,n.new_customers,s.marketing_sales_spend_gbp/NULLIF(n.new_customers,0) cac FROM fact_marketing_sales_spend s LEFT JOIN n USING(month,acquisition_channel) ORDER BY 1,2;

-- Q32
WITH new_logo_arr AS (
  SELECT DATE_TRUNC('month',a.signup_date)::date AS month,
         a.acquisition_channel,
         SUM(f.mrr_gbp)*12 AS new_arr
  FROM dim_accounts a
  JOIN fact_monthly_account_snapshot f
    ON f.account_id=a.account_id
   AND f.month=DATE_TRUNC('month',a.signup_date)::date
  GROUP BY 1,2
)
SELECT n.month,n.acquisition_channel,n.new_arr,s.marketing_sales_spend_gbp,
       n.new_arr/NULLIF(s.marketing_sales_spend_gbp,0) AS new_arr_per_spend
FROM new_logo_arr n
JOIN fact_marketing_sales_spend s USING(month,acquisition_channel)
ORDER BY 1,2;

-- Q33
WITH c AS(SELECT account_id,DATE_TRUNC('month',signup_date)::date cohort_month FROM dim_accounts),x AS(SELECT f.account_id,c.cohort_month,f.month,(DATE_PART('year',age(f.month,c.cohort_month))*12+DATE_PART('month',age(f.month,c.cohort_month)))::int age_month,f.churned_flag FROM fact_monthly_account_snapshot f JOIN c USING(account_id)) SELECT cohort_month,age_month,COUNT(DISTINCT account_id) FILTER(WHERE churned_flag=0) active_logos FROM x GROUP BY 1,2 ORDER BY 1,2;

-- Q34
WITH c AS(SELECT account_id,DATE_TRUNC('month',signup_date)::date cohort_month FROM dim_accounts),x AS(SELECT f.account_id,c.cohort_month,f.month,(DATE_PART('year',age(f.month,c.cohort_month))*12+DATE_PART('month',age(f.month,c.cohort_month)))::int age_month,f.mrr_gbp FROM fact_monthly_account_snapshot f JOIN c USING(account_id)) SELECT cohort_month,age_month,SUM(mrr_gbp) cohort_mrr FROM x GROUP BY 1,2 ORDER BY 1,2;

-- Q35
SELECT a.segment,PERCENTILE_CONT(.5) WITHIN GROUP(ORDER BY (s.cancellation_date-s.start_date)) median_days_to_churn FROM fact_subscriptions s JOIN dim_accounts a USING(account_id) WHERE s.subscription_status='Cancelled' GROUP BY 1;

-- Q36
SELECT month,SUM(GREATEST(mrr_gbp-prior_mrr_gbp,0)) FILTER(WHERE revenue_movement='Expansion') expansion_mrr,SUM(GREATEST(prior_mrr_gbp-mrr_gbp,0)) FILTER(WHERE revenue_movement='Contraction') contraction_mrr FROM fact_monthly_account_snapshot GROUP BY 1 ORDER BY 1;

-- Q37
SELECT segment,COUNT(*) FILTER(WHERE revenue_movement='Expansion')::numeric/COUNT(*) expansion_event_rate FROM fact_monthly_account_snapshot GROUP BY 1 ORDER BY 2 DESC;

-- Q38
SELECT account_id,SUM(GREATEST(prior_mrr_gbp-mrr_gbp,0)) contraction_mrr FROM fact_monthly_account_snapshot WHERE revenue_movement='Contraction' GROUP BY 1 ORDER BY 2 DESC LIMIT 100;

-- Q39
WITH lastm AS(SELECT DISTINCT ON(account_id) account_id,mrr_gbp FROM fact_monthly_account_snapshot ORDER BY account_id,month DESC) SELECT s.primary_churn_reason,COUNT(*) churned_accounts,SUM(l.mrr_gbp)*12 lost_arr FROM fact_subscriptions s JOIN lastm l USING(account_id) WHERE s.subscription_status='Cancelled' GROUP BY 1 ORDER BY 3 DESC;

-- Q40
WITH lm AS(SELECT MAX(month)m FROM fact_monthly_account_snapshot),a AS(SELECT account_id,mrr_gbp*12 arr FROM fact_monthly_account_snapshot f,lm WHERE f.month=lm.m AND churned_flag=0),r AS(SELECT *,ROW_NUMBER()OVER(ORDER BY arr DESC)rn FROM a) SELECT SUM(arr) FILTER(WHERE rn<=10)/SUM(arr) top10_arr_concentration FROM r;

-- Q41
WITH lm AS(SELECT MAX(month)m FROM fact_monthly_account_snapshot) SELECT a.industry,SUM(f.mrr_gbp)*12 arr FROM fact_monthly_account_snapshot f JOIN dim_accounts a USING(account_id),lm WHERE f.month=lm.m AND f.churned_flag=0 GROUP BY 1 ORDER BY 2 DESC;

-- Q42
WITH lm AS(SELECT MAX(month)m FROM fact_monthly_account_snapshot) SELECT f.account_id,f.plan_id,f.seats,p.max_seats,f.mrr_gbp*12 arr FROM fact_monthly_account_snapshot f JOIN dim_plans p USING(plan_id),lm WHERE f.month=lm.m AND f.seats>p.max_seats ORDER BY arr DESC;

-- Q43
WITH lm AS(SELECT MAX(month)m FROM fact_monthly_account_snapshot) SELECT f.account_id,f.plan_id,f.seats,(p2.list_price_per_seat_month-p.list_price_per_seat_month)*f.seats*12 potential_upgrade_value FROM fact_monthly_account_snapshot f JOIN dim_plans p USING(plan_id) LEFT JOIN dim_plans p2 ON p2.plan_rank=p.plan_rank+1,lm WHERE f.month=lm.m AND p2.plan_id IS NOT NULL AND f.seats>p.max_seats*.85 ORDER BY potential_upgrade_value DESC;

-- Q44
WITH e AS(SELECT account_id,MIN(month) exp_month FROM fact_monthly_account_snapshot WHERE revenue_movement='Expansion' GROUP BY 1),u AS(SELECT f.account_id,AVG(f.seat_utilization) avg_pre_util FROM fact_monthly_account_snapshot f JOIN e USING(account_id) WHERE f.month BETWEEN e.exp_month-INTERVAL '3 month' AND e.exp_month-INTERVAL '1 month' GROUP BY 1) SELECT AVG(avg_pre_util) avg_util_before_expansion FROM u;

-- Q45
WITH lm AS(SELECT MAX(month)m FROM fact_monthly_account_snapshot) SELECT a.account_manager_id,COUNT(DISTINCT f.account_id) accounts,SUM(f.mrr_gbp)*12 portfolio_arr FROM fact_monthly_account_snapshot f JOIN dim_accounts a USING(account_id),lm WHERE f.month=lm.m AND f.churned_flag=0 GROUP BY 1 ORDER BY 3 DESC;

-- Q46
WITH lm AS(SELECT MAX(month)m FROM fact_monthly_account_snapshot),p AS(SELECT a.account_manager_id,SUM(f.mrr_gbp)*12 portfolio_arr FROM fact_monthly_account_snapshot f JOIN dim_accounts a USING(account_id),lm WHERE f.month=lm.m AND f.churned_flag=0 GROUP BY 1) SELECT p.*,m.portfolio_capacity_arr_gbp,p.portfolio_arr/m.portfolio_capacity_arr_gbp capacity_utilization FROM p JOIN dim_account_managers m USING(account_manager_id) ORDER BY capacity_utilization DESC;

-- Q47
WITH active AS (
 SELECT s.*,
        GREATEST(s.contract_term_months,1) AS step_months
 FROM fact_subscriptions s
 WHERE s.subscription_status='Active'
),
renewals AS (
 SELECT a.*,
        gs::date AS renewal_date
 FROM active a
 CROSS JOIN LATERAL generate_series(
   (a.start_date + make_interval(months => a.step_months))::timestamp,
   (CURRENT_DATE + INTERVAL '3 years')::timestamp,
   make_interval(months => a.step_months)
 ) gs
)
SELECT account_id,subscription_id,renewal_date
FROM renewals
WHERE renewal_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '90 days'
ORDER BY renewal_date;

-- Q48
WITH lm AS (SELECT MAX(month)m FROM fact_monthly_account_snapshot),
latest AS (
 SELECT f.*,a.account_manager_id
 FROM fact_monthly_account_snapshot f
 JOIN dim_accounts a USING(account_id),lm
 WHERE f.month=lm.m AND f.churned_flag=0
),
risk AS (
 SELECT *,
   100 * (
     0.45*(1-seat_utilization)
     + 0.20*CASE WHEN nps_score IS NULL THEN 0.30 WHEN nps_score<=6 THEN 1 WHEN nps_score<=8 THEN 0.50 ELSE 0 END
     + 0.20*LEAST(critical_tickets,2)/2.0
     + 0.15*LEAST(avg_resolution_hours,48)/48.0
   ) AS risk_score
 FROM latest
)
SELECT account_id,account_manager_id,mrr_gbp*12 arr_gbp,risk_score
FROM risk
ORDER BY (mrr_gbp*12)*risk_score DESC
LIMIT 500;

-- Q49
WITH lm AS(SELECT MAX(month)m FROM fact_monthly_account_snapshot) SELECT segment,COUNT(DISTINCT account_id) active_logos,SUM(mrr_gbp)*12 arr,AVG(seat_utilization) avg_utilization,AVG(discount_pct) avg_discount,AVG(nps_score) avg_nps,SUM(churned_flag) churn_events FROM fact_monthly_account_snapshot f,lm WHERE f.month=lm.m GROUP BY 1 ORDER BY arr DESC;

-- Q50
SELECT 'Pricing leakage' issue,SUM(seats*p.list_price_per_seat_month*GREATEST(f.discount_pct-p.standard_discount_pct,0)*12) annualized_impact FROM fact_monthly_account_snapshot f JOIN dim_plans p USING(plan_id) WHERE f.month=(SELECT MAX(month) FROM fact_monthly_account_snapshot) UNION ALL SELECT 'Latest month churned ARR',SUM(mrr_gbp)*12 FROM fact_monthly_account_snapshot WHERE month=(SELECT MAX(month) FROM fact_monthly_account_snapshot) AND revenue_movement='Churn';
