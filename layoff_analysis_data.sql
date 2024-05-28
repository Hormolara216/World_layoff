SELECT * FROM layoff_staging;

-- comapnies with entire staff laid off
SELECT * FROM layoff_staging
WHERE percentage_laid_off=1
ORDER BY total_laid_off desc;

-- total lay off by country
SELECT country, SUM(total_laid_off), ROUND(AVG(percentage_laid_off),2)
FROM layoff_staging
GROUP BY country
ORDER BY 2 DESC ;

-- total lay off by industry
SELECT industry,SUM(total_laid_off) total_laidoff FROM layoff_staging
GROUP BY industry
ORDER BY 2 desc;

-- total lay off company
SELECT company,SUM(total_laid_off) total_laidoff FROM layoff_staging
GROUP BY company
ORDER BY 2 desc;

-- minimum and maximum laid off by industry
SELECT industry,MAX(total_laid_off) industry_max_laidoff,MIN(total_laid_off) industry_min_laidoff FROM layoff_staging
GROUP BY industry
ORDER BY 2 desc;


SELECT MIN(`date`),MIN(`date`)
FROM layoff_staging;

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoff_staging
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

SELECT stage, SUM(total_laid_off)
FROM layoff_staging
GROUP BY stage
ORDER BY 2 DESC;

-- average fund raised by industry
SELECT industry, ROUND(AVG(funds_raised_millions),2) avg_funds_raised_M
FROM layoff_staging
GROUP BY industry
ORDER BY avg_funds_raised_M;

-- Layoff trend over time
use world_layoff;

SELECT date_month, total_laid_off,SUM(total_laid_off) OVER(ORDER BY date_month) AS rolling_total 
FROM (SELECT SUBSTRING(`date`,1,7) AS date_month, SUM(total_laid_off) as total_laid_off
FROM layoff_staging
WHERE `date` IS NOT NULL
GROUP BY date_month
ORDER BY 1) AS temp ;

-- top 5 companies layoff ranking by year 

WITH layoff_rank AS (SELECT company, YEAR(`date`)AS `year`, SUM(total_laid_off) AS total_laid_off
FROM layoff_staging
WHERE `date` IS NOT NULL and total_laid_off IS NOT NULL
GROUP BY company, `year`
), top5_rank AS 
(SELECT *,
DENSE_RANK() OVER(PARTITION BY `year` ORDER BY total_laid_off DESC) AS ranking
FROM layoff_rank)
SELECT * FROM top5_rank
WHERE ranking <=5;

-- top 3 industries layoff ranking by year 
WITH layoff_rank AS (SELECT industry, YEAR(`date`)AS `year`, SUM(total_laid_off) AS total_laid_off
FROM layoff_staging
WHERE `date` IS NOT NULL and total_laid_off IS NOT NULL
GROUP BY industry, `year`
), top3_rank AS 
(SELECT *,
DENSE_RANK() OVER(PARTITION BY `year` ORDER BY total_laid_off DESC) AS ranking
FROM layoff_rank)
SELECT * FROM top3_rank
WHERE ranking <=3;