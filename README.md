# retail-data-analysis

# Retail Data Analysis: SQL Case Study + Interactive Dashboard

## Overview

This repository combines a detailed SQL-based retail data analysis case study with an interactive Python/Streamlit dashboard built on top of the same retail dataset. Together they cover everything from raw data cleaning and exploratory SQL analysis to a live, filterable dashboard for exploring sales, customer, and inventory insights.

- `Retail-Data-Analysis.sql` — the full SQL case study (data quality checks, EDA, cross-table insights, and behavioral analysis).
- `data_preparation.py` / `database.py` — cleans the raw CSVs and loads them into `retail_analysis.db` (SQLite).
- `dashboard_app.py` — the Streamlit dashboard for interactive exploration.
- `customer_profiles_raw_data.csv`, `product_inventory_raw_data.csv`, `sales_transaction_raw_data.csv` — the raw source data used by both the SQL analysis and the dashboard.

## Key Features & Analyses (SQL Case Study)

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

**Technologies:** SQL (MySQL syntax, e.g. `DATEDIFF`, `DATE_FORMAT`, `YEAR`, `HOUR`, `DAYNAME`).

**How to use the SQL analysis:**
1. Load the raw CSVs into a MySQL (or compatible) database, creating `customer_profiles`, `product_inventory`, and `sales_transaction` tables with the expected schemas.
2. Execute the queries in `Retail-Data-Analysis.sql`.

---

## 🛒 Interactive Dashboard

This project also provides a comprehensive interactive dashboard for analyzing retail sales data, customer profiles, and product inventory. It leverages Python for data preparation and Streamlit for building the web-based dashboard, with Plotly for interactive visualizations. The data is stored and managed efficiently using a SQLite database.

### ✨ Features
- **Key Performance Indicators (KPIs):** Displays essential metrics such as Total Revenue, Average Transaction Value, Unique Customers, and Unique Products Sold.
- **Sales Trend Analysis:** Visualize continuous monthly sales trends and identify peak sales periods (top months/days by revenue and transactions). Includes a multi-year filter.
- **Product Performance:** Analyze revenue distribution by product category and detailed sales performance for individual products within a selected category.
- **Customer Insights:** Understand customer demographics through distribution charts based on gender and geographical location.
- **RFM (Recency, Frequency, Monetary) Analysis:** Segment customers into distinct groups (e.g., Champions, Loyal Customers, At Risk) based on their purchasing behavior, enabling targeted marketing strategies.
- **Robust Data Preparation:** A dedicated script handles loading raw CSV data, performing cleaning (date conversion, missing value imputation, duplicate removal), and resolving data inconsistencies (e.g., price discrepancies between sales and inventory).
- **Efficient Data Storage:** Utilizes a SQLite database for structured and optimized data storage, ensuring fast retrieval for the dashboard.

### 🛠️ Technologies Used
- Python 3.x
- Streamlit — for building the interactive web dashboard
- Pandas — for data loading, cleaning, and manipulation
- Plotly Express — for creating rich, interactive visualizations
- SQLite3 — for local database management

### 🚀 Setup and Installation

1. **Clone the repository**
   ```
   git clone https://github.com/tushar-nebhnani/retail-data-analysis.git
   cd retail-data-analysis
   ```

2. **Create a virtual environment (recommended)**
   ```
   python -m venv venv
   # On Windows
   .\venv\Scripts\activate
   # On macOS/Linux
   source venv/bin/activate
   ```

3. **Install dependencies**
   ```
   pip install -r requirements.txt
   ```
   `requirements.txt` includes: `streamlit`, `pandas`, `plotly`.

4. **Prepare the data**

   Ensure the following raw CSV files are in the project directory:
   - `customer_profiles_raw_data.csv`
   - `product_inventory_raw_data.csv`
   - `sales_transaction_raw_data.csv`

   Then run the data preparation script to build the SQLite database:
   ```
   python database.py
   ```
   This creates `retail_analysis.db` in the project directory.

5. **Run the Streamlit dashboard**
   ```
   streamlit run dashboard_app.py
   ```
   This opens the dashboard in your default web browser.

### 📁 Project Structure

```
├── Retail-Data-Analysis.sql        # SQL case study queries
├── database.py                     # Script for cleaning raw data and populating SQLite DB
├── dashboard_app.py                # Streamlit application for the dashboard
├── requirements.txt                # List of Python dependencies
├── customer_profiles_raw_data.csv  # Raw customer data
├── product_inventory_raw_data.csv  # Raw product data
├── sales_transaction_raw_data.csv  # Raw sales transaction data
└── retail_analysis.db              # SQLite database (generated after running database.py)
```

### 💡 Future Enhancements
- Interactive Filters: Add more dynamic filters for product, customer, and time ranges.
- Predictive Analytics: Integrate machine learning models for sales forecasting or customer churn prediction.
- User Authentication: Implement basic user authentication for access control.
- More Detailed RFM Segments: Refine RFM segmentation logic for more granular customer targeting.

## ✍️ Author
Tushar Nebhnani
[Dashboard](https://retail-dashboard-analysis-tushar-nebhnani.streamlit.app/)

Feel free to connect with me on [LinkedIn](https://www.linkedin.com/in/tushar-nebhnani)
