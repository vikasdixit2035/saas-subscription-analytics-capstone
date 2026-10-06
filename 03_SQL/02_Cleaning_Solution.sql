SET search_path TO saas_capstone;
UPDATE dim_accounts
SET industry=INITCAP(TRIM(industry)),
    region=CASE WHEN TRIM(region)='UK & I' THEN 'UK&I' ELSE TRIM(region) END,
    acquisition_channel=TRIM(acquisition_channel);

UPDATE fact_invoices SET payment_status=INITCAP(TRIM(payment_status));
UPDATE fact_support_tickets
SET ticket_type=CASE WHEN LOWER(TRIM(ticket_type))='product bug' THEN 'Product Bug' ELSE TRIM(ticket_type) END;

UPDATE fact_monthly_account_snapshot
SET discount_pct=CASE WHEN discount_pct>1 THEN discount_pct/100.0 ELSE discount_pct END,
    nps_score=CASE WHEN nps_score BETWEEN 0 AND 10 THEN nps_score ELSE NULL END,
    seat_utilization=CASE WHEN seat_utilization IS NULL AND seats>0 THEN active_users::numeric/seats ELSE seat_utilization END;

DELETE FROM fact_invoices a USING fact_invoices b
WHERE a.ctid<b.ctid AND a.invoice_id=b.invoice_id;
