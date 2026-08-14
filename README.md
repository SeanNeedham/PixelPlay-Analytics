# 🎮 PixelPlay Sales & Customer Analytics

> End-to-end data analytics project using SQL Server and Power BI to analyse sales performance, customer behaviour, product performance, regional trends and refunds.

## Executive Summary

*To be completed after final insights are confirmed.*

## Key Insights

*To be completed after final analysis is confirmed.*

## Business Recommendations

*To be completed after final insights are confirmed.*

## Dashboard

*Dashboard screenshots will be added here.*

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
| **Power BI** | Data modelling, dashboard devlopment and interactive reporting |
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

## Data Quality & Validation

Validation checks were performed in SQL Server after cleaning to confirm that the transformed data was suitable for analysis and reporting.

Key validation checks included:

- Checked for missing or invalid purchase dates.

- Identified shipping dates occurring before the corresponding purchase date.
- Identified refund dates occurring before the original purchase.
- Validated product prices and revenue-eligible transactions.
- Checked customer, product and regional identifiers for unmatched records.
- Confirmed duplicate and record counts before and after transformation.
- Reconciled key KPIs between SQL Server and Power BI to ensure consistent reporting logic.

Data-quality flags were retained within the analytical model so that unreliable records could be excluded from specific calculations without unnecessarily removing them from the dataset.

## Data Model

A star schema was created to organise the cleaned data into a structure suitable for reporting and analysis.

The model uses `fact_orders` as the central fact table, supported by dimension tables for customers, products, regions and dates.

- `fact_orders` – transactional order data and analysis flags

- `dim_customer` – customer attributes and segmentation fields
- `dim_product` – product and category information
- `dim_region` – geographic details
- `dim_date` – calendar attributes used for trend and time-intelligence analysis

This structure reduces duplication, improves reporting consistency and supports reliable relationships between transactional data and descriptive business dimensions.

### Star Schema

![PixelPlay Data Model](images/data_model.png)
## SQL Analysis

## Business Questions

The analysis was structured around six key business questions designed to understand PixelPlay's commercial performance and identify opportunities for improvement.

1. How are revenue and order volumes performing over time?

2. Which products and product categories generate the most revenue and orders?
3. Which customer segments contribute the greatest value to the business?
4. How does performance vary across regions and markets?
5. Where are refunds concentrated, and which products or customer groups have the highest refund rates?
6. What trends and patterns can be identified to support future commercial decision-making?

[View supporting SQL analysis →](sql/05_business_analysis.sql)

## Power BI & DAX

Power BI was used to transform the validated data model into an interactive reporting solution focused on commercial and customer performance.

Key dashboard functionality included:

* KPI reporting for revenue, orders, customers, average order value, revenue per customer and refund rate.

* Month-over-month calculations to monitor changes in key performance indicators.
* Time-intelligence measures for analysing performance across months and reporting periods.
* Interactive slicers allowing users to explore performance by customer, product, region and time period.
* Product and customer segmentation to identify key revenue drivers and behavioural patterns.
* Conditional formatting and visual cues to highlight performance changes and areas requiring attention.
* Consistent DAX eligibility logic to ensure only appropriate transactions contributed to revenue, order and refund calculations.

The dashboard was designed to allow stakeholders to move from a high-level performance overview into more detailed customer, product and regional analysis.

## Dashboard

The final Power BI dashboard provides an interactive view of PixelPlay's performance across commercial KPIs, products, customers, regions and data quality controls.

### Executive Overview

This page provides a high-level summary of total revenue, orders, customers, average order value and refund rate, supported by trend, category and regional views.

![Executive Overview](Images/executive_overview.png)

### Product & Refund Analysis

This page focuses on product performance, revenue contribution and refund behaviour, helping identify both top-performing products and areas of refund risk.

![Product & Refund Analysis](Images/product_analysis.png)

### Customer Analysis

This page explores customer value, segmentation and behavioural patterns, including revenue per customer, average order value and customer profile metrics.

![Customer Analysis](Images/customer_analysis.png)

### Marketing & Regional Analysis

This page compares performance across marketing channels, purchase platforms and geographic markets to highlight where revenue is being generated.

![Marketing & Regional Analysis](Images/Marketing_&_Region.png)

### Data Quality Summary

This page provides visibility of excluded records, data-quality controls and recommended actions to support transparent reporting.

![Data Quality Summary](Images/data_quality.png)

## Limitations

## Limitations

Several limitations should be considered when interpreting the analysis:


* Transactions with invalid or missing purchase dates were excluded from time-based analysis where a reliable reporting period could not be established.

* Unknown or unmatched customer and product records were retained where possible, but these records provide less detail for segmentation analysis.
* Refund data identifies where refunds occurred but does not include detailed refund reasons, limiting the ability to determine the underlying causes.
* The dataset focuses primarily on revenue and transactional performance and does not include detailed cost or profit margin data, so product performance should not be interpreted as profitability.


## Repository Structure

## Full Project Documentation