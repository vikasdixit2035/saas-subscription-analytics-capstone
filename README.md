# SaaS Subscription Analytics — Capstone Project

An end-to-end management-consulting-style analytics capstone evaluating SaaS recurring revenue, retention, pricing discipline, product adoption, and customer success productivity.

---

## 📌 Executive Summary & Scenario

Supporting the executive leadership team of **Northstar Cloud**, a synthetic multi-product B2B enterprise SaaS company, this project diagnoses drivers of durable ARR growth, customer health, and commercial discipline across:
- **Active Logos:** 4,328
- **Active ARR:** ~£1.093B
- **Latest NRR / GRR:** 97.8% / 95.6%
- **Critical / At-Risk ARR:** ~£47.1M
- **Annualized Pricing Leakage:** ~£20.9M excess-discount leakage
- **Addressable Expansion Pool:** ~£166.9M in healthy, high-utilization accounts

---

## 🛠️ Tech Stack & Workflow

```
Raw CSV / Excel ➔ PostgreSQL / SQL Cleaning & Metric Layer ➔ Python EDA & ML Health Scoring ➔ Power BI Dashboard ➔ Executive Memo & Strategic Roadmap
```

- **Database / SQL:** PostgreSQL 15+ (Schema modeling, data reconciliation, 50 business queries, metric layer)
- **Python / Data Science:** Python 3.11+ (`pandas`, `numpy`, `scikit-learn`, `matplotlib`, `seaborn`)
- **BI & Visualization:** Power BI semantic model, DAX measures, executive reporting blueprint
- **Consulting Artifacts:** Issue Tree, KPI Framework, Hypothesis Register, Workplan, Executive Storyline

---

## 📂 Repository Structure

```text
├── 00_README/                  # Quickstart guide and run order documentation
├── 01_Project_Brief/           # Learner brief (PDF) and architectural differentiator memo
├── 02_Data/
│   ├── Raw/                    # Deliberately imperfect raw CSVs (invoices, snapshots, tickets, NPS)
│   ├── Clean_Reference/        # Validated clean baseline datasets
│   └── Data_Dictionary_KPI_Catalog.xlsx
├── 03_SQL/
│   ├── 00_Load_Data.sql        # Database initialization and ingest
│   ├── 01_Create_Schema.sql    # Relational schema definition
│   ├── 02_Cleaning_Solution.sql# Data reconciliation logic
│   ├── 03_Business_Questions_50.txt
│   └── 04_Solution_Queries_50.sql
├── 04_Python/
│   ├── SaaS_Subscription_Analytics_Learner.ipynb
│   ├── SaaS_Subscription_Analytics_Solution.ipynb
│   ├── SaaS_Subscription_Analytics_Solution_Executed.ipynb
│   ├── SaaS_Subscription_Analytics_Solution_Executed.html
│   └── requirements.txt
├── 05_PowerBI/                 # DAX measures, semantic model schema, theme JSON, dashboard blueprint
├── 06_Consulting_Workflow/     # Issue tree, KPI tree, hypothesis register, workplan, executive report
├── 07_Solution_Outputs/        # Exported analysis tables, scored cohorts, and sizing matrices
├── 08_Submission_Templates/    # Blank templates for student deliverables
├── PROJECT_MANIFEST.md         # Full file and deliverable breakdown
└── .gitignore
```

---

## 🚀 Recommended Run Order

1. **Briefing:** Review `01_Project_Brief/SaaS_Subscription_Analytics_Learner_Brief.pdf` and `02_Data/Data_Dictionary_KPI_Catalog.xlsx`.
2. **Database Ingestion:** Load `02_Data/Raw/*.csv` using `03_SQL/00_Load_Data.sql` and `03_SQL/01_Create_Schema.sql`.
3. **Data Quality & Metrics:** Complete SQL business questions in `03_SQL/03_Business_Questions_50.txt` (reference solutions in `03_SQL/04_Solution_Queries_50.sql`).
4. **Python Exploratory Analysis:** Execute `04_Python/SaaS_Subscription_Analytics_Learner.ipynb` for cohort retention and risk scoring.
5. **Business Intelligence:** Build the Power BI model using specifications in `05_PowerBI/`.
6. **Executive Storyline:** Review consulting frameworks in `06_Consulting_Workflow/` to formulate the final strategy recommendations.

---

## 📄 Notes & Disclaimers

This is synthetic training data generated for educational and analytical benchmarking purposes. The workflow reflects common SaaS management-consulting best practices and does not reproduce proprietary methodology or confidential data from any specific firm.
