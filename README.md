# PixelPlay Sales & Customer Analytics

**SQL Server | Power BI | DAX | Star schema | Revenue, customer, product, regional and refund analysis**

An end-to-end analytics build: raw, unreliable retail data cleaned and modelled in SQL Server, then delivered as an interactive Power BI reporting solution.

---

## Executive Summary

### The Problem

PixelPlay held orders, customers, products and regional data in separate datasets riddled with inconsistent identifiers, missing values, invalid dates and classification errors. No consolidated, trustworthy view of business performance existed — so stakeholders could not see revenue, customer value, product performance or refund risk with any confidence.

### The Solution

Clean and validate in SQL Server, model as a star schema, report in Power BI.

- Records with data-quality issues were **flagged rather than deleted**, then excluded only from the specific measures they could distort.
- A **`fact_orders` star schema** with five dimensions replaced the fragmented source tables.
- **DAX eligibility logic mirrored the SQL rules**, and KPIs were reconciled between SQL Server and Power BI so both layers agree.

### The Impact

- Exposed a **four-month revenue decline** running from the February peak through June.
- Quantified June's deterioration across every headline KPI: **revenue −13.1%**, **orders −9.6%**, **customers −8.5%**, **AOV −4.3%**.
- Identified refund risk sitting in two distinct places — the **largest** revenue category and the **highest-rate** one.
- Revealed heavy concentration risk: **81%** of revenue in two product categories, **83%** in two regions.

---

## Key Operational Insights

### June weakened across every headline KPI
Revenue fell to **£127.3K**, down **13.1%** month on month. Orders dropped **9.6%**, customers **8.5%**, and AOV **4.3%** to **£199.92**. Volume and spend per order fell together — which is why AOV was analysed alongside revenue rather than in isolation. Refund rate rose **1.27 percentage points to 14.7%**, compounding the pressure on retained revenue.

### The decline is sustained, not a single bad month
Revenue peaked in **February** and then fell for **four consecutive months** through June.

### Refund risk sits in two different places
**Monitor** recorded a **16.2%** refund rate against the **14.7%** overall — significant because Monitor generates **30%** of revenue. **Audio** carried the highest category rate at **20.8%**. Ranking by rate alone would have missed Monitor; ranking by revenue alone would have missed Audio.

### Revenue is heavily concentrated
**Console (51%)** and **Monitor (30%)** produced **81%** of June revenue, with Laptop adding **12.5%**.

### Customer value is falling, and reach is narrowing
**Casual Gamer** was the largest segment by both volume and revenue. Revenue per customer fell **5.0%**. **Platinum** loyalty customers recorded the highest AOV. Email opt-in stood at **50.7%**, down **0.82 percentage points** from May — shrinking the audience available for retention activity.

### Regional growth and refund risk do not align
**NA (£68K)** and **EMEA (£38K)** delivered **83%** of regional revenue, with the **US** alone at approximately **£62K**. But **LATAM (20.7%)** and **APAC (17.9%)** carried far higher refund rates than **NA (14.0%)** and **EMEA (13.4%)** — so regions cannot be assessed on revenue alone. The **Direct** channel generated **£60K** and the **Website** platform **£97K**.

## Dashboard Views

### Executive Overview
Revenue, orders, customers, AOV and refund rate with trend, category, regional and segment analysis.

![PixelPlay Executive Overview dashboard](images/executive-overview-v2.png)

### Product & Refund Analysis
Product performance, revenue contribution, refund behaviour.

![PixelPlay Product & Refund Analysis dashboard](images/product-refund-analysis-v2.png)

### Customer Analysis
Customer value, segmentation, loyalty tier, age band, email opt-in.

![PixelPlay Customer Analysis dashboard](images/customer-analysis-v2.png)

### Marketing & Regional Analysis
Channels, platforms, regions, countries.

![PixelPlay Marketing & Regional Analysis dashboard](images/marketing-regional-analysis-v2.png)

### Data Quality Summary
Excluded records, matching outcomes, quality controls.

![PixelPlay Data Quality Summary dashboard](images/data-quality-summary-v2.png)

---

## Recommendations & Business Actions

### 1. Product & Merchandising — prioritise high-value refund reduction
**Finding:** Audio (**20.8%**) and Monitor (**16.2%**) exceed the **14.7%** overall refund rate, and Monitor alone contributes **30%** of revenue.

**Business impact:** Refunds are eroding retained revenue, most materially through Monitor.

**Action:** Investigate the reasons behind Audio and Monitor refunds before any corrective step. Review evidence for product defects, compatibility issues, listing clarity and customer expectations — the cause may differ by category.

**Expected impact:** Reducing avoidable refunds could protect revenue, particularly across the Monitor range.

### 2. Commercial & Finance — diagnose the four-month decline
**Finding:** Revenue has fallen for four consecutive months since the February peak.

**Business impact:** A continued decline makes demand harder to read and short-term targets harder to set realistically.

**Action:** Break the decline down by product category, region, customer segment and purchase platform to establish whether it is broad-based or concentrated. Use the result to separate a wider demand issue from a category or market-specific one.

**Expected impact:** A clearer cause, more targeted actions and more realistic forecasts.

### 3. Customer & CRM — strengthen retention reach before testing loyalty growth
**Finding:** Platinum customers have the highest AOV, while email opt-in is only **50.7%** and falling.

**Business impact:** A valuable loyalty segment exists, but the reachable audience is shrinking.

**Action:** First review the voluntary opt-in journey, messaging and touchpoints to lift consent rates. Once reach improves, test tier-progression campaigns among suitable Gold and Silver customers — rather than assuming a tier move automatically raises spend.

**Expected impact:** More customers reachable by retention campaigns, plus evidence on whether loyalty activity genuinely lifts customer value.

### 4. Marketing & E-commerce — reduce channel reliance while monitoring refund risk
**Finding:** Direct brings in the most channel revenue, and Website brings in the most platform revenue. LATAM (20.7%) and APAC (17.9%) have higher refund rates.

**Business impact:** Sales rely heavily on Direct and Website. Higher refund rates in LATAM and APAC also reduce the revenue kept from sales in those regions.

**Action:** Investigate the reasons for higher refunds in LATAM and APAC before increasing marketing activity there. Test whether Paid Search, Social and Affiliate can bring in more sales while continuing to support Direct and Website.

**Expected impact:** Sales from a wider range of channels and fewer avoidable refunds.

### What this analysis cannot tell you
The dashboard supports monitoring, comparison and targeting further investigation. It cannot establish causes, assess profitability or evaluate marketing efficiency. Recommendations are therefore areas to **investigate or test**, not guaranteed outcomes.

- Orders with missing or invalid purchase dates are excluded from time-based analysis.
- Unmatched or unknown customer records carry less segmentation detail.
- Refund data records where refunds occurred but not **why**, limiting root-cause work.
- No product costs or margins are present — revenue performance must not be read as profitability.
- No marketing spend data, so CAC and ROMI cannot be calculated.

---

## The Dataset & Metrics

Four core datasets covering transactional, customer, product and regional information.

| Dataset | Description |
|---|---|
| **Orders** | Transaction-level data — purchase dates, product prices, shipping, refund information |
| **Customers** | Demographics, signup information, email opt-in status |
| **Products** | Product names, categories, pricing |
| **Regions** | Geographic reference data for grouping customers and transactions by market |

Original simulated source files are retained unchanged in `data/raw`. Cleaned exports are not duplicated — all cleaning, validation and modelling logic lives in `sql/` and is fully reproducible from it.

**Metrics measured**

- Revenue, orders, customers — with month-on-month change
- **Average order value (AOV)** and revenue per customer
- **Refund rate** — overall, by product category, by region
- Revenue share by product category, region, country, channel and platform
- Customer segment performance by volume and revenue
- Average order value by loyalty tier
- Email opt-in rate and month-on-month movement

---

## Methodology & Technical Stack

| Tool | Use in project |
|---|---|
| **Excel** | Initial data inspection and profiling |
| **SQL Server** | Cleaning, transformation, validation, business analysis |
| **Power BI** | Data modelling, dashboard development, interactive reporting |
| **DAX** | KPI measures, time intelligence, dynamic calculations |
| **VS Code** | Project file management and documentation |
| **Git & GitHub** | Version control and portfolio hosting |

### 1. Data cleaning and transformation
- Standardised and validated purchase, shipping, refund and customer signup dates.
- Identified invalid date sequences — shipments or refunds preceding the original purchase.
- Validated product prices and blocked invalid or missing values from reaching revenue calculations.
- Standardised email opt-in values and validated demographic fields such as age.
- Cleaned inconsistent product, country and regional classifications.
- Reconciled product and customer identifiers across datasets to support reliable relationships.
- Created analysis flags governing eligibility for revenue, trend and refund calculations.

Records were **retained wherever they remained valid for other analysis**. Measure-specific rules then excluded unreliable rows only from the calculations they could affect.
→ `sql/02_data_cleaning/`

### 2. Data quality and validation
Post-cleaning checks confirmed: missing or invalid purchase dates; shipping dates before purchase; refund dates before purchase; invalid or missing prices; unmatched customer, product and regional records; duplicate business keys and row counts; revenue and date eligibility flags; and **KPI reconciliation between SQL Server and Power BI**.
→ `sql/03_post_cleaning_validation.sql` · `sql/06_final_validation.sql`

### 3. Data model — star schema
`fact_orders` at the centre, supported by `dim_customer`, `dim_product`, `dim_region` and `dim_date`. This reduces duplication, enforces reporting consistency and supports reliable one-to-many relationships.

![PixelPlay Data Model](images/data-model.png)
→ `sql/04_star_schema/`

### 4. Power BI and DAX
- KPI reporting across revenue, orders, customers, AOV, revenue per customer and refund rate.
- Month-on-month calculations and time-intelligence measures.
- Interactive slicers for date, region, product category and purchase platform.
- Customer and product segmentation to surface revenue drivers.
- Conditional formatting to flag performance changes.
- **Consistent DAX eligibility logic**, matching the SQL rules, so only appropriate transactions reach each measure.

→ [Download the Power BI report](PowerBI/PixelPlay_Analytics.pbix)

### Repository structure

```text
PixelPlay-Analytics/
├── .gitattributes
├── README.md
├── data/
│   ├── README.md
│   └── raw/
│       ├── orders.csv
│       ├── customers.csv
│       ├── products.csv
│       └── region.csv
├── sql/
│   ├── 01_data_profiling.sql
│   ├── 03_data_validation.sql
│   ├── 05_business_analysis.sql
│   ├── 06_final_validation.sql
│   ├── 02_data_cleaning/
│   │   ├── clean_region.sql
│   │   ├── clean_products.sql
│   │   ├── clean_customers.sql
│   │   └── clean_orders.sql
│   └── 04_star_schema/
│       ├── dim_customer.sql
│       ├── dim_product.sql
│       ├── dim_region.sql
│       ├── dim_date.sql
│       └── fact_orders.sql
├── images/
└── PowerBI/
    └── PixelPlay_Analytics.pbix
```
