# Fetch_Case
## Diagram a New Structured Relational Data Model
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

### Potential Index

### data Type

### Other questions

## Second: Query for predetermined question
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

## Evaluate Data Quality Issues in the Data Provided

After reviewing the data in the JSON file, I will check following aspects to address potential issues:

(1) Verify if there are any columns that contain NULL values;

(2) Identify conflicting information or duplicate records; 

(3) Validate the data to ensure it adheres to the expected format. For instance, validate barcode values for correctness and verify if categoryCode values align with their corresponding categories.

I use Python to evaluate the data quality by inserting data from a JSON file into database tables. In the following code, I created a brands table as an example:

**Handling the process of inserting data from a JSON file into a MySQL database table**
```python
import pymysql
import models
import json
import sql_constant


def brand_handler(path):
    cursor.execute(sql_constant.brand_create_table_query)
    with open(path, "r") as file:
        for line in file:
            json_data = json.loads(line)
            brand = models.Brand(json_data)
            values = (
                brand._id,
                brand.barcode,
                brand.brandCode,
                brand.category,
                brand.categoryCode,
                brand.cpg_id,
                brand.cpg_ref,
                brand.name,
                brand.topBrand
            )
            cursor.execute(sql_constant.brand_insert_query, values)

    # 提交事务
    connection.commit()

    # 关闭游标和连接
    cursor.close()
    connection.close()


if __name__ == "__main__":
    connection = pymysql.connect(
        host='localhost',
        user='root',
        password='59348649',
        database='mysql'
    )
    cursor = connection.cursor()
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
