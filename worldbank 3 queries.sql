--Query 1: Bulgaria Economic Trajectory with YoY GDP Growth

WITH bulgaria_indicators AS
(SELECT 
        f.year,
        c.country_name,
        i.indicator_name,
        ROUND(f.value, 2) AS value
    FROM fact_indicators f
    JOIN dim_country c ON f.country_id = c.country_id
    JOIN dim_indicator i ON f.indicator_id = i.indicator_id
    WHERE c.country_code = 'BGR'),

pivoted AS 
(SELECT 
        year,
        MAX(CASE WHEN indicator_name = 'gdp_per_capita' THEN value END) AS gdp_per_capita_usd,
        MAX(CASE WHEN indicator_name = 'inflation_rate' THEN value END) AS inflation_pct,
        MAX(CASE WHEN indicator_name = 'unemployment_rate' THEN value END) AS unemployment_pct
    FROM bulgaria_indicators
    GROUP BY year)

SELECT 
    year,
    gdp_per_capita_usd,
    ROUND(
        (gdp_per_capita_usd - LAG(gdp_per_capita_usd) OVER (ORDER BY year)) 
        / LAG(gdp_per_capita_usd) OVER (ORDER BY year) * 100, 
        2) AS gdp_yoy_growth_pct,
    inflation_pct,
    unemployment_pct
FROM pivoted
ORDER BY year DESC;

-- Query 2: Inflation Comparison 2022 vs 2019

WITH inflation_pivot AS 
(SELECT 
        c.country_name,
        c.region,
        MAX(CASE WHEN f.year = 2019 THEN ROUND(f.value, 2) END) AS inflation_2019,
        MAX(CASE WHEN f.year = 2022 THEN ROUND(f.value, 2) END) AS inflation_2022
    FROM fact_indicators f
    JOIN dim_country c ON f.country_id = c.country_id
    JOIN dim_indicator i ON f.indicator_id = i.indicator_id
    WHERE i.indicator_name = 'inflation_rate'
      AND f.year IN (2019, 2022)
    GROUP BY c.country_name, c.region)

SELECT 
    RANK() OVER (ORDER BY inflation_2022 DESC) AS rank_2022,
    country_name,
    region,
    inflation_2019,
    inflation_2022,
    ROUND(inflation_2022 - inflation_2019, 2) AS increase
FROM inflation_pivot
ORDER BY inflation_2022 DESC;

-- Query 3: Top 5 Richest Countries 2024 vs European Average

WITH gdp_2024 AS 
(SELECT 
        c.country_name,
        c.region,
        ROUND(f.value, 2) AS gdp_per_capita
    FROM fact_indicators f
    JOIN dim_country c ON f.country_id = c.country_id
    JOIN dim_indicator i ON f.indicator_id = i.indicator_id
    WHERE f.year = 2024
      AND i.indicator_name = 'gdp_per_capita')

SELECT 
    country_name,
    region,
    gdp_per_capita,
    ROUND((SELECT AVG(gdp_per_capita) FROM gdp_2024), 2) AS european_average,
    ROUND(gdp_per_capita - (SELECT AVG(gdp_per_capita) FROM gdp_2024), 2) AS diff_from_avg
FROM gdp_2024
ORDER BY gdp_per_capita DESC
LIMIT 5;



