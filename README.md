# PixelPlay Sales & Customer Analytics

SQL Server | Power BI | DAX | Star schema | Revenue, customer, product, regional and refund analysis

An end-to-end retail analytics project that turns fragmented, unreliable source data into a validated SQL Server model and interactive Power BI report.

## Project Background

PixelPlay is a gaming hardware retailer selling across international markets. Its orders, customers, products and regional reference data were stored separately and contained inconsistent identifiers, missing values, invalid dates and classification errors. Commercial and operations stakeholders needed a dependable view of sales performance, customer value and refund exposure before deciding where to investigate or act.

Intended stakeholders: Commercial and sales leaders, product and merchandising teams, customer/CRM teams, and regional operations managers.

Decision context: Understand the sustained revenue decline, identify where sales and refunds are concentrated, and prioritise investigations and measurable tests. Revenue is the primary performance measure; orders, customers, average order value (AOV), revenue per customer and refund rate provide context.

## Business Questions

1. How are revenue, order volume, customer count and spend per order changing over time?
2. Which product categories, regions and sales routes contribute most to revenue, and where is concentration risk greatest?
3. Which categories and regions have the highest refund rates, and how do those rates compare with their revenue contribution?
4. Which customer segments and loyalty tiers generate the most value, and how much of the customer base is reachable through email?
5. Which data-quality issues affect each measure, and can SQL Server and Power BI produce consistent KPIs?

## Data Structure & Initial Checks

The project uses four source datasets. Original files are retained unchanged in `data/raw`; cleaning and modelling logic is reproducible from `sql/` rather than duplicated as cleaned exports.

| Dataset | Role |
|---|---|
| Orders | Transactions, purchase dates, product prices, shipping and refunds |
| Customers | Demographics, signup information and email opt-in status |
| Products | Product names, categories and pricing |
| Regions | Geographic reference data for market reporting |

The reporting model centres on `fact_orders`, with `dim_customer`, `dim_product`, `dim_region` and `dim_date`. Initial profiling and later validation checked date sequences, prices, identifier matching, classifications, duplicate business keys, row counts and measure eligibility. Problem records were flagged and retained where they could still support other analyses; each KPI excludes only records that would make that particular measure unreliable. SQL Server and Power BI KPIs were reconciled, with DAX eligibility rules aligned to the SQL rules.

![PixelPlay data model](images/data-model.png)

## Executive Summary

- Sales fell for four consecutive months after February. June revenue was £127.3K, down 13.1% from May. Fewer customers bought, and the average order was smaller, so the commercial team should find out which products and markets account for the decline.
- Refunds increased. The June refund rate reached 14.7%, up 1.27 percentage points. Monitor warrants attention because it brings in 30% of revenue but has a 16.2% refund rate; Audio has the highest category refund rate at 20.8%.
- Sales depend heavily on a small number of products and markets. Console and Monitor generated 81% of June revenue, while NA and EMEA generated 83% of regional revenue. A setback in either group could have a large effect on overall results.

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

These are proposed investigations and tests. The data shows where to look, but the benefit of any action has not yet been measured.

| Priority | What to do | Suggested owner | Intended result | What to check |
|---|---|---|---|---|
| 1 | Find out why customers return Audio and Monitor products. Audio has the highest refund rate (20.8%); Monitor has a 16.2% rate and supplies 30% of revenue. Review defects, compatibility, product descriptions and customer feedback before changing anything. | Product & Merchandising, with Operations | Identify refunds that could be prevented, especially in the larger Monitor business. | Number, value and rate of refunds by category; sales kept after refunds |
| 2 | Find where the four-month sales decline is coming from. Compare products, markets, customer groups and purchase platforms before deciding on a response. | Commercial & Finance | Direct attention to the parts of the business driving the decline. | Monthly sales, orders, customer numbers and spend per order for each group |
| 3 | Make voluntary email sign-up clearer, then test whether relevant messages bring customers back. Opt-in is 50.7% and falling. Platinum customers spend more per order, but moving someone into a loyalty tier may not change their behaviour. | Customer & CRM | Reach more consenting customers and learn whether retention activity raises customer value. | Opt-in, campaign reach, repeat purchases and spend per customer, compared with a similar group that did not receive the campaign |
| 4 | Find out why refunds are higher in LATAM (20.7%) and APAC (17.9%) before increasing promotion there. Test whether Paid Search, Social and Affiliate add sales while continuing to support Direct and Website. | Regional Operations and Marketing & E-commerce | Reduce preventable returns and learn whether other sales routes can contribute. | Refunds by region; sales by channel and platform; additional sales from controlled tests |

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

Explore the [data-cleaning scripts](sql/02_data_cleaning/), [post-cleaning validation script](sql/03_post_cleaning_validation.sql), [star-schema scripts](sql/04_star_schema/) and [final validation](sql/06_final_validation.sql).

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
│   ├── 03_post_cleaning_validation.sql
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
