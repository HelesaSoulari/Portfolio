# World_life_expectancy (Data Cleaning)
# I break this down into two different phases: Data Cleaning and Exploratory Data Analysis (EDA) includes grouping and using window functions. 
# In most cases, these two phases should be done alongside each other. However, in this project, I will do each separately.
--


SELECT * FROM worldlifexpectancy;

# The following query is to identify if there is any duplicates in our data and identify those records.

SELECT Country, Year, concat(Country, year), count(concat(Country, year))
FROM worldlifexpectancy
	GROUP BY Country, Year, concat(Country, year)
	HAVING count(concat(Country, year)) > 1
;

# The following query keeps only duplicate rows for each Country and year, removing the first one.

SELECT *
FROM (
	SELECT Row_ID, concat(Country, year), 
	ROW_NUMBER() OVER ( PARTITION BY concat(Country, year) 
	ORDER BY concat(Country, year)) 
			AS Row_Num
	FROM worldlifexpectancy)
AS Row_Table
WHERE Row_num > 1
    ;

SET SQL_SAFE_UPDATES = 0;


DELETE FROM worldlifexpectancy
WHERE 
		Row_ID IN (
				SELECT ROW_ID
				FROM (
					SELECT Row_ID, concat(Country, year), 
					ROW_NUMBER() OVER ( PARTITION BY concat(Country, year) 
					ORDER BY concat(Country, year)) 
							AS Row_Num
					FROM worldlifexpectancy)
				AS Row_Table
				WHERE Row_Num > 1
					)
					;

# Identify the null values in the Status column
	
SELECT *
FROM worldlifexpectancy
WHERE Status = '';

-- To find all unique values in the Status column that are not empty
SELECT DISTINCT (Status)
FROM worldlifexpectancy
WHERE Status <> '';

#
SELECT DISTINCT (Country)
FROM worldlifexpectancy
WHERE Status = 'Developing';

-- Let's make the changes using try and error. (Although the following code will cause and error)
UPDATE worldlifexpectancy
SET Status = 'Developing'
WHERE Country IN (
					SELECT DISTINCT (Country)
					FROM worldlifexpectancy
					WHERE Status = 'Developing');

# This one works!! However, this only affects 'Developing' countries.
UPDATE worldlifexpectancy t1
JOIN worldlifexpectancy t2
			ON t1.Country = t2.Country
		SET t1.Status = 'Developing'
		WHERE t1.Status = ''
		AND t2.Status <> ''
		AND t2. Status = 'Developing'
;

-- Therefore, we change it to 'Developed' countries this time:
UPDATE worldlifexpectancy t1
JOIN worldlifexpectancy t2
			ON t1.Country = t2.Country
		SET t1.Status = 'Developed'
		WHERE t1.Status = ''
		AND t2.Status <> ''
		AND t2. Status = 'Developed'
;


SELECT * FROM worldlifexpectancy



SELECT t1.Country, t1.year, t1.`LifeExpectancy`,
       t2.Country, t2.year, t2.`LifeExpectancy`,
       t3.Country, t3.year, t3.`LifeExpectancy`,
      ROUND((t2. `LifeExpectancy` + t3. `LifeExpectancy`)/2,1)
FROM worldlifexpectancy t1
JOIN worldlifexpectancy t2
    ON t1.Country = t2.Country
    AND t1.year = t2.year - 1
JOIN worldlifexpectancy t3
    ON t1.Country = t3.Country
    AND t1.year = t3.year + 1 
WHERE t1.`LifeExpectancy` = '';

SELECT *
FROM worldlifexpectancy;


UPDATE worldlifexpectancy t1
JOIN worldlifexpectancy t2
    ON t1.Country = t2.Country
    AND t1.year = t2.year - 1
JOIN worldlifexpectancy t3
    ON t1.Country = t3.Country
    AND t1.year = t3.year + 1 
SET t1.`LifeExpectancy` =  ROUND((t2. `LifeExpectancy` + t3. `LifeExpectancy`)/2,1)
WHERE t1.`LifeExpectancy` = ''
;

-- END of Data Cleaning

# World_life_expectancy (Exploratory Data Analysis (EDA))
-- I would like to see how each country has been doing in terms of life expectancy over the past 15 years.

SELECT *
FROM worldlifexpectancy
;

SELECT Country, MIN(`LifeExpectancy`), MAX(`LifeExpectancy`)
FROM worldlifexpectancy
GROUP BY Country
ORDER BY Country DESC
;

-- Here we find some data quality issues. If we consider the above query, MIN and MAX values for some countries are 0.
SELECT Country, 
	MIN(`LifeExpectancy`), 
	MAX(`LifeExpectancy`),
	ROUND(MAX(`LifeExpectancy`) - MIN(`LifeExpectancy`),1) AS Life_Increase
FROM worldlifexpectancy
GROUP BY Country
HAVING MIN(`LifeExpectancy`) <> 0
AND MAX (`LifeExpectancy`) <> 0
ORDER BY Country DESC
;
SELECT Country, 
    MIN(`LifeExpectancy`) AS Min_LifeExpectancy, 
    MAX(`LifeExpectancy`) AS Max_LifeExpectancy,
    ROUND(MAX(`LifeExpectancy`) - MIN(`LifeExpectancy`), 1) AS Life_Increase
FROM worldlifexpectancy
GROUP BY Country
HAVING MIN(`LifeExpectancy`) <> 0
   AND MAX(`LifeExpectancy`) <> 0
ORDER BY Country DESC;


SELECT Year, ROUND(AVG(`LifeExpectancy`),2)
FROM worldlifexpectancy
WHERE `LifeExpectancy`<> 0
   AND `LifeExpectancy`<> 0
GROUP BY Year 
ORDER BY Year
;

SELECT Country, 
ROUND(AVG(LifeExpectancy),1) AS Life_Exp, 
ROUND(AVG(GDP),1) AS GDP
FROM worldlifexpectancy
GROUP BY Country
;


# Using the above query, we find some countries like Bahamas having zero GDP. Let's fix this:
SELECT Country, 
ROUND(AVG(LifeExpectancy),1) AS Life_Exp, 
ROUND(AVG(GDP),1) AS GDP
FROM worldlifexpectancy
GROUP BY Country
HAVING Life_Exp > 0
AND GDP > 0
ORDER BY GDP DESC
;


# **Objective: Analyzing the Correlation Between GDP and Life Expectancy**
-- This section, we aim to investigate if there is any correlation between GDP and life expectancy. This analysis is a key part of our Exploratory Data Analysis (EDA).
SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) High_GDP_Count,
AVG(CASE WHEN GDP >= 1500 THEN `LifeExpectancy` ELSE NULL END) High_GDP_Life_Expectancy,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) Low_GDP_Count,
AVG(CASE WHEN GDP <= 1500 THEN `LifeExpectancy` ELSE NULL END) Low_GDP_Life_Expectancy
FROM worldlifexpectancy
;

SELECT Status, ROUND(AVG(`LifeExpectancy`),1)
FROM worldlifexpectancy
GROUP BY Status
;

SELECT Status, COUNT(DISTINCT Country), ROUND(AVG(`LifeExpectancy`),1)
FROM worldlifexpectancy
GROUP BY Status
;

SELECT *
FROM worldlifexpectancy;

SELECT Country, 
ROUND(AVG(LifeExpectancy),1) AS Life_Exp, 
ROUND(AVG(BMI),1) AS BMI
FROM worldlifexpectancy
GROUP BY Country
HAVING Life_Exp > 0
AND BMI > 0
ORDER BY BMI DESC
;

SELECT *
FROM worldlifexpectancy;

# Rolling Total (Using Window Function)
#Let's take a look at 'Life Mortality' using rolling Total!
SELECT Country,
Year,
`LifeExpectancy`,
`AdultMortality`,
SUM(`AdultMortality`) OVER (PARTITION BY Country ORDER BY Year)
AS Rolling_Total
FROM worldlifexpectancy
WHERE Country LIKE '%United%';  
-- This indicates, for instance, the total number of people who have died in each country over the 15-year period from 2007 to 2022.
-- In Afghanistan, the total for this 15 years is 4305.
-- We can specify the query for each country. 


# END of EDA









