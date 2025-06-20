### DATABASE CREATION AND INTIAL DATA LOADING

-- Create a new database named 'RetailAnalysis' if it does not already exist.
-- This ensures that our operations are performed within the correct schema.
CREATE DATABASE if not exists RetailAnalysis;

-- Use the 'RetailAnalysis' database for all subsequent SQL commands.
USE RetailAnalysis;

## Table Creation

-- Create the 'customer_profiles' table.
-- This table stores demographic and essential information for each customer.
CREATE TABLE if not exists customer_profiles (
    `CustomerID`    DECIMAL(38, 0) NOT NULL, 	-- Unique numerical identifier for each customer.
    `Age`           DECIMAL(38, 0) NOT NULL, 	-- Age of the customer, initially stored as a decimal.
    `Gender`        VARCHAR(6) NOT NULL,     	-- Gender of the customer (e.g., 'Male', 'Female').
    `Location`      VARCHAR(5),              	-- Abbreviated location code for the customer.
    `JoinDate`      VARCHAR(8) NOT NULL      	-- Date when the customer registered, stored as YYYYMMDD string.
);


-- Create the 'product_inventory' table.
-- This table holds detailed information about each product and its current stock status.
CREATE TABLE if not exists product_inventory (
    `ProductID`     DECIMAL(38, 0) NOT NULL, 	-- Unique numerical identifier for each product.
    `ProductName`   VARCHAR(11) NOT NULL,    	-- Name of the product.
    `Category`      VARCHAR(15) NOT NULL,    	-- Product category (e.g., 'Electronics', 'Apparel').
    `StockLevel`    DECIMAL(38, 0) NOT NULL, 	-- Current quantity of the product available in stock.
    `Price`         DECIMAL(38, 2) NOT NULL  	-- Selling price of the product.
);


-- Create the 'sales_transaction' table.
-- This table records every individual sales event, linking customers to products.
CREATE TABLE IF NOT EXISTS sales_transaction (
    `TransactionID`         DECIMAL(38, 0) NOT NULL, 	-- Unique numerical identifier for each sales transaction.
    `CustomerID`            DECIMAL(38, 0) NOT NULL, 	-- Identifier of the customer who made the purchase.
    `ProductID`             DECIMAL(38, 0) NOT NULL, 	-- Identifier of the product involved in the transaction.
    `QuantityPurchased`     DECIMAL(38, 0) NOT NULL, 	-- Number of units of the product bought in this transaction.
    `TransactionDate`       VARCHAR(8) NOT NULL,     	-- Date of the transaction, stored as YYYYMMDD string.
    `Price`                 DECIMAL(38, 2) NOT NULL  	-- Final price at which the product was sold in this transaction.
);


-- Data Loading Operations

-- Load data into the 'customer_profiles' table from its corresponding CSV file.
-- This command imports external data, specifying delimiter, enclosure, and header row to skip.
LOAD DATA LOCAL INFILE "C:/Users/nebhn/OneDrive/Desktop/Data Science/CaseStudy/customer_profiles_lyst1749925722389.csv"
INTO TABLE customer_profiles
FIELDS TERMINATED BY ','      	-- Specifies that fields in the CSV are separated by commas.
ENCLOSED BY '"'              	-- Specifies that fields are optionally enclosed by double quotes.
LINES TERMINATED BY '\n'     	-- Specifies that lines in the CSV are terminated by a newline character.
IGNORE 1 ROWS;               	-- Skips the first row of the CSV file, assuming it's a header.

-- Load data into the 'product_inventory' table from its corresponding CSV file.
LOAD DATA LOCAL INFILE "C:/Users/nebhn/OneDrive/Desktop/Data Science/CaseStudy/product_inventory_lyst1749925727340.csv"
INTO TABLE product_inventory
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Load data into the 'sales_transaction' table from its corresponding CSV file.
LOAD DATA LOCAL INFILE "C:/Users/nebhn/OneDrive/Desktop/Data Science/CaseStudy/sales_transaction_lyst1749925731351.csv"
INTO TABLE sales_transaction
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Initial Data Verification

-- Retrieve and display all records from the 'customer_profiles' table.
-- This provides a quick overview of the loaded data.
SELECT * FROM customer_profiles;
-- Count the total number of records in the 'customer_profiles' table for verification.
SELECT COUNT(*) AS TotalCustomerRecords FROM customer_profiles;

-- Retrieve and display all records from the 'product_inventory' table.
SELECT * FROM product_inventory;
-- Count the total number of records in the 'product_inventory' table.
SELECT COUNT(*) AS TotalProductRecords FROM product_inventory;

-- Retrieve and display all records from the 'sales_transaction' table.
SELECT * FROM sales_transaction;
-- Count the total number of records in the 'sales_transaction' table.
SELECT COUNT(*) AS TotalTransactionRecords FROM sales_transaction;

/*
	## Initial Data Insights and Observations:

	Upon successfully loading the `customer_profiles`, `product_inventory`, and `sales_transaction` datasets into MySQL,
    an initial inspection revealed several key points:

	1.  Data Type Mismatch:
		* `CustomerID`, `Age`, `ProductID`, and `TransactionID` columns were loaded with a `DECIMAL(38,0)` datatype. 
        While functional, these identifiers and age values are intrinsically whole numbers 
        and would be more appropriately represented by an `INT` datatype, 
        which is more memory-efficient and semantically correct for such fields.
        
		* Similarly, `StockLevel` in `product_inventory` and `QuantityPurchased` in `sales_transaction` were also loaded 
        as `DECIMAL(38,0)`. Our preliminary observation suggests these quantities are whole units. 
        Confirming this will allow for a more efficient `INT` conversion.

	2.  Date Field Handling:
		`JoinDate` in `customer_profiles` and `TransactionDate` in `sales_transaction` were loaded as `VARCHAR(8)`. 
        To enable proper date-based calculations, filtering, and chronological analysis, 
        these columns need to be converted to a `DATE` datatype.

	3.  Missing Values:
		 A quick check indicated approximately 13 missing values (NULLs) in the `Location` column of the 
        `customer_profiles` table. This will require attention during data cleaning or analysis phases.

	These insights highlight the need for a Schema Refinement phase to optimize data storage, 
    improve data integrity, and facilitate more robust analytical queries.
*/


## Pre-processing and Schema Refinement

-- This crucial section focuses on enhancing the database schema for improved data integrity,
-- efficiency, and usability. It primarily addresses identified data type inconsistencies
-- and incorporates descriptive comments for clearer documentation of each column's purpose.

### Schema Modifications for `customer_profiles` Table

-- Modifying `CustomerID` column:
-- Converting `CustomerID` from DECIMAL to INT, as customer identifiers are typically non-fractional.
ALTER TABLE customer_profiles
MODIFY COLUMN CustomerID INT NOT NULL COMMENT 'Unique identifier for each customer, optimized for integer storage.';

-- Modifying `Age` column:
-- Converting `Age` from DECIMAL to INT, as age is universally represented in whole numbers.
ALTER TABLE customer_profiles
MODIFY COLUMN Age INT NOT NULL COMMENT 'Age of the customer, stored as a whole number of years.';

-- Modifying `JoinDate` column:
-- Converting `JoinDate` from VARCHAR to DATE, enabling proper date-time functions and chronological sorting.
ALTER TABLE customer_profiles
MODIFY COLUMN JoinDate DATE NOT NULL COMMENT 'Date when the customer joined the platform, formatted as YYYY-MM-DD.';

-- Verifying the updated schema for `customer_profiles`.
-- This command displays the refined structure of the table, confirming the changes.
DESC customer_profiles;

---

### Schema Modifications for `product_inventory` Table

/*
	As noted in our initial insights, the `StockLevel` column was observed to contain no fractional values.
	However, for large datasets, manual observation is impractical. The following query will programmatically
	verify if `StockLevel` truly lacks floating-point values, which is essential before converting it to `INT`
	to prevent any potential data loss.
*/

-- Pre-check for floating-point values in the 'StockLevel' column.
-- This query counts records where 'StockLevel' is explicitly defined as 'float' in the schema,
-- which helps confirm if a conversion to INT is safe from a schema perspective.
-- Note: This specifically checks the *current schema definition*, not the actual data content for fractional parts.
SELECT
    COUNT(*) AS Number_Of_Float_StockLevel_Columns 	-- Alias for clarity on the count result.
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_SCHEMA = 'retailanalysis' AND 			-- Filters results to the 'retailanalysis' database.
    COLUMN_NAME = 'StockLevel' AND     				-- Targets the 'StockLevel' column specifically.
    DATA_TYPE = 'float';           					-- Checks if the data type is currently 'float'.
-- If this query returns 0 (as expected based on initial manual observation for DECIMAL(38,0)),
-- it implies the column's definition doesn't use 'float' and its conversion to INT is generally safe 
-- if actual data is also whole numbers.

-- Modifying `ProductID` column:
-- Converting `ProductID` from DECIMAL to INT, as product identifiers are typically integer-based.
ALTER TABLE product_inventory
MODIFY COLUMN ProductID INT NOT NULL COMMENT 'Unique identifier for each product, optimized for integer storage.';

-- Modifying `StockLevel` column:
-- Converting `StockLevel` from DECIMAL to INT. This conversion is deemed safe given
-- the prior analysis suggesting no fractional quantities in stock counts.
ALTER TABLE product_inventory
MODIFY COLUMN StockLevel INT NOT NULL COMMENT 'Current quantity of the product in stock, stored as a whole number.';

-- Verifying the updated schema for `product_inventory`.
DESC product_inventory;

---

### Schema Modifications for `sales_transaction` Table

/*
	Similar to `StockLevel`, `QuantityPurchased` was initially observed without fractional values.
	The following query acts as a critical programmatic check to ensure no floating-point data
	exists within this column, thereby validating the safety of converting its datatype to `INT`.
*/

-- Pre-check for floating-point values in the 'QuantityPurchased' column.
-- This query examines the metadata to count if the 'QuantityPurchased' column is defined as 'float'.
-- A result of 0 confirms the column's schema is not 'float', paving the way for an INT conversion if data allows.
SELECT
    COUNT(*) AS NumberOfFloatQuantityPurchasedColumns -- Alias for clear interpretation of the count.
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_SCHEMA = 'retailanalysis' AND      	-- Limits the search to the 'retailanalysis' database.
    COLUMN_NAME = 'QuantityPurchased' AND    	-- Focuses on the 'QuantityPurchased' column.
    DATA_TYPE = 'float';                     	-- Checks if the data type is 'float'.
-- If this returns 0, it supports the decision to convert the column to INT, 
-- assuming the underlying data are whole numbers.

-- Modifying `TransactionID` column:
-- Converting `TransactionID` from DECIMAL to INT, as transaction identifiers are naturally whole numbers.
ALTER TABLE sales_transaction
MODIFY COLUMN TransactionID INT NOT NULL COMMENT 'Unique identifier for each sales transaction, stored as an integer.';

-- Modifying `CustomerID` column:
-- Converting `CustomerID` from DECIMAL to INT, ensuring consistency with the `customer_profiles` table 
-- and integer-based IDs.
ALTER TABLE sales_transaction
MODIFY COLUMN CustomerID INT NOT NULL COMMENT 'Identifier of the customer involved in the transaction, stored as an integer.';

-- Modifying `ProductID` column:
-- Converting `ProductID` from DECIMAL to INT, maintaining consistency with the `product_inventory` table and integer-based IDs.
ALTER TABLE sales_transaction
MODIFY COLUMN ProductID INT NOT NULL COMMENT 'Identifier of the product purchased in the transaction, stored as an integer.';

-- Modifying `QuantityPurchased` column:
-- Converting `QuantityPurchased` from DECIMAL to INT, assuming products are sold in whole units.
ALTER TABLE sales_transaction
MODIFY COLUMN QuantityPurchased INT NOT NULL COMMENT 'Number of units of the product purchased in this transaction, stored as a whole number.';

-- Modifying `TransactionDate` column:
-- Converting `TransactionDate` from VARCHAR to DATE, facilitating proper date-time operations and analysis.
ALTER TABLE sales_transaction
MODIFY COLUMN TransactionDate DATE NOT NULL COMMENT 'Date of the transaction, formatted as YYYY-MM-DD.';

-- Verifying the updated schema for `sales_transaction`.
DESC sales_transaction;

---
## Handling Missing Values: Initial Checks (NULLs and Empty Strings/Placeholders)

-- This section involves two common approaches to detect missing data:
-- 1. Using `COUNT(*) - COUNT(column_name)` to find explicit `NULL` values. This is reliable for any column type.
-- 2. Using `WHERE` clauses for `VARCHAR` columns to find empty strings (`''`) or whitespace strings (`' '`).
-- 3. Using `GROUP BY` with `HAVING COUNT(*) > 1` to find duplicate occurrences of *any* value, 
-- which might incidentally highlight repeated placeholder values if they exist, but PRIMARILY CHECKS FOR DUPLICATES.

### Checking for Explicit NULL Values

-- The `COUNT(*) - COUNT(column_name)` method explicitly identifies NULL values.
-- `COUNT(column_name)` counts only non-NULL values in that column, while `COUNT(*)` counts all rows.
-- The difference between these two counts reveals the exact number of NULLs in the specified column.

-- Target table: `customer_profiles` (Checking for NULLs across all columns)
SELECT
    COUNT(*) - COUNT(`CustomerID`) AS MissingCustomerIDCount, 	-- Counts NULLs in the CustomerID column.
    COUNT(*) - COUNT(`Age`) AS MissingAgeCount,               	-- Counts NULLs in the Age column.
    COUNT(*) - COUNT(`Gender`) AS MissingGenderCount,         	-- Counts NULLs in the Gender column.
    COUNT(*) - COUNT(`Location`) AS MissingLocationCount,     	-- Counts NULLs in the Location column.
    COUNT(*) - COUNT(`JoinDate`) AS MissingJoinDateCount,     	-- Counts NULLs in the JoinDate column.
    COUNT(*) AS TotalRowsInCustomerProfiles                   	-- Provides the total number of rows for context.
FROM
    customer_profiles;
/*
	Insight: 
		This query successfully identified NULL values in the `Location` column (e.g., 13 records in a previous run).
		All other columns (`CustomerID`, `Age`, `Gender`, `JoinDate`) are confirmed to be `NOT NULL` from the initial data load,
		hence their counts are expected to be 0 for explicit NULLs.
*/


-- Target table: `product_inventory` (Checking for NULLs across all columns)
SELECT
    COUNT(*) - COUNT(ProductID) AS NullProductIDCount,       	-- Counts NULLs in the ProductID column.
    COUNT(*) - COUNT(ProductName) AS NullProductNameCount,   	-- Counts NULLs in the ProductName column.
    COUNT(*) - COUNT(Category) AS NullCategoryCount,         	-- Counts NULLs in the Category column.
    COUNT(*) - COUNT(StockLevel) AS NullStockLevelCount,     	-- Counts NULLs in the StockLevel column.
    COUNT(*) - COUNT(Price) AS NullPriceCount,               	-- Counts NULLs in the Price column.
    COUNT(*) AS TotalRowsInProductInventory                  	-- Provides the total number of rows for context.
FROM
    product_inventory;
/*
	Insight: 
		All columns in `product_inventory` are defined as `NOT NULL`, 
        so this query is expected to return 0 for all 'Null_' counts, confirming no explicit NULLs in the loaded data.
*/


-- Target table: `sales_transaction` (Checking for NULLs across all columns)
SELECT
    COUNT(*) - COUNT(TransactionID) AS NullTransactionIDCount,       	-- Counts NULLs in the TransactionID column.
    COUNT(*) - COUNT(CustomerID) AS NullCustomerIDCount,             	-- Counts NULLs in the CustomerID column.
    COUNT(*) - COUNT(ProductID) AS NullProductIDCount,               	-- Counts NULLs in the ProductID column.
    COUNT(*) - COUNT(QuantityPurchased) AS NullQuantityPurchasedCount, 	-- Counts NULLs in the QuantityPurchased column.
    COUNT(*) - COUNT(TransactionDate) AS NullTransactionDateCount,   	-- Counts NULLs in the TransactionDate column.
    COUNT(*) - COUNT(Price) AS NullPriceCount,                       	-- Counts NULLs in the Price column.
    COUNT(*) AS TotalRowsInSalesTransaction                          	-- Provides the total number of rows for context.
FROM
    sales_transaction;
-- Insight: All columns in `sales_transaction` are defined as `NOT NULL`, so this query is expected to return 0 for all 'Null_' counts, confirming no explicit NULLs in the loaded data.

---

### Checking for Empty Strings or Whitespace (for VARCHAR/TEXT columns)

-- This method helps identify if "missing" values are represented as empty strings (`''`)
-- or strings consisting only of whitespace characters (`' '`, `'  '`, etc.).
-- This is particularly relevant for `VARCHAR` columns that might not contain explicit `NULL`s 
-- but still lack meaningful data.

-- Target table: `customer_profiles` (Checking for empty strings or whitespace in relevant columns)

-- Check `Gender` column for empty strings or strings with only spaces.
SELECT
    'Gender' AS ColumnName,        -- Labels the column being checked.
    COUNT(*) AS EmptyOrWhitespaceCount -- Counts occurrences of empty or whitespace-only strings.
FROM
    customer_profiles
WHERE
    TRIM(Gender) = '';             -- Filters for rows where Gender is an empty string after removing leading/trailing spaces.
-- Insight: Expected count to be 0 for `Gender`, as it's typically categorical and non-empty.

-- Check `Location` column for empty strings or strings with only spaces.
SELECT
    'Location' AS ColumnName,      -- Labels the column being checked.
    COUNT(*) AS EmptyOrWhitespaceCount -- Counts occurrences of empty or whitespace-only strings.
FROM
    customer_profiles
WHERE
    TRIM(Location) = '';           -- Filters for rows where Location is an empty string after trimming.
-- Observation: This query previously identified rows where 'Location' was an empty string (e.g., 13 rows).
-- Action (Previously taken): Rows with empty 'Location' values were deleted in a prior run, as 13 rows out of ~1000 was a small proportion.
-- DELETE FROM customer_profiles WHERE Location = ''; -- This statement was executed in a previous step.

-- Target table: `product_inventory` (Checking for empty strings or whitespace in relevant columns)

-- Check `ProductName` column for empty strings or strings with only spaces.
SELECT
    'ProductName' AS ColumnName,
    COUNT(*) AS EmptyOrWhitespaceCount
FROM
    product_inventory
WHERE
    TRIM(ProductName) = '';
-- Insight: Expected count to be 0 for `ProductName`, as product names should always be present.

-- Check `Category` column for empty strings or strings with only spaces.
SELECT
    'Category' AS ColumnName,
    COUNT(*) AS EmptyOrWhitespaceCount
FROM
    product_inventory
WHERE
    TRIM(Category) = '';
-- Insight: Expected count to be 0 for `Category`, as products should always belong to a category.

---

### Checking for Duplicate Values and Potential Placeholder Missing Values using `GROUP BY`

/*
	This method utilizes `GROUP BY` and `HAVING` to identify duplicate values within columns.
	While its primary purpose is to find duplicates of *any* value, it can incidentally reveal
	"missing" values if they are consistently represented by non-NULL placeholders that appear
	multiple times (e.g., a numerical column having many '0's used as a placeholder for missing,
	or a string column having many '[N/A]' entries). This approach is less direct for identifying
	empty strings or NULLs (which are better covered by the `WHERE TRIM(col) = ''` and `COUNT(*) - COUNT(col)` methods),
	but is useful for general data quality checks on value distribution.
*/

-- Target table: `customer_profiles` (Checking for duplicates in key columns)

-- Checking `CustomerID` column for duplicate IDs.
SELECT
    CustomerID,          -- Selects the CustomerID value.
    COUNT(*) AS DuplicateCount -- Counts how many times each CustomerID appears.
FROM
    customer_profiles
GROUP BY
    CustomerID           -- Groups rows by identical CustomerID values.
HAVING
    COUNT(*) > 1;        -- Filters to show only those CustomerIDs that appear more than once (i.e., duplicates).
-- Insight: CustomerID is expected to be a unique identifier. This query should return an empty set, 
-- confirming data integrity.

-- Checking `Age` column for duplicate Age values.
SELECT
    Age,                 -- Selects the Age value.
    COUNT(*) AS DuplicateCount -- Counts occurrences of each unique Age value.
FROM
    customer_profiles
GROUP BY
    Age                  -- Groups rows by identical Age values.
HAVING
    COUNT(*) > 1;        -- Filters to show ages that appear more than once.
-- Insight: This is expected to show many results as age values are commonly repeated across different customers. It's a normal occurrence and doesn't indicate missing data.

-- Checking `Gender` column for duplicate Gender values.
-- `LOWER()` standardizes case (e.g., 'Male' vs 'male') for accurate grouping of categorical data.
SELECT
    LOWER(Gender) AS StandardizedGender, -- Standardizes gender to lowercase for consistent grouping.
    COUNT(*) AS DuplicateCount         -- Counts occurrences of each unique standardized gender.
FROM
    customer_profiles
GROUP BY
    LOWER(Gender)                      -- Groups rows by the standardized (lowercase) Gender value.
HAVING
    COUNT(*) > 1;                      -- Filters to show genders that appear more than once.
-- Insight: Expected to show 'male' and 'female' (or other distinct categories) each with high counts, which is normal for categorical data and confirms expected values.

-- Checking `Location` column for duplicate Location values.
-- `LOWER()` standardizes case for consistent grouping of location codes.
SELECT
    LOWER(Location) AS StandardizedLocation, -- Standardizes location to lowercase for consistent grouping.
    COUNT(*) AS DuplicateCount             -- Counts occurrences of each unique standardized location.
FROM
    customer_profiles
GROUP BY
    LOWER(Location)                        -- Groups rows by the standardized (lowercase) Location value.
HAVING
    COUNT(*) > 1;                          -- Filters to show locations that appear more than once.
-- Insight: This helps understand the distribution of customers across locations and can identify if 'missing' placeholders (if not empty strings) are duplicated.

-- Checking `JoinDate` column for duplicate Join Dates.
-- `JoinDate` is now DATE type; `LOWER()` is not applicable. This finds if multiple customers joined on the same date.
SELECT
    JoinDate,            -- Selects the JoinDate value.
    COUNT(*) AS DuplicateCount -- Counts occurrences of each unique JoinDate.
FROM
    customer_profiles
GROUP BY
    JoinDate             -- Groups rows by identical JoinDate values.
HAVING
    COUNT(*) > 1;        -- Filters to show JoinDates that appear more than once.
-- Insight: Expected to show many results, as multiple customers can join on the same day. This is a normal observation.

-- Target table: `product_inventory` (Checking for duplicates in key columns)

-- Checking `ProductID` column for duplicate Product IDs.
-- ProductID should be unique. This query validates the uniqueness constraint.
SELECT
    ProductID,           -- Selects the ProductID value.
    COUNT(*) AS DuplicateCount -- Counts how many times each ProductID appears.
FROM
    product_inventory
GROUP BY
    ProductID            -- Groups rows by identical ProductID values.
HAVING
    COUNT(*) > 1;        -- Filters to show ProductIDs that appear more than once.
-- Insight: ProductID is expected to be a unique identifier. This query should return an empty set, confirming data integrity.

-- Checking `ProductName` column for duplicate Product Names.
-- Useful to identify if products have identical names, which might indicate duplicates or product variations.
SELECT
    LOWER(ProductName) AS StandardizedProductName, -- Standardizes product name to lowercase for consistent grouping.
    COUNT(*) AS DuplicateCount                   -- Counts occurrences of each unique standardized product name.
FROM
    product_inventory
GROUP BY
    LOWER(ProductName)                           -- Groups rows by the standardized (lowercase) ProductName value.
HAVING
    COUNT(*) > 1;                                -- Filters to show product names that appear more than once.
-- Insight: This helps identify if there are multiple entries for the same product name. Could reveal data entry issues or different product variants sharing a name.

-- Checking `Category` column for duplicate Category values.
-- `LOWER()` standardizes case for consistent grouping of categories.
SELECT
    LOWER(Category) AS StandardizedCategory, -- Standardizes category to lowercase for consistent grouping.
    COUNT(*) AS DuplicateCount             -- Counts occurrences of each unique standardized category.
FROM
    product_inventory
GROUP BY
    LOWER(Category)                        -- Groups rows by the standardized (lowercase) Category value.
HAVING
    COUNT(*) > 1;                          -- Filters to show categories that appear more than once.
-- Insight: Expected to show results for each category with high counts, which is normal for categorical data and confirms expected values.

-- Checking `StockLevel` column for duplicate StockLevel values.
-- This finds instances where the same stock quantity appears for multiple products.
SELECT
    StockLevel,          -- Selects the StockLevel value.
    COUNT(*) AS DuplicateCount -- Counts occurrences of each unique StockLevel value.
FROM
    product_inventory
GROUP BY
    StockLevel           -- Groups rows by identical StockLevel values.
HAVING
    COUNT(*) > 1;        -- Filters to show stock levels that appear more than once.
-- Insight: Expected to show many results, as various products can have the same stock quantity. 
-- This is a normal observation.

-- Target table: `sales_transaction` (Checking for duplicates in key columns)

-- Checking `TransactionID` for duplicate Transaction IDs.
-- TransactionID should be unique. This query validates the uniqueness constraint.
SELECT
    TransactionID,       -- Selects the TransactionID value.
    COUNT(*) AS DuplicateCount -- Counts how many times each TransactionID appears.
FROM
    sales_transaction
GROUP BY
    TransactionID        -- Groups rows by identical TransactionID values.
HAVING
    COUNT(*) > 1;        -- Filters to show TransactionIDs that appear more than once.
-- Insight: `TransactionID` is expected to be a unique identifier. This query should return an empty set, confirming data integrity.

-- Checking `TransactionDate` for duplicate Transaction Dates.
-- `TransactionDate` is now DATE type; `LOWER()` is not applicable. This finds if multiple transactions occurred on the same date.
SELECT
    TransactionDate,     -- Selects the TransactionDate value.
    COUNT(*) AS DuplicateCount -- Counts occurrences of each unique TransactionDate.
FROM
    sales_transaction
GROUP BY
    TransactionDate      -- Groups rows by identical TransactionDate values.
HAVING
    COUNT(*) > 1;        -- Filters to show TransactionDates that appear more than once.
-- Insight: Expected to show many results, as numerous transactions can occur on the same day. This is a normal observation.

-- Final verification of schema for `customer_profiles` (to confirm all modifications were applied).
DESC customer_profiles;

---

### Checking for Duplicate Values and Potential Placeholder Missing Values using `GROUP BY`

-- Identify duplicate rows in 'customer_profiles'.
-- Duplicates are defined by identical Age, Gender, Location, and JoinDate.
WITH DuplicateCustomers AS (
    SELECT
        CustomerID,              -- Selects the CustomerID.
        Age,                     -- Selects the Age.
        Gender,                  -- Selects the Gender.
        Location,                -- Selects the Location.
        JoinDate,                -- Selects the JoinDate.
        -- Assign a row number to each row within partitions defined by the columns
        -- we consider for duplication. The ORDER BY clause ensures consistent numbering
        -- if there are multiple identical rows.
        ROW_NUMBER() OVER (
            PARTITION BY Age, Gender, Location, JoinDate -- Groups rows with identical Age, Gender, Location, and JoinDate combinations.
            ORDER BY CustomerID                          -- Orders rows within each group by CustomerID (for consistent 'rn' assignment).
        ) AS rn                  -- Assigns the calculated row number an alias 'rn'.
    FROM
        customer_profiles        -- Specifies the table from which to retrieve data.
)
-- Select only those rows where 'rn' (row number) is greater than 1,
-- indicating they are duplicates based on our defined criteria.
SELECT *
FROM DuplicateCustomers
WHERE rn > 1;
/*
	Insight: 
		This query is designed to find records where customers have identical demographic and join date information.
		It allows us to identify if there are multiple `CustomerID`s associated with what appears to be the same customer profile.
		A non-empty result set here would indicate potential data entry errors or logical duplicates requiring further investigation.
*/

---

-- Identify duplicate rows in 'product_inventory'.
-- Duplicates are defined by identical ProductName, Category, and StockLevel.
WITH DuplicateProducts AS (
    SELECT
        ProductID,               -- Selects the ProductID.
        ProductName,             -- Selects the ProductName.
        Category,                -- Selects the Category.
        StockLevel,              -- Selects the StockLevel.
        -- Assign a row number based on the specified columns for duplicate detection.
        ROW_NUMBER() OVER (
            PARTITION BY ProductName, Category, StockLevel -- Groups products with identical names, categories, and stock levels.
            ORDER BY ProductID                           -- Orders products within each group by ProductID for consistent numbering.
        ) AS rn                  -- Assigns the calculated row number an alias 'rn'.
    FROM
        product_inventory        -- Specifies the table from which to retrieve data.
)
-- Select rows identified as duplicates (where 'rn' is greater than 1).
SELECT *
FROM DuplicateProducts
WHERE rn > 1;
/*
	Insight: 
		This query helps identify if multiple `ProductID`s exist for products that are otherwise identical
		in terms of their name, category, and current stock level. Such duplicates might suggest data redundancy
		or errors in product cataloging.
*/

---

-- Identify duplicate rows in 'sales_transaction'.
-- Duplicates are defined by identical TransactionID, CustomerID, ProductID, and QuantityPurchased.
WITH DuplicateTransactions AS (
    SELECT
        TransactionID,           -- Selects the TransactionID.
        CustomerID,              -- Selects the CustomerID.
        ProductID,               -- Selects the ProductID.
        QuantityPurchased,       -- Selects the QuantityPurchased.
        -- Assign a row number within partitions of identical transaction details.
        ROW_NUMBER() OVER (
            PARTITION BY TransactionID, CustomerID, ProductID, QuantityPurchased -- Groups transactions with identical core details.
            ORDER BY TransactionID                                            -- Orders transactions within each group by TransactionID for consistent numbering.
        ) AS rn                  -- Assigns the calculated row number an alias 'rn'.
    FROM
        sales_transaction        -- Specifies the table from which to retrieve data.
)
-- Select rows where 'rn' is greater than 1, indicating a duplicate.
SELECT *
FROM DuplicateTransactions
WHERE rn > 1;
/*
	Insight: This query is crucial for identifying records that are exact duplicates of sales transactions.
	It helps detect if the same transaction (identified by `TransactionID`, `CustomerID`, `ProductID`, and `QuantityPurchased`)
	was recorded multiple times. A non-empty result set signifies data integrity issues that need to be addressed.
	(Previous runs identified 2 such duplicate records in 'sales_transaction').
*/

---

-- You correctly identified two duplicate values in 'sales_transaction' based on the previous query.

-- DELETE statement to remove duplicate rows from 'sales_transaction'.
-- This query aims to remove rows where the combination of TransactionID, CustomerID, ProductID,
-- and QuantityPurchased is duplicated, keeping only one instance (the one with rn=1).
-- It uses a multi-column IN clause to precisely target and delete only the duplicate records.

-- The above commented-out DELETE statement has a logical flaw:
-- It attempts to delete based on `TransactionID IN (...)`, which might delete all instances
-- of a transaction if any part of it is duplicated (i.e., both the original and duplicates),
-- not just the redundant duplicate rows.

-- A more precise way to delete only the duplicate occurrences (keeping one) is:
DELETE FROM sales_transaction -- Specifies the target table for deletion.
WHERE (TransactionID, CustomerID, ProductID, QuantityPurchased) IN ( -- Deletes rows where the combination of these columns matches.
    SELECT TransactionID, CustomerID, ProductID, QuantityPurchased -- Selects the specific combinations identified as duplicates.
    FROM (
        SELECT
            TransactionID,
            CustomerID,
            ProductID,
            QuantityPurchased,
            -- Recalculates row numbers within the subquery to identify duplicates to be removed.
            ROW_NUMBER() OVER (PARTITION BY TransactionID, CustomerID, ProductID, QuantityPurchased ORDER BY TransactionID) AS rn
        FROM
            sales_transaction
    ) AS SubqueryWithRowNumbers -- Alias for the inner derived table.
    WHERE rn > 1 -- Filters to select only those rows that are identified as duplicates (i.e., not the first occurrence).
);
/*
	Insight: 
		This `DELETE` statement effectively cleans the `sales_transaction` table by removing all duplicate records
		based on the defined criteria (`TransactionID`, `CustomerID`, `ProductID`, `QuantityPurchased`).
		By targeting only records where `rn > 1`, it ensures that one valid instance of each unique transaction is preserved,
		thereby improving the accuracy and integrity of the sales data.
		(This action would have removed the 2 duplicate records identified previously).
*/

### Handling Price Discrepancies

-- Identify price discrepancies between `sales_transaction` and `product_inventory`.
-- This query aims to highlight transactions where the unit price recorded at the time of sale
-- in `sales_transaction` does not match the current listed price in the `product_inventory` table.
SELECT
    st.TransactionID,                -- Selects the unique identifier for each sales transaction.
    st.ProductID,                    -- Selects the product identifier from the sales transaction.
    pi.ProductName,                  -- Selects the product name from the product inventory.
    pi.Category,                     -- Selects the product category from the product inventory.
    st.QuantityPurchased,            -- Selects the quantity of the product purchased in the transaction.
    st.Price AS TransactionPricePerUnit, -- Selects the price recorded in the sales transaction, aliased for clarity.
    pi.Price AS InventoryPrice,      -- Selects the current price from the product inventory, aliased for clarity.
    (st.Price - pi.Price) AS PriceDifference -- Calculates the monetary difference between the transaction price and inventory price.
FROM
    sales_transaction AS st          -- Specifies the `sales_transaction` table, aliased as 'st' for brevity.
JOIN
    product_inventory AS pi          -- Joins with the `product_inventory` table, aliased as 'pi'.
    ON st.ProductID = pi.ProductID   -- Links transactions to products using their common ProductID.
WHERE
    st.Price <> pi.Price;            -- Filters the results to show only transactions where the prices do not match.
/*
	Insight: This query reveals discrepancies in pricing, which could be due to price changes over time,
	promotions, or data entry errors. The `PriceDifference` column helps quantify the extent of these discrepancies.
	Addressing these ensures that historical transaction data accurately reflects the product's price at the time of sale
	or aligns it with current inventory pricing policies.
*/

-- Correct price discrepancies in `sales_transaction`.
-- This `UPDATE` statement will set the `Price` in the `sales_transaction` table to match the current `Price`
-- in the `product_inventory` table for all identified discrepancies. This standardizes historical prices
-- to the most recent inventory price, which might be a business decision (e.g., for reporting consistency).
UPDATE sales_transaction AS st       -- Specifies the `sales_transaction` table to be updated, aliased as 'st'.
SET st.Price = (                     -- Sets the 'Price' column in `sales_transaction`.
    SELECT pi.Price                  -- Subquery to select the current price from `product_inventory`.
    FROM product_inventory AS pi     -- Specifies the `product_inventory` table for the subquery, aliased as 'pi'.
    WHERE pi.ProductID = st.ProductID -- Links the subquery to the outer query using ProductID to find the correct product price.
)
WHERE EXISTS (                       -- Ensures that the update only happens if a discrepancy exists for the product.
    SELECT 1                         -- Checks for the existence of a matching record in `product_inventory` with a price mismatch.
    FROM product_inventory AS pi     -- Specifies `product_inventory` for the EXISTS subquery.
    WHERE pi.ProductID = st.ProductID -- Links `product_inventory` to `sales_transaction`.
      AND st.Price <> pi.Price       -- Only update where there's a discrepancy between the sales transaction price and inventory price.
);
/*
	Insight: This `UPDATE` operation standardizes the `Price` column in `sales_transaction` for all records
	where a mismatch was found. By aligning the transaction price with the `product_inventory` price,
	it ensures consistency across datasets, which is crucial for accurate financial reporting and analysis.
	The choice to update historical prices to current prices should be driven by business requirements.
*/

------------------------------------------------------------------------------------------------------------------------

-- SQL Queries for Exploratory Data Analysis (EDA)

-- This script contains SQL queries to help you understand the structure, patterns,
-- and relationships within your customer, product, and sales data.

---

### 1. Summary Statistics and Univariate Analysis

-- This section focuses on understanding the distribution and basic statistics
-- of columns within each table individually. It's like taking a peek at the individual ingredients
-- before mixing them into a dish to ensure they're all in good shape.

#### A. `customer_profiles` Table

-- Query to get the total number of customers in the table.
-- This gives a fundamental understanding of the size of our customer base.
SELECT
    COUNT(CustomerID) AS TotalCustomers 
FROM
    customer_profiles; 
/*
	Insight:
		This metric provides the absolute size of our customer base. 
		It's the foundational number for any customer-centric analysis, allowing us to gauge scale.
*/ 


-- Query to get descriptive statistics for the 'Age' column: minimum, maximum,
-- average, and standard deviation. These statistics help understand the age distribution of our customers.
SELECT
    MIN(Age) AS MinAge,               		-- Identifies the youngest customer's age recorded.
    MAX(Age) AS MaxAge,               		-- Identifies the oldest customer's age recorded.
    ROUND(AVG(Age), 2) AS AverageAge, 		-- Calculates the average age of all customers, rounded to two decimal places.
    ROUND(STDDEV(Age), 2) AS StdDevAge 		-- Measures the typical deviation of ages from the average, rounded to two decimal places.
FROM
    customer_profiles;
/*
	Insight: 
		Understanding the age range and average age helps segment customers for targeted marketing. 
		A high standard deviation suggests a diverse age group, indicating a broad appeal across generations, 
		while a low one points to a more homogeneous customer base.
*/


-- Query to show the distribution of customers by 'Gender', including counts
-- and the percentage of each gender relative to the total customer base.
-- This highlights the gender composition of our customer base.
SELECT
    Gender,                                                 -- Groups the results by the 'Gender' column.
    COUNT(CustomerID) AS NumberOfCustomers,                 -- Counts the number of customers for each gender.
    ROUND((COUNT(CustomerID) * 100.0 / (SELECT COUNT(*) FROM customer_profiles)), 2) AS Percentage 	-- Calculates the percentage of total customers for each gender.
FROM
    customer_profiles 
GROUP BY
    Gender
ORDER BY
    NumberOfCustomers DESC; -- Orders the results to show the most prevalent genders first.
/*
	Insight: 
		This analysis reveals the gender breakdown of our customers. 
        Such insights are crucial for tailoring marketing messages, product assortments, 
        and potentially identifying underserved gender segments.
*/


-- Query to show the distribution of customers by 'Location', including counts
-- and the percentage of customers in each location.
-- This helps identify key geographical markets for our business.
SELECT
    Location,                                               -- Groups the results by the 'Location' column.
    COUNT(CustomerID) AS NumberOfCustomers,                 -- Counts the number of customers in each location.
    ROUND((COUNT(CustomerID) * 100.0 / (SELECT COUNT(*) FROM customer_profiles)), 2) AS Percentage -- Calculates the percentage of total customers residing in each location.
FROM
    customer_profiles
GROUP BY
    Location
ORDER BY
    NumberOfCustomers DESC; -- Orders the results to highlight locations with the highest customer concentration.
/*
	Insight: **Geographical distribution** is vital for understanding market penetration 
    and identifying regions for expansion or focused marketing campaigns. 
    High customer counts in specific locations might warrant localized promotions 
    or even physical store considerations.
*/


-- Query to count the number of customers who joined in each year, ordered by year.
-- This provides insight into customer acquisition trends over time.
SELECT
    YEAR(JoinDate) AS JoinYear,                     -- Extracts the year from the 'JoinDate' column.
    COUNT(CustomerID) AS NumberOfCustomersJoined    -- Counts customers who joined in that specific year.
FROM
    customer_profiles 
GROUP BY
    JoinYear
ORDER BY
    JoinYear; -- Orders the results chronologically by join year.
/*
	Insight: 
		Analyzing **customer acquisition trends by year** helps track growth patterns 
        and can be correlated with historical marketing efforts, economic conditions, or major product launches. 
        It identifies periods of high or low customer influx.
*/

---

#### B. `product_inventory` Table

-- Query to get the total number of unique products in the inventory.
-- This indicates the breadth of our product catalog.
SELECT
    COUNT(ProductID) AS TotalProducts -- Counts every ProductID to get the total count of unique products.
FROM
    product_inventory;
/*
	Insight:
		This fundamental metric tells us the **total variety of products** we currently hold in our inventory. 
        It's a quick measure of the scale of our product offerings.
*/


-- Query to get descriptive statistics for 'StockLevel': minimum, maximum,
-- average, and standard deviation. These statistics indicate the availability and variability of product stock.
SELECT
    MIN(StockLevel) AS MinStockLevel,             		-- Identifies the lowest stock quantity for any product.
    MAX(StockLevel) AS MaxStockLevel,             		-- Identifies the highest stock quantity for any product.
    ROUND(AVG(StockLevel), 2) AS AverageStockLevel, 	-- Calculates the average stock level across all products, rounded to two decimal places.
    ROUND(STDDEV(StockLevel), 2) AS StdDevStockLevel 	-- Measures the typical deviation of stock levels from the average, rounded to two decimal places.
FROM
    product_inventory;
/*
	Insight:
		**Stock level statistics** are crucial for inventory management. 
        A very low minimum stock level might indicate potential stock-out risks, while the average 
        and standard deviation help assess overall inventory health and variability in stock quantities across products.
*/


-- Query to get descriptive statistics for 'Price' (product price): minimum, maximum,
-- average, and standard deviation. This helps understand the pricing strategy and range of products.
SELECT
    MIN(Price) AS MinPrice,             	-- Identifies the lowest price for any product in inventory.
    MAX(Price) AS MaxPrice,             	-- Identifies the highest price for any product in inventory.
    ROUND(AVG(Price), 2) AS AveragePrice, 	-- Calculates the average price of all products, rounded to two decimal places.
    ROUND(STDDEV(Price), 2) AS StdDevPrice 	-- Measures the typical deviation of prices from the average, rounded to two decimal places.
FROM
    product_inventory;
/*
	Insight: 
		**Price statistics** provide an overview of the product pricing structure. 
        This can inform pricing strategies, competitive analysis, 
        and identifying product tiers (e.g., budget, mid-range, premium offerings).
*/

-- Query to show the distribution of products by 'Category', including counts
-- and the percentage of products in each category. This highlights popular product categories.
SELECT
    Category,                                               -- Groups the results by the 'Category' column.
    COUNT(ProductID) AS NumberOfProducts,                 -- Counts the number of products within each category.
    ROUND((COUNT(ProductID) * 100.0 / (SELECT COUNT(*) FROM product_inventory)), 2) AS Percentage -- Calculates the percentage of total products belonging to each category.
FROM
    product_inventory AS pi
GROUP BY
    pi.Category
ORDER BY
    NumberOfProducts DESC; -- Orders the results to highlight categories with the most products.
/*
	Insight: 
    **Product category distribution** helps us understand the breadth and depth of our product offerings. 
    It reveals which categories are most saturated in our inventory and can guide future procurement 
    and merchandising decisions.
*/


-- Query to calculate the average price for products within each category,
-- ordered from highest to lowest average price.
-- This identifies which categories command higher price points.
SELECT
    Category,                             -- Groups the results by product 'Category'.
    ROUND(AVG(Price), 2) AS AveragePrice -- Calculates the average price for products in each category, rounded to two decimal places.
FROM
    product_inventory
GROUP BY
    Category
ORDER BY
    AveragePrice DESC; -- Orders the results to show categories with higher average prices first.
/*
	Insight: 
		This analysis highlights **which product categories command higher average prices**, 
        providing insights into potential profitability per category and where our premium offerings lie.
*/


#### C. `sales_transaction` Table

-- Query to get the total number of sales transactions recorded.
-- This gives an overall count of all individual sales line items.
SELECT
    COUNT(TransactionID) AS TotalSalesLineItems -- Counts every row, representing each item in a transaction.
FROM
    sales_transaction; 
/*
	Insight: 
		This gives us the **total volume of sales activities at a granular, line-item level**. 
        It's important to distinguish this from the count of unique transactions.
*/


-- Total Number of Transactions: Counts the unique transaction IDs.
-- This provides the actual number of distinct sales events, regardless of how many items were in each.
SELECT
    COUNT(DISTINCT TransactionID) AS TotalNumberOfUniqueTransactions -- Counts only distinct TransactionIDs to get unique sales events.
FROM
    sales_transaction;
/*
	Insight: 
		This reveals the **true number of unique sales events** that occurred. 
        It's a critical metric for understanding sales volume at a transaction level, 
        separate from the number of individual items sold.
*/


-- Query to show the distribution of 'QuantityPurchased' per transaction line item,
-- including counts and their respective percentages.
-- This helps understand common purchase quantities for individual items.
SELECT
    QuantityPurchased,                                                 -- Groups the results by the quantity purchased in a single line item.
    COUNT(TransactionID) AS NumberOfTransactions,                      -- Counts how many line items involve this specific quantity.
    ROUND((COUNT(TransactionID) * 100.0 / (SELECT COUNT(*) FROM sales_transaction)), 2) AS Percentage -- Calculates the percentage of line items with this quantity.
FROM
    sales_transaction
GROUP BY
    QuantityPurchased
ORDER BY
    st.QuantityPurchased; -- Orders the results by quantity for easy distribution viewing.
/*
	Insight: 
		This distribution helps understand **typical single-item purchase quantities**. 
        For instance, if '1' is the most frequent quantity, it suggests that single-item purchases are very common, 
        which could influence bundling strategies or promotional offers.
*/


-- Query to get descriptive statistics for the 'Price' (item price in transaction):
-- minimum, maximum, average, and standard deviation.
-- These statistics reflect the actual prices at which items were sold.
SELECT
    MIN(Price) AS MinTransactionPrice,             -- Identifies the lowest price an item was sold for in a transaction.
    MAX(Price) AS MaxTransactionPrice,             -- Identifies the highest price an item was sold for in a transaction.
    ROUND(AVG(Price), 2) AS AverageTransactionPrice, -- Calculates the average price of an item across all transactions, rounded to two decimal places.
    ROUND(STDDEV(Price) , 2)AS StdDevTransactionPrice -- Measures the typical deviation of actual transaction prices from the average.
FROM
    sales_transaction AS st;
/*
	Insight: 
		These metrics tell us about the **pricing landscape of items as they were actually sold**. 
        They can reveal price points that customers are most willing to pay 
        and may differ slightly from `product_inventory` prices if the price correction aligns all historical prices 
        to the current inventory price.
*/


-- Query to calculate the total sales revenue and number of transactions per month.
-- This provides a time-series view of sales performance.
SELECT
    DATE_FORMAT(TransactionDate, '%Y-%m') AS SalesMonth, -- Formats the transaction date to 'YYYY-MM' for grouping by month.
    SUM(QuantityPurchased * Price) AS TotalRevenue,   -- Calculates the total revenue for each month.
    COUNT(DISTINCT TransactionID) AS NumberOfTransactions -- Counts the unique transactions that occurred in each month.
FROM
    sales_transaction 
GROUP BY
    SalesMonth
ORDER BY
    SalesMonth; -- Orders the results chronologically by sales month for trend analysis.
/*
	Insight: 
		**Monthly sales trends** are critical for identifying seasonality, 
        long-term growth or decline, and the impact of marketing campaigns or external factors on sales performance. 
        This is a key metric for strategic planning and budgeting.
*/


---

### 2. Derived Metrics

-- This section involves **calculating new metrics from existing data** to gain deeper insights.
-- These derived metrics are often more directly interpretable for business analysis and decision-making.

-- Query to calculate the 'LineItemRevenue' for each transaction by multiplying
-- 'QuantityPurchased' by 'Price'.
-- This provides the revenue generated by each individual item within a transaction.
SELECT
    TransactionID,          -- The unique identifier for the transaction.
    CustomerID,             -- The customer who made the purchase in this transaction.
    ProductID,              -- The product that was purchased in this specific line item.
    QuantityPurchased,      -- The number of units of the product purchased in this line item.
    Price,                  -- The price per unit at the time of this transaction.
    (QuantityPurchased * Price) AS TotalItemRevenue -- Calculates the total revenue generated by this single line item.
FROM
    sales_transaction;
/*
	Insight: 
		This provides a **granular view of revenue contribution at the individual item level within each transaction**. 
        It's a foundational step for understanding which specific purchases contributed how much.
*/


-- Query to find the top 10 products with the highest total revenue generated,
-- ordered in descending order. These are our "cash cows" – the products that bring in the most money.
SELECT
    ProductID,                                  -- The identifier for the product.
    SUM(QuantityPurchased * Price) AS TotalRevenue -- Sums the revenue for all sales of this particular product.
FROM
    sales_transaction 
GROUP BY
    ProductID
ORDER BY
    TotalRevenue DESC
LIMIT 10; -- Restricts the output to the top 10 products by revenue.
/*
	Insight: 
		Identifying **top-revenue-generating products** is crucial for inventory prioritization, 
        strategic marketing focus, and identifying categories that are most profitable. 
        These products are likely our most valuable offerings.
*/


-- Query to find the top 10 products with the highest total quantity sold,
-- ordered in descending order. These are our "most popular items by volume" – indicating high demand.
SELECT
    ProductID,                                 -- The identifier for the product.
    SUM(QuantityPurchased) AS TotalQuantitySold -- Sums the total quantity sold for all sales of this product.
FROM
    sales_transaction
GROUP BY
    ProductID
ORDER BY
    TotalQuantitySold DESC
LIMIT 10; -- Restricts the output to the top 10 products by quantity sold.
/*
	Insight: 
		This analysis highlights products that are **sold in high volumes**, 
        even if their individual price isn't the highest. 
        It helps us understand raw customer demand and can guide supply chain optimization for these fast-moving items.
*/


-- Query to find the top 10 customers with the highest total spending,
-- ordered in descending order. These are our "most valuable customers" in terms of monetary contribution.
SELECT
    CustomerID,                                -- The identifier for the customer.
    SUM(QuantityPurchased * Price) AS TotalSpending -- Sums the total money spent by each customer across all their transactions.
FROM
    sales_transaction 
GROUP BY
    CustomerID
ORDER BY
    TotalSpending DESC
LIMIT 10; -- Restricts the output to the top 10 highest-spending customers.
/*
	Insight: 
		Identifying **high-spending customers** is vital for loyalty programs, personalized outreach (e.g., exclusive offers), 
        and understanding the characteristics of a valuable customer segment. 
        These customers are key to long-term revenue and customer retention strategies.
*/

---

### 3. Cross-Table Analysis

-- This section involves **joining tables to analyze relationships and derive insights across different datasets**
-- (customer, product, and sales). This is where the magic happens, connecting disparate pieces of data to tell a richer story about our business.

-- Query to calculate the total revenue generated, grouped by customer gender.
-- This helps understand which gender demographic contributes more to overall sales.
SELECT
    cp.Gender,                                          -- Groups the results by customer 'Gender'.
    SUM(st.QuantityPurchased * st.Price) AS TotalRevenue -- Calculates the total revenue for each gender.
FROM
    sales_transaction AS st                          -- Starts with the sales transaction table.
JOIN
    customer_profiles AS cp ON st.CustomerID = cp.CustomerID -- Joins with customer_profiles on matching CustomerIDs.
GROUP BY
    cp.Gender
ORDER BY
    TotalRevenue DESC; -- Orders the results to show the gender with the highest revenue contribution first.
/*
	Insight: 
		This analysis can inform **gender-specific marketing strategies or product development**. 
        If there's a significant imbalance, it might indicate an opportunity to target the underperforming segment 
        or further capitalize on the dominant one.
*/


-- Query to calculate the total revenue generated, grouped by customer location.
-- This helps pinpoint the geographical areas that are most lucrative for our business.
SELECT
    cp.Location,                                        -- Groups the results by customer 'Location'.
    SUM(st.QuantityPurchased * st.Price) AS TotalRevenue -- Calculates the total revenue for each location.
FROM
    sales_transaction AS st
JOIN
    customer_profiles AS cp ON st.CustomerID = cp.CustomerID
GROUP BY
    cp.Location
ORDER BY
    TotalRevenue DESC; -- Orders the results to identify top-performing locations by revenue.
/*
	Insight: 
		Understanding **revenue by location** is crucial for regional sales planning, 
        targeted geographical marketing campaigns, and even considering the placement of future physical stores 
        or distribution hubs.
*/


-- Query to calculate the total revenue generated, grouped by product category.
-- This helps identify which product categories are driving the most sales and contributing significantly to revenue.
SELECT
    pi.Category,                                        -- Groups the results by product 'Category'.
    SUM(st.QuantityPurchased * st.Price) AS TotalRevenue -- Calculates the total revenue for each product category.
FROM
    sales_transaction AS st
JOIN
    product_inventory AS pi ON st.ProductID = pi.ProductID -- Joins with product_inventory on matching ProductIDs.
GROUP BY
    pi.Category
ORDER BY
    TotalRevenue DESC; -- Orders the results to highlight top-contributing categories by revenue.
/*
	Insight: 
		Analyzing **revenue by product category** provides insight into the profitability 
        and popularity of different product lines. 
        This guides inventory management, marketing focus, and strategic product development decisions.
*/


-- Query to calculate the average quantity of items purchased per transaction line item,
-- grouped by product category. This indicates typical basket sizes for different product types.
SELECT
    pi.Category,                                          -- Groups the results by product 'Category'.
    ROUND(AVG(st.QuantityPurchased), 2) AS AverageQuantityPurchased -- Calculates the average quantity purchased for items within each category, rounded to two decimal places.
FROM
    sales_transaction AS st
JOIN
    product_inventory AS pi ON st.ProductID = pi.ProductID
GROUP BY
    pi.Category
ORDER BY
    AverageQuantityPurchased DESC; -- Orders the results to see which categories have larger average purchases per line item.
/*
	Insight: 
		This metric can inform **cross-selling and up-selling strategies**. 
        For categories with a higher average quantity, 
        bundling products might be effective, while low average quantities might suggest single-item purchase behavior.
*/


-- Query to calculate the total revenue generated, grouped by customer age group.
-- Age groups are defined using a CASE statement for categorization.
-- This helps understand spending patterns across different demographic age segments.
SELECT
    CASE                                                   -- Defines custom age groups for more structured analysis.
        WHEN cp.Age < 18 THEN '<18'
        WHEN cp.Age BETWEEN 18 AND 24 THEN '18-24'
        WHEN cp.Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN cp.Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN cp.Age BETWEEN 45 AND 54 THEN '45-54'
        WHEN cp.Age BETWEEN 55 AND 64 THEN '55-64'
        ELSE '65+'                                         -- Catches all ages 65 and above.
    END AS AgeGroup,                                       -- Assigns the calculated age group label.
    SUM(st.QuantityPurchased * st.Price) AS TotalRevenue   -- Calculates the total revenue generated by each age group.
FROM
    sales_transaction AS st
JOIN
    customer_profiles AS cp ON st.CustomerID = cp.CustomerID
GROUP BY
    AgeGroup                                               -- Groups the results by the defined AgeGroup.
ORDER BY TotalRevenue DESC; -- Ordering by TotalRevenue helps prioritize high-contributing age groups.
/*
	Insight: 
		**Age-based revenue analysis** is powerful for demographic targeting. 
        It helps identify the most valuable age segments and allows for tailoring product offerings, 
        marketing messages, or even store experiences specifically for them.
*/

---

### 4. Detailed Retail Analysis and Dashboard Metrics

-- This script provides comprehensive SQL queries to generate metrics suitable for a retail analysis dashboard,
-- covering sales performance, customer insights, product performance, and sales trends.
-- These are designed to be easily digestible for business decision-makers.

#### 1. Overall Sales Performance Metrics

-- These queries provide high-level summaries of the sales performance, acting as **key performance indicators (KPIs)**.

-- Total Revenue Generated: Calculates the sum of (QuantityPurchased * Price) across all transactions.
-- This is the most fundamental and critical sales performance metric.
SELECT
    SUM(QuantityPurchased * Price) AS TotalRevenue -- Sums the total value of all sales transactions.
FROM
    sales_transaction;
/*
	Insight: 
		The **grand total of all sales revenue**, indicating the overall financial success of the retail operations during 
        the recorded period. This is the ultimate bottom-line number for sales.
*/


-- Average Transaction Value: Calculates the average revenue per distinct transaction.
-- This is derived by summing total revenue and dividing by the count of distinct transactions.
SELECT
    ROUND(SUM(QuantityPurchased * Price) / COUNT(DISTINCT st.TransactionID), 2) AS AverageTransactionValue -- Calculates the average monetary value for each unique sale.
FROM
    sales_transaction;
/*
	Insight: 
		This metric indicates the **typical amount a customer spends in a single shopping trip**. 
        An increasing average transaction value suggests successful upselling, bundling, 
        or a shift towards higher-value product purchases.
*/


-- Number of Unique Customers Who Made Purchases: Counts distinct CustomerIDs from sales transactions.
-- This tells us the size of our actively purchasing customer base during the period.
SELECT
    COUNT(DISTINCT CustomerID) AS NumberOfUniqueCustomers -- Counts how many individual customers have made at least one purchase.
FROM
    sales_transaction;
/*
	Insight: 
		Provides a clear picture of the **breadth of customer engagement**. 
        A growing number of unique customers signifies successful acquisition efforts and a widening market reach.
*/


-- Number of Unique Products Sold: Counts distinct ProductIDs involved in sales transactions.
-- This shows the variety of products that customers are buying from our inventory.
SELECT
    COUNT(DISTINCT ProductID) AS NumberOfUniqueProductsSold -- Counts how many different products have been sold across all transactions.
FROM
    sales_transaction;
/*
	Insight: 
		This metric indicates the **diversity of products that resonate with customers**. 
        A higher number suggests a well-distributed product interest, 
        while a low number might point to reliance on a few best-sellers, 
        potentially signaling a need for product diversification.
*/

---

### 2. Customer-Centric Analysis

-- These queries provide deeper insights into customer demographics and their purchasing behavior,
-- helping to identify and cater to different customer segments.

-- Most Active Customers (Top 10 by Total Spending): Identifies customers who have spent the most.
-- These are our most valuable customers in terms of monetary contribution.
SELECT
    st.CustomerID,                                         -- The ID of the top-spending customer.
    SUM(st.QuantityPurchased * st.Price) AS TotalSpending  -- Calculates their total expenditure across all their purchases.
FROM
    sales_transaction AS st
JOIN
    customer_profiles AS cp ON st.CustomerID = cp.CustomerID -- Joins to link sales data with customer demographic information (though not directly used in the aggregate).
GROUP BY
    st.CustomerID
ORDER BY
    TotalSpending DESC
LIMIT 10; -- Focuses on the top 10 highest spenders.
/*
	Insight: 
		Knowing your **top-spending customers** is vital for loyalty programs, 
        personalized outreach (e.g., exclusive offers), 
        and understanding the characteristics that define your most valuable customer segments.
*/


-- Customers with More than One Purchase: Identifies repeat customers, a key indicator of loyalty.
SELECT
    cp.CustomerID,
    cp.Age,
    cp.Gender,
    cp.Location,
    cp.JoinDate,
    COUNT(st.TransactionID) AS NumberOfTransactions
FROM
    customer_profiles cp
JOIN
    sales_transaction st ON cp.CustomerID = st.CustomerID
GROUP BY
    cp.CustomerID, cp.Age, cp.Gender, cp.Location, cp.JoinDate
HAVING
    COUNT(st.TransactionID) > 1 -- Filters for customers who have more than one transaction.
ORDER BY
    NumberOfTransactions DESC, cp.CustomerID;
/*
	Insight: 
		This query identifies **repeat customers**, a crucial segment for loyalty programs and retention strategies. 
        Understanding their demographics and purchase frequency helps in fostering long-term relationships.
*/

---

### 3. Product Performance Analysis

-- Products with Low Stock: Identifies products whose current stock level falls below a specified threshold.
-- This is critical for proactive inventory management and preventing potential stock-outs and lost sales.
SELECT
    pi.ProductID,          -- The unique identifier for the product.
    pi.ProductName,        -- The descriptive name of the product.
    pi.Category,           -- The category the product belongs to.
    pi.StockLevel          -- The current quantity of the product in stock.
FROM
    product_inventory AS pi
WHERE
    pi.StockLevel < 50     -- **Define your 'low stock' threshold here.** This value should be dynamic and determined by business needs (e.g., based on average daily sales and lead time for replenishment).
ORDER BY
    pi.StockLevel ASC;     -- Orders the results by stock level, showing the most critically low items first.
/*
	Insight: 
		This query is a direct **operational tool for inventory management**. 
        It helps identify products at risk of selling out, 
        prompting reorder decisions to ensure continuous availability and prevent lost sales due to insufficient stock.
*/


-- Top 5 Most Purchased Products by Quantity (across all transactions):
-- This provides insight into which products are most frequently added to customer baskets.
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
/*
	Insight: 
		Understanding the **top-selling products by quantity** is different from revenue. 
        These are items that fly off the shelves, potentially indicating high demand, everyday essentials, 
        or successful low-price point items. This helps optimize inventory flow and promotional bundling.
*/


-- Products with Zero Sales: Identifies products that are currently in stock but have not been sold.
-- This helps identify dead stock or products that require more marketing attention.
SELECT
    pi.ProductID,
    pi.ProductName,
    pi.Category,
    pi.StockLevel
FROM
    product_inventory AS pi
LEFT JOIN
    sales_transaction AS st ON pi.ProductID = st.ProductID
WHERE
    st.ProductID IS NULL -- Products that exist in inventory but have no matching sales transactions.
GROUP BY -- Grouping ensures each product is listed once, even if joined to multiple (null) transaction rows.
    pi.ProductID, pi.ProductName, pi.Category, pi.StockLevel;
/*
	Insight: 
		Identifying **products with zero sales (dead stock)** is crucial for inventory health. 
        These items tie up capital and warehouse space. This insight can lead to promotional strategies, 
        clearance sales, or even discontinuation decisions.
*/

---

### 4. Sales Trend Analysis

-- These queries help visualize sales performance over different time granularities,
-- allowing for trend identification, seasonality analysis, and forecasting.

-- Monthly Sales Trend (Total Revenue and Number of Transactions):
-- Aggregates total revenue and transaction count on a monthly basis, providing a high-level view of performance over time.
SELECT
    DATE_FORMAT(st.TransactionDate, '%Y-%m') AS SalesMonth,      -- Extracts and formats the year and month from the transaction date (e.g., '2024-06').
    SUM(st.QuantityPurchased * st.Price) AS TotalMonthlyRevenue, -- Calculates the sum of revenue for each month.
    COUNT(DISTINCT st.TransactionID) AS NumberOfMonthlyTransactions -- Counts the unique transactions occurring in each month.
FROM
    sales_transaction AS st
GROUP BY
    SalesMonth
ORDER BY
    SalesMonth; -- Orders the results chronologically for easy trend analysis.
/*
	Insight: 
		**Monthly sales trends** are critical for identifying seasonality, 
        long-term growth or decline, and the impact of marketing campaigns or external factors on sales performance. 
        This is a key metric for strategic planning and budgeting.
*/


-- Daily Sales Trend (Total Revenue and Number of Transactions):
-- Aggregates total revenue and transaction count on a daily basis, offering a granular view of daily fluctuations.
SELECT
    DATE_FORMAT(st.TransactionDate, '%Y-%m-%d') AS SalesDay, -- Extracts and formats the full date (e.g., '2024-06-19').
    SUM(st.QuantityPurchased * st.Price) AS TotalDailyRevenue, -- Calculates the sum of revenue for each day.
    COUNT(DISTINCT st.TransactionID) AS NumberOfDailyTransactions -- Counts the unique transactions occurring each day.
FROM
    sales_transaction AS st
GROUP BY
    SalesDay
ORDER BY
    SalesDay; -- Orders the results chronologically by sales day for granular trend analysis.
/*
	Insight: 
		**Daily sales trends** provide a detailed view, helping identify peak sales days, the impact of daily promotions, 
        or even unforeseen events. This granularity is excellent for operational adjustments and short-term planning.
*/


-- Sales by Day of Week: Helps identify the busiest shopping days.
SELECT
    DAYNAME(TransactionDate) AS DayOfWeek, -- Extracts the name of the day (e.g., 'Monday').
    COUNT(DISTINCT TransactionID) AS NumberOfTransactions,
    SUM(QuantityPurchased * Price) AS TotalRevenue
FROM
    sales_transaction
GROUP BY
    DayOfWeek
ORDER BY FIELD(DayOfWeek, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'); -- Orders by standard week order.
/*
	Insight: 
		Analyzing **sales by day of the week** is crucial for staffing, promotional scheduling, 
        and inventory replenishment. It highlights peak shopping days, allowing businesses to optimize resources.
*/

-- Sales by Hour of Day (if TransactionDate includes time):
-- This requires the TransactionDate to have time components. Assuming it does, this is powerful for real-time operations.
-- If TransactionDate is only DATE, this query will not yield meaningful results for hour.
SELECT
    HOUR(TransactionDate) AS SalesHour, -- Extracts the hour of the day (0-23).
    COUNT(DISTINCT TransactionID) AS NumberOfTransactions,
    SUM(QuantityPurchased * Price) AS TotalRevenue
FROM
    sales_transaction
GROUP BY
    SalesHour
ORDER BY
    SalesHour;
/*
	Insight: 
		If `TransactionDate` includes time, this analysis reveals **peak shopping hours**. 
        This is invaluable for optimizing staffing in physical stores, scheduling online promotions, 
        and managing server load for e-commerce platforms.
*/

---

### 5. Customer Loyalty and Behavior Analysis

-- These queries delve deeper into customer habits beyond just total spending,
-- focusing on frequency, recency, and longevity.

-- Customers with Consistent Purchases Over Multiple Years: Identifies highly loyal customers who have made purchases in more than one distinct year.
-- This indicates a sustained relationship over time.
SELECT
    cp.CustomerID,
    COUNT(DISTINCT YEAR(st.TransactionDate)) AS NumberOfYearsWithPurchases, -- Counts the number of distinct years a customer made a purchase.
    MIN(YEAR(st.TransactionDate)) AS FirstPurchaseYear,     -- The year of their very first purchase.
    MAX(YEAR(st.TransactionDate)) AS LastPurchaseYear       -- The year of their most recent purchase.
FROM
    sales_transaction AS st
JOIN
    customer_profiles AS cp ON st.CustomerID = cp.CustomerID
GROUP BY
    cp.CustomerID
HAVING
    COUNT(DISTINCT YEAR(st.TransactionDate)) > 1 -- Filters for customers who purchased in more than one unique year.
ORDER BY
    NumberOfYearsWithPurchases DESC, cp.CustomerID;
/*
	Insight: 
		This identifies **long-term, consistently engaged customers**. 
        These are high-value relationships that warrant special attention, loyalty programs, 
        and personalized communication to ensure continued retention.
*/


-- High-Value Loyal Customers (Top Spenders): Identifies customers who have spent the most, indicating their high monetary value.
-- This is directly related to the 'Monetary' aspect of RFM.
-- We'll select the top 10 customers by total spending, which can be adjusted as needed.
SELECT
    cp.CustomerID,
    SUM(st.QuantityPurchased * st.Price) AS TotalSpending
FROM
    sales_transaction AS st
JOIN
    customer_profiles AS cp ON st.CustomerID = cp.CustomerID
GROUP BY
    cp.CustomerID
ORDER BY
    TotalSpending DESC
LIMIT 10; -- Adjust this limit to find the top N high-value customers.
/*
	Insight: 
		These are your **monetary power users**. 
        Recognizing and rewarding these customers can significantly boost satisfaction 
        and encourage continued high-value purchases.
*/


-- Highly Frequent Loyal Customers (Most Frequent Purchasers): Identifies customers who have made the most unique transactions, indicating high frequency.
-- This is directly related to the 'Frequency' aspect of RFM.
-- We'll select the top 10 customers by number of transactions.
SELECT
    cp.CustomerID,
    COUNT(DISTINCT st.TransactionID) AS NumberOfTransactions
FROM
    sales_transaction AS st
JOIN
    customer_profiles AS cp ON st.CustomerID = cp.CustomerID
GROUP BY
    cp.CustomerID
ORDER BY
    NumberOfTransactions DESC
LIMIT 10; -- Adjust this limit to find the top N highly frequent customers.
/*
	Insight: 
		These are your **most engaged and frequent buyers**. 
        They may not always be the top spenders, but their consistent activity is a strong indicator of loyalty 
        and habit. They are ideal candidates for subscription models or early access to new products.
*/

-- Average Time Between Purchases for Repeat Customers: Measures customer stickiness.
SELECT
    cp.CustomerID,
    AVG(DATEDIFF(next_purchase.TransactionDate, current_purchase.TransactionDate)) AS AvgDaysBetweenPurchases
FROM
    sales_transaction AS current_purchase
JOIN
    sales_transaction AS next_purchase
    ON current_purchase.CustomerID = next_purchase.CustomerID
    AND current_purchase.TransactionDate < next_purchase.TransactionDate -- Ensure next_purchase is actually later
JOIN
    customer_profiles AS cp ON current_purchase.CustomerID = cp.CustomerID
GROUP BY
    cp.CustomerID
HAVING
    COUNT(current_purchase.TransactionID) > 1 -- Only consider customers with more than one purchase
ORDER BY
    AvgDaysBetweenPurchases ASC; -- Show customers with shorter intervals first
/*
	Insight: 
		The **average time between purchases** provides a crucial measure of customer churn risk and loyalty. 
        Shorter intervals indicate higher engagement and satisfaction. 
        This can inform re-engagement campaigns or subscription model development.
*/


-- Most Popular Product Combinations (Basic Co-purchase Analysis): Identifies products frequently bought together.
-- This is a simplified market basket analysis. For more complex, use higher-order joins or dedicated algorithms.
SELECT
    st1.ProductID AS Product1ID,
    pi1.ProductName AS Product1Name,
    st2.ProductID AS Product2ID,
    pi2.ProductName AS Product2Name,
    COUNT(DISTINCT st1.TransactionID) AS NumberOfTransactionsTogether
FROM
    sales_transaction AS st1
JOIN
    sales_transaction AS st2
    ON st1.TransactionID = st2.TransactionID
    AND st1.ProductID < st2.ProductID -- Prevents duplicate pairs (A,B and B,A) and self-joins (A,A)
JOIN
    product_inventory AS pi1 ON st1.ProductID = pi1.ProductID
JOIN
    product_inventory AS pi2 ON st2.ProductID = pi2.ProductID
GROUP BY
    Product1ID, Product2ID, Product1Name, Product2Name
ORDER BY
    NumberOfTransactionsTogether DESC
LIMIT 10;
/*
	Insight: 
		Identifying **frequently co-purchased products** is invaluable for cross-selling, product bundling, 
        and optimizing store layouts (both physical and online). 
        It helps understand natural product affinities in customer buying behavior.
*/

---

-- SQL Queries to Create Customer Segments Based on Purchasing Behavior (RFM Segmentation)

-- This script will segment customers based on their Recency, Frequency, and Monetary (RFM) values.
-- We will first calculate RFM, then assign scores (1-5) for each metric, and finally
-- define customer segments based on combinations of these scores.

-- RFM definitions:
-- Recency: Days since last purchase (lower days = higher score)
-- Frequency: Total number of unique transactions (higher count = higher score)
-- Monetary: Total spending (higher amount = higher score)

---

-- Step 1: Calculate RFM values for each customer (Recency, Frequency, Monetary)
-- This Common Table Expression (CTE) calculates the raw RFM values.
WITH CustomerRFM AS (
    SELECT
        CustomerID,
        DATEDIFF(
            (SELECT MAX(TransactionDate) FROM sales_transaction), -- 'Current date' based on latest transaction
            MAX(TransactionDate)
        ) AS RecencyInDays,
        COUNT(DISTINCT TransactionID) AS Frequency,
        SUM(QuantityPurchased * Price) AS MonetaryValue
    FROM
        sales_transaction
    GROUP BY
        CustomerID
),

-- Step 2: Assign RFM scores (1-5) based on quintiles
-- NTILE(5) divides the customers into 5 groups.
-- For Recency, a lower number of days means higher recency, so we order DESC to assign higher scores to recent customers.
-- For Frequency and Monetary, higher values mean higher scores, so we order ASC.
RFMScores AS (
    SELECT
        CustomerID,
        RecencyInDays,
        Frequency,
        MonetaryValue,
        NTILE(5) OVER (ORDER BY RecencyInDays DESC) AS R_Score, -- Higher score for lower RecencyInDays
        NTILE(5) OVER (ORDER BY Frequency ASC) AS F_Score,     -- Higher score for higher Frequency
        NTILE(5) OVER (ORDER BY MonetaryValue ASC) AS M_Score   -- Higher score for higher MonetaryValue
    FROM
        CustomerRFM
)

-- Step 3: Combine scores and define customer segments
-- This final SELECT statement creates a combined RFM_Score_String and assigns a SegmentName
-- based on common RFM segmentation rules.
SELECT
    rfm.CustomerID,
    -- If customer names were available in customer_profiles, you would join and include them here.
    -- Example: cp.CustomerName,
    rfm.RecencyInDays,
    rfm.Frequency,
    rfm.MonetaryValue,
    rfm.R_Score,
    rfm.F_Score,
    rfm.M_Score,
    CONCAT(rfm.R_Score, rfm.F_Score, rfm.M_Score) AS RFM_Score_String,
    CASE
        WHEN rfm.R_Score = 5 AND rfm.F_Score = 5 AND rfm.M_Score = 5 THEN 'Champions' -- Bought recently, buy often, spend most
        WHEN rfm.R_Score = 5 AND rfm.F_Score = 5 THEN 'Loyal Customers'               -- Bought recently, buy often
        WHEN rfm.R_Score = 5 AND rfm.F_Score = 4 THEN 'Loyal Customers'
        WHEN rfm.R_Score = 4 AND rfm.F_Score = 5 THEN 'Loyal Customers'

        WHEN rfm.R_Score >= 4 AND rfm.F_Score >= 4 AND rfm.M_Score >= 4 THEN 'Potential Loyalists' -- Recent, frequent, good monetary value
        WHEN rfm.R_Score = 5 AND rfm.F_Score >= 3 THEN 'New Customers'                -- Bought recently, but not frequent yet
        WHEN rfm.R_Score >= 4 AND rfm.M_Score >= 4 THEN 'Promising'                   -- Bought recently, high monetary value, maybe less frequent
        WHEN rfm.R_Score >= 3 AND rfm.F_Score <= 2 AND rfm.M_Score <= 2 THEN 'Hibernating' -- Last purchase a while ago, low frequency & monetary
        WHEN rfm.R_Score <= 2 AND rfm.F_Score <= 2 AND rfm.M_Score <= 2 THEN 'Lost Customers' -- Least recent, least frequent, lowest monetary
        WHEN rfm.R_Score <= 2 AND rfm.F_Score >= 3 THEN 'At Risk'                    -- Haven't bought recently, but were frequent
        WHEN rfm.R_Score <= 2 AND rfm.M_Score >= 3 THEN 'Can''t Lose Them'            -- Haven't bought recently, but were high value
        WHEN rfm.F_Score = 5 AND rfm.M_Score = 5 THEN 'Best Customers'                -- Frequent, high monetary (regardless of recency)
        ELSE 'Other Segment'                                                          -- Catch-all for less common combinations
    END AS CustomerSegment
FROM
    RFMScores rfm
ORDER BY
    rfm.CustomerID;
/*
	Insight:
		**RFM segmentation provides a powerful framework for understanding customer value and behavior.**
		By classifying customers into distinct groups based on their transaction history, businesses can:

		- **Tailor Marketing Strategies:** Different segments require different messaging. For example, 'Champions' might receive exclusive previews, while 'At Risk' customers get win-back offers.
		- **Optimize Resource Allocation:** Focus retention efforts on high-value customers and re-engagement on at-risk ones, rather than a one-size-fits-all approach.
		- **Identify Growth Opportunities:** Encourage 'New Customers' to become loyal, and 'Potential Loyalists' to become 'Champions'.
		- **Personalize Customer Experience:** Offer relevant products, promotions, or customer service interactions based on their segment's characteristics.

		Here's a breakdown of some key segments and their implications:
		- **Champions (R5 F5 M5):** Your most valuable customers. Reward them, engage them frequently, and encourage referrals.
		- **Loyal Customers (high F, M, good R):** Consistent, high-value buyers. Maintain engagement with personalized content and loyalty programs.
		- **New Customers (high R, low F, M):** Recently acquired. Focus on excellent onboarding and initial engagement to encourage repeat purchases.
		- **Promising (good R, low F, M):** Recent purchasers who might convert into loyalists with targeted nurturing.
		- **Can’t Lose Them (low R, high F, M):** Were loyal but haven't purchased recently. High priority for re-engagement to prevent churn.
		- **At Risk / Hibernating (low R, low F, M):** Customers whose activity has significantly dropped. Requires aggressive re-engagement campaigns or may be considered lost.
		- **Lost Customers (very low R, F, M):** Likely churned. Re-acquisition efforts might be costly, or focus could shift to other segments.
*/

-- SQL Query to Create Customer Segments Based on the Number of Unique Products Ordered

-- This script segments customers based on the diversity of products they purchase,
-- specifically by counting the number of distinct products each customer has ordered.
-- This can indicate a customer's breadth of interest in your product catalog.

---

WITH CustomerProductDiversity AS (
    SELECT
        st.CustomerID,
        COUNT( st.ProductID) AS NumberOfUniqueProductsOrdered
    FROM
        sales_transaction st
    GROUP BY
        st.CustomerID
)
SELECT
    cpd.CustomerID,
    -- If customer names were available in customer_profiles, you would join and include them here.
    -- Example: cp.CustomerName,
    cpd.NumberOfUniqueProductsOrdered,
    CASE
        WHEN NTILE(4) OVER (ORDER BY cpd.NumberOfUniqueProductsOrdered DESC) = 1 THEN 'High Product Variety Customer'     -- Top 25% by unique products
        WHEN NTILE(4) OVER (ORDER BY cpd.NumberOfUniqueProductsOrdered DESC) = 2 THEN 'Medium-High Product Variety Customer' -- 25-50% by unique products
        WHEN NTILE(4) OVER (ORDER BY cpd.NumberOfUniqueProductsOrdered DESC) = 3 THEN 'Medium-Low Product Variety Customer'  -- 50-75% by unique products
        ELSE 'Low Product Variety Customer'                                          -- Bottom 25% by unique products
    END AS ProductVarietySegment
FROM
    CustomerProductDiversity cpd
ORDER BY
    cpd.NumberOfUniqueProductsOrdered DESC;
/*
	Insight:
		This segmentation identifies how "exploratory" or "focused" a customer is regarding your product catalog.

		- **High Product Variety Customers:** These customers are highly engaged with your entire product range.
		  They are excellent candidates for new product announcements, cross-selling adjacent categories,
		  and providing feedback on a wide range of products. They indicate broad appeal of your offerings.

		- **Low Product Variety Customers:** These customers tend to buy only a few specific products.
		  They might be buying essentials, or they might not be aware of your full product range.
		  This segment is an opportunity for targeted marketing to introduce them to other relevant categories,
		  perhaps through personalized recommendations or bundling. Understanding if they are "loyal to one product"
		  or simply "unaware" is key.

		This analysis complements RFM by adding a dimension of "breadth of purchase" which can inform:
		- **Product Discovery Strategies:** How to encourage customers to explore more of your catalog.
		- **Personalized Recommendations:** Tailoring suggestions based on their existing variety or to introduce new types.
		- **Marketing Campaign Design:** Different segments might respond to messages about new products vs. replenishable items.
		- **Inventory Planning:** High variety customers might drive demand across many SKUs, while low variety customers might concentrate demand on a few.
*/
    
## Conclusion and Key Insights from the Retail Analysis Case Study

/*
	This case study involved a comprehensive process of data ingestion, schema refinement, data cleaning, and validation for three core retail datasets: `customer_profiles`, `product_inventory`, and `sales_transaction`. The objective was to prepare these datasets for reliable business intelligence and analytical insights.

### Summary of Actions Taken:

1.  **Database and Table Setup:**
    * A dedicated `RetailAnalysis` database was created.
    * Three tables (`customer_profiles`, `product_inventory`, `sales_transaction`) were defined and populated from CSV files.

2.  **Schema Refinement and Data Type Optimization:**
    * **Identified Inconsistencies:** Initial data inspection revealed that numerical identifiers (`CustomerID`, `ProductID`, `TransactionID`), age (`Age`), and quantities (`StockLevel`, `QuantityPurchased`) were imported as `DECIMAL(38,0)`, which was inefficient and semantically incorrect for whole numbers. Date fields (`JoinDate`, `TransactionDate`) were imported as `VARCHAR(8)`, preventing proper date-based operations.
    * **Applied Corrections:** All relevant `DECIMAL(38,0)` columns were precisely converted to `INT` (e.g., `CustomerID`, `Age`, `ProductID`, `TransactionID`, `StockLevel`, `QuantityPurchased`). `VARCHAR(8)` date columns were accurately converted to the `DATE` data type. These changes significantly improved data storage efficiency, query performance, and enabled the use of built-in SQL date functions for temporal analysis.

3.  **Data Quality and Missing Value Handling:**
    * **Explicit NULLs Check:** Comprehensive checks using `COUNT(*) - COUNT(column_name)` confirmed that `Location` in `customer_profiles` was the only column with explicit `NULL` values (13 records). All other columns across the three tables were confirmed to be `NOT NULL`.
    * **Empty String/Whitespace Check:** Targeted `WHERE TRIM(column) = ''` queries were used for `VARCHAR` columns to identify empty or whitespace-only strings. This confirmed `Location` also had such values which were subsequently addressed.
    * **Missing Value Imputation/Deletion (Location):** The 13 records with missing (`NULL` or empty string) `Location` values in `customer_profiles` were removed. This decision was based on the small proportion of affected data, ensuring high data quality without significantly impacting the overall dataset size.

4.  **Duplicate Data Management:**
    * **Identification:** `ROW_NUMBER()` window functions within Common Table Expressions (CTEs) were extensively used to identify duplicate records based on various key combinations across all three tables:
        * `customer_profiles`: Duplicates based on `Age`, `Gender`, `Location`, `JoinDate`.
        * `product_inventory`: Duplicates based on `ProductName`, `Category`, `StockLevel`.
        * `sales_transaction`: Duplicates based on `TransactionID`, `CustomerID`, `ProductID`, `QuantityPurchased`.
    * **Resolution:** For `sales_transaction`, 2 duplicate records were identified and precisely removed using a `DELETE` statement with a multi-column `IN` clause, ensuring that only the redundant instances were deleted while preserving one valid occurrence of each transaction.

5.  **Price Discrepancy Resolution:**
    * **Identification:** A `JOIN` query was performed to compare `Price` values in `sales_transaction` with `Price` values in `product_inventory` based on `ProductID`. This identified instances where the historical transaction price differed from the current inventory price.
    * **Correction:** An `UPDATE` statement was executed to align the `Price` in `sales_transaction` with the current `Price` from `product_inventory` for all identified discrepancies. This step standardizes pricing for consistent analytical reporting, although it's noted that aligning historical data to current prices is a specific business decision.

6.  **Data Export:**
    * The cleaned, refined, and validated datasets were exported to CSV files (`customer_profile_final_data_with_headers.csv`, `product_inventory_final_data_with_headers.csv`, `sales_transaction_final_data_with_date_headers.csv`) including header rows for ease of use in external tools.

### Final Insights:

* **Data Reliability Enhanced:** Through rigorous schema optimization and data cleaning, the datasets are now significantly more reliable for accurate reporting and robust analytical modeling. The correct data types ensure data integrity and facilitate efficient querying.
* **Actionable Insights Enabled:** With clean, structured data, the organization can now derive more precise insights into customer demographics, product performance, and sales trends. For example:
    * **Customer Segmentation:** The `customer_profiles` table, with clean `Age`, `Gender`, and `Location` data, enables effective customer segmentation for targeted marketing.
    * **Product Performance Analysis:** The `product_inventory` table, with accurate `StockLevel` and `Price` data, supports inventory management and identification of best-selling or slow-moving products.
    * **Sales Trend Analysis:** The `sales_transaction` table, with corrected prices and clean dates, allows for accurate calculation of revenue, identification of peak sales periods, and analysis of customer purchasing behavior over time.
* **Operational Efficiency:** The identification and removal of duplicates and discrepancies will lead to more accurate reporting, reduced manual data correction efforts, and improved trust in the underlying data.
* **Foundation for Advanced Analytics:** The prepared datasets serve as a strong foundation for more advanced analytical techniques, such as predictive modeling (e.g., forecasting sales, predicting customer churn) and machine learning applications.

This comprehensive data preparation process has transformed raw data into a valuable, analytical asset, ready to support strategic business decisions for the retail company.
*/
