# What are the top 5 brands by receipts scanned for most recent month?
SELECT
    b.brandID,
    b.brandCode,
    b.name,
    SUM(finalPrice * quantityPurchased) AS brand_sales
FROM
    rewardsReceiptItem ri
    LEFT JOIN Receipts r ON ri.receiptId = r.receiptId
    LEFT JOIN Brands b ON ri.brandId = b.brandId
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
