#Data Cleaning
# step 1: Remove duplicates if any
# step 2: Standardize data
# step 3: Null values or blank values
# step 4: Remove any unwanted columns

#create a staging table for exisiting layoff data
#CREATE TABLE layoffs_new LIKE layoffs;

INSERT INTO layoffs_new
SELECT * FROM layoffs;

SELECT * FROM  layoffs_new;


-- REMOVE DUPLICATE
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,stage, country ) row_num
FROM layoffs_new
ORDER BY row_num DESC;
 
# find rows with duplicate values 
WITH duplicate_cte AS (
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,stage, country, `date`, funds_raised_millions ) row_num
FROM layoffs_new
ORDER BY row_num DESC)
SELECT * FROM duplicate_cte 
WHERE row_num > 1;

-- add new column to add row number to a new table
CREATE TABLE layoff_staging( 
company text,
location text,
industry text,
total_laid_off int,
percentage_laid_off text, 
`date` text,
stage text ,
country text ,
funds_raised_millions int,
row_num int);

-- insert record into the new table created
INSERT INTO layoff_staging
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off,stage, country, `date`, funds_raised_millions ) row_num
FROM layoffs_new;
 
-- SET SQL_SAFE_UPDATES = 0;
-- delete duplicate records from table

DELETE FROM layoff_staging where row_num >1;

SELECT * FROM layoff_staging;




-- STANDARDIZE DATA 
SELECT * FROM layoff_staging;
SELECT company, TRIM(company) FROM layoff_staging;

UPDATE layoff_staging
SET company=TRIM(company);

SELECT DISTINCT industry FROM layoff_staging
order by 1;

UPDATE layoff_staging
SET industry='Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country stage FROM layoff_staging
order by 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country) stage FROM layoff_staging
order by 1;

UPDATE layoff_staging
SET country= TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT DISTINCT industry FROM layoff_staging
order by 1;
SELECT * FROM layoff_staging;

-- change date text col to date format 
 SELECT `date`, STR_TO_DATE(`date`,'%m/%d/%Y') as `date2` FROM layoff_staging;
 
 UPDATE layoff_staging
 SET `date`=STR_TO_DATE(`date`,'%m/%d/%Y');

ALTER TABLE layoff_staging
MODIFY COLUMN `date` DATE ;


-- WORKING WITH NULL & BLANK VALUES
SELECT * FROM layoff_staging
WHERE industry IS NULL OR industry='';

SELECT * FROM layoff_staging
WHERE company='Carvana'; 


SELECT t1.industry, t2.industry FROM layoff_staging t1
JOIN layoff_staging t2
ON t1.company=t2.company
AND t1.location=t2.location
WHERE (t1.industry IS NULL OR t1.industry='')
AND t2.industry IS NOT NULL;

-- set blanks to null
/* UPDATE layoff_staging
SET industry= NULL
WHERE industry=''; */

-- update all null values 
UPDATE layoff_staging t1
JOIN layoff_staging t2
ON t1.company=t2.company
AND t1.location=t2.location
SET t1.industry=t2.industry
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;

SELECT * FROM layoff_staging
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL ;

-- delete all irrelevant data
DELETE FROM layoff_staging
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL ; 

SELECT * FROM layoff_staging;


-- REMOVE UNWANTED COLUMN
ALTER TABLE layoff_staging
DROP COLUMN row_num;