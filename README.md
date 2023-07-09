# Fetch_Case
## Diagram a New Structured Relational Data Model
I diagram this data model as below:
![Alt text](https://github.com/HaomingLiu00/Fetch_Case/blob/main/DataModel.png)
### Tables and Primary Key
The three sample dataset stored information about receipts, users, and brands. 
Users and brands data are relatively easy, just store each feature as a column in the table. The primary key for Users is userId, and the primary key for Brands is brandId.

The receipt data contains a rewardsReceiptItemList feature, which were items details purchased on the receipt. I choose to pull this out into a new table as rewardsReceiptItem, and other features are kept as columns in Receipts table. The primary key for Receipts is receiptId, and the primary key for rewardsReceiptItem is receiptId and barcode.
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


# When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
SELECT rewardsReceiptStatus, AVG(totalSpent) AS avg_spent
FROM Receipts r
GROUP BY rewardsReceiptStatus;
’’’
