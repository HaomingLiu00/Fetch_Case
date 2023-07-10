# Check Null Value
#Report: 2448
SELECT 
	COUNT(*) AS null_count, 
	topBrand
FROM mysql.brand
WHERE topBrand IS NULL
GROUP BY topBrand;


#Report: 936
SELECT 
	COUNT(*) AS null_count, 
	brandCode
FROM mysql.brand
WHERE brandCode IS NULL
GROUP BY brandCode;


#Report: 620
SELECT 
	COUNT(*) AS null_count, 
	category
FROM mysql.brand
WHERE category IS NULL
GROUP BY category;


#Report: 2600
SELECT 
	COUNT(*) AS null_count, 
	categoryCode
FROM mysql.brand
WHERE categoryCode IS NULL
GROUP BY categoryCode;


# Identify Duplicate Records
SELECT barcode, COUNT(*) AS duplicate_count
FROM your_table
GROUP BY barcode
HAVING COUNT(*) > 1;