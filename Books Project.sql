-- Select datasets to be used

SELECT *
FROM Books..bestseller_list
ORDER BY year;

SELECT *
FROM Books..book_details;


-- Join table used above with Book Details table

DROP TABLE IF EXISTS #updated_list
CREATE TABLE #updated_list
(
year numeric,
title nvarchar(255),
author nvarchar(255),
genre nvarchar(255),
user_rating float,
review_count float,
price float,
num_pages float,
publisher nvarchar(255),
)

INSERT INTO #updated_list
SELECT best.year, best.name, best.author, best.genre, best.user_rating, MAX(best.reviews) AS review_count, AVG(best.price) AS price, det.num_pages, det.publisher
FROM Books..bestseller_list AS best
OUTER APPLY
        (
        SELECT  TOP 1 num_pages, publisher
        FROM    Books..book_details
        WHERE   best.name LIKE ('%' + LEFT(book_details.title,8) + '%')
        ) det
GROUP BY best.year, best.name, best.author, best.genre, best.user_rating, det.num_pages, det.publisher

SELECT *
FROM #updated_list


-- Find Top 10 bestselling books based on number of years on list
-- All Genres

SELECT TOP 10 title, author, COUNT(*) AS years_on_list
FROM #updated_list
GROUP BY title, author, genre
ORDER BY years_on_list DESC;


-- Find Top 10 bestselling books based on number of years on list
-- Fiction

SELECT TOP 10 title, author, COUNT(*) AS years_on_list
FROM #updated_list
WHERE genre = 'Fiction'
GROUP BY title, author, genre
ORDER BY years_on_list DESC;


-- Find Top 10 bestselling books based on number of years on list
-- Non-Fiction

SELECT TOP 10 title, author, COUNT(*) AS years_on_list
FROM #updated_list
WHERE genre = 'Non Fiction'
GROUP BY title, author, genre
ORDER BY years_on_list DESC;


-- Find Authors with the most books on Bestseller list 

SELECT TOP 10 author, count(DISTINCT title) AS times_on_list
FROM #updated_list
GROUP BY author
ORDER BY count(DISTINCT title) DESC


-- Find distribution of each bestseller genres per year 

SELECT 
	year,
	SUM(CASE WHEN genre = 'Fiction' THEN 1 ELSE 0 END) AS fiction_count,
	CAST(SUM(CASE WHEN genre = 'Fiction' THEN 1 ELSE 0 END) AS DECIMAL)/50*100 AS percent_fiction,
	SUM(CASE WHEN genre = 'Non Fiction' THEN 1 ELSE 0 END) AS nonfiction_count,
	CAST(SUM(CASE WHEN genre = 'Non Fiction' THEN 1 ELSE 0 END) AS DECIMAL)/50*100 AS percent_nonfiction,
	SUM(CASE WHEN genre = 'Children' THEN 1 ELSE 0 END) AS childrens_count,
	CAST(SUM(CASE WHEN genre = 'Children' THEN 1 ELSE 0 END) AS DECIMAL)/50*100 AS percent_childrens
FROM #updated_list
GROUP BY year;


-- Find top 10 publishers with most bestsellers 

SELECT TOP 10 publisher, count(DISTINCT title) AS times_on_list
FROM #updated_list
WHERE publisher IS NOT null
GROUP BY publisher
ORDER BY count(DISTINCT title) DESC


-- Identify book length distribution per year

SELECT 
	year,
	SUM(CASE WHEN num_pages BETWEEN 0 AND 300 THEN 1 ELSE 0 END) AS short,
	SUM(CASE WHEN num_pages BETWEEN 301 AND 600 THEN 1 ELSE 0 END) AS medium,
	SUM(CASE WHEN num_pages BETWEEN 601 AND 1500 THEN 1 ELSE 0 END) AS long
FROM #updated_list
GROUP BY year


-- Is there a relationship between page count and number of times read? (Assuming number of reviews = number of times read)
-- Calculate correlation coefficient between page count & review count

SELECT 
	ROUND((AVG(num_pages * review_count) - 
	(Avg(num_pages) * Avg(review_count))) / 
	(StDevP(num_pages) * StDevP(review_count)),2) AS CorrCoeff
FROM #updated_list

-- A (0.2) correlation does not indicate a strong relationship between these two factors.

