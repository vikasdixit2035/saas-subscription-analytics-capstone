-- In psql, replace <RAW_FOLDER> with the absolute path to 02_Data/Raw
SET search_path TO saas_capstone;
\copy dim_accounts FROM '<RAW_FOLDER>/dim_accounts.csv' CSV HEADER;
\copy dim_plans FROM '<RAW_FOLDER>/dim_plans.csv' CSV HEADER;
\copy dim_products FROM '<RAW_FOLDER>/dim_products.csv' CSV HEADER;
\copy dim_account_managers FROM '<RAW_FOLDER>/dim_account_managers.csv' CSV HEADER;
\copy fact_subscriptions FROM '<RAW_FOLDER>/fact_subscriptions.csv' CSV HEADER;
\copy fact_monthly_account_snapshot FROM '<RAW_FOLDER>/fact_monthly_account_snapshot.csv' CSV HEADER;
\copy fact_invoices FROM '<RAW_FOLDER>/fact_invoices.csv' CSV HEADER;
\copy fact_support_tickets FROM '<RAW_FOLDER>/fact_support_tickets.csv' CSV HEADER;
\copy fact_nps_surveys FROM '<RAW_FOLDER>/fact_nps_surveys.csv' CSV HEADER;
\copy bridge_account_products FROM '<RAW_FOLDER>/bridge_account_products.csv' CSV HEADER;
\copy fact_marketing_sales_spend FROM '<RAW_FOLDER>/fact_marketing_sales_spend.csv' CSV HEADER;
