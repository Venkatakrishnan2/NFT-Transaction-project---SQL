USE CRYPTOPUNKDATA;

ALTER TABLE PRICEDATA RENAME COLUMN ï»¿buyer_address TO buyer_address;

-- 1.	How many sales occurred during this time period? 

SELECT COUNT(*) FROM PRICEDATA;

-- 2.	Return the top 5 most expensive transactions (by USD price) for this data set. 
-- Return the name, ETH price, and USD price, as well as the date.

SELECT DAY, NAME, ETH_PRICE, USD_PRICE FROM PRICEDATA 
ORDER BY USD_PRICE DESC 
LIMIT 5;

-- 3.	Return a table with a row for each transaction with an event column, 
-- a USD price column, and a moving average of USD price that averages the last 50 transactions.

SELECT DAY AS EVENT, USD_PRICE, AVG(USD_PRICE)
OVER(ORDER BY DAY 
ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS "MOVING_AVERAGE"
FROM PRICEDATA;

-- 4.	Return all the NFT names and their average sale price in USD. Sort descending. 
-- Name the average column as average_price.

SELECT NAME, AVG(USD_PRICE) AS AVERAGE_PRICE FROM PRICEDATA
GROUP BY NAME
ORDER BY AVERAGE_PRICE DESC;

-- 5.	Return each day of the week and the number of sales that occurred on that day 
-- of the week, as well as the average price in ETH. Order by the count of 
-- transactions in ascending order.

SELECT DAYOFWEEK(DAY), COUNT(USD_PRICE), AVG(ETH_PRICE) 
FROM PRICEDATA
GROUP BY DAYOFWEEK(DAY)
ORDER BY COUNT(USD_PRICE) ASC;

-- 6.	Construct a column that describes each sale and is called summary. The sentence 
-- should include who sold the NFT name, who bought the NFT, who sold the NFT, the date, 
-- and what price it was sold for in USD rounded to the nearest thousandth.
--  Here’s an example summary:
--  “CryptoPunk #1139 was sold for $194000 to 0x91338ccfb8c0adb7756034a82008531d7713009d 
-- from 0x1593110441ab4c5f2c133f21b0743b2b43e297cb on 2022-01-14”

SELECT CONCAT(NAME, ' WAS SOLD FOR $', ROUND(USD_PRICE, -3), 
' TO ', BUYER_ADDRESS, ' FROM ', SELLER_ADDRESS, ' ON ', DAY ) AS SUMMARY
FROM PRICEDATA;

-- 7.	Create a view called “1919_purchases” and contains any sales where 
-- “0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685” was the buyer.

CREATE VIEW 1919_PURCHASES AS
SELECT * FROM PRICEDATA
WHERE BUYER_ADDRESS = '0X1919DB36CA2FA2E15F9000FD9CDC2EDCF863E685';

SELECT * FROM 1919_PURCHASES;

-- 8.	Return a unioned query that contains the highest price each NFT was bought for 
-- and a new column called status saying “highest” with a query that has the lowest price 
-- each NFT was bought for and the status column saying “lowest”. The table should have a 
-- name column, a price column called price, and a status column. Order the result set 
-- by the name of the NFT, and the status, in ascending order. 

SELECT NAME, MAX(USD_PRICE) AS PRICE, 'HIGHEST' AS STATUS FROM PRICEDATA
GROUP BY NAME
UNION 
SELECT NAME, MIN(USD_PRICE) AS PRICE, 'LOWEST' AS STATUS FROM PRICEDATA
GROUP BY NAME
ORDER BY NAME, STATUS;

-- 9.	What NFT sold the most each month / year combination? Also, what was the name and 
-- the price in USD? Order in chronological format. 

SELECT NAME, USD_PRICE, CONCAT(MONTH(DAY), '/', YEAR(DAY)) AS MONTH_YEAR
FROM PRICEDATA
ORDER BY DAY; 

-- 10.	Return the total volume (sum of all sales), round to the nearest hundred on a monthly 
-- basis (month/year).

SELECT DAY, ROUND(SUM(USD_PRICE),-2)
FROM PRICEDATA
GROUP BY DAY
ORDER BY DAY;

-- 11.	Count how many transactions the wallet "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685"had 
-- over this time period.

SELECT COUNT(*)
FROM PRICEDATA
WHERE BUYER_ADDRESS = "0X1919DB36CA2FA2E15F9000FD9CDC2EDCF863E685" 
OR SELLER_ADDRESS = "0X1919DB36CA2FA2E15F9000FD9CDC2EDCF863E685";

-- 12.	Create an “estimated average value calculator” that has a representative price of the collection every day based off of these criteria:
--  - Exclude all daily outlier sales where the purchase price is below 10% of the daily average price
--  - Take the daily average of remaining transactions
--  a) First create a query that will be used as a subquery. Select the event date, 
-- the USD price, and the average USD price for each day using a window function. 
-- Save it as a temporary table.

CREATE TEMPORARY TABLE TEMP_TABLE AS
SELECT DAY, USD_PRICE, AVG(USD_PRICE) OVER(ORDER BY DAY) AS DAILY_AVG
FROM PRICEDATA;

SELECT * FROM TEMP_TABLE;

--  b) Use the table you created in Part A to filter out rows where the USD prices is below 
-- 10% of the daily average and return a new estimated value which is just the daily 
-- average of the filtered data.

SELECT DAY, AVG(USD_PRICE) AS NEW_AVERAGE 
FROM TEMP_TABLE
WHERE USD_PRICE > .1*DAILY_AVG 
GROUP BY DAY;





