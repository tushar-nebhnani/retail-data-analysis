🛒 Retail Data Analysis Dashboard
This project provides a comprehensive interactive dashboard for analyzing retail sales data, customer profiles, and product inventory. It leverages Python for data preparation and Streamlit for building the web-based dashboard, with Plotly for interactive visualizations. The data is stored and managed efficiently using a SQLite database.

✨ Features
Key Performance Indicators (KPIs): Displays essential metrics such as Total Revenue, Average Transaction Value, Unique Customers, and Unique Products Sold.

Sales Trend Analysis: Visualize continuous monthly sales trends and identify peak sales periods (top months/days by revenue and transactions). Includes a multi-year filter.

Product Performance: Analyze revenue distribution by product category and detailed sales performance for individual products within a selected category.

Customer Insights: Understand customer demographics through distribution charts based on gender and geographical location.

RFM (Recency, Frequency, Monetary) Analysis: Segment customers into distinct groups (e.g., Champions, Loyal Customers, At Risk) based on their purchasing behavior, enabling targeted marketing strategies.

Robust Data Preparation: A dedicated script handles loading raw CSV data, performing cleaning (date conversion, missing value imputation, duplicate removal), and resolving data inconsistencies (e.g., price discrepancies between sales and inventory).

Efficient Data Storage: Utilizes a SQLite database for structured and optimized data storage, ensuring fast retrieval for the dashboard.

🛠️ Technologies Used
Python 3.x

Streamlit: For building the interactive web dashboard.

Pandas: For data loading, cleaning, and manipulation.

Plotly Express: For creating rich, interactive visualizations.

SQLite3: For local database management.

🚀 Setup and Installation
Follow these steps to get the dashboard up and running on your local machine:

1. Clone the Repository
First, clone this GitHub repository to your local machine:

git clone https://github.com/your-username/retail-data-analysis.git
cd retail-data-analysis

2. Create a Virtual Environment (Recommended)
It's highly recommended to use a virtual environment to manage project dependencies:

python -m venv venv
# On Windows
.\venv\Scripts\activate
# On macOS/Linux
source venv/bin/activate

3. Install Dependencies
Install all required Python packages using pip:

pip install -r requirements.txt

The requirements.txt file should contain:

streamlit
pandas
plotly

4. Prepare the Data
Before running the dashboard, you need to prepare the data and populate the SQLite database. Ensure you have the following raw CSV files in the same directory as data_preparation.py:

customer_profiles_raw_data.csv

product_inventory_raw_data.csv

sales_transaction_raw_data.csv

Then, run the data preparation script:

python data_preparation.py

This script will create retail_analysis.db in your project directory.

5. Run the Streamlit Dashboard
Once the database is prepared, you can launch the Streamlit dashboard:

streamlit run dashboard_app.py

This command will open the dashboard in your default web browser.

📁 Project Structure
.
├── data_preparation.py         # Script for cleaning raw data and populating SQLite DB
├── dashboard_app.py            # Streamlit application for the dashboard
├── requirements.txt            # List of Python dependencies
├── customer_profiles_raw_data.csv  # Raw customer data
├── product_inventory_raw_data.csv  # Raw product data
├── sales_transaction_raw_data.csv  # Raw sales transaction data
└── retail_analysis.db          # SQLite database (generated after running data_preparation.py)

📊 Screenshots
(Optional: Add screenshots of your dashboard here to give users a visual preview.)

💡 Future Enhancements
Interactive Filters: Add more dynamic filters for product, customer, and time ranges.

Predictive Analytics: Integrate machine learning models for sales forecasting or customer churn prediction.

User Authentication: Implement basic user authentication for access control.

Deployment: Deploy the application to a cloud platform (e.g., Streamlit Cloud, Heroku, AWS).

More Detailed RFM Segments: Refine RFM segmentation logic for more granular customer targeting.

✍️ Author
Tushar Nebhnani

Feel free to connect with me on [LinkedIn](www.linkedin.com/in/tushar-nebhnani)
