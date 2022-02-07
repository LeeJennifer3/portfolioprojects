-- SQL analysis of bestselling books for the period of 2009-2021 
-- Dataset of Amazon Book Bestsellers taken from Kaggle

-- Select datasets to be used

SELECT *
FROM Books..bestseller_list
ORDER BY year;

SELECT *
FROM Books..book_details;


-- Join both tables together / create temp table 

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

| title                                                                             | author                             | years_on_list | 
|-----------------------------------------------------------------------------------|------------------------------------|---------------|
| The 5 Love Languages: The Secret to Love That Lasts                               | Gary Chapman                       | 12            |  
| Publication Manual of the American Psychological Association, 6th Edition         | American Psychological Association | 11            |  
| Oh, the Places You'll Go!                                                         | Dr. Seuss                          | 9             |  
| StrengthsFinder 2.0                                                               | Gallup                             | 9             |   
| The Very Hungry Caterpillar                                                       | Eric Carle                         | 9             |  
| The Four Agreements: A Practical Guide to Personal Freedom (A Toltec Wisdom Book) | Don Miguel Ruiz                    | 8             |  
| The 7 Habits of Highly Effective People: Powerful Lessons in Personal Change      | Stephen R. Covey                   | 7             |  
| Giraffes Can't Dance                                                              | Giles Andreae                      | 6             | 
| How to Win Friends & Influence People                                             | Dale Carnegie                      | 6             |  
| Jesus Calling: Enjoying Peace in His Presence (with Scripture References)         | Sarah Young                        | 6             |  


-- Find Top 10 bestselling books based on number of years on list
-- Fiction

SELECT TOP 10 title, author, COUNT(*) AS years_on_list
FROM #updated_list
WHERE genre = 'Fiction'
GROUP BY title, author, genre
ORDER BY years_on_list DESC;


| title                                                                                             | author              | years_on_list |
|---------------------------------------------------------------------------------------------------|---------------------|---------------|
| To Kill a Mockingbird                                                                             | Harper Lee          | 5             |
| Wonder                                                                                            | R. J. Palacio       | 5             |
| The Great Gatsby                                                                                  | F. Scott Fitzgerald | 3             |
| Game of Thrones Boxed Set: A Game of Thrones/A Clash of Kings/A Storm of Swords/A Feast for Crows | George R.R. Martin  | 3             |
| Gone Girl                                                                                         | Gillian Flynn       | 3             |
| The Fault in Our Stars                                                                            | John Green          | 3             |
| The Help                                                                                          | Kathryn Stockett    | 3             |
| Catching Fire (The Hunger Games)                                                                  | Suzanne Collins     | 3             |
| Mockingjay (The Hunger Games)                                                                     | Suzanne Collins     | 3             |
| Player's Handbook (Dungeons & Dragons)                                                            | Wizards RPG Team    | 3             |


-- Find Top 10 bestselling books based on number of years on list
-- Non-Fiction

SELECT TOP 10 title, author, COUNT(*) AS years_on_list
FROM #updated_list
WHERE genre = 'Non Fiction'
GROUP BY title, author, genre
ORDER BY years_on_list DESC;

| title                                                                                  | author                             | years_on_list |
|----------------------------------------------------------------------------------------|------------------------------------|---------------|
| The 5 Love Languages: The Secret to Love that Lasts                                    | Gary Chapman                       | 12            |
| Publication Manual of the American Psychological Association, 6th Edition              | American Psychological Association | 11            |
| StrengthsFinder 2.0                                                                    | Gallup                             | 9             |
| The Four Agreements: A Practical Guide to Personal Freedom (A Toltec Wisdom Book)      | Don Miguel Ruiz                    | 8             |
| The 7 Habits of Highly Effective People: Powerful Lessons in Personal Change           | Stephen R. Covey                   | 7             |
| How to Win Friends & Influence People                                                  | Dale Carnegie                      | 6             |
| Jesus Calling: Enjoying Peace in His Presence (with Scripture References)              | Sarah Young                        | 6             |
| The Five Dysfunctions of a Team: A Leadership Fable                                    | Patrick Lencioni                   | 5             |
| The Official SAT Study Guide                                                           | The College Board                  | 5             |
| You Are a Badass: How to Stop Doubting Your Greatness and Start Living an Awesome Life | Jen Sincero                        | 4             |


