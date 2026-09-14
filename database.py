# data_preparation.py
# This script is responsible for loading raw CSV data, cleaning it,
# and then populating a SQLite database for use with our Streamlit dashboard.

import pandas as pd # Used for data manipulation and analysis, especially with DataFrames.
import sqlite3      # Used for interacting with SQLite databases.
import os           # Used to check if the database file exists (though not explicitly used for existence check in final version, good for path manipulation).

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
    # Attempt to read each CSV file into a pandas DataFrame.
    df_customers_raw = pd.read_csv(customer_profiles_file)
    df_products_raw = pd.read_csv(product_inventory_file)
    df_sales_raw = pd.read_csv(sales_transaction_file)
    print("Raw CSV files loaded successfully.")
except FileNotFoundError as e:
    # Catch specific error if any CSV file is not found.
    print(f"Error: One or more raw CSV files not found. Please ensure they are in the correct directory.")
    print(f"Missing file: {e.filename}")
    print("Exiting data preparation.")
    exit() # Stop execution if files are missing to prevent further errors.
except Exception as e:
    # Catch any other unexpected errors during file reading.
    print(f"An unexpected error occurred while reading CSV files: {e}")
    print("Exiting data preparation.")
    exit() # Stop execution for other errors.

# Display initial info to verify loading and see raw data types/nulls.
# This helps in understanding the raw state of the data before cleaning.
print("\n--- Initial Raw Data Info ---")
print("\nCustomer Profiles:")
df_customers_raw.info() # Provides a concise summary of the DataFrame, including data types and non-null values.
print("\nProduct Inventory:")
df_products_raw.info()
print("\nSales Transaction:")
df_sales_raw.info()

# --- 2. Perform Data Cleaning and Refinement using Pandas ---
print("\n--- Starting Data Cleaning and Refinement ---")

# 2.1. Cleaning for customer_profiles
# Create a copy to avoid modifying the raw DataFrame directly.
# This is good practice to preserve original data.
df_customers_cleaned = df_customers_raw.copy()

# Convert 'JoinDate' to datetime objects.
# The format '%d/%m/%y' is specified based on the expected input format (e.g., '01/01/20').
df_customers_cleaned['JoinDate'] = pd.to_datetime(df_customers_cleaned['JoinDate'], format='%d/%m/%y')
print("customer_profiles: 'JoinDate' converted to datetime.")

# Fill missing 'Location' values with 'Unknown'.
# The SQL analysis mentioned 13 missing values in Location, this addresses that.
# Note: The line `df_customers_cleaned[df_customers_cleaned['Location'] != 'Unknown']`
#       in the original script doesn't actually perform the fillna.
#       It should be `df_customers_cleaned['Location'].fillna('Unknown', inplace=True)`
#       or `df_customers_cleaned['Location'] = df_customers_cleaned['Location'].fillna('Unknown')`.
#       Assuming the intent was to fill missing values, the corrected line would be:
df_customers_cleaned['Location'].fillna('Unknown', inplace=True) # Corrected line for filling missing values
print("customer_profiles: Missing 'Location' values filled with 'Unknown'.")

# Remove duplicate CustomerIDs, keeping the first occurrence.
# This ensures each customer has a unique profile, critical for relational integrity.
initial_customer_rows = len(df_customers_cleaned)
df_customers_cleaned.drop_duplicates(subset=['CustomerID'], inplace=True) # `inplace=True` modifies the DataFrame directly.
if len(df_customers_cleaned) < initial_customer_rows:
    print(f"customer_profiles: Removed {initial_customer_rows - len(df_customers_cleaned)} duplicate CustomerID rows.")
else:
    print("customer_profiles: No duplicate CustomerID rows found.")

# 2.2. Cleaning for product_inventory
df_products_cleaned = df_products_raw.copy()

# Remove duplicate ProductIDs, keeping the first occurrence.
# Ensures each product has a unique entry, similar to CustomerIDs.
initial_product_rows = len(df_products_cleaned)
df_products_cleaned.drop_duplicates(subset=['ProductID'], inplace=True)
if len(df_products_cleaned) < initial_product_rows:
    print(f"product_inventory: Removed {initial_product_rows - len(df_products_cleaned)} duplicate ProductID rows.")
else:
    print("product_inventory: No duplicate ProductID rows found.")

# 2.3. Cleaning for sales_transaction
df_sales_cleaned = df_sales_raw.copy()

# Convert 'TransactionDate' to datetime objects.
# Format '%d/%m/%y' is specified based on the expected input format (e.g., '01/01/23').
df_sales_cleaned['TransactionDate'] = pd.to_datetime(df_sales_cleaned['TransactionDate'], format='%d/%m/%y')
print("sales_transaction: 'TransactionDate' converted to datetime.")

# Remove duplicate TransactionIDs, keeping the first occurrence.
# The SQL analysis identified 2 duplicates here, this handles them.
initial_sales_rows = len(df_sales_cleaned)
df_sales_cleaned.drop_duplicates(subset=['TransactionID'], inplace=True)
if len(df_sales_cleaned) < initial_sales_rows:
    print(f"sales_transaction: Removed {initial_sales_rows - len(df_sales_cleaned)} duplicate TransactionID rows.")
else:
    print("sales_transaction: No duplicate TransactionID rows found.")

# IMPORTANT: Handle Price Discrepancies as per your SQL analysis.
# Your SQL script updated sales_transaction.Price to match product_inventory.Price.
# We'll replicate this by merging and updating in Pandas.
# First, ensure ProductID columns are of consistent integer type for accurate merging.
df_sales_cleaned['ProductID'] = df_sales_cleaned['ProductID'].astype(int)
df_products_cleaned['ProductID'] = df_products_cleaned['ProductID'].astype(int)

# Merge sales with product inventory to get the current product prices.
# This creates a temporary DataFrame that includes both the transaction price
# and the inventory price for comparison.
df_sales_with_inventory_price = pd.merge(
    df_sales_cleaned,
    df_products_cleaned[['ProductID', 'Price']], # Select only ProductID and its current Price from products.
    on='ProductID',                            # Merge based on matching ProductID.
    how='left',                                # Use a left merge to keep all sales transactions.
    suffixes=('_transaction', '_inventory')    # Add suffixes to distinguish 'Price' columns from each DataFrame.
)

# Update the 'Price' column in df_sales_cleaned to match 'Price_inventory'
# where there was a discrepancy.
# This aligns transaction prices with current inventory prices, as per the SQL script's logic.
# Use `.loc` for setting values to avoid the `SettingWithCopyWarning`.
mismatched_prices_count = (df_sales_with_inventory_price['Price_transaction'] != df_sales_with_inventory_price['Price_inventory']).sum()
if mismatched_prices_count > 0:
    df_sales_cleaned.loc[df_sales_with_inventory_price['Price_transaction'] != df_sales_with_inventory_price['Price_inventory'], 'Price'] = \
        df_sales_with_inventory_price.loc[df_sales_with_inventory_price['Price_transaction'] != df_sales_with_inventory_price['Price_inventory'], 'Price_inventory']
    print(f"sales_transaction: Corrected {mismatched_prices_count} price discrepancies to match product inventory prices.")
else:
    print("sales_transaction: No price discrepancies found or corrected.")


print("\n--- Cleaned Data Info ---")
# Display info for cleaned DataFrames to confirm data types and non-null counts after cleaning.
print("\nCustomer Profiles (Cleaned):")
df_customers_cleaned.info()
print("\nProduct Inventory (Cleaned):")
df_products_cleaned.info()
print("\nSales Transaction (Cleaned):")
df_sales_cleaned.info()

print("\n--- Cleaned Data Head Samples ---")
# Display the first few rows of the cleaned DataFrames to visually inspect the changes.
print("\nCustomer Profiles:")
print(df_customers_cleaned.head())
print("\nProduct Inventory:")
print(df_products_cleaned.head())
print("\nSales Transaction:")
print(df_sales_cleaned.head())

# --- 3. Create SQLite Database and Load Cleaned Data ---
print(f"\n--- Creating/Updating SQLite Database: {DB_FILE} ---")

# Connect to SQLite database.
# If the database file specified by DB_FILE does not exist, it will be created.
# Otherwise, a connection to the existing database will be established.
conn = sqlite3.connect(DB_FILE)
cursor = conn.cursor() # Create a cursor object to execute SQL commands.

# Define SQL DDL (Data Definition Language) for creating tables.
# These schemas match the refined structure from your SQL analysis.
# `INTEGER PRIMARY KEY` in SQLite automatically handles auto-incrementing IDs.

# SQL to create the 'customer_profiles' table if it doesn't already exist.
create_customer_table_sql = '''
    CREATE TABLE IF NOT EXISTS customer_profiles (
        CustomerID INTEGER PRIMARY KEY,
        Age INTEGER,
        Gender TEXT,
        Location TEXT,
        JoinDate TEXT -- Storing dates as TEXT in 'YYYY-MM-DD' format for SQLite compatibility.
    )
'''
cursor.execute(create_customer_table_sql) # Execute the SQL command.
print("Table 'customer_profiles' ensured.")

# SQL to create the 'product_inventory' table if it doesn't already exist.
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

# SQL to create the 'sales_transaction' table if it doesn't already exist.
create_sales_table_sql = '''
    CREATE TABLE IF NOT EXISTS sales_transaction (
        TransactionID INTEGER PRIMARY KEY,
        CustomerID INTEGER,
        ProductID INTEGER,
        QuantityPurchased INTEGER,
        TransactionDate TEXT, -- Storing dates as TEXT in 'YYYY-MM-DD' format for SQLite compatibility.
        Price REAL
    )
'''
cursor.execute(create_sales_table_sql)
print("Table 'sales_transaction' ensured.")

# Convert datetime columns in DataFrames to string format 'YYYY-MM-DD'.
# This is necessary because SQLite prefers dates as TEXT (ISO 8601 strings) or REAL (Julian day numbers),
# not native Python datetime objects, for direct insertion via `to_sql`.
df_customers_cleaned['JoinDate'] = df_customers_cleaned['JoinDate'].dt.strftime('%Y-%m-%d')
df_sales_cleaned['TransactionDate'] = df_sales_cleaned['TransactionDate'].dt.strftime('%Y-%m-%d')
print("Datetime columns converted to 'YYYY-MM-DD' string format for SQLite insertion.")

# Load the cleaned DataFrames into the respective SQLite tables.
# `if_exists='replace'` will drop the table if it exists and then recreate it.
# This is very useful for re-running this script during development to ensure a fresh start.
# `index=False` prevents Pandas from writing the DataFrame index as a separate column in the SQL table.
df_customers_cleaned.to_sql('customer_profiles', conn, if_exists='replace', index=False)
print("Data loaded into 'customer_profiles' table.")

df_products_cleaned.to_sql('product_inventory', conn, if_exists='replace', index=False)
print("Data loaded into 'product_inventory' table.")

df_sales_cleaned.to_sql('sales_transaction', conn, if_exists='replace', index=False)
print("Data loaded into 'sales_transaction' table.")

# Commit changes to the database.
# This saves all the executed SQL commands (table creation, data insertion) permanently to the DB file.
conn.commit()
# Close the database connection.
# It's important to close the connection when done to release resources.
conn.close()

print(f"\n--- Data Preparation Complete! Database '{DB_FILE}' is ready. ---")
print("You can now proceed to build your Streamlit dashboard using this database.")
