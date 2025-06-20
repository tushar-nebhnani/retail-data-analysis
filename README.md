# retail-data-analysis

# Retail Data Analysis Case Study with SQL

## Overview

This repository presents a detailed case study on retail data analysis, implemented entirely using SQL. The project demonstrates a systematic approach to transforming raw transactional data into actionable business intelligence, covering everything from data integrity to advanced customer behavior patterns. It's designed to showcase robust SQL skills for data cleaning, exploratory analysis, and deriving strategic insights for retail operations.

## Key Features & Analyses

### 1. Data Quality Assurance
* **Duplicate Detection & Resolution:** SQL queries to identify and precisely remove logical duplicate entries across `customer_profiles`, `product_inventory`, and `sales_transaction` tables.
* **Price Discrepancy Management:** Identification and correction of inconsistencies between sales transaction prices and current product inventory prices.

### 2. Exploratory Data Analysis (EDA)
* **Univariate Analysis:** Deep dives into the distribution and summary statistics of individual columns (e.g., customer age, gender, location; product stock levels, pricing; sales quantities).
* **Derived Metrics:** Calculation of fundamental business metrics such as total revenue per line item, top-selling products by revenue and quantity, and top-spending customers.

### 3. Cross-Table Insights
* **Demographic-based Revenue Analysis:** Understanding revenue contributions segmented by customer gender, location, and categorized age groups.
* **Product Performance by Category:** Analyzing total revenue and average purchase quantities across different product categories.

### 4. Retail Dashboard Metrics
* **Overall Sales Performance:** KPIs like Total Revenue, Average Transaction Value, Unique Customers, and Unique Products Sold.
* **Customer-Centric Analytics:** Identifying most active customers and repeat purchasers for loyalty programs.
* **Product Inventory Management:** Queries for low-stock items, top-purchased products by volume, and identification of products with zero sales (dead stock).
* **Sales Trend Analysis:** Granular insights into sales performance on monthly, daily, day-of-week, and hourly bases to understand seasonality and peak periods.

### 5. Customer Loyalty & Behavior
* **Long-term Loyalty:** Identification of customers with consistent purchase history across multiple years.
* **High-Value & High-Frequency Customers:** Deep dive into top spenders and most frequent purchasers.
* **Customer Stickiness:** Calculation of average time between purchases for repeat customers.
* **Market Basket Analysis (Basic):** Discovery of popular product combinations for cross-selling opportunities.

## Technologies Used

* **Database:** Assumed to be a relational database (queries written with MySQL syntax, e.g., `DATEDIFF`, `DATE_FORMAT`, `YEAR`, `HOUR`, `DAYNAME`).
* **Language:** SQL

## How to Use

1.  Clone this repository: `git clone https://github.com/YourUsername/YourRepoName.git`
2.  Navigate to the cloned directory.
3.  Load your retail dataset into a MySQL (or compatible) database, ensuring the tables `customer_profiles`, `product_inventory`, and `sales_transaction` are present with the expected schemas.
4.  Execute the SQL queries provided in the respective files/sections to perform the analysis.

---
**Note:** The RFM (Recency, Frequency, Monetary) segmentation analysis can be integrated for an even deeper dive into customer value, by calculating scores based on purchase history. (You can add the actual RFM code here or as a separate file if you choose to include it later).
