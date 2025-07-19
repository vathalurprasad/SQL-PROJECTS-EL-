-- COVID-19 DATA ANALYTICS SQL SCRIPT
create schema covid_analysis;
-- Step 1: Create Table
CREATE TABLE covid_data (
    Date TEXT,
    Country TEXT,
    Confirmed INTEGER,
    Deaths INTEGER,
    Recovered INTEGER,
    Active INTEGER
);

-- Step 2: Insert Sample Data
INSERT INTO covid_data VALUES ('2025-07-01', 'India', 1000, 10, 900, 90);
INSERT INTO covid_data VALUES ('2025-07-01', 'USA', 1500, 20, 1200, 280);
INSERT INTO covid_data VALUES ('2025-07-01', 'Brazil', 800, 5, 700, 95);
INSERT INTO covid_data VALUES ('2025-07-02', 'India', 1100, 12, 950, 138);
INSERT INTO covid_data VALUES ('2025-07-02', 'USA', 1600, 25, 1300, 275);
INSERT INTO covid_data VALUES ('2025-07-02', 'Brazil', 850, 8, 720, 122);
INSERT INTO covid_data VALUES ('2025-07-03', 'India', 1200, 14, 980, 206);
INSERT INTO covid_data VALUES ('2025-07-03', 'USA', 1700, 22, 1400, 278);
INSERT INTO covid_data VALUES ('2025-07-03', 'Brazil', 900, 6, 750, 144);

select * from covid_data;
-- Step 3: Total Confirmed Cases by Country

SELECT Country, SUM(Confirmed) AS TotalConfirmed
FROM covid_data
GROUP BY Country
ORDER BY TotalConfirmed DESC;

-- Step 4: Total Deaths by Country
SELECT Country, SUM(Deaths) AS TotalDeaths
FROM covid_data
GROUP BY Country
ORDER BY TotalDeaths DESC;

-- Step 5: Total Recovered by Country
SELECT Country, SUM(Recovered) AS TotalRecovered
FROM covid_data
GROUP BY Country
ORDER BY TotalRecovered DESC;

-- Step 6: Active Cases Trend (Daily)
SELECT Date, Country, Active
FROM covid_data
ORDER BY Country, Date;

-- Step 7: Daily New Cases (Confirmed difference)
SELECT a.Date, a.Country,
       a.Confirmed - b.Confirmed AS DailyNewCases
FROM covid_data a
JOIN covid_data b 
  ON a.Country = b.Country 
 AND a.Date = DATE_ADD(b.Date, INTERVAL 1 DAY);

-- Step 8: 3-Day Rolling Average of New Cases
WITH daily_cases AS (
  SELECT a.Date, a.Country, (a.Confirmed - b.Confirmed) AS DailyNewCases
  FROM covid_data a
  JOIN covid_data b 
    ON a.Country = b.Country AND a.Date = DATE_ADD(b.Date, INTERVAL 1 DAY)
)
SELECT Country, Date,
       AVG(DailyNewCases) OVER (
         PARTITION BY Country 
         ORDER BY Date 
         ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ) AS RollingAvg
FROM daily_cases;

-- Step 9: Countries with Highest Recovery Rate
SELECT Country,
       SUM(Recovered)*1.0 / SUM(Confirmed) AS RecoveryRate
FROM covid_data
GROUP BY Country
ORDER BY RecoveryRate DESC;

-- Step 10: Daily Death Rate per Country
SELECT Date, Country,
       ROUND((Deaths*100.0)/Confirmed, 2) AS DailyDeathRate
FROM covid_data;

-- Step 11: Total Cases Over Time
SELECT Date, SUM(Confirmed) AS TotalGlobalCases
FROM covid_data
GROUP BY Date
ORDER BY Date;

-- Step 12: View - Summary per Country
CREATE VIEW covid_summary AS
SELECT Country,
       SUM(Confirmed) AS TotalConfirmed,
       SUM(Deaths) AS TotalDeaths,
       SUM(Recovered) AS TotalRecovered,
       SUM(Active) AS TotalActive
FROM covid_data
GROUP BY Country;

SELECT * FROM covid_summary;

-- Step 13: Query from View
SELECT * FROM covid_summary ORDER BY TotalConfirmed DESC;

-- Step 14: View - Daily Summary
CREATE VIEW daily_summary AS
SELECT Date,
       SUM(Confirmed) AS Confirmed,
       SUM(Deaths) AS Deaths,
       SUM(Recovered) AS Recovered,
       SUM(Active) AS Active
FROM covid_data
GROUP BY Date;

select * from daily_summary;

-- Step 15: Top Country per Day by Confirmed Cases
SELECT Date, Country, Confirmed
FROM (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY Date ORDER BY Confirmed DESC) AS rn
  FROM covid_data
) sub
WHERE rn = 1;

-- Step 16: Country-wise Average Daily Cases
SELECT Country, AVG(Confirmed) AS AvgConfirmedPerDay
FROM covid_data
GROUP BY Country;

-- Step 17: Death Rate Over Time
SELECT Date, SUM(Deaths)*1.0 / SUM(Confirmed) AS GlobalDeathRate
FROM covid_data
GROUP BY Date;

-- Step 18: Country Growth Rate (Confirmed)
WITH prev_day AS (
  SELECT a.Date, a.Country, 
         (a.Confirmed - b.Confirmed)*1.0 / b.Confirmed AS GrowthRate
  FROM covid_data a
  JOIN covid_data b ON a.Country = b.Country AND a.Date = DATE_ADD(b.Date, INTERVAL 1 DAY)
)
SELECT * FROM prev_day
ORDER BY Country, Date;

-- End of Script
