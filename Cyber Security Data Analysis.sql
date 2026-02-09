CREATE DATABASE cyber_security;
USE cyber_security;

CREATE TABLE CYBER_SECURITY (
    Country CHAR(100),
    Year INT,
    Attack_Type VARCHAR(100),
    Target_Industry CHAR(100),
    Financial_loss_in_million_dollar FLOAT,
    No_of_affected_users INT,
    Attack_source VARCHAR(100),
    Security_vulnerability_type VARCHAR(100),
    Defense_mechanism_used CHAR(100),
    Incident_Resolution_Time_in_Hours INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Global_Cybersecurity_Threats_2015-2024.csv'
INTO TABLE CYBER_SECURITY
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM CYBER_SECURITY;

-- checking for duplicates

SELECT 
    Country,
    Year,
    Attack_Type,
    Target_Industry,
    Financial_loss_in_million_dollar,
    No_of_affected_users,
    Attack_source,
    Security_vulnerability_type,
    Defense_mechanism_used,
    Incident_Resolution_Time_in_Hours,
    COUNT(*) AS duplicate_count
FROM CYBER_SECURITY
GROUP BY
    Country,
    Year,
    Attack_Type,
    Target_Industry,
    Financial_loss_in_million_dollar,
    No_of_affected_users,
    Attack_source,
    Security_vulnerability_type,
    Defense_mechanism_used,
    Incident_Resolution_Time_in_Hours
HAVING COUNT(*) > 1;

-- Professional method of finding duplicates

SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY
                   Country, Year, Attack_Type, Target_Industry,
                   Financial_loss_in_million_dollar, No_of_affected_users,
                   Attack_source, Security_vulnerability_type,
                   Defense_mechanism_used, Incident_Resolution_Time_in_Hours
               ORDER BY Year
           ) AS rn
    FROM CYBER_SECURITY
) t
WHERE rn > 1;


-- ## Insights
-- # Business & Security Impact Insights

-- Which countries experience the highest number of cyber attacks? 
SELECT Country, count(*) as No_of_CyberAttacks from CYBER_SECURITY 
group by Country order by No_of_CyberAttacks desc;

-- What is the total and average financial loss by country? 
SELECT 
    Country,
    ROUND(SUM(Financial_loss_in_million_dollar), 2) AS Total_Loss,
    ROUND(AVG(Financial_loss_in_million_dollar), 2) AS Average_Loss
FROM CYBER_SECURITY
GROUP BY Country;

-- Which attack types cause the highest financial loss? 
SELECT Attack_Type, ROUND(SUM(Financial_loss_in_million_dollar), 2) AS Total_Loss 
FROM CYBER_SECURITY 
GROUP BY Attack_Type 
ORDER BY Total_Loss DESC;

-- Which industries are most frequently targeted? 
SELECT Target_Industry, COUNT(*) AS Targetted_times 
FROM CYBER_SECURITY 
GROUP BY Target_Industry 
ORDER BY Targetted_times DESC;

-- Which industries incur the highest average financial loss per attack? 
SELECT Target_Industry, 
ROUND(AVG(Financial_loss_in_million_dollar),2) AS Average_Loss_in_million_dollar 
FROM CYBER_SECURITY 
GROUP BY Target_Industry 
ORDER BY Average_Loss_in_million_dollar DESC LIMIT 3;


-- How does financial loss vary by attack source (internal vs external)? 
SELECT
    CASE
        WHEN Attack_source = 'Insider' THEN 'Internal'
        WHEN Attack_source IN ('Hacker group', 'Nation-state') THEN 'External'
        ELSE 'Unknown'
    END AS Attack_Source_Type,
    ROUND(SUM(Financial_loss_in_million_dollar), 2) AS Total_Loss_in_million_dollar
FROM CYBER_SECURITY
GROUP BY 
      CASE
        WHEN Attack_source = 'Insider' THEN 'Internal'
        WHEN Attack_source IN ('Hacker group', 'Nation-state') THEN 'External'
        ELSE 'Unknown'
        END;


-- # Time & Trend Analysis

-- How have cyber attacks evolved year over year?
SELECT
    Year,
    No_of_Attacks,
    No_of_Attacks - LAG(No_of_Attacks) OVER (ORDER BY Year) AS YoY_Change
FROM (
    SELECT
        Year,
        COUNT(*) AS No_of_Attacks
    FROM CYBER_SECURITY
    GROUP BY Year
) t
ORDER BY Year;

-- Which years recorded the highest financial losses?
SELECT 
    Year,
    ROUND(SUM(Financial_loss_in_million_dollar), 2) AS Total_Loss_in_million_dollar
FROM CYBER_SECURITY
GROUP BY Year
ORDER BY Total_Loss_in_million_dollar DESC
LIMIT 3;

-- Are incident resolution times improving or worsening over time? 
SELECT
    Year,
    Avg_Resolution_Time,
    Avg_Resolution_Time - LAG(Avg_Resolution_Time) OVER (ORDER BY Year) AS YOY_Change
FROM (
    SELECT
        Year,
        ROUND(AVG(Incident_Resolution_Time_in_Hours), 2) AS Avg_Resolution_Time
    FROM CYBER_SECURITY
    GROUP BY Year
) rt
ORDER BY Year;

-- Which attack types take the longest time to resolve? 
SELECT Attack_Type, 
ROUND(AVG(Incident_Resolution_Time_in_Hours),2) AS Avg_Resolution_Time_in_hours 
FROM CYBER_SECURITY 
GROUP BY Attack_Type 
ORDER BY Avg_Resolution_Time_in_hours DESC LIMIT 3;


-- # User Impact & Severity

-- Which attack types affect the highest number of users? 
SELECT Attack_Type, SUM(No_of_affected_users) AS Total_affected_users 
FROM CYBER_SECURITY 
GROUP BY Attack_Type 
ORDER BY Total_affected_users DESC LIMIT 3;


-- Which industries experience high user impact but lower financial loss?
SELECT 
    Target_Industry,
    ROUND(AVG(No_of_affected_users), 2) AS Average_affected_users,
    ROUND(AVG(Financial_loss_in_million_dollar), 2) AS Average_financial_loss
FROM CYBER_SECURITY
GROUP BY Target_Industry
ORDER BY Average_affected_users DESC,
         Average_financial_loss ASC LIMIT 3;

-- or (if specific)

SELECT 
    Target_Industry,
    ROUND(AVG(No_of_affected_users), 2) AS Average_affected_users,
    ROUND(AVG(Financial_loss_in_million_dollar), 2) AS Average_financial_loss
FROM CYBER_SECURITY
GROUP BY Target_Industry
HAVING AVG(No_of_affected_users) > (
    SELECT AVG(No_of_affected_users) FROM CYBER_SECURITY
)
AND AVG(Financial_loss_in_million_dollar) < (
    SELECT AVG(Financial_loss_in_million_dollar) FROM CYBER_SECURITY
);

-- What is the average number of affected users per attack type? 
SELECT 
    Attack_Type,
    ROUND(AVG(No_of_affected_users), 2) AS Avg_affected_users
FROM CYBER_SECURITY
GROUP BY Attack_Type
ORDER BY Avg_affected_users DESC;

-- # Defense & Vulnerability Effectiveness

-- Which security vulnerabilities are most commonly exploited? 
SELECT Security_vulnerability_type, COUNT(*) AS No_of_Times_Exploited 
FROM CYBER_SECURITY 
GROUP BY Security_vulnerability_type 
ORDER BY No_of_Times_Exploited DESC;


-- Which defense mechanisms are used most frequently?
SELECT Defense_mechanism_used,
COUNT(*) AS No_of_times_used
FROM CYBER_SECURITY 
GROUP BY Defense_mechanism_used
ORDER BY No_of_times_used DESC LIMIT 3;


-- Which defense mechanisms are associated with lower resolution times?
SELECT
Defense_mechanism_used, 
ROUND(AVG(Incident_Resolution_Time_in_Hours),2) AS Avg_resolution_time
FROM CYBER_SECURITY 
GROUP BY Defense_mechanism_used
ORDER BY Avg_resolution_time ASC;

-- Which vulnerabilities lead to higher financial loss despite defense mechanisms?
SELECT
    Security_vulnerability_type,
    ROUND(AVG(Financial_loss_in_million_dollar), 2) AS Avg_financial_loss
FROM CYBER_SECURITY
WHERE Defense_mechanism_used IS NOT NULL
GROUP BY Security_vulnerability_type
HAVING AVG(Financial_loss_in_million_dollar) >
       (SELECT AVG(Financial_loss_in_million_dollar) FROM CYBER_SECURITY)
ORDER BY Avg_financial_loss DESC;

-- # Performance & Efficiency Metrics

-- Which countries have the fastest average incident resolution time?
SELECT Country, ROUND(AVG(Incident_Resolution_Time_in_Hours),2) AS Avg_Incident_Resolution_time
FROM CYBER_SECURITY
GROUP BY Country ORDER BY Avg_Incident_Resolution_time ASC LIMIT 3;

-- Which industries resolve incidents most efficiently?
SELECT
    Target_Industry,
    ROUND(AVG(Incident_Resolution_Time_in_Hours), 2) AS Avg_Resolution_Time
FROM CYBER_SECURITY
GROUP BY Target_Industry
ORDER BY Avg_Resolution_Time ASC LIMIT 3;

-- What is the average resolution time by attack type?
SELECT Attack_Type, ROUND(AVG(Incident_Resolution_Time_in_Hours), 2) AS Avg_Resolution_Time
FROM CYBER_SECURITY
GROUP BY Attack_Type
ORDER BY Avg_Resolution_Time;

-- Which combinations of attack type and defense mechanism are most effective?
SELECT Attack_Type, Defense_mechanism_used, 
ROUND(AVG(Incident_Resolution_Time_in_Hours), 2) AS Avg_Resolution_Time
FROM CYBER_SECURITY
GROUP BY Attack_Type, Defense_mechanism_used
ORDER BY Avg_Resolution_Time LIMIT 10;

-- # Other factors

-- Rank attack types by financial loss using window functions.
SELECT Attack_Type,
ROUND(SUM(Financial_loss_in_million_dollar),2) AS Total_Financial_Loss,
RANK() OVER (ORDER BY SUM(Financial_loss_in_million_dollar) DESC) AS Loss_Rank 
FROM CYBER_SECURITY
GROUP BY Attack_Type;

-- Identify top 3 countries per year with the highest losses.
SELECT Year, Country,Total_Financial_Loss
FROM 
(
SELECT 
Year, 
Country,
ROUND(SUM(Financial_loss_in_million_dollar),2) AS Total_Financial_Loss,
Dense_Rank() OVER(
PARTITION BY year
ORDER BY SUM(Financial_loss_in_million_dollar) DESC
) AS Loss_Rank
FROM CYBER_SECURITY
GROUP BY Year,Country
)t
WHERE loss_rank <= 3
ORDER BY Year, loss_rank;

-- Classify attacks into High / Medium / Low severity using CASE.
-- only based on incident resolution time
SELECT
    Country,
    Year,
    Attack_Type,
    Incident_Resolution_Time_in_Hours,
    CASE
        WHEN Incident_Resolution_Time_in_Hours < 25 THEN 'Low'
        WHEN Incident_Resolution_Time_in_Hours < 45 THEN 'Medium'
        ELSE 'High'
    END AS Severity_Level
FROM CYBER_SECURITY;

-- considered both incident resolution time and financial loss
SELECT
    Attack_Type,
    Incident_Resolution_Time_in_Hours,
    Financial_loss_in_million_dollar,
    CASE
        WHEN Incident_Resolution_Time_in_Hours >= 48
          OR Financial_loss_in_million_dollar >= 20 THEN 'High'
        WHEN Incident_Resolution_Time_in_Hours >= 24
          OR Financial_loss_in_million_dollar >= 5 THEN 'Medium'
        ELSE 'Low'
    END AS Severity_Level
FROM CYBER_SECURITY;

-- Detect outliers in financial loss or resolution time.
SELECT
    AVG(Incident_Resolution_Time_in_Hours) AS avg_time,
    STDDEV(Incident_Resolution_Time_in_Hours) AS std_time,
    AVG(Financial_loss_in_million_dollar) AS avg_loss,
    STDDEV(Financial_loss_in_million_dollar) AS std_loss
FROM CYBER_SECURITY;

SELECT
    Country,
    Attack_Type,
    Incident_Resolution_Time_in_Hours,
    Financial_loss_in_million_dollar
FROM CYBER_SECURITY
WHERE Incident_Resolution_Time_in_Hours >
      (SELECT AVG(Incident_Resolution_Time_in_Hours) 
       + 2 * STDDEV(Incident_Resolution_Time_in_Hours)
       FROM CYBER_SECURITY)
   OR Financial_loss_in_million_dollar >
      (SELECT AVG(Financial_loss_in_million_dollar) 
       + 2 * STDDEV(Financial_loss_in_million_dollar)
       FROM CYBER_SECURITY);


-- Compare internal vs external attack sources on impact and resolution.
SELECT
	CASE
	WHEN Attack_source = 'Insider' THEN 'Internal'
	WHEN Attack_source IN ('Hacker group', 'Nation-state') THEN 'External'
	ELSE 'Unknown'
	END
AS Attack_Source_Type,
ROUND(AVG(Incident_Resolution_Time_in_Hours),2) AS Avg_Resolution_Time,
ROUND(AVG(Financial_loss_in_million_dollar), 2) AS Avg_Loss,
ROUND(SUM(No_of_affected_users),2) AS No_of_affected_users
FROM CYBER_SECURITY
GROUP BY
	CASE
	WHEN Attack_source = 'Insider' THEN 'Internal'
	WHEN Attack_source IN ('Hacker group', 'Nation-state') THEN 'External'
	ELSE 'Unknown'
	END;
    

