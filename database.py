
import pandas as pd
import sqlite3
import os

print("--- Starting Data Preparation ---")

customer_profiles_file = 'customer_profiles_raw_data.csv'
product_inventory_file = 'product_inventory_raw_data.csv'
sales_transaction_file = 'sales_transaction_raw_data.csv'

DB_FILE = 'retail_analysis.db'

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
    exit()
except Exception as e:
    print(f"An unexpected error occurred while reading CSV files: {e}")
    print("Exiting data preparation.")
    exit()

print("\n--- Initial Raw Data Info ---")
print("\nCustomer Profiles:")
df_customers_raw.info()
print("\nProduct Inventory:")
df_products_raw.info()
print("\nSales Transaction:")
df_sales_raw.info()

print("\n--- Starting Data Cleaning and Refinement ---")

df_customers_cleaned = df_customers_raw.copy()

df_customers_cleaned['JoinDate'] = pd.to_datetime(df_customers_cleaned['JoinDate'], format='%d/%m/%y')
print("customer_profiles: 'JoinDate' converted to datetime.")

df_customers_cleaned['Location'].fillna('Unknown', inplace=True)
print("customer_profiles: Missing 'Location' values filled with 'Unknown'.")

initial_customer_rows = len(df_customers_cleaned)
df_customers_cleaned.drop_duplicates(subset=['CustomerID'], inplace=True)
if len(df_customers_cleaned) < initial_customer_rows:
    print(f"customer_profiles: Removed {initial_customer_rows - len(df_customers_cleaned)} duplicate CustomerID rows.")
else:
    print("customer_profiles: No duplicate CustomerID rows found.")

df_products_cleaned = df_products_raw.copy()

initial_product_rows = len(df_products_cleaned)
df_products_cleaned.drop_duplicates(subset=['ProductID'], inplace=True)
if len(df_products_cleaned) < initial_product_rows:
    print(f"product_inventory: Removed {initial_product_rows - len(df_products_cleaned)} duplicate ProductID rows.")
else:
    print("product_inventory: No duplicate ProductID rows found.")

df_sales_cleaned = df_sales_raw.copy()

df_sales_cleaned['TransactionDate'] = pd.to_datetime(df_sales_cleaned['TransactionDate'], format='%d/%m/%y')
print("sales_transaction: 'TransactionDate' converted to datetime.")

initial_sales_rows = len(df_sales_cleaned)
df_sales_cleaned.drop_duplicates(subset=['TransactionID'], inplace=True)
if len(df_sales_cleaned) < initial_sales_rows:
    print(f"sales_transaction: Removed {initial_sales_rows - len(df_sales_cleaned)} duplicate TransactionID rows.")
else:
    print("sales_transaction: No duplicate TransactionID rows found.")

df_sales_cleaned['ProductID'] = df_sales_cleaned['ProductID'].astype(int)
df_products_cleaned['ProductID'] = df_products_cleaned['ProductID'].astype(int)

df_sales_with_inventory_price = pd.merge(
    df_sales_cleaned,
    df_products_cleaned[['ProductID', 'Price']],
    on='ProductID',
    how='left',
    suffixes=('_transaction', '_inventory')
)

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

print(f"\n--- Creating/Updating SQLite Database: {DB_FILE} ---")

conn = sqlite3.connect(DB_FILE)
cursor = conn.cursor()


create_customer_table_sql = '''
    CREATE TABLE IF NOT EXISTS customer_profiles (
        CustomerID INTEGER PRIMARY KEY,
        Age INTEGER,
        Gender TEXT,
        Location TEXT,
        JoinDate TEXT -- Storing dates as TEXT in 'YYYY-MM-DD' format for SQLite compatibility.
    )
'''
cursor.execute(create_customer_table_sql)
print("Table 'customer_profiles' ensured.")

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

df_customers_cleaned['JoinDate'] = df_customers_cleaned['JoinDate'].dt.strftime('%Y-%m-%d')
df_sales_cleaned['TransactionDate'] = df_sales_cleaned['TransactionDate'].dt.strftime('%Y-%m-%d')
print("Datetime columns converted to 'YYYY-MM-DD' string format for SQLite insertion.")

df_customers_cleaned.to_sql('customer_profiles', conn, if_exists='replace', index=False)
print("Data loaded into 'customer_profiles' table.")

df_products_cleaned.to_sql('product_inventory', conn, if_exists='replace', index=False)
print("Data loaded into 'product_inventory' table.")

df_sales_cleaned.to_sql('sales_transaction', conn, if_exists='replace', index=False)
print("Data loaded into 'sales_transaction' table.")

conn.commit()
conn.close()

print(f"\n--- Data Preparation Complete! Database '{DB_FILE}' is ready. ---")
print("You can now proceed to build your Streamlit dashboard using this database.")
