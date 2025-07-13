import streamlit as st 
import pandas as pd     
import sqlite3          
import plotly.express as px 

st.set_page_config(
    layout="wide", 
    page_title="Retail Analysis Dashboard", 
    page_icon="🛒"
)

DB_FILE = 'retail_analysis.db'

@st.cache_data
def get_data_from_db(query):
    """
    Fetches data from the SQLite database using a given SQL query.
    This function is cached by Streamlit for efficiency.
    """
    try:
        conn = sqlite3.connect(DB_FILE) 
        df = pd.read_sql(query, conn)  
        conn.close()                   
        return df                      
    except FileNotFoundError:
        st.error(f"Database file '{DB_FILE}' not found. Please ensure 'data_preparation.py' was run successfully.")
        return pd.DataFrame() # Return an empty DataFrame on error
    except Exception as e:
        st.error(f"An error occurred while fetching data: {e}")
        return pd.DataFrame() # Return an empty DataFrame on error
    else:
        print("Database connected successfully.")

def home_page():
    st.title("🛒 Retail Analysis Dashboard")
    kpis()
    st.subheader("Summary of the Actions Taken: ")
    st.markdown("""
        1.  **Database and Table Setup:**
            * A dedicated `RetailAnalysis` database was created.
            * The three core tables were defined and populated from raw CSV files.
        2.  **Schema Refinement and Data Type Optimization:**
            * **Identified Inconsistencies:** Numerical identifiers (e.g., `CustomerID`, `ProductID`) and quantities (`StockLevel`, `QuantityPurchased`) were initially inefficiently stored as `DECIMAL(38,0)`. Date fields (`JoinDate`, `TransactionDate`) were stored as `VARCHAR(8)`, limiting temporal analysis.
            * **Applied Corrections:** All relevant `DECIMAL(38,0)` columns were precisely converted to `INT`. `VARCHAR(8)` date columns were accurately converted to the `DATE` data type. These changes significantly improved data storage efficiency, query performance, and enabled robust date-based operations.

        3.  **Data Quality and Missing Value Handling:**
            * **Explicit NULLs Check:** `Location` in `customer_profiles` was identified as having 13 explicit `NULL` values.
            * **Empty String/Whitespace Check:** Confirmed `Location` also contained empty or whitespace-only strings.
            * **Missing Value Resolution:** The 13 records with missing `Location` values were removed to ensure high data quality.

        4.  **Duplicate Data Management:**
            * **Identification:** Advanced `ROW_NUMBER()` window functions were used to identify duplicate records across all three tables based on key combinations.
            * **Resolution:** For `sales_transaction`, 2 duplicate records were identified and precisely removed, preserving one valid instance of each transaction.

        5.  **Price Discrepancy Resolution:**
            * **Identification:** Discrepancies between `Price` in `sales_transaction` (historical) and `product_inventory` (current) were identified.
            * **Correction:** An `UPDATE` statement aligned the `Price` in `sales_transaction` with the current `Price` from `product_inventory` for consistency in reporting.

        6.  **Data Export:**
            * The cleaned and validated datasets were exported to new CSV files for external tool compatibility.
    """)

    st.subheader("Final Insights & Impact:")
    st.markdown("""
        * **Data Reliability Enhanced:** Rigorous cleaning and optimization have made the datasets significantly more reliable for accurate reporting and robust analytical modeling.
        * **Actionable Insights Enabled:** Clean, structured data now allows for precise insights into:
            * **Customer Segmentation:** Effective targeting based on `Age`, `Gender`, and `Location`.
            * **Product Performance:** Accurate `StockLevel` and `Price` data for inventory management and identifying best-sellers.
            * **Sales Trend Analysis:** Corrected prices and dates enable accurate revenue calculation and trend identification.
        * **Operational Efficiency:** Reduced manual data correction and improved trust in data.
        * **Foundation for Advanced Analytics:** The prepared datasets serve as a strong base for predictive modeling and machine learning applications.

        This comprehensive data preparation has transformed raw data into a valuable analytical asset, ready to support strategic business decisions for the retail company.
        """)
    
    st.text("Created by Tushar Nebhnani.")

def kpis():
    """
    Displays Key Performance Indicators (KPIs) for overall sales performance.
    """
    st.header("Key Performance Indicators")

    col1, col2, col3, col4 = st.columns(4) # Create 4 columns for KPIs

    total_revenue_query = "SELECT SUM(QuantityPurchased * Price) AS TotalRevenue FROM sales_transaction;"
    df_total_revenue = get_data_from_db(total_revenue_query)
    total_revenue = df_total_revenue['TotalRevenue'].iloc[0] if not df_total_revenue.empty and df_total_revenue['TotalRevenue'].iloc[0] is not None else 0
    with col1:
        st.metric(label="Total Revenue", value=f"{total_revenue:,.2f}") # Format as currency with 2 decimal places

    avg_transaction_value_query = "SELECT ROUND(SUM(QuantityPurchased * Price) / COUNT(DISTINCT TransactionID), 2) AS AverageTransactionValue FROM sales_transaction;"
    df_avg_transaction_value = get_data_from_db(avg_transaction_value_query)
    avg_transaction_value = df_avg_transaction_value['AverageTransactionValue'].iloc[0] if not df_avg_transaction_value.empty and df_avg_transaction_value['AverageTransactionValue'].iloc[0] is not None else 0
    with col2:
        st.metric(label="Avg Transaction Value", value=f"{avg_transaction_value:,.2f}")

    # KPI 3: Number of Unique Customers Who Made Purchases
    unique_customers_query = "SELECT COUNT(DISTINCT CustomerID) AS NumberOfUniqueCustomers FROM sales_transaction;"
    df_unique_customers = get_data_from_db(unique_customers_query)
    unique_customers = df_unique_customers['NumberOfUniqueCustomers'].iloc[0] if not df_unique_customers.empty and df_unique_customers['NumberOfUniqueCustomers'].iloc[0] is not None else 0
    with col3:
        st.metric(label="Unique Customers", value=f"{unique_customers:,}") # Format with comma separator

    # KPI 4: Number of Unique Products Sold
    unique_products_sold_query = "SELECT COUNT(DISTINCT ProductID) AS NumberOfUniqueProductsSold FROM sales_transaction;"
    df_unique_products_sold = get_data_from_db(unique_products_sold_query)
    unique_products_sold = df_unique_products_sold['NumberOfUniqueProductsSold'].iloc[0] if not df_unique_products_sold.empty and df_unique_products_sold['NumberOfUniqueProductsSold'].iloc[0] is not None else 0
    with col4:
        st.metric(label="Unique Products Sold", value=f"{unique_products_sold:,}")

def sales_trend():
    """
    Displays simplified sales trend analysis focusing on continuous trends and peak periods.
    """
    st.header("Sales Trends Over Time")
    st.markdown("Analyze revenue and transaction trends across different time granularities to identify peak sales periods.")

    # --- Year Selection Filter ---
    years_query = "SELECT DISTINCT STRFTIME('%Y', TransactionDate) AS SalesYear FROM sales_transaction ORDER BY SalesYear DESC;"
    df_years = get_data_from_db(years_query)

    if not df_years.empty:
        all_unique_years = sorted([str(year) for year in df_years['SalesYear'].tolist()])
    else:
        all_unique_years = []

    available_years = ['All Years'] + all_unique_years

    selected_years = st.multiselect(
        "Filter by Year(s)",
        options=available_years,
        default=['All Years'] if 'All Years' in available_years else []
    )

    # Build the WHERE clause based on selected years
    where_clause = ""
    if selected_years and 'All Years' not in selected_years:
        years_str = ', '.join(f"'{year}'" for year in selected_years)
        where_clause = f"WHERE STRFTIME('%Y', TransactionDate) IN ({years_str})"
    elif not selected_years:
        st.warning("Please select at least one year to display sales trends.")
        return # Exit the function if no years are selected

    # --- Continuous Monthly Trend (YYYY-MM) ---
    st.subheader("Continuous Monthly Sales Trend")
    monthly_sales_query = f"""
        SELECT
            STRFTIME('%Y-%m', TransactionDate) AS SalesPeriod,
            SUM(QuantityPurchased * Price) AS TotalMonthlyRevenue,
            COUNT(DISTINCT TransactionID) AS NumberOfMonthlyTransactions
        FROM
            sales_transaction
        {where_clause}
        GROUP BY
            SalesPeriod
        ORDER BY
            SalesPeriod;
    """
    df_monthly_sales = get_data_from_db(monthly_sales_query)

    if not df_monthly_sales.empty:
        df_monthly_sales['SalesPeriod'] = df_monthly_sales['SalesPeriod'].astype(str)

        fig_monthly_revenue = px.line(
            df_monthly_sales,
            x='SalesPeriod',
            y='TotalMonthlyRevenue',
            title='Total Revenue by Month (Continuous)',
            labels={'SalesPeriod': 'Month', 'TotalMonthlyRevenue': 'Total Revenue ($)'},
            markers=True
        )
        fig_monthly_revenue.update_layout(hovermode="x unified")
        st.plotly_chart(fig_monthly_revenue, use_container_width=True)

        fig_monthly_transactions = px.line(
            df_monthly_sales,
            x='SalesPeriod',
            y='NumberOfMonthlyTransactions',
            title='Number of Transactions by Month (Continuous)',
            labels={'SalesPeriod': 'Month', 'NumberOfMonthlyTransactions': 'Number of Transactions'},
            markers=True
        )
        fig_monthly_transactions.update_layout(hovermode="x unified")
        st.plotly_chart(fig_monthly_transactions, use_container_width=True)
    else:
        st.warning("No monthly sales data available for the selected year(s) to display continuous trends.")

    st.markdown("---") # Separator for clarity

    # --- Peak Sales Periods ---
    st.subheader("Peak Sales Periods")

    # Top 5 Months by Revenue
    top_months_revenue_query = f"""
        SELECT
            STRFTIME('%Y-%m', TransactionDate) AS SalesPeriod,
            SUM(QuantityPurchased * Price) AS TotalRevenue
        FROM
            sales_transaction
        {where_clause}
        GROUP BY
            SalesPeriod
        ORDER BY
            TotalRevenue DESC
        LIMIT 5;
    """
    df_top_months_revenue = get_data_from_db(top_months_revenue_query)
    if not df_top_months_revenue.empty:
        st.write("#### Top 5 Months by Revenue")
        st.dataframe(df_top_months_revenue.style.format({'TotalRevenue': '${:,.2f}'}))
    else:
        st.info("No data to show top months by revenue.")

    # Top 5 Days by Revenue
    top_days_revenue_query = f"""
        SELECT
            STRFTIME('%Y-%m-%d', TransactionDate) AS SalesDate,
            SUM(QuantityPurchased * Price) AS TotalRevenue
        FROM
            sales_transaction
        {where_clause}
        GROUP BY
            SalesDate
        ORDER BY
            TotalRevenue DESC
        LIMIT 5;
    """
    df_top_days_revenue = get_data_from_db(top_days_revenue_query)
    if not df_top_days_revenue.empty:
        st.write("#### Top 5 Days by Revenue")
        st.dataframe(df_top_days_revenue.style.format({'TotalRevenue': '${:,.2f}'}))
    else:
        st.info("No data to show top days by revenue.")

    # Top 5 Months by Transactions
    top_months_transactions_query = f"""
        SELECT
            STRFTIME('%Y-%m', TransactionDate) AS SalesPeriod,
            COUNT(DISTINCT TransactionID) AS NumberOfTransactions
        FROM
            sales_transaction
        {where_clause}
        GROUP BY
            SalesPeriod
        ORDER BY
            NumberOfTransactions DESC
        LIMIT 5;
    """
    df_top_months_transactions = get_data_from_db(top_months_transactions_query)
    if not df_top_months_transactions.empty:
        st.write("#### Top 5 Months by Number of Transactions")
        st.dataframe(df_top_months_transactions.style.format({'NumberOfTransactions': '{:,}'}))
    else:
        st.info("No data to show top months by transactions.")

    # Top 5 Days by Transactions
    top_days_transactions_query = f"""
        SELECT
            STRFTIME('%Y-%m-%d', TransactionDate) AS SalesDate,
            COUNT(DISTINCT TransactionID) AS NumberOfTransactions
        FROM
            sales_transaction
        {where_clause}
        GROUP BY
            SalesDate
        ORDER BY
            NumberOfTransactions DESC
        LIMIT 5;
    """
    df_top_days_transactions = get_data_from_db(top_days_transactions_query)
    if not df_top_days_transactions.empty:
        st.write("#### Top 5 Days by Number of Transactions")
        st.dataframe(df_top_days_transactions.style.format({'NumberOfTransactions': '{:,}'}))
    else:
        st.info("No data to show top days by transactions.")

def product_performance():
    """
    Displays sales for each product within a selected category.
    """
    st.header("Product Performance")

    # Total Revenue by Product Category
    revenue_by_category_query = """
        SELECT
            pi.Category,
            SUM(st.QuantityPurchased * st.Price) AS TotalRevenue
        FROM
            sales_transaction AS st
        JOIN
            product_inventory AS pi ON st.ProductID = pi.ProductID
        GROUP BY
            pi.Category
        ORDER BY
            TotalRevenue DESC;
    """
    df_revenue_by_category = get_data_from_db(revenue_by_category_query)

    if not df_revenue_by_category.empty:
        st.subheader("Revenue by Product Category")
        # Using Plotly for an interactive bar chart
        fig_category_revenue = px.bar(
            df_revenue_by_category,
            x='Category',
            y='TotalRevenue',
            title='Total Revenue by Product Category',
            labels={'Category': 'Product Category', 'TotalRevenue': 'Total Revenue ($)'},
            color='Category', # Color bars by category
            text='TotalRevenue' # Show value on bars
        )
        fig_category_revenue.update_traces(texttemplate='$%{text:,.2s}', textposition='outside') # Format text and position
        fig_category_revenue.update_layout(uniformtext_minsize=8, uniformtext_mode='hide') # Hide text if too small
        st.plotly_chart(fig_category_revenue, use_container_width=True)
    else:
        st.warning("No product category revenue data available.")

      # Top 5 Most Purchased Products by Quantity
    top_products_by_quantity_query = """
            SELECT
                pi.ProductName,
                pi.Category,
                SUM(st.QuantityPurchased) AS TotalQuantitySold
            FROM
                sales_transaction AS st
            JOIN
                product_inventory AS pi ON st.ProductID = pi.ProductID
            GROUP BY
                pi.ProductName, pi.Category
            ORDER BY
                TotalQuantitySold DESC
            LIMIT 5;
        """
    df_top_products = get_data_from_db(top_products_by_quantity_query)

    if not df_top_products.empty:
            st.subheader("Top 5 Most Purchased Products (by Quantity)")
            fig_top_products = px.bar(
                df_top_products,
                x='ProductName',
                y='TotalQuantitySold',
                title='Top 5 Products by Quantity Sold',
                labels={'ProductName': 'Product Name', 'TotalQuantitySold': 'Total Quantity Sold'},
                color='Category',
                text='TotalQuantitySold'
            )
            fig_top_products.update_traces(texttemplate='%{text:,}', textposition='outside')
            fig_top_products.update_layout(uniformtext_minsize=8, uniformtext_mode='hide')
            st.plotly_chart(fig_top_products, use_container_width=True)

    st.header("Product Sales by Category")

    # Get all unique categories for the selectbox
    categories_query = "SELECT DISTINCT Category FROM product_inventory ORDER BY Category ASC;"
    df_categories = get_data_from_db(categories_query)

    if df_categories.empty:
        st.warning("No product categories found in the database.")
        return

    # Create a selectbox for category selection
    selected_category = st.selectbox(
        "Select a Product Category",
        options=df_categories['Category'].tolist()
    )

    if selected_category:
        # Corrected SQL query with a placeholder for the category
        product_sales_query = f"""
            SELECT
                pi.ProductName,
                SUM(st.QuantityPurchased * st.Price) AS TotalRevenue
            FROM
                sales_transaction AS st
            JOIN
                product_inventory AS pi ON st.ProductID = pi.ProductID
            WHERE
                pi.Category = '{selected_category}' -- Use WHERE for filtering before grouping
            GROUP BY
                pi.ProductName
            ORDER BY
                TotalRevenue DESC;
        """
        df_product_sales = get_data_from_db(product_sales_query)

        if not df_product_sales.empty:
            st.subheader(f"Sales for Products in '{selected_category}' Category")
            
            # Display as a table
            st.dataframe(df_product_sales)

            # Optional: Display as a bar chart
            fig_product_sales = px.bar(
                df_product_sales,
                x='ProductName',
                y='TotalRevenue',
                title=f'Total Revenue by Product in {selected_category}',
                labels={'ProductName': 'Product Name', 'TotalRevenue': 'Total Revenue ($)'},
                text='TotalRevenue'
            )
            fig_product_sales.update_traces(texttemplate='$%{text:,.2s}', textposition='outside')
            fig_product_sales.update_layout(uniformtext_minsize=8, uniformtext_mode='hide')
            st.plotly_chart(fig_product_sales, use_container_width=True)
        else:
            st.warning(f"No sales data found for products in the '{selected_category}' category.")
    else:
        st.info("Please select a category to view product sales.")

def customer_insights():
    """
    Displays customer insights analysis.
    """
    st.header("Customer Insights")

    # Customer Distribution by Gender
    gender_distribution_query = """
        SELECT
            Gender,
            COUNT(CustomerID) AS NumberOfCustomers,
            ROUND((COUNT(CustomerID) * 100.0 / (SELECT COUNT(*) FROM customer_profiles)), 2) AS Percentage
        FROM
            customer_profiles
        GROUP BY
            Gender
        ORDER BY
            NumberOfCustomers DESC;
    """
    df_gender_distribution = get_data_from_db(gender_distribution_query)

    if not df_gender_distribution.empty:
        st.subheader("Customer Distribution by Gender")
        fig_gender = px.pie(
            df_gender_distribution,
            names='Gender',
            values='NumberOfCustomers',
            title='Customer Distribution by Gender',
            hole=0.3, # Creates a donut chart
            labels={'NumberOfCustomers': 'Number of Customers'}
        )
        fig_gender.update_traces(textinfo='percent+label', pull=[0.05, 0, 0]) # Show percentage and label, slightly pull out largest slice
        st.plotly_chart(fig_gender, use_container_width=True)
    else:
        st.warning("No customer gender data available.")

    # Customer Distribution by Location
    location_distribution_query = """
        SELECT
            Location,
            COUNT(CustomerID) AS NumberOfCustomers,
            ROUND((COUNT(CustomerID) * 100.0 / (SELECT COUNT(*) FROM customer_profiles)), 2) AS Percentage
        FROM
            customer_profiles
        GROUP BY
            Location
        ORDER BY
            NumberOfCustomers DESC;
    """
    df_location_distribution = get_data_from_db(location_distribution_query)

    if not df_location_distribution.empty:
        st.subheader("Customer Distribution by Location")
        fig_location = px.bar(
            df_location_distribution,
            x='Location',
            y='NumberOfCustomers',
            title='Customer Distribution by Location',
            labels={'Location': 'Location', 'NumberOfCustomers': 'Number of Customers'},
            color='Location',
            text='NumberOfCustomers'
        )
        fig_location.update_traces(texttemplate='%{text:,}', textposition='outside')
        fig_location.update_layout(uniformtext_minsize=8, uniformtext_mode='hide')
        st.plotly_chart(fig_location, use_container_width=True)
    else:
        st.warning("No customer location data available.")

def rfm_analysis():
    """
    Displays RFM (Recency, Frequency, Monetary) analysis for customer segmentation.
    """
    st.header("Customer Segmentation: RFM Analysis")

    rfm_query = """
    WITH CustomerRFM AS (
        SELECT
            CustomerID,
            JULIANDAY((SELECT MAX(TransactionDate) FROM sales_transaction)) - JULIANDAY(MAX(TransactionDate)) AS RecencyInDays,
            COUNT(DISTINCT TransactionID) AS Frequency,
            SUM(QuantityPurchased * Price) AS MonetaryValue
        FROM
            sales_transaction
        GROUP BY
            CustomerID
    ),
    RFMScores AS (
        SELECT
            CustomerID,
            RecencyInDays,
            Frequency,
            MonetaryValue,
            NTILE(5) OVER (ORDER BY RecencyInDays DESC) AS R_Score,
            NTILE(5) OVER (ORDER BY Frequency ASC) AS F_Score,
            NTILE(5) OVER (ORDER BY MonetaryValue ASC) AS M_Score
        FROM
            CustomerRFM
    )
    SELECT
        rfm.CustomerID,
        rfm.RecencyInDays,
        rfm.Frequency,
        rfm.MonetaryValue,
        rfm.R_Score,
        rfm.F_Score,
        rfm.M_Score,
        (rfm.R_Score || rfm.F_Score || rfm.M_Score) AS RFM_Score_String,
        CASE
            WHEN rfm.R_Score = 5 AND rfm.F_Score = 5 AND rfm.M_Score = 5 THEN 'Champions'
            WHEN rfm.R_Score = 5 AND rfm.F_Score >= 4 THEN 'Loyal Customers'
            WHEN rfm.R_Score >= 4 AND rfm.F_Score = 5 THEN 'Loyal Customers'
            WHEN rfm.R_Score >= 4 AND rfm.F_Score >= 4 AND rfm.M_Score >= 4 THEN 'Potential Loyalists'
            WHEN rfm.R_Score = 5 AND rfm.F_Score >= 3 THEN 'New Customers'
            WHEN rfm.R_Score >= 4 AND rfm.M_Score >= 4 THEN 'Promising'
            WHEN rfm.R_Score <= 2 AND rfm.F_Score <= 2 AND rfm.M_Score <= 2 THEN 'Lost Customers'
            WHEN rfm.R_Score <= 2 AND rfm.F_Score >= 3 THEN 'At Risk'
            WHEN rfm.R_Score <= 2 AND rfm.M_Score >= 3 THEN 'Can''t Lose Them'
            WHEN rfm.F_Score = 5 AND rfm.M_Score = 5 THEN 'Best Customers'
            ELSE 'Other Segment'
        END AS CustomerSegment
    FROM
        RFMScores rfm
    ORDER BY
        rfm.MonetaryValue DESC;
        
    """
    df_rfm = get_data_from_db(rfm_query)

    if not df_rfm.empty:
        st.subheader("RFM Scores and Customer Segments")
        st.dataframe(df_rfm.head(50)) # Display first 10 rows of RFM data

        st.subheader("Distribution of Customer Segments")
        segment_counts = df_rfm['CustomerSegment'].value_counts().reset_index()
        segment_counts.columns = ['CustomerSegment', 'Count']
        fig_segments = px.bar(
            segment_counts,
            x='CustomerSegment',
            y='Count',
            title='Distribution of Customer Segments by RFM',
            labels={'CustomerSegment': 'Segment', 'Count': 'Number of Customers'},
            color='CustomerSegment'
        )
        st.plotly_chart(fig_segments, use_container_width=True)
    else:
        st.warning("No data available for RFM analysis.")

def main():
    selection = st.sidebar.radio(
        "Navigation Page",
        [
            "Home Page",
            "Sales Trends",
            "Product Performance",
            "Customer Insights",
            "RFM Analysis"
        ]
    )


    if selection == "Home Page":
        home_page()
    elif selection == "Sales Trends":
        sales_trend()
    elif selection == "Product Performance":
        product_performance()
    elif selection == "Customer Insights":
        customer_insights()
    elif selection == "RFM Analysis":
        rfm_analysis()


if __name__ == '__main__':
    main()