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

