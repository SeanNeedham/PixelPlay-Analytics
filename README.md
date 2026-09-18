# PixelPlay Sales & Customer Analytics

SQL Server | Power BI | DAX | Star schema | Revenue, customer, product, regional and refund analysis

An end-to-end retail analytics project that turns fragmented, unreliable source data into a validated SQL Server model and interactive Power BI report.

## Project Background

PixelPlay is a simulated gaming hardware retailer selling across international markets. Its orders, customers, products and regional reference data were stored separately and contained inconsistent identifiers, missing values, invalid dates and classification errors. Commercial and operations stakeholders needed a dependable view of sales performance, customer value and refund exposure before deciding where to investigate or act.

Intended stakeholders: Commercial and sales leaders, product and merchandising teams, customer/CRM teams, and regional operations managers.

Decision context: Understand the sustained revenue decline, identify where sales and refunds are concentrated, and prioritise investigations and measurable tests. Revenue is the primary performance measure; orders, customers, average order value (AOV), revenue per customer, refund rate and email opt-in provide context.

## Business Questions

1. How are revenue, order volume, customer count and spend per order changing over time?
2. Which product categories, regions and sales routes contribute most to revenue, and where is concentration risk greatest?
3. Which categories and regions have the highest refund rates, and how do those rates compare with their revenue contribution?
4. Which customer segments and loyalty tiers generate the most value, and how much of the customer base is reachable through email?
5. Which data-quality issues affect each measure, and can SQL Server and Power BI produce consistent KPIs?

## Data Structure & Initial Checks

The project uses four simulated source datasets. Original files are retained unchanged in `data/raw`; cleaning and modelling logic is reproducible from `sql/` rather than duplicated as cleaned exports.

| Dataset | Role |
|---|---|
| Orders | Transactions, purchase dates, product prices, shipping and refunds |
| Customers | Demographics, signup information and email opt-in status |
| Products | Product names, categories and pricing |
| Regions | Geographic reference data for market reporting |

The reporting model centres on `fact_orders`, with `dim_customer`, `dim_product`, `dim_region` and `dim_date`. Initial profiling and later validation checked date sequences, prices, identifier matching, classifications, duplicate business keys, row counts and measure eligibility. Problem records were flagged and retained where they could still support other analyses; each KPI excludes only records that would make that particular measure unreliable. SQL Server and Power BI KPIs were reconciled, with DAX eligibility rules aligned to the SQL rules.

![PixelPlay data model](images/data-model.png)

## Executive Summary

- Performance: Revenue peaked in February and declined for four consecutive months through June. June revenue was £127.3K, down 13.1% month on month; orders fell 9.6%, customers 8.5%, and AOV 4.3% to £199.92. The simultaneous declines in volume and order value warrant a breakdown by category, region and customer segment.
- Refund exposure: The overall refund rate rose 1.27 percentage points to 14.7% in June. Monitor generated 30% of revenue with a 16.2% refund rate, while Audio had the highest category refund rate at 20.8%. Both deserve investigation for different reasons.
- Concentration: Console (51%) and Monitor (30%) generated 81% of June revenue. NA and EMEA generated 83% of regional revenue. Changes in a small number of categories and markets therefore matter greatly.

## Insights Deep Dive

### Sales trend and customer value

June's £127.3K revenue followed four consecutive monthly declines from the February peak. The 9.6% drop in orders and 8.5% drop in customers coincided with a 4.3% fall in AOV to £199.92. Revenue per customer fell 5.0%. These movements show pressure on both transaction volume and spend, but the dashboard alone does not establish why they occurred.

Casual Gamer was the largest customer segment by volume and revenue. Platinum customers had the highest AOV. Email opt-in was 50.7%, down 0.82 percentage points from May, limiting the audience available for consent-based retention activity.

![PixelPlay Executive Overview dashboard](images/executive-overview-v2.png)

![PixelPlay Customer Analysis dashboard](images/customer-analysis-v2.png)

### Product mix and refund exposure

Console (51%) and Monitor (30%) accounted for 81% of June revenue; Laptop added 12.5%. The overall refund rate reached 14.7%, up 1.27 percentage points month on month. Monitor's 16.2% refund rate matters because it applies to a major revenue category; Audio's 20.8% rate is the highest category rate. A rate-only ranking would understate Monitor's potential impact, while a revenue-only ranking would miss Audio.

![PixelPlay Product & Refund Analysis dashboard](images/product-refund-analysis-v2.png)

### Markets and sales routes

NA (£68K) and EMEA (£38K) contributed 83% of regional revenue; the US alone contributed approximately £62K. Refund rates were higher in LATAM (20.7%) and APAC (17.9%) than in NA (14.0%) and EMEA (13.4%). Regional performance therefore needs both sales and refund measures.

The Direct channel generated £60K, and the Website platform generated £97K. Channel and platform are different reporting dimensions, so these figures should not be added together.

![PixelPlay Marketing & Regional Analysis dashboard](images/marketing-regional-analysis-v2.png)

### Trust in the reporting

The data-quality view makes exclusions and matching outcomes visible. Date, price and relationship checks feed measure-specific eligibility flags. Matching SQL and DAX rules and reconciling final KPIs reduce the risk that dashboard totals diverge from the underlying analysis.

![PixelPlay Data Quality Summary dashboard](images/data-quality-summary-v2.png)

## Recommendations

These are proposed investigations and tests. Expected impacts are directional because the available data does not establish causes or quantify the benefit of an intervention.

| Priority | Recommendation and evidence | Suggested owner | Expected impact | Metric to track |
|---|---|---|---|---|
| 1 | Investigate Audio and Monitor refunds. Audio has the highest category rate (20.8%); Monitor combines a 16.2% rate with 30% of revenue. Examine defects, compatibility, listings and customer expectations before choosing a remedy. | Product & Merchandising, with Operations | Identify avoidable refunds and protect retained revenue, especially in Monitor. | Category refund rate; refund count and value; retained revenue |
| 2 | Diagnose the four-month revenue decline. Break changes down by category, region, customer segment and platform to test whether the decline is broad or concentrated. | Commercial & Finance | Target action and forecasts to the segments driving the decline. | Revenue, orders, customers, AOV and revenue per customer by segment and month |
| 3 | Improve consent-based retention reach, then test loyalty progression. Email opt-in is 50.7% and falling; Platinum has the highest AOV. Review the voluntary opt-in journey, then test suitable Gold and Silver campaigns without assuming tier movement causes higher spend. | Customer & CRM | Expand the reachable audience and measure whether campaigns increase customer value. | Email opt-in rate; campaign reach; repeat purchase and revenue per customer in test versus comparison groups |
| 4 | Investigate regional refunds and test channel diversification. LATAM (20.7%) and APAC (17.9%) have elevated refund rates. Assess causes before scaling activity there; test Paid Search, Social and Affiliate while maintaining Direct and Website performance. | Regional Operations and Marketing & E-commerce | Reduce avoidable refunds and learn whether other channels can contribute incremental sales. | Regional refund rate and value; revenue by channel/platform; incremental sales in controlled tests |

## Assumptions & Caveats

- The source data is simulated. Findings describe this dataset and are not claims about an actual retailer.
- Orders with missing or invalid purchase dates are excluded from time-based measures. Other records are excluded only from measures affected by their quality issue.
- Unmatched or unknown customer records have limited segmentation detail.
- Refund records show whether a refund occurred, not why. Category and regional patterns identify investigation priorities, not root causes.
- Product costs and margins are unavailable, so revenue and refund measures do not establish profitability.
- Marketing spend is unavailable; customer acquisition cost and return on marketing investment cannot be calculated. Channel revenue alone does not establish marketing efficiency.
- The analysis is observational. It supports monitoring, comparison and test design, but cannot attribute the revenue decline or show that loyalty status, channel choice or another factor caused an outcome.

## Tools & Technical Approach

| Tool | Use |
|---|---|
| Excel | Initial inspection and profiling |
| SQL Server | Cleaning, transformation, validation and business analysis |
| Power BI | Data model and interactive reporting |
| DAX | KPI measures, time intelligence and dynamic calculations |
| VS Code | Project files and documentation |
| Git & GitHub | Version control and portfolio hosting |

### Cleaning, validation and modelling

SQL scripts standardise purchase, shipping, refund and signup dates; flag shipping or refund dates before purchase; validate prices and demographic fields; standardise email opt-in and geographic/product classifications; and reconcile customer and product identifiers. Analysis flags control eligibility for revenue, trends and refund calculations. Post-cleaning checks cover invalid dates and prices, unmatched customer/product/region records, duplicate business keys, row counts and KPI reconciliation.

Explore the [data-cleaning scripts](sql/02_data_cleaning/), [data-validation script](sql/03_data_validation.sql), [star-schema scripts](sql/04_star_schema/) and [final validation](sql/06_final_validation.sql).

### Measures and report

The report covers revenue, orders, customers, AOV, revenue per customer, refund rate and month-on-month change. It also analyses revenue share by category, region, country, channel and platform; segment volume and revenue; loyalty-tier AOV; and email opt-in. Interactive slicers cover date, region, product category and purchase platform. DAX applies the same eligibility rules used in SQL.

[Download the Power BI report](PowerBI/PixelPlay_Analytics.pbix)

## Repository Structure

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
