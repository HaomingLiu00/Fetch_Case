# Fetch_Case

Thank you for reviewing my coding challenge! You can find all the answers and code in the provided readme file, which is also available in this repository. I used MySQL and Python to complete this challenge.

## Part 1: Diagram a New Structured Relational Data Model
I diagram this data model as below:
![Alt text](https://github.com/HaomingLiu00/Fetch_Case/blob/main/DataModel.png)

### Tables and Primary Key

The sample dataset consists of three types of data: receipts, users, and brands. 

For users and brands, each feature is stored as a column in their respective tables. The primary key for the Users table is userId, and for the Brands table, it is brandId.

Regarding the receipt data, there is a feature called rewardsReceiptItemList, which contains details of items purchased on the receipt. To handle this, a new table called rewardsReceiptItem is created to store the item-level details. The remaining features are stored as columns in the Receipts table. The primary key for the Receipts table is receiptId, while the primary key for the rewardsReceiptItem table is a combination of receiptId and barcode. 

This design allows for efficient storage and retrieval of receipt-related information.

### Joinable Keys

(1) Receipts and Users can join together on userId in Receipts

(2) Brands and rewardsReceiptItem can join together on barcode

(3) rewardsReceiptItem and Receipts can join together on receiptId

### Potential Index & Partition

To optimize the query performance and data access for the tables in our database, we can consider implementing appropriate indexes and partitions. The decision to create indexes should be based on the specific queries and usage patterns of the application. In Part 4, I will request additional information from the business leader to determine the specific indexes and partitions that would best optimize the data assets and improve query efficiency.

### Other questions

(1) The current time in the JSON file is in timestamp format and needs to be converted into a human-readable date and time format.

(2) When creating tables, I would carefully consider the nature of the data and select appropriate data types to optimize storage and performance.


## Part 2:  Query for predetermined question

```sql
# What are the top 5 brands by receipts scanned for most recent month?

SELECT
    b.brandID,
    b.brandCode,
    b.name,
    SUM(finalPrice * quantityPurchased) AS brand_sales
FROM
    rewardsReceiptItem ri
    LEFT JOIN Receipts r ON ri.receiptId = r.receiptId
    LEFT JOIN Brands b ON ri.barcode = b.barcode
WHERE
    dateScanned BETWEEN "2023-06-09" AND "2023-07-09"
GROUP BY
    b.brandID,
    b.brandCode,
    b.name
ORDER BY
    brand_sales DESC
LIMIT 5;


# When considering average spend from receipts with 'rewardsReceiptStatus’
# of ‘Accepted’ or ‘Rejected’, which is greater?

SELECT rewardsReceiptStatus, AVG(totalSpent) AS avg_spent
FROM Receipts r
GROUP BY rewardsReceiptStatus;
```

## Part 3: Evaluate Data Quality Issues in the Data Provided

After reviewing the data in the JSON file, I checked following aspects to address potential issues:

(1) Verify if there are any columns that contain NULL values;

(2) Identify conflicting information or duplicate records; 

(3) Validate the data to ensure it adheres to the expected format. For instance, validate barcode values for correctness and verify if categoryCode values align with their corresponding categories.

### Step1: from a JSON file into database tables ( Brands table as an example)

I use Python to evaluate the data quality by inserting data from a JSON file into database tables. In the following code, I created a brands table as an example:

**Handling the process of inserting data from a JSON file into a MySQL database table**
```python
import pymysql
import models
import json
import sql_constant

# Import necessary libraries and modules


def brand_handler(path):
    # Create table if it doesn't exist
    cursor.execute(sql_constant.brand_create_table_query)

    # Open and read the JSON file
    with open(path, "r") as file:
        for line in file:
            # Load JSON data
            json_data = json.loads(line)

            # Create Brand object
            brand = models.Brand(json_data)

            # Prepare values for insertion
            values = (
                brand.brandId,
                brand.barcode,
                brand.brandCode,
                brand.category,
                brand.categoryCode,
                brand.cpg_id,
                brand.cpg_ref,
                brand.name,
                brand.topBrand
            )

            # Execute SQL insert query
            cursor.execute(sql_constant.brand_insert_query, values)

    # Commit the transaction
    connection.commit()

    # Close the cursor and connection
    cursor.close()
    connection.close()


if __name__ == "__main__":
    # Establish a connection to the database
    connection = pymysql.connect(
        host='localhost',
        user='root',
        password='my_password',
        database='mysql'
    )

    # Create a cursor object
    cursor = connection.cursor()

    # Call the brand_handler function with the path to the JSON file
    brand_handler("./data/brands.json")

```


**Extract specific fields from the given JSON data and assign them to corresponding attributes of the Brand object.**

```python
class Brand:
    def __init__(self, json_data):
        try:
            self.brandId = json_data["_id"]["$oid"]
        except KeyError:
            self.brandId = None

        try:
            self.barcode = json_data["barcode"]
        except KeyError:
            self.barcode = None

        try:
            self.brandCode = json_data["brandCode"]
        except KeyError:
            self.brandCode = None

        try:
            self.category = json_data["category"]
        except KeyError:
            self.category = None

        try:
            self.categoryCode = json_data["categoryCode"]
        except KeyError:
            self.categoryCode = None

        try:
            self.cpg_id = json_data["cpg"]["$id"]["$oid"]
        except KeyError:
            self.cpg_id = None

        try:
            self.cpg_ref = json_data["cpg"]["$ref"]
        except KeyError:
            self.cpg_ref = None

        try:
            self.name = json_data["name"]
        except KeyError:
            self.name = None

        try:
            self.topBrand = json_data["topBrand"]
        except KeyError:
            self.topBrand = None
```


**Create tables and insert data** 
```python
brand_create_table_query = '''
CREATE TABLE IF NOT EXISTS brands (
    brandId VARCHAR(255) PRIMARY KEY,
    barcode VARCHAR(255),
    brandCode VARCHAR(255),
    category VARCHAR(255),
    categoryCode VARCHAR(255),
    cpg_id VARCHAR(255),
    cpg_ref VARCHAR(255),
    name VARCHAR(255),
    topBrand BOOLEAN
)
'''
brand_insert_query = '''
        INSERT INTO brands (
            brandId,
            barcode,
            brandCode,
            category,
            categoryCode,
            cpg_id,
            cpg_ref,
            name,
            topBrand
        ) VALUES (
            %s, %s, %s, %s, %s, %s, %s, %s, %s
        )
        '''
```


### Step2: Check the Data Quality with MySQL

**Detect Null Vaules**
```sql
# Null Value
#Report: 612
SELECT 
	COUNT(*) AS null_count, 
	topBrand
FROM mysql.brand
WHERE topBrand IS NULL
GROUP BY topBrand;


#Report: 234
SELECT 
	COUNT(*) AS null_count, 
	brandCode
FROM mysql.brand
WHERE brandCode IS NULL
GROUP BY brandCode;


#Report: 155
SELECT 
	COUNT(*) AS null_count, 
	category
FROM mysql.brand
WHERE category IS NULL
GROUP BY category;


#Report: 650
SELECT 
	COUNT(*) AS null_count, 
	categoryCode
FROM mysql.brand
WHERE categoryCode IS NULL
GROUP BY categoryCode;
```

**Summary of Data Issues in the "brands" Table:**

Null Values in "topBrand":
Total count: 612

Null Values in "brandCode":
Total count: 234

Null Values in "category":
Total count: 155

Null Values in "categoryCode":
Total count: 650

These data issues indicate the presence of null values in specific columns of the "brands" table in the database.

**Verify duplicate records**
```sql
# Identify Duplicate Records
SELECT barcode, COUNT(*) AS duplicate_count
FROM mysql.brand
GROUP BY barcode
HAVING COUNT(*) > 1;
```


## Part 4: Communicate with Stakeholders


Dear Busness Leader,

I hope this message finds you well. I wanted to discuss some important observations regarding the data we have been working with. As a data analyst, I have been conducting various checks to assess the quality of the data and have come across some significant issues that I believe are important to address.

**Data Quality Issues: Missing Data**

Upon loading the JSON data into our database and conducting thorough checks, I have identified a concerning problem of missing data within the dataset. Specifically, I have noticed that a considerable number of rows in the brand, receipts, and users data do not contain important information such as "topBrand", "brandCode", "category", and "categoryCode". Consequently, the corresponding columns in our database have null values. To illustrate the magnitude of the issue, more than half of the "topBrand" values (650 out of 1167) and "categoryCode" values (612 out of 1167) are null.

**Resolving the Data Quality Issues: Additional Information Required**

To resolve these data quality issues, it is crucial to gather additional information and context. 

Understanding the reasons behind the missing data is important; we need to determine whether it is a result of data collection or extraction processes. 

Moreover, knowing the criteria or rules used to determine the values for "topBrand", "brandCode", "category", and "categoryCode" would greatly assist us in addressing the missing data problem. For example, I have observed that in most cases, "brandCode" can be derived from the "name" attribute, which doesn't have null values. These insights could potentially help us fill in the missing values.

**Handling Test Information**

Additionally, I have noticed that some of the attributions in brands include test information like "TEST BRANDCODE @1597342520277". I would appreciate clarification on whether this test information should be included in the final table or if any changes need to be made.

**Optimizing Data Assets: Gathering Additional Information**

I would like to gather some information to optimize our data assets and enhance query efficiency.

**Business Goal and Focus:** To align our efforts with the business objectives, I would like to understand which specific information or details regarding customer receipt transactions are of utmost interest to you. By identifying the key areas of focus, we can tailor our data analysis and reporting to provide the most valuable insights that align with your goals.

**Time Scope of Data Retrieval:** It would be helpful to know the typical time scope or range within which you usually access the data. This information will assist us in optimizing data retrieval strategies and designing efficient queries that align with your preferred time frames. 

By addressing these questions, we can enhance the overall performance of our data assets, ensure that our analyses are aligned with your business objectives, and optimize data management practices.

**Understanding "bonusPointsEarned" and "pointsEarned"**

Lastly, I have a specific question regarding the columns "bonusPointsEarned" and "pointsEarned". From the data I have analyzed, these two concepts seem to be very similar, almost identical. However, I believe there might be subtle differences and underlying activities behind each of these columns. It would be immensely helpful if you could provide an explanation to help us better understand these differences. This understanding will enable our data analysts to utilize these columns more rigorously in their analyses.

Thank you for your time and attention to these matters. Should you have any questions or require further clarification, please feel free to reach out to me.

Best regards,

Haoming Liu





