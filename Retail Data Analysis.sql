CREATE DATABASE RETAIL_DATA;
USE RETAIL_DATA;

CREATE TABLE RETL_TRAN 
( customer_id VARCHAR(255),
trans_date VARCHAR(255),
tran_amount INT );

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Retail_Data_Transactions.csv"
 INTO TABLE RETL_TRAN
 FIELDS TERMINATED BY ","
 LINES TERMINATED BY '\n'
 IGNORE 1 ROWS;

CREATE TABLE RETL_RESP
( customer_id VARCHAR(255),
response INT );

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Retail_Data_Response.csv"
 INTO TABLE RETL_RESP
 FIELDS TERMINATED BY ","
 LINES TERMINATED BY '\n'
 IGNORE 1 ROWS;

SELECT * FROM RETL_TRAN;

-- Adding a date column to convert the datatype of the existing date column
 ALTER TABLE RETL_TRAN ADD COLUMN trans_date_new DATE;

-- Turning off sql safe updates to update column without where case
SET sql_safe_updates=0;

-- Updating the new date column with the correct date format
UPDATE RETL_TRAN SET trans_date_new = STR_TO_DATE(trans_date, '%d-%b-%y');

SET sql_safe_updates=1;

-- Deleting the old date column
ALTER TABLE RETL_TRAN DROP COLUMN trans_date;

-- Renaming the new column
ALTER TABLE RETL_TRAN
RENAME COLUMN trans_date_new TO trans_date;

-- Getting insights from the data

-- What is the average spend per customer for responders (response = 1) vs non-responders (response = 0)?
SELECT r.response, AVG(tran_amount) AS Avg_spend
FROM RETL_TRAN t
JOIN RETL_RESP r ON t.customer_id = r.customer_id
GROUP BY r.response;

-- How does total transaction amount vary by month?
SELECT DATE_FORMAT(trans_date, '%y-%m') AS Month, SUM(tran_amount) AS Monthly_sales
FROM RETL_TRAN
GROUP BY Month
ORDER BY Month ;

-- What percentage of customers responded (response = 1)?
SELECT COUNT(CASE WHEN response = 1 THEN 1 END)*100 / COUNT(*) AS RESPONSE_RATE FROM RETL_RESP;


-- Is there a difference in total spend between responders and non-responders?
SELECT r.response, SUM(t.tran_amount) AS Total_Spent
FROM RETL_RESP r
JOIN RETL_TRAN t ON r.customer_id=t.customer_id
GROUP BY r.response;


-- Are recent purchasers more likely to respond?
SELECT r.response, AVG(DATEDIFF(CURRENT_DATE, last_purchase_date)) AS avg_days_since_last_purchase
FROM (
    SELECT 
        customer_id,
        MAX(trans_date) AS last_purchase_date
    FROM RETL_TRAN
    GROUP BY customer_id
) AS recent
JOIN RETL_RESP r ON recent.customer_id = r.customer_id
GROUP BY r.response;


-- What is the average total spend per customer grouped by response?
SELECT r.response, AVG(total_spent) AS avg_lifetime_value
FROM (
    SELECT customer_id, SUM(tran_amount) AS total_spent
    FROM RETL_TRAN
    GROUP BY customer_id
) t
JOIN RETL_RESP r ON t.customer_id = r.customer_id
GROUP BY r.response;


-- Do frequent shoppers respond more often?

SELECT r.response,
       CASE 
           WHEN tran_count = 1 THEN '1'
           WHEN tran_count BETWEEN 2 AND 5 THEN '2-5'
           ELSE '6+' 
       END AS tran_count_segment,
       COUNT(*) AS customers
FROM (
    SELECT customer_id, COUNT(*) AS tran_count
    FROM RETL_TRAN
    GROUP BY customer_id
) t
JOIN RETL_RESP r ON t.customer_id = r.customer_id
GROUP BY r.response, tran_count_segment
ORDER BY tran_count_segment;



