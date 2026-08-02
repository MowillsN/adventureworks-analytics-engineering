# AdventureWorks Sales Analytics Engineering Platform

An end-to-end analytics engineering project transforming raw AdventureWorks 2025 DW sales data into a tested, documented, orchestrated, and BI-ready analytics platform, built with Python, Databricks (Unity Catalog + Delta Lake), dbt, and Power BI.

This isn't a "load a CSV, build a chart" project. It's a deliberately scoped, production style pipeline: dimensional modeling on paper before a line of code was written, automated data quality testing at every layer, CI/CD gating every change, and a scheduled orchestration job keeping the warehouse fresh.

---

## Table of Contents

- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Data Model](#data-model)
- [Project Structure](#project-structure)
- [Key Engineering Decisions](#key-engineering-decisions)
- [Data Quality & Testing](#data-quality--testing)
- [CI/CD](#cicd)
- [Orchestration](#orchestration)
- [Dashboard](#dashboard)
- [Business Questions Answered](#business-questions-answered)
- [Setup & Reproduction](#setup--reproduction)
- [Known Limitations](#known-limitations)
- [Contact](#contact)

---

## Architecture

```
AdventureWorks2025DW.bak (SQL Server backup)
        │
        ▼
SQL Server (local, restored one-time)
        │
        ▼  Python (pyodbc, SQLAlchemy, pandas, pyarrow)
        │   extract → validate (row counts, nulls, grain uniqueness) → convert to Parquet
        ▼
Databricks Unity Catalog — Volumes (raw file landing)
        │
        ▼  Managed Delta tables (CREATE TABLE AS SELECT from Parquet)
        ▼
Databricks Unity Catalog — bronze schema (13 raw tables)
        │
        ▼  dbt-databricks
        │   staging (bronze → silver): cleaning, renaming, type casting
        │   intermediate (silver → silver_int): joins, business logic, SCD-aware denormalization
        │   marts (silver_int → gold): final star schema, BI-facing
        ▼
Databricks Unity Catalog — gold schema (star schema: dimensions, facts, bridge, role-playing dates)
        │
        ▼  Databricks SQL Warehouse
        ▼
Power BI (Import mode) — 6-page interactive report
```

**Orchestration** (Databricks Workflows, daily schedule) automates the `dbt build` step — pulling the latest code from this GitHub repo and rebuilding staging → intermediate → marts, including all tests, every day.

**CI/CD** (GitHub Actions) runs the same `dbt build` against isolated `ci_`-prefixed schemas on every pull request, so no untested change can reach production tables.

> **Note on ingestion:** the Python ingestion step (SQL Server → Parquet → Databricks) is a manual/local step, not part of the cloud orchestration. This is a deliberate, honest boundary as the source system is an on-premises SQL Server instance with no network path to cloud-hosted Databricks Workflows. See [Known Limitations](#known-limitations) for more on this and how a real production setup would close the gap.

---

## Tech Stack

| Layer | Tool | Why |
|---|---|---|
| Source | SQL Server (AdventureWorks2025DW) | Provided dataset, restored from `.bak` |
| Ingestion | Python (pyodbc, SQLAlchemy, pandas, pyarrow) | Scripted, reproducible extraction and validation |
| Data Lake / Warehouse | Databricks (Unity Catalog, Delta Lake, Free Edition) | Modern lakehouse architecture; serverless compute |
| Transformation | dbt-databricks + dbt_utils | Industry-standard analytics engineering tooling |
| Orchestration | Databricks Workflows | Native scheduling, no extra infrastructure |
| CI/CD | GitHub Actions | Automated testing on every pull request |
| BI | Power BI (Import mode) | Industry-leading BI tool; native Databricks connector |
| Version Control | Git / GitHub | Full project history, branch-based workflow |

---

## Data Model

The project is scoped around **Sales Performance Analytics** — internet (direct-to-consumer) and reseller (B2B) sales channels — deliberately excluding call center, finance, and survey response data, which belong to unrelated business processes and would have diluted the project's focus without adding meaningful analytical value.

### Conformed Bus Matrix

| Dimension | Internet Sales | Reseller Sales |
|---|:---:|:---:|
| Date (order/due/ship — role-playing) | ✅ | ✅ |
| Product (denormalized w/ category) | ✅ | ✅ |
| Promotion | ✅ | ✅ |
| Sales Territory | ✅ | ✅ |
| Customer | ✅ | ❌ |
| Reseller | ❌ | ✅ |
| Sales Reason (via bridge) | ✅ | ❌ |

### Grain Declarations

| Table | Grain |
|---|---|
| `fct_internet_sales` | One row per internet sales order line |
| `fct_reseller_sales` | One row per reseller sales order line |
| `fct_sales` | Unified (UNION ALL) of both channels' conformed columns |
| `bridge_internet_sales_reason` | One row per (order line, sales reason) — many-to-many resolver, no measures |

### Role-Playing Dimension: Date

`dim_date` is the single source of truth for date attributes. Three lightweight views — `dim_order_date`, `dim_due_date`, `dim_ship_date` — sit on top of it, giving Power BI three independent, filterable date relationships without relying on DAX `USERELATIONSHIP` workarounds.

---

## Project Structure

```
adventureworks-analytics-engineering/
├── ingestion/
│   ├── extract_to_parquet.py       # SQL Server → Parquet
│   ├── validate_raw_data.py        # Row counts, null profiling, grain checks
│   ├── upload_to_databricks.py     # Parquet → Unity Catalog Volume
│   └── create_bronze_tables.sql    # Volume files → managed Delta tables
├── adventureworks_dbt/
│   ├── models/
│   │   ├── staging/                # 13 models, 1:1 with bronze sources
│   │   ├── intermediate/           # Joins, denormalization, channel union
│   │   └── marts/                  # Final star schema (11 dims, 4 facts/bridge)
│   ├── macros/
│   │   └── generate_schema_name.sql
│   ├── tests/
│   │   └── assert_fct_sales_row_count_matches_channels.sql
│   └── dbt_project.yml
├── ci/
│   └── profiles.yml                # CI-safe dbt profile (env vars only, no secrets)
├── .github/workflows/
│   └── ci.yml                      # GitHub Actions: dbt build on every PR
├── dashboards/
│   └── AdventureWorks_Sales_Analytics.pbix
├── .env.example
└── .gitignore
```

---

## Key Engineering Decisions

A few decisions worth calling out, since they reflect deliberate tradeoffs rather than defaults:

- **Grain declared explicitly, before any modeling.** Every fact table's grain was written down and later verified programmatically (both in a standalone Python validation script and as a permanent dbt test), not just assumed from documentation.
- **Bridge table (factless fact) correctly modeled.** `FactInternetSalesReason` resolves a genuine many-to-many relationship between sales order lines and sales reasons — verified against the data (confirmed reseller sales have no equivalent concept) rather than assumed from naming conventions.
- **Role-playing dimension handled via database views, not fact-table denormalization.** Keeps a proper, drillable star schema in Power BI instead of flattening date attributes into the fact table three times over.
- **Legitimate business nulls are preserved, not "cleaned away."** Columns like `CarrierTrackingNumber` (100% null for internet sales — a B2B/freight concept that doesn't apply to direct consumer purchases) are kept as-is, with the reasoning documented, rather than silently dropped or defaulted.
- **A surrogate composite key (`sales_order_line_key`) was added specifically to support Power BI**, since Power BI relationships require a single-column key and our bridge table's natural grain is composite. Added at the dbt layer (staging), consistent with the project's principle of keeping BI-layer logic minimal.
- **CI runs against isolated `ci_`-prefixed schemas**, not production tables — a custom dbt macro makes schema naming environment-aware, so every pull request is tested safely without touching the tables the daily production job maintains.
- **Minimally-scoped credentials throughout**, not one broad token reused everywhere — a `files`-scoped token for the Python ingestion script, a separate `sql`-scoped token for dbt/Power BI, each generated for its specific purpose.

---

## Data Quality & Testing

**67 automated dbt tests** run across staging and marts on every build (both in CI and the daily production job):

- `unique` + `not_null` on every dimension's surrogate key
- `not_null` on core measures (`sales_amount`, `order_quantity`) — not applied blanket-wide, since several columns have legitimate business nulls (documented per-column in the dbt-generated docs)
- `relationships` tests validating every fact-to-dimension foreign key against the conformed bus matrix
- `dbt_utils.unique_combination_of_columns` enforcing composite grain uniqueness on all three fact/bridge tables
- A custom singular test (`assert_fct_sales_row_count_matches_channels`) validating that the unified `fct_sales` mart's row count exactly equals the sum of both channel-specific fact tables — proof the UNION ALL neither dropped nor duplicated rows
- `accepted_values` on the derived `sales_channel` column

Full column-level documentation (descriptions, tests, and lineage) is generated via `dbt docs` — see [Setup & Reproduction](#setup--reproduction) for how to view it locally.

---

## CI/CD

Every pull request into `main` automatically triggers a GitHub Actions workflow that:
1. Installs `dbt-databricks` and dbt packages (`dbt deps`)
2. Runs `dbt build` (models + tests, in dependency order) against isolated `ci_silver` / `ci_silver_int` / `ci_gold` schemas
3. Reports pass/fail directly on the PR — merges are gated on this passing

This means no change to a model, test, or macro can reach the production pipeline without first being independently verified in a sandboxed environment, without ever touching the tables Power BI or the scheduled production job depend on.

---

## Orchestration

A Databricks Workflow, connected directly to this GitHub repository via a Git folder, runs `dbt deps` + `dbt build` on a **daily schedule**. Because it pulls from Git at run time, any merged change to `main` is automatically picked up on the next scheduled run — no manual redeployment step required.

---

## Dashboard

The Power BI report (`dashboards/AdventureWorks_Sales_Analytics.pbix`) contains 6 pages:

1. **Executive Overview** — headline KPIs, YoY trend, channel split
2. **Channel Performance** — Internet vs. Reseller comparison (revenue, AOV, margin, regional mix)
3. **Product Performance** — category/subcategory/product drill-down, profitability
4. **Geography & Territory** — regional sales breakdown (map + matrix views)
5. **Customer Insights** — age banding (calculated as of first purchase, not current date, for historically stable reporting), income/occupation analysis
6. **Promotion Effectiveness** — promoted vs. non-promoted sales, discount-vs-margin tradeoff

**📄 [View the full dashboard as a PDF](dashboards/AdventureWorks_Sales_Analytics.pdf)** — no Power BI installation required.

If you have Power BI Desktop installed, open `dashboards/AdventureWorks_Sales_Analytics.pbix` directly for the full interactive experience (drill-downs, slicers).

> **Note:** the data model fully supports sales reason analysis — `dim_sales_reason` and the `bridge_internet_sales_reason` factless fact table are built, tested, and documented (see the dbt docs lineage graph) — but a dedicated dashboard page for it wasn't included in this report, to keep the final report focused on the six core business-performance pages above.

---

## Business Questions Answered

- **How does revenue and profitability compare between the Internet (B2C) and Reseller (B2B) channels?**
  Reseller sales total **$80.45M** against Internet sales of **$29.36M** — Reseller drives roughly **73%** of total revenue despite being a B2B channel with far fewer individual transactions. This shows up clearly in average order value: Reseller AOV is dramatically higher than Internet AOV, consistent with wholesale/bulk purchasing behavior versus individual consumer orders.

- **Which product categories/subcategories drive the most revenue *and* the most profit — and are they the same ones?**
  The **Bikes** category leads on both fronts — highest revenue *and* highest profit. This is a notable finding in itself: it's common for a high-revenue category to actually carry thinner margins than a smaller category, but that's not the case here, making Bikes the unambiguous priority category for the business.

- **Which sales territories and regions are over/under-performing?**
  **Southwest** is the strongest-performing region, at **$24.1M** in sales — the clear standout territory once broken out from the rest.

- **How do customer age, income, and occupation relate to purchase behavior?**
  The **35–44** age band is the single largest driver of Internet sales, accounting for roughly **36%** of total revenue in that channel — a meaningful concentration in one demographic segment worth factoring into any customer targeting strategy.

- **Do deeper promotional discounts erode margin, or does volume lift compensate?**
  Only **6.81%** of total sales occur under an active promotion — the large majority of revenue is generated at full price. Where promotions are used, higher discount percentages correlate with lower profit margins, with no clear evidence of a volume effect fully offsetting that margin loss in this dataset.

---

## Setup & Reproduction

### Prerequisites
- SQL Server with `AdventureWorks2025DW.bak` restored
- Python 3.12+
- A Databricks workspace with Unity Catalog (Free Edition works)
- dbt-databricks
- Power BI Desktop (for viewing/editing the dashboard)

### Steps

```bash
# 1. Clone and set up environment
git clone https://github.com/MowillsN/adventureworks-analytics-engineering.git
cd adventureworks-analytics-engineering
python -m venv venv
venv\Scripts\activate          # Windows
pip install -r requirements.txt

# 2. Configure credentials
cp .env.example .env           # fill in your Databricks host/token

# 3. Run ingestion (requires local SQL Server with AdventureWorks2025DW restored)
python ingestion/extract_to_parquet.py
python ingestion/validate_raw_data.py
python ingestion/upload_to_databricks.py
# Then run ingestion/create_bronze_tables.sql in the Databricks SQL editor

# 4. Run dbt
cd adventureworks_dbt
dbt deps
dbt build

# 5. View documentation locally
dbt docs generate
dbt docs serve
```

Connect Power BI Desktop to your Databricks SQL Warehouse and open `dashboards/AdventureWorks_Sales_Analytics.pbix`, or rebuild the connection against your own workspace.

Prefer not to install Power BI? See `dashboards/AdventureWorks_Sales_Analytics.pdf` for a static, no-setup-required view of all 6 report pages.

---

## Known Limitations

Documenting these deliberately, rather than leaving them to be discovered:

- **Ingestion is not part of the cloud orchestration.** The source SQL Server instance is on-premises with no network path to Databricks Workflows. A production version of this pipeline would replace the manual Python step with something like a self-hosted integration runtime, a persistent on-prem agent, or migrating the source system to the cloud entirely.
- **Currency conversion (`FactCurrencyRate`) is out of scope.** `currency_key` is retained on fact tables for reference but not resolved to actual exchange rates — a deliberate scoping decision to keep the project focused on sales performance rather than financial reporting.
- **Employee/sales quota data is out of scope**, for the same reason — this project is scoped to Sales Performance Analytics, not HR or finance reporting.
- **Databricks Free Edition constraints:** single SQL Warehouse capped at 2X-Small; scheduled jobs limited to 5 concurrent tasks account-wide. Neither constraint affects this project's actual workload, but they'd matter at larger scale.
- **`fct_sales` (the unified mart) has no path to geography.** Since customer/reseller keys were deliberately excluded from the channel union (per the conformed bus matrix), geographic analysis in Power BI uses `Internet Sales Amount + Reseller Sales Amount` summed independently through each channel's own dimension path, rather than the unified mart directly.

---

## Contact

Built by **Williams Nnamdi**.

- LinkedIn: [linkedin.com/in/nnamdi-williams](https://www.linkedin.com/in/nnamdi-williams)
- GitHub: [github.com/MowillsN](https://github.com/MowillsN)

Feel free to reach out if you'd like to discuss the project or the design decisions behind it.

---

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details. The AdventureWorks dataset is a Microsoft sample dataset used here for educational/portfolio purposes.
