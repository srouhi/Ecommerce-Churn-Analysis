CREATE DATABASE ecommerce_db;
USE ecommerce_db;

-- total number of customers
SELECT DISTINCT COUNT(CustomerID) AS TotalNumberOfCustomers
FROM ecommercechurn;

-- check for duplicates
SELECT CustomerID, COUNT(CustomerID) as Count
FROM ecommercechurn
GROUP BY CustomerID
Having COUNT(CustomerID) > 1;

-- checking for null values
SELECT 'Tenure' as ColumnName, COUNT(*) AS NullCount 
FROM ecommercechurn
WHERE Tenure= '' OR Tenure = 'NA' OR Tenure = 'null'
UNION
SELECT 'WarehouseToHome' as ColumnName, COUNT(*) AS NullCount 
FROM ecommercechurn
WHERE WarehouseToHome= '' OR WarehouseToHome = 'NA' OR WarehouseToHome = 'null'
UNION
SELECT 'HourSpendonApp' as ColumnName, COUNT(*) AS NullCount 
FROM ecommercechurn
WHERE HourSpendonApp= '' OR HourSpendonApp = 'NA' OR HourSpendonApp = 'null'
UNION
SELECT 'OrderAmountHikeFromLastYear' as ColumnName, COUNT(*) AS NullCount 
FROM ecommercechurn
WHERE OrderAmountHikeFromLastYear= '' OR OrderAmountHikeFromLastYear = 'NA' OR OrderAmountHikeFromLastYear = 'null'
UNION
SELECT 'CouponUsed' as ColumnName, COUNT(*) AS NullCount 
FROM ecommercechurn
WHERE CouponUsed= '' OR CouponUsed = 'NA' OR CouponUsed = 'null'
UNION
SELECT 'OrderCount' as ColumnName, COUNT(*) AS NullCount 
FROM ecommercechurn
WHERE OrderCount= '' OR OrderCount = 'NA' OR OrderCount = 'null'
UNION
SELECT 'DaySinceLastOrder' as ColumnName, COUNT(*) AS NullCount 
FROM ecommercechurn
WHERE DaySinceLastOrder= '' OR DaySinceLastOrder = 'NA' OR DaySinceLastOrder = 'null';

-- Alter column types to FLOAT
ALTER TABLE ecommercechurn 
MODIFY Tenure FLOAT;

ALTER TABLE ecommercechurn 
MODIFY HourSpendOnApp FLOAT;

-- Fill NULLs with column averages
-- Tenure
SELECT AVG(Tenure) 
INTO @avg_tenure 
FROM ecommercechurn 
WHERE Tenure IS NOT NULL;

UPDATE ecommercechurn 
SET Tenure = @avg_tenure 
WHERE Tenure IS NULL;

-- HourSpendOnApp
SELECT AVG(HourSpendOnApp) 
INTO @avg_hourspend 
FROM ecommercechurn 
WHERE HourSpendOnApp IS NOT NULL;

UPDATE ecommercechurn 
SET HourSpendOnApp = @avg_hourspend 
WHERE HourSpendOnApp IS NULL;

-- OrderAmountHikeFromLastYear
SELECT AVG(OrderAmountHikeFromLastYear) 
INTO @avg_orderhike 
FROM ecommercechurn 
WHERE OrderAmountHikeFromLastYear IS NOT NULL;

UPDATE ecommercechurn 
SET OrderAmountHikeFromLastYear = @avg_orderhike 
WHERE OrderAmountHikeFromLastYear IS NULL;

-- WarehouseToHome
SELECT AVG(WarehouseToHome) 
INTO @avg_warehouse 
FROM ecommercechurn 
WHERE WarehouseToHome IS NOT NULL;

UPDATE ecommercechurn 
SET WarehouseToHome = @avg_warehouse 
WHERE WarehouseToHome IS NULL;

-- CouponUsed
SELECT AVG(CouponUsed) 
INTO @avg_coupon 
FROM ecommercechurn 
WHERE CouponUsed IS NOT NULL;

UPDATE ecommercechurn 
SET CouponUsed = @avg_coupon 
WHERE CouponUsed IS NULL;

-- OrderCount
SELECT AVG(OrderCount) 
INTO @avg_ordercount 
FROM ecommercechurn 
WHERE OrderCount IS NOT NULL;

UPDATE ecommercechurn 
SET OrderCount = @avg_ordercount 
WHERE OrderCount IS NULL;

-- DaysSinceLastOrder
SELECT AVG(DaySinceLastOrder) 
INTO @avg_days 
FROM ecommercechurn 
WHERE DaySinceLastOrder IS NOT NULL;

UPDATE ecommercechurn 
SET DaySinceLastOrder = @avg_days 
WHERE DaySinceLastOrder IS NULL;

-- Preview cleaned data
SELECT * FROM ecommercechurn LIMIT 100;



-- new churn column from the existing one
UPDATE ecommercechurn
SET CustomerStatus =
    CASE
        WHEN Churn = 1 THEN 'Churned'
        WHEN Churn = 0 THEN 'Stayed'
        ELSE NULL
    END;

-- new column from an already existing “complain” column
UPDATE ecommercechurn
SET ComplainRecieved =  
CASE 
    WHEN complain = 1 THEN 'Yes'
    WHEN complain = 0 THEN 'No'
END;


-- checking each col for accuracy.
-- PreferedLoginDevice
SELECT DISTINCT PreferredLoginDevice 
FROM ecommercechurn;
-- phone and mobile phone are the same so replace "mobile phone" with "phone"
UPDATE ecommercechurn
SET PreferredLoginDevice = 'Phone'
WHERE PreferredLoginDevice = 'Mobile Phone';

-- PreferedOrderCat
SELECT DISTINCT PreferedOrderCat
FROM ecommercechurn;

UPDATE ecommercechurn
SET PreferedOrderCat = 'Mobile Phone'
WHERE PreferedOrderCat = 'Mobile';

-- PreferredPaymentMode
SELECT DISTINCT PreferredPaymentMode
FROM ecommercechurn;

UPDATE ecommercechurn
SET PreferredPaymentMode  = 'Cash on Delivery'
WHERE PreferredPaymentMode  = 'COD';

-- WarehouseToHome
SELECT DISTINCT warehousetohome
FROM ecommercechurn;

UPDATE ecommercechurn
SET warehousetohome = 27
WHERE warehousetohome = 127;

UPDATE ecommercechurn
SET warehousetohome = 26
WHERE warehousetohome = 126;

-- now the data is clean
-- next: insight generationion

-- overal customer churn rate
SELECT TotalNumberofCustomers, 
       TotalNumberofChurnedCustomers,
       CAST(
			(TotalNumberofChurnedCustomers * 1.0 / TotalNumberofCustomers * 1.0) * 100
			AS DECIMAL(10,2)
		) AS ChurnRate  
FROM
(SELECT COUNT(*) AS TotalNumberofCustomers
FROM ecommercechurn) AS Total,
(SELECT COUNT(*) AS TotalNumberofChurnedCustomers
FROM ecommercechurn
WHERE CustomerStatus = 'churned') AS Churned;

-- churn rate variation based on the preferred login device
SELECT preferredlogindevice, 
        COUNT(*) AS TotalCustomers,
        SUM(churn) AS ChurnedCustomers,
        CAST(SUM(churn) * 1.0 / COUNT(*) * 100 AS DECIMAL(10,2)) AS ChurnRate
FROM ecommercechurn
GROUP BY preferredlogindevice;

-- distribution of customers across different city tiers
SELECT citytier, 
       COUNT(*) AS TotalCustomer, 
       SUM(Churn) AS ChurnedCustomers, 
       CAST(SUM(churn) * 1.0 / COUNT(*) * 100 AS DECIMAL(10,2)) AS ChurnRate
FROM ecommercechurn
GROUP BY citytier
ORDER BY churnrate DESC;
-- so ciry tier has an impact on customer churn rates. e.g. tier 1 cities have lower churn rate.alter

-- correlation between warehouse to home distance and customer churn
UPDATE ecommercechurn
SET warehousetohomerange =
CASE 
    WHEN warehousetohome <= 10 THEN 'Very close distance'
    WHEN warehousetohome > 10 AND warehousetohome <= 20 THEN 'Close distance'
    WHEN warehousetohome > 20 AND warehousetohome <= 30 THEN 'Moderate distance'
    WHEN warehousetohome > 30 THEN 'Far distance'
END;

-- Finding a correlation between warehouse to home and churn rate.
SELECT warehousetohomerange,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY warehousetohomerange
ORDER BY Churnrate DESC;

-- what's the most preferred payment method among churned customers?
SELECT preferredpaymentmode,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY preferredpaymentmode
ORDER BY Churnrate DESC;

-- what is the typical tenure for churned customers?
ALTER TABLE ecommercechurn
ADD TenureRange VARCHAR(50);

UPDATE ecommercechurn
SET TenureRange =
CASE 
    WHEN tenure <= 6 THEN '6 Months'
    WHEN tenure > 6 AND tenure <= 12 THEN '1 Year'
    WHEN tenure > 12 AND tenure <= 24 THEN '2 Years'
    WHEN tenure > 24 THEN 'more than 2 years'
END;

-- typical tenure for churned customers
SELECT TenureRange,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY TenureRange
ORDER BY Churnrate DESC;

-- is there a difference in churn rate between male and female?
SELECT gender,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY gender
ORDER BY Churnrate DESC;
-- both genders show churn rate but males having a bit higher churn rate compared to female.

-- How avg time on the app diff for churned and non churned?
SELECT customerstatus, avg(hourspendonapp) AS AverageHourSpentonApp
FROM ecommercechurn
GROUP BY customerstatus;
-- they are almost the same average house in both type of customers so this isn't a factor

-- Does the number of registered devices impact the linkelihood of churn?
SELECT NumberofDeviceRegistered,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY NumberofDeviceRegistered
ORDER BY Churnrate DESC;
-- more registered devices show more churn rate

-- which category is most preferred between churned customers?
SELECT preferedordercat,
	COUNT(*) AS TotalCustomer,
	SUM(Churn) AS CustomerChurn,
	CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY preferedordercat
ORDER BY Churnrate DESC;
-- seems like the different order categories have diff impact on churn rate.

-- relationship between customer satisfaction score and churn?
SELECT satisfactionscore,
	COUNT(*) AS TotalCustomer,
    SUM(Churn) AS CustomerChurn,
	CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY satisfactionscore
ORDER BY Churnrate DESC;
-- customers with higher satisfaction score show more churn compared to other scores

-- Does the marital status impact churn behavior?
SELECT maritalstatus,
	COUNT(*) AS TotalCustomer,
    SUM(Churn) AS CustomerChurn,
	CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY maritalstatus
ORDER BY Churnrate DESC;
-- single users show the highest churn rate

-- how many addresses do churned customers have on average?
SELECT AVG(numberofaddress) AS Averagenumofchurnedcustomeraddress
FROM ecommercechurn
WHERE customerstatus = 'stayed'; 
-- on avg customers chanurned had 4 address associated with their account

-- do customers complaints inmpact churns?
SELECT complainrecieved,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY complainrecieved
ORDER BY Churnrate DESC;
-- larger proportion of those stopped using services registered complaints shows importance of dealing and resolving issues and their concerns

-- how does the use of coupons differ between churned and not churned users?
SELECT customerstatus, SUM(couponused) AS SumofCouponUsed
FROM ecommercechurn
GROUP BY customerstatus;
-- seems like higher coupon usage among stayed customers so it higher level of loyalty.

-- whats the avg # of days since the last order for churned customer?
SELECT AVG(daysincelastorder) AS AverageNumofDaysSinceLastOrder
FROM ecommercechurn
WHERE customerstatus = 'churned';
-- churned users have on avg short time since their last order so they recently stopped engaging

-- is there any correlation between cashback amount and churn rate?
UPDATE ecommercechurn
SET cashbackamountrange =
CASE 
    WHEN cashbackamount <= 100 THEN 'Low Cashback Amount'
    WHEN cashbackamount > 100 AND cashbackamount <= 200 THEN 'Moderate Cashback Amount'
    WHEN cashbackamount > 200 AND cashbackamount <= 300 THEN 'High Cashback Amount'
    WHEN cashbackamount > 300 THEN 'Very High Cashback Amount'
END;

SELECT cashbackamountrange,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY cashbackamountrange
ORDER BY Churnrate DESC;
-- seems like customers who received moderate cashback had a higher churn rate

SELECT * FROM ecommercechurn;



