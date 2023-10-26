-- Create a View called “forestation” by joining all three tables - forest_area, land_area and regions in the workspace.
CREATE VIEW forestation
AS
SELECT fa.country_code AS country_code
	,fa.country_name AS country_name
	,fa.year AS year
	,fa.forest_area_sqkm AS forest_area_sqkm
	,la.total_area_sq_mi AS total_area_sq_mi
	,r.region AS region
	,r.income_group AS income_group
	,(forest_area_sqkm / (total_area_sq_mi * 2.59)) * 100 AS percent_forest_area
FROM forest_area fa
INNER JOIN land_area la
	ON fa.country_code = la.country_code
		AND fa.year = la.year
INNER JOIN regions r
	ON la.country_code = r.country_code
ORDER BY 1;

-- . GLOBAL SITUATION
-- a. What was the total forest area (in sq km) of the world in 1990? Please keep in mind that you can use the country record denoted as “World" in the region table.
SELECT forest_area_sqkm
FROM forestation
WHERE region = 'World'
	AND year = 1990
-- 41282694.9

-- 3. What was the change (in sq km) in the forest area of the world from 1990 to 2016?
WITH t1
AS (
	SELECT region
		,forest_area_sqkm AS fa
	FROM forestation
	WHERE region = 'World'
		AND year = 1990
	)
	,t2
AS (
	SELECT region
		,forest_area_sqkm AS fa
	FROM forestation
	WHERE region = 'World'
		AND year = 2016
	)
SELECT t1.fa - t2.fa AS change_sqkm
FROM t1
INNER JOIN t2
	ON t1.region = t2.region

--1324449


-- 4. What was the percent change in forest area of the world between 1990 and 2016?
WITH t1
AS (
	SELECT region
		,forest_area_sqkm AS fa
	FROM forestation
	WHERE region = 'World'
		AND year = 1990
	)
	,t2
AS (
	SELECT region
		,forest_area_sqkm AS fa
	FROM forestation
	WHERE region = 'World'
		AND year = 2016
	)
SELECT (t1.fa - t2.fa) / t1.fa * 100 AS change_percent
FROM t1
INNER JOIN t2
	ON t1.region = t2.region
--3.20824258980244

--5. If you compare the amount of forest area lost between 1990 and 2016, to which country's total area in 2016 is it closest to? 
SELECT f.country_code cc
	,f.country_name country
	,f.total_area_sq_mi * 2.59 AS total_area
FROM forestation f
WHERE (f.total_area_sq_mi * 2.59) >= (
		WITH t1 AS (
				SELECT region
					,forest_area_sqkm AS fa
				FROM forestation
				WHERE region = 'World'
					AND year = 1990
				)
			,t2 AS (
				SELECT region
					,forest_area_sqkm AS fa
				FROM forestation
				WHERE region = 'World'
					AND year = 2016
				)
		SELECT t1.fa - t2.fa AS change_sqkm
		FROM t1
		INNER JOIN t2
			ON t1.region = t2.region
		)
ORDER BY 3 LIMIT 1
--MANGOLIA

SELECT f.country_code cc
	,f.country_name country
	,f.total_area_sq_mi * 2.59 AS total_area
FROM forestation f
WHERE (f.total_area_sq_mi * 2.59) < (
		WITH t1 AS (
				SELECT region
					,forest_area_sqkm AS fa
				FROM forestation
				WHERE region = 'World'
					AND year = 1990
				)
			,t2 AS (
				SELECT region
					,forest_area_sqkm AS fa
				FROM forestation
				WHERE region = 'World'
					AND year = 2016
				)
		SELECT t1.fa - t2.fa AS change_sqkm
		FROM t1
		INNER JOIN t2
			ON t1.region = t2.region
		)
ORDER BY 3 DESC LIMIT 1 -
--PERU


--A- Create a table that shows the Regions and their percent forest area (sum of forest area divided by sum of land area) in 1990 and 2016. (Note that 1 sq mi = 2.59 sq km).Based on the table you created,
CREATE
	OR REPLACE VIEW region_forest AS

SELECT region
	,year
	,SUM(forest_area_sqkm) total_region_forest
	,SUM(total_area_sq_mi) * 2.59 total_region_land
	,100 * SUM(forest_area_sqkm) / (SUM(total_area_sq_mi) * 2.59) AS percent_forest
FROM forestation
GROUP BY 1
	,2
ORDER BY 1
	,2;


-- a, What was the percent forest of the entire world in 2016? Which region had the HIGHEST percent forest in 2016, and which had the LOWEST, to 2 decimal places? 
--WORLD:
SELECT region
	,percent_forest
FROM region_forest
WHERE year = 2016
	AND region = 'World' region percent_forest
--World 31.3755709643095


--HIGHEST : 
SELECT region
	,percent_forest
FROM region_forest
WHERE year = 2016
ORDER BY 2 DESC Limit 1
	--region, percent_forest
	--Latin America & Caribbean, 46.1620721996047
	

-- LOWEST: 
SELECT region
	,percent_forest
FROM region_forest
WHERE year = 2016
ORDER BY 2 Limit 1
	--region percent_forest
	--Middle East & North Africa 2.0682648687150
	

--b) What was the percent forest of the entire world in 1990? Which region had the HIGHEST percent forest in 1990, and which had the LOWEST, to 2 decimal places?
--WORLD)
SELECT region
	,percent_forest
FROM region_forest
WHERE year = 1990
	AND region = 'World'
	--region percent_forest
	--World 32.4222035575689


--HIGHEST)
SELECT region
	,percent_forest
FROM region_forest
WHERE year = 1990
ORDER BY 2 DESC Limit 1
	--region percent_forest
	--Latin America & Caribbean 51.0299798667514
	
--LOWEST
SELECT region
	,percent_forest
FROM region_forest
WHERE year = 1990
ORDER BY 2 Limit 1
	--region percent_forest
	--Middle East & North Africa 1.77524062469353



--c) Based on the table you created, which regions of the world DECREASED in forest area from 1990 to 2016?
WITH t1
AS (
	SELECT *
	FROM region_forest
	WHERE year = 1990
	)
	,t2
AS (
	SELECT *
	FROM region_forest
	WHERE year = 2016
	)
SELECT t1.region
	,t1.percent_forest forest_1990
	,t2.percent_forest forest_2016
FROM t1
INNER JOIN t2
	ON t1.region = t2.region
WHERE t1.percent_forest > t2.percent_forest

--region, forest_1990, forest_2016
--Latin America & Caribbean 51.0299798667514 46.1620721996047
--Sub-Saharan Africa 30.6741454610006 28.7881883550464
--World 32.4222035575689 31.3755709643095


--3. COUNTRY-LEVEL DETAIL
--Instructions:
--Answering these questions will help you add information to the template.
--Use these questions as guides to write SQL queries.
--Use the output from the query to answer these questions.
--Country with largest increase in forest area


--ABSOLUTE INCREASE COUNTRYWISE
WITH t1
AS (
	SELECT country_code
		,country_name
		,forest_area_sqkm
	FROM forestation
	WHERE year = 1990
		AND forest_area_sqkm IS NOT NULL
		AND country_name != 'World'
	)
	,t2
AS (
	SELECT country_code
		,country_name
		,forest_area_sqkm
	FROM forestation
	WHERE year = 2016
		AND forest_area_sqkm IS NOT NULL
		AND country_name != 'World'
	)
SELECT t2.country_code
	,t2.country_name
	,(t2.forest_area_sqkm - t1.forest_area_sqkm) AS change_forest_area
FROM t1
INNER JOIN t2
	ON t1.country_code = t2.country_code
ORDER BY 3 DESC LIMIT 5
--country_code country_name change_forest_area
--CHN China 527229.062


--PERCENTAGE – LARGEST COUNTIRYWISE INCREASE
WITH t1
AS (
	SELECT country_code
		,country_name
		,forest_area_sqkm
	FROM forestation
	WHERE year = 1990
		AND forest_area_sqkm IS NOT NULL
		AND country_name != 'World'
	)
	,t2
AS (
	SELECT country_code
		,country_name
		,forest_area_sqkm
	FROM forestation
	WHERE year = 2016
		AND forest_area_sqkm IS NOT NULL
		AND country_name != 'World'
	)
SELECT t1.country_code
	,t1.country_name
	,ROUND(CAST(((t2.forest_area_sqkm - t1.forest_area_sqkm) * 100 / t1.forest_area_sqkm) AS NUMERIC), 2) AS percent_change_forest_area
FROM t1
INNER JOIN t2
	ON t1.country_code = t2.country_code
ORDER BY 3 DESC LIMIT 5


--a. Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? What was the difference in forest area for each?
WITH t1
AS (
	SELECT country_code
		,region
		,country_name
		,forest_area_sqkm
	FROM forestation
	WHERE year = 1990
		AND forest_area_sqkm IS NOT NULL
		AND country_name != 'World'
	)
	,t2
AS (
	SELECT country_code
		,region
		,country_name
		,forest_area_sqkm
	FROM forestation
	WHERE year = 2016
		AND forest_area_sqkm IS NOT NULL
		AND country_name != 'World'
	)
SELECT t1.country_code
	,t1.country_name
	,t1.region
	,(t1.forest_area_sqkm - t2.forest_area_sqkm) AS change_forest_area
FROM t1
INNER JOIN t2
	ON t1.country_code = t2.country_code
ORDER BY 4 DESC LIMIT 5

--country_code, country_name, change_forest_area
--BRA, Brazil, 541510
--IDN, Indonesia, 282193.9844
--MMR, Myanmar, 107234.0039
--NGA, Nigeria, 106506.00098
--TZA, Tanzania, 102320


--b. Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? What was the percent change to 2 decimal places for each?
WITH t1
AS (
	SELECT country_code
		,region
		,country_name
		,forest_area_sqkm
	FROM forestation
	WHERE year = 1990
		AND forest_area_sqkm IS NOT NULL
		AND country_name != 'World'
	)
	,t2
AS (
	SELECT country_code
		,region
		,country_name
		,forest_area_sqkm
	FROM forestation
	WHERE year = 2016
		AND forest_area_sqkm IS NOT NULL
		AND country_name != 'World'
	)
SELECT t1.country_code
	,t1.country_name
	,t1.region
	,ROUND(CAST(((t1.forest_area_sqkm - t2.forest_area_sqkm) * 100 / t1.forest_area_sqkm) AS NUMERIC), 2) AS percent_change_forest_area
FROM t1
INNER JOIN t2
	ON t1.country_code = t2.country_code
ORDER BY 4 DESC LIMIT 5
--country_code country_name percent_change_forest_area
--TGO Togo 75.45
--NGA Nigeria 61.80
--UGA Uganda 59.13
--MRT Mauritania 46.75
--HND Honduras 45.03


--c. If countries were grouped by percent forestation in quartiles, which group had the most countries in it in 2016?
WITH t1
AS (
	SELECT country_code
		,country_name
		,Round(cast(forest_area_sqkm * 100 / (total_area_sq_mi * 2.59) AS NUMERIC), 2) AS percent_forest
	FROM forestation
	WHERE year = 2016
		AND forest_area_sqkm IS NOT NULL
		AND total_area_sq_mi IS NOT NULL
		AND country_name != 'World'
	ORDER BY 3
	)
	,t2
AS (
	SELECT country_code
		,country_name
		,percent_forest
		,CASE 
			WHEN t1.percent_forest >= 75
				THEN 4
			WHEN t1.percent_forest BETWEEN 50
					AND 75
				THEN 3
			WHEN t1.percent_forest BETWEEN 25
					AND 50
				THEN 2
			ELSE 1
			END AS quartile
	FROM t1
	ORDER BY 3
	)
SELECT quartile
	,COUNT(*)
FROM t2
GROUP BY 1
ORDER BY 2 DESC
	--quartile count
	--1 85
	--2 72
	--3 38
	--4 9



--d. List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016
WITH t1
AS (
	SELECT country_code
		,region
		,country_name
		,Round(cast(forest_area_sqkm * 100 / (total_area_sq_mi * 2.59) AS NUMERIC), 2) AS percent_forest
	FROM forestation
	WHERE year = 2016
		AND forest_area_sqkm IS NOT NULL
		AND total_area_sq_mi IS NOT NULL
		AND country_name != 'World'
	ORDER BY 3
	)
	,t2
AS (
	SELECT country_code
		,country_name
		,region
		,percent_forest
		,CASE 
			WHEN t1.percent_forest >= 75
				THEN 4
			WHEN t1.percent_forest BETWEEN 50
					AND 75
				THEN 3
			WHEN t1.percent_forest BETWEEN 25
					AND 50
				THEN 2
			ELSE 1
			END AS quartile
	FROM t1
	ORDER BY 3
	)
SELECT country_code
	,country_name
	,region
	,percent_forest
FROM t2
WHERE quartile = 4
ORDER BY 1
	--country_code country_name percent_forest
	--ASM American Samoa 87.50
	--FSM Micronesia, Fed. Sts. 91.86
	--GAB Gabon 90.04
	--GUY Guyana 83.90
	--LAO Lao PDR 82.11
	--PLW Palau 87.61
	--SLB Solomon Islands 77.86
	--SUR Suriname 98.26
	--SYC Seychelles 88.41


--e. How many countries had a percent forestation higher than the United States in 2016?
WITH t1
AS (
	SELECT country_code
		,country_name
		,Round(cast(forest_area_sqkm * 100 / (total_area_sq_mi * 2.59) AS NUMERIC), 2) AS percent_forest
	FROM forestation
	WHERE year = 2016
		AND country_name = 'United States'
	)
SELECT COUNT(*)
FROM (
	SELECT country_code
		,country_name
		,Round(cast(forest_area_sqkm * 100 / (total_area_sq_mi * 2.59) AS NUMERIC), 2) AS percent_forest
	FROM forestation
	WHERE YEAR = 2016
		AND Round(cast(forest_area_sqkm * 100 / (total_area_sq_mi * 2.59) AS NUMERIC), 2) > (
			SELECT percent_forest
			FROM (
				SELECT country_code
					,country_name
					,Round(cast(forest_area_sqkm * 100 / (total_area_sq_mi * 2.59) AS NUMERIC), 2) AS percent_forest
				FROM forestation
				WHERE year = 2016
					AND country_name = 'United States'
				) t2
			)
	) t3
	--count - 94



