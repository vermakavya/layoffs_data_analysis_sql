-- Data Cleaning
-- objective: 

Select * 
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardise the Data
-- 3. Null / Blank Values
-- 4. Remove Columns / Rows not Necessary


-- REMOVING DUPLICATES
CREATE TABLE layoffs_staging
LIKE layoffs;

Select * 
FROM layoffs_staging ;

Insert layoffs_staging 
Select * 
FROM layoffs;

Select *,
row_number() over(
Partition by company, industry, total_laid_off, percentage_laid_off, `date`)  AS row_num
FROM layoffs_staging ;

With duplicate_cte AS
(
Select *,
row_number() over(
Partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions)  AS row_num
FROM layoffs_staging 
)
Select * 
FROM duplicate_cte
Where row_num >1;

CREATE TABLE layoffs_staging2
(
company text,
location text,
industry text,
total_laid_off int Default null, 
percentage_laid_off text,
date text, 
stage text, 
country text, 
funds_raised_millions int DEFAULT Null,
row_num int
);

DELETE
FROM layoffs_staging2
WHERE row_num >1;

InSERT Into layoffs_staging2
Select *,
row_number() over(
Partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions)  AS row_num
FROM layoffs_staging;

SELECT * 
FROM layoffs_staging2;


-- STANDARDIZING DATA

-- 1. Removing the White Space using TRIM
UPDATE layoffs_staging2
SET company = TRIM(company);

-- 2. CHecking Columns Data for Similar ENrties
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%' ;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(Trailing '.' FROM country)
WHERE country LIKE 'United States%';

SELECT `date`,
STR_to_Date( `date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_to_Date( `date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2
ORDER BY 1;
 
 ALTER TABLE layoffs_staging2
 MODIFY COLUMN `date` DATE;
 
 -- WORKING WITH NULL AND BLANK VALUES
 SELECT * 
 FROM layoffs_staging2
 WHERE total_laid_off IS NULL
 AND percentage_laid_off IS NULL;
 
  SELECT * 
 FROM layoffs_staging2
 WHERE industry IS NULL
 OR industry ='';
 
 SELECT *
 FROM layoffs_staging2 t1
 JOIN layoffs_staging2 t2
	ON t1.company = t2.company
		WHERE (t1.industry IS NULL OR t1.industry = '')
		AND t2.industry IS NOT NULL;
 
 UPDATE layoffs_staging2
 SET industry = NULL
 WHERE industry ='';
 
UPDATE layoffs_staging2 t1
  JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
	WHERE (t1.industry IS NULL OR t1.industry = '')
	AND t2.industry IS NOT NULL
    ;
    
-- REMOVING ROWS/COLUMNS WHICH ARE NOT NEEDED

 DELETE
 FROM layoffs_staging2
 WHERE total_laid_off IS NULL
 AND percentage_laid_off IS NULL;
 
 ALTER TABLE layoffs_staging2
 DROP COLUMN row_num;