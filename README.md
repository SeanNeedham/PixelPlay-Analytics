# 🎮 PixelPlay Sales & Customer Analytics

> End-to-end data analytics project using SQL Server and Power BI to analyse sales performance, customer behaviour, product performance, regional trends and refunds.

## Executive Summary

*To be completed after final insights are confirmed.*

## Key Insights

*To be completed after final analysis is confirmed.*

## Business Recommendations

*To be completed after final insights are confirmed.*

## Business Problem

PixelPlay is a fictional gaming retailer with transactional data covering customers, products, regions, sales and refunds. However, the data is spread across multiple raw datasets and contains inconsistencies and data-quality issues, making it difficult to produce a reliable, consolidated view of business performance. 

Stakeholders require a trusted reporting solution that brings this information together and provides clear visibility of revenue, order volumes, customer behaviour, product performance, regional trends and refunds to support more informed commercial decision-making.


## Project Objectives

- Clean and validate the raw datasets to create a reliable reporting foundation.

- Consolidate customer, product, regional and transactional data into a structured reporting model.

- Analyse revenue, orders, customer behaviour, product performance and refunds to identify meaningful trends.

- Build an interactive Power BI dashboard that enables stakeholders to monitor performance across key business areas.

- Produce clear, evidence-based insights and recommendations to support commercial decision-making.

## Business Questions

- How are revenue and order volumes performing over time?

- Which products and product categories generate the most revenue and orders?

- Which customer segments contribute the greatest value to the business?

- How does performance vary across regions and markets?

- Where are refunds concentrated, and which products or customer groups have the highest refund rates?

- What trends and patterns can be identified to support future decision-making?

[View supporting SQL analysis →](sql/05_business_analysis.sql)

## Dataset

The project uses four core datasets covering transactional, customer, product and regional information.

| Dataset | Description |
|---|---|
| Orders | Transactional level data including purchase dates, product prices, shipping and refund information |
| Customers | Customer attributes including demographics, signup information and email opt-in status |
| Products | Product details including product names, categories and pricing |
| Regions | Geographic reference data used to group customers and transactions by market |

## Tools & Technologies

| Tool | Use in Project |
|---|---|
| **Excel** | Initial data inspection and profiling |
| **SQL Server** | Data cleaning, transformation, validation and business analysis |
| **Power BI** | Data modelling, dashboard development and interactive reporting |
| **Power Query** | Additional data preparation and transformation |
| **DAX** | KPI measures, time intelligence and dynamic calculations |
| **VS Code** | Project file management and documentation |
| **Git & GitHub** | Version control and project portfolio hosting |

## Data Cleaning & Transformation

The raw datasets were profiled and cleaned in SQL Server before being used for analysis. Key transformations included:

- Standardised and validated purchase, shipping, refund and customer signup dates.

- Identified invalid date sequences, including shipments or refunds occurring before the original purchase.
- Validated product prices and applied rules to prevent invalid or missing values from affecting revenue calculations.
- Standardised customer email opt-in values and validated demographic fields such as age.
- Cleaned inconsistent product, country and regional classifications.
- Reconciled product and customer identifiers across datasets to support reliable relationships.
- Created analysis flags to control which records were eligible for revenue, trend and refund calculations.

Rather than automatically deleting records with data-quality issues, transactions were retained where they remained valid for other forms of analysis. Measure-specific rules were then used to exclude unreliable records only from the calculations they could affect.

[View data cleaning scripts →](sql/02_data_cleaning/)

## Data Quality & Validation

Validation checks were performed in SQL Server after cleaning to confirm that the transformed data was suitable for analysis and reporting.

Key checks included:

- Missing or invalid purchase dates.

- Shipping dates occurring before purchase dates.
- Refund dates occurring before purchase dates.
- Invalid or missing product prices.
- Unmatched customer, product and regional records.
- Duplicate business keys and transaction row counts.
- Revenue and date-analysis eligibility flags.
- KPI reconciliation between SQL Server and Power BI.

Data-quality flags were retained in the analytical model so unreliable records could be excluded only from the calculations they affected, rather than removing otherwise usable transactions.

[View post-cleaning validation →](sql/03_data_validation.sql)

[View final validation →](sql/06_final_validation.sql)


## Data Model

A star schema was created to organise the cleaned data into a structure suitable for reporting and analysis.

The model uses `fact_orders` as the central fact table, supported by dimension tables for customers, products, regions and dates.

- `fact_orders` – transactional order data, measures and analysis flags
- `dim_customer` – customer attributes and segmentation
- `dim_product` – product and category information
- `dim_region` – geographic information
- `dim_date` – calendar fields used for trend and time-intelligence analysis

This structure reduces duplication, improves reporting consistency and supports reliable one-to-many relationships between the dimensions and the fact table.

### Star Schema

![PixelPlay Data Model](images/data-model.png)

[View star schema SQL →](sql/04_star_schema/)


## Power BI & DAX

Power BI was used to turn the validated data model into an interactive reporting solution focused on commercial, customer and operational performance.

Key functionality included:

- KPI reporting for revenue, orders, customers, average order value, revenue per customer and refund rate.

- Month-over-month calculations to monitor changes in key performance indicators.
- Time-intelligence measures for analysing performance across reporting periods.
- Interactive slicers for date, region, product category and purchase platform.
- Customer and product segmentation to identify key revenue drivers and behavioural patterns.
- Conditional formatting and visual cues to highlight performance changes and areas requiring attention.
- Consistent DAX eligibility logic so only appropriate transactions contributed to revenue and date-based calculations.

The dashboard was designed to allow stakeholders to move from a high-level performance overview into more detailed product, customer, marketing and regional analysis.

## Dashboard

The final Power BI dashboard provides an interactive view of PixelPlay's performance across commercial KPIs, products, customers, marketing channels, regions and data quality.

### Executive Overview

Provides a high-level view of revenue, orders, customers, average order value and refund rate, supported by trend, product category, regional and customer-segment analysis.

![Executive Overview](images/executive-overview-v2.png)

### Product & Refund Analysis

Focuses on product performance, revenue contribution and refund behaviour, helping identify strong-performing products and areas of refund risk.

![Product & Refund Analysis](images/product-refund-analysis-v2.png)

### Customer Analysis

Explores customer value, segmentation and behavioural patterns, including revenue per customer, average order value, loyalty tier, age band and email opt-in performance.

![Customer Analysis](images/customer-analysis-v2.png)

### Marketing & Regional Analysis

Compares performance across marketing channels, purchase platforms, regions and countries to highlight where revenue and demand are being generated.

![Marketing & Regional Analysis](images/marketing-regional-analysis-v2.png)

### Data Quality Summary

Provides visibility of excluded records, matching outcomes and data-quality controls used to support reliable reporting.

![Data Quality Summary](images/data-quality-summary-v2.png)

## Limitations

The following limitations should be considered when interpreting the analysis:

- Orders with missing or invalid purchase dates could not be included in time-based analysis.

- Unmatched or unknown customer records provide less detail for customer segmentation.
- Refund data identifies where refunds occurred but does not include refund reasons, limiting root-cause analysis.
- The dataset does not include product costs or profit margins, so revenue performance should not be interpreted as profitability.
- Marketing spend is not available, so metrics such as churn rate and customer acquisition cost cannot be calculated.

## Repository Structure

```text
PixelPlay-Analytics/
│
├── README.md
│
├── SQL/
│   ├── 01_data_profiling.sql
│   │
│   ├── 02_data_cleaning/
│   │   ├── clean_region.sql
│   │   ├── clean_products.sql
│   │   ├── clean_customers.sql
│   │   └── clean_orders.sql
│   │
│   ├── 03_data_validation.sql
│   │
│   ├── 04_star_schema/
│   │   ├── dim_customer.sql
│   │   ├── dim_product.sql
│   │   ├── dim_region.sql
│   │   ├── dim_date.sql
│   │   ├── fact_orders.sql
│   │   └── relationships.sql
│   │
│   ├── 05_business_analysis.sql
│   └── 06_final_validation.sql
│
├── Images/
│   ├── pixel-play-data-model-v2.png
│   ├── executive-overview-v2.png
│   ├── product-refund-analysis-v2.png
│   ├── customer-analysis-v2.png
│   ├── marketing-regional-analysis-v2.png
│   └── data-quality-summary-v2.png
│
└── PowerBI/
    └── PixelPlay_Analytics.pbix