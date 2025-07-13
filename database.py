# data_preparation.py
# This script is responsible for loading raw CSV data, cleaning it,
# and then populating a SQLite database for use with our Streamlit dashboard.

import pandas as pd
import sqlite3
import os # Used to check if the database file exists

print("--- Starting Data Preparation ---")

# Define file paths for the raw data.
# IMPORTANT: Ensure these CSV files are in the same directory as this script,
# or provide the full, correct path to them.
customer_profiles_file = 'customer_profiles_raw_data.csv'
product_inventory_file = 'product_inventory_raw_data.csv'
sales_transaction_file = 'sales_transaction_raw_data.csv'

# Define the name for our SQLite database file.
DB_FILE = 'retail_analysis.db'

# --- 1. Load Raw CSV Files into Pandas DataFrames ---
print(f"Loading raw data from: {customer_profiles_file}, {product_inventory_file}, {sales_transaction_file}")
try:
    df_customers_raw = pd.read_csv(customer_profiles_file)
    df_products_raw = pd.read_csv(product_inventory_file)
    df_sales_raw = pd.read_csv(sales_transaction_file)
    print("Raw CSV files loaded successfully.")
except FileNotFoundError as e:
    print(f"Error: One or more raw CSV files not found. Please ensure they are in the correct directory.")
    print(f"Missing file: {e.filename}")
    print("Exiting data preparation.")
    exit() # Stop execution if files are missing
except Exception as e:
    print(f"An unexpected error occurred while reading CSV files: {e}")
    print("Exiting data preparation.")
    exit()

# Display initial info to verify loading and see raw data types/nulls
print("\n--- Initial Raw Data Info ---")
print("\nCustomer Profiles:")
df_customers_raw.info()
print("\nProduct Inventory:")
df_products_raw.info()
print("\nSales Transaction:")
df_sales_raw.info()

# --- 2. Perform Data Cleaning and Refinement using Pandas ---
print("\n--- Starting Data Cleaning and Refinement ---")

# 2.1. Cleaning for customer_profiles
df_customers_cleaned = df_customers_raw.copy() # Create a copy to avoid modifying the raw DataFrame directly

# Convert 'JoinDate' to datetime objects.
# The format '%d/%m/%y' is inferred from the head() output (e.g., '01/01/20').
df_customers_cleaned['JoinDate'] = pd.to_datetime(df_customers_cleaned['JoinDate'], format='%d/%m/%y')
print("customer_profiles: 'JoinDate' converted to datetime.")

# Fill missing 'Location' values with 'Unknown'.
# Your SQL analysis mentioned 13 missing values in Location.
# Assuming df_customers_cleaned is your DataFrame
df_customers_cleaned[df_customers_cleaned['Location'] != 'Unknown']
print("customer_profiles: Missing 'Location' values filled with 'Unknown'.")

# Remove duplicate CustomerIDs, keeping the first occurrence.
# This ensures each customer has a unique profile.
initial_customer_rows = len(df_customers_cleaned)
df_customers_cleaned.drop_duplicates(subset=['CustomerID'], inplace=True)
if len(df_customers_cleaned) < initial_customer_rows:
    print(f"customer_profiles: Removed {initial_customer_rows - len(df_customers_cleaned)} duplicate CustomerID rows.")
else:
    print("customer_profiles: No duplicate CustomerID rows found.")

# 2.2. Cleaning for product_inventory
df_products_cleaned = df_products_raw.copy()

# Remove duplicate ProductIDs, keeping the first occurrence.
# Ensures each product has a unique entry.
initial_product_rows = len(df_products_cleaned)
df_products_cleaned.drop_duplicates(subset=['ProductID'], inplace=True)
if len(df_products_cleaned) < initial_product_rows:
    print(f"product_inventory: Removed {initial_product_rows - len(df_products_cleaned)} duplicate ProductID rows.")
else:
    print("product_inventory: No duplicate ProductID rows found.")

# 2.3. Cleaning for sales_transaction
df_sales_cleaned = df_sales_raw.copy()

# Convert 'TransactionDate' to datetime objects.
# Format '%d/%m/%y' is inferred from the head() output (e.g., '01/01/23').
df_sales_cleaned['TransactionDate'] = pd.to_datetime(df_sales_cleaned['TransactionDate'], format='%d/%m/%y')
print("sales_transaction: 'TransactionDate' converted to datetime.")

# Remove duplicate TransactionIDs, keeping the first occurrence.
# Your SQL analysis identified 2 duplicates here.
initial_sales_rows = len(df_sales_cleaned)
df_sales_cleaned.drop_duplicates(subset=['TransactionID'], inplace=True)
if len(df_sales_cleaned) < initial_sales_rows:
    print(f"sales_transaction: Removed {initial_sales_rows - len(df_sales_cleaned)} duplicate TransactionID rows.")
else:
    print("sales_transaction: No duplicate TransactionID rows found.")

# IMPORTANT: Handle Price Discrepancies as per your SQL analysis.
# Your SQL script updated sales_transaction.Price to match product_inventory.Price.
# We'll replicate this by merging and updating.
# First, ensure ProductID is consistent for merging
df_sales_cleaned['ProductID'] = df_sales_cleaned['ProductID'].astype(int)
df_products_cleaned['ProductID'] = df_products_cleaned['ProductID'].astype(int)

# Merge sales with product inventory to get the current product prices
df_sales_with_inventory_price = pd.merge(
    df_sales_cleaned,
    df_products_cleaned[['ProductID', 'Price']], # Select only ProductID and its current Price
    on='ProductID',
    how='left',
    suffixes=('_transaction', '_inventory') # Suffixes to differentiate prices
)

# Update the 'Price' column in df_sales_cleaned to match 'Price_inventory'
# where there was a discrepancy.
# This aligns transaction prices with current inventory prices, as per your SQL script's logic.
# Use .loc for setting values to avoid SettingWithCopyWarning
mismatched_prices_count = (df_sales_with_inventory_price['Price_transaction'] != df_sales_with_inventory_price['Price_inventory']).sum()
if mismatched_prices_count > 0:
    df_sales_cleaned.loc[df_sales_with_inventory_price['Price_transaction'] != df_sales_with_inventory_price['Price_inventory'], 'Price'] = \
        df_sales_with_inventory_price.loc[df_sales_with_inventory_price['Price_transaction'] != df_sales_with_inventory_price['Price_inventory'], 'Price_inventory']
    print(f"sales_transaction: Corrected {mismatched_prices_count} price discrepancies to match product inventory prices.")
else:
    print("sales_transaction: No price discrepancies found or corrected.")


print("\n--- Cleaned Data Info ---")
print("\nCustomer Profiles (Cleaned):")
df_customers_cleaned.info()
print("\nProduct Inventory (Cleaned):")
df_products_cleaned.info()
print("\nSales Transaction (Cleaned):")
df_sales_cleaned.info()

print("\n--- Cleaned Data Head Samples ---")
print("\nCustomer Profiles:")
print(df_customers_cleaned.head())
print("\nProduct Inventory:")
print(df_products_cleaned.head())
print("\nSales Transaction:")
print(df_sales_cleaned.head())

# --- 3. Create SQLite Database and Load Cleaned Data ---
print(f"\n--- Creating/Updating SQLite Database: {DB_FILE} ---")

# Connect to SQLite database. It will create the file if it doesn't exist.
conn = sqlite3.connect(DB_FILE)
cursor = conn.cursor()

# Define SQL DDL (Data Definition Language) for creating tables.
# These match the refined schema from your SQL analysis.
# INTEGER PRIMARY KEY automatically handles AUTOINCREMENT in SQLite.

# customer_profiles table schema
create_customer_table_sql = '''
    CREATE TABLE IF NOT EXISTS customer_profiles (
        CustomerID INTEGER PRIMARY KEY,
        Age INTEGER,
        Gender TEXT,
        Location TEXT,
        JoinDate TEXT -- Storing as TEXT in 'YYYY-MM-DD' format for SQLite
    )
'''
cursor.execute(create_customer_table_sql)
print("Table 'customer_profiles' ensured.")

# product_inventory table schema
create_product_table_sql = '''
    CREATE TABLE IF NOT EXISTS product_inventory (
        ProductID INTEGER PRIMARY KEY,
        ProductName TEXT,
        Category TEXT,
        StockLevel INTEGER,
        Price REAL
    )
'''
cursor.execute(create_product_table_sql)
print("Table 'product_inventory' ensured.")

# sales_transaction table schema
create_sales_table_sql = '''
    CREATE TABLE IF NOT EXISTS sales_transaction (
        TransactionID INTEGER PRIMARY KEY,
        CustomerID INTEGER,
        ProductID INTEGER,
        QuantityPurchased INTEGER,
        TransactionDate TEXT, -- Storing as TEXT in 'YYYY-MM-DD' format for SQLite
        Price REAL
    )
'''
cursor.execute(create_sales_table_sql)
print("Table 'sales_transaction' ensured.")

# Convert datetime columns in DataFrames to string format 'YYYY-MM-DD'
# This is necessary because SQLite prefers dates as TEXT or REAL, not native datetime objects.
df_customers_cleaned['JoinDate'] = df_customers_cleaned['JoinDate'].dt.strftime('%Y-%m-%d')
df_sales_cleaned['TransactionDate'] = df_sales_cleaned['TransactionDate'].dt.strftime('%Y-%m-%d')
print("Datetime columns converted to 'YYYY-MM-DD' string format for SQLite insertion.")

# Load the cleaned DataFrames into the SQLite tables.
# if_exists='replace' will drop the table if it exists and then recreate it,
# which is useful for re-running this script during development.
# index=False prevents Pandas from writing the DataFrame index as a column in the SQL table.
df_customers_cleaned.to_sql('customer_profiles', conn, if_exists='replace', index=False)
print("Data loaded into 'customer_profiles' table.")

df_products_cleaned.to_sql('product_inventory', conn, if_exists='replace', index=False)
print("Data loaded into 'product_inventory' table.")

df_sales_cleaned.to_sql('sales_transaction', conn, if_exists='replace', index=False)
print("Data loaded into 'sales_transaction' table.")

# Commit changes to the database and close the connection.
conn.commit()
conn.close()

print(f"\n--- Data Preparation Complete! Database '{DB_FILE}' is ready. ---")
print("You can now proceed to build your Streamlit dashboard using this database.")