-- Find Authors with the most books on Bestseller list 

SELECT TOP 10 author, count(DISTINCT title) AS times_on_list
FROM #updated_list
GROUP BY author
ORDER BY count(DISTINCT title) DESC


| author           | times_on_list |
|------------------|---------------|
| Jeff Kinney      | 14            |
| Rick Riordan     | 10            |
| Dav Pilkey       | 8             |
| Stephenie Meyer  | 8             |
| Bill O'Reilly    | 6             |
| J.K. Rowling     | 6             |
| Suzanne Collins  | 6             |
| E L James        | 5             |
| John Grisham     | 5             |
| Charlaine Harris | 4             |


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


| year | fiction_count | percent_fiction | nonfiction_count | percent_nonfiction | childrens_count | percent_childrens |
|------|---------------|-----------------|------------------|--------------------|-----------------|-------------------|
| 2009 | 21            | 42              | 26               | 52                 | 3               | 6                 |
| 2010 | 19            | 38              | 30               | 60                 | 1               | 2                 |
| 2011 | 19            | 38              | 28               | 56                 | 2               | 4                 |
| 2012 | 18            | 36              | 28               | 56                 | 4               | 8                 |
| 2013 | 19            | 38              | 24               | 48                 | 7               | 14                |
| 2014 | 20            | 40              | 17               | 34                 | 11              | 22                |
| 2015 | 10            | 20              | 29               | 58                 | 11              | 22                |
| 2016 | 12            | 24              | 29               | 58                 | 9               | 18                |
| 2017 | 12            | 24              | 24               | 48                 | 14              | 28                |
| 2018 | 9             | 18              | 26               | 52                 | 15              | 30                |
| 2019 | 7             | 14              | 22               | 44                 | 21              | 42                |
| 2020 | 9             | 18              | 21               | 42                 | 20              | 40                |


-- Find top 10 publishers with most bestsellers 

SELECT TOP 10 publisher, count(DISTINCT title) AS times_on_list
FROM #updated_list
WHERE publisher IS NOT null
GROUP BY publisher
ORDER BY count(DISTINCT title) DESC


| publisher                 | times_on_list |
|---------------------------|---------------|
| Penguin Books             | 21            |
| Vintage                   | 18            |
| Mariner Books             | 9             |
| Scholastic Inc.           | 9             |
| William Morrow Paperbacks | 9             |
| Anchor                    | 8             |
| Avon                      | 7             |
| Penguin Classics          | 7             |
| Scribner                  | 7             |
| Penguin                   | 6             |


-- Identify book length distribution per year

SELECT 
	year,
	SUM(CASE WHEN num_pages BETWEEN 0 AND 300 THEN 1 ELSE 0 END) AS short,
	SUM(CASE WHEN num_pages BETWEEN 301 AND 600 THEN 1 ELSE 0 END) AS medium,
	SUM(CASE WHEN num_pages BETWEEN 601 AND 1500 THEN 1 ELSE 0 END) AS long
FROM #updated_list
GROUP BY year


| year | short | medium | long |
|------|-------|--------|------|
| 2009 | 19    | 21     | 2    |
| 2010 | 19    | 20     | 3    |
| 2011 | 17    | 18     | 3    |
| 2012 | 23    | 17     | 1    |
| 2013 | 19    | 19     | 2    |
| 2014 | 20    | 16     | 0    |
| 2015 | 16    | 19     | 3    |
| 2016 | 11    | 17     | 9    |
| 2017 | 14    | 17     | 5    |
| 2018 | 21    | 16     | 1    |
| 2019 | 26    | 15     | 3    |
| 2020 | 20    | 11     | 3    |
| 2021 | 25    | 13     | 0    |


-- Is there a relationship between page count and number of times read? (Assuming number of reviews = number of times read)
-- Calculate correlation coefficient between page count & review count

SELECT 
	ROUND((AVG(num_pages * review_count) - 
	(Avg(num_pages) * Avg(review_count))) / 
	(StDevP(num_pages) * StDevP(review_count)),2) AS CorrCoeff
FROM #updated_list

| CorrCoeff | 
|-----------|
|   -0.21   |

-- A (0.21) correlation does not indicate a strong relationship between these two factors.

