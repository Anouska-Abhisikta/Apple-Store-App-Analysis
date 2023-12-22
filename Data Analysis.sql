CREATE TABLE appleStore_description_combined AS

SELECT * FROM appleStore_description1

UNION ALL

SELECT * FROM appleStore_description2

UNION ALL

SELECT * FROM appleStore_description3

UNION ALL

SELECT * FROM appleStore_description4


** EXPLORATORY DATA ANALYSIS(EDA)**


--Check the number of unique apps in both tablesApplestoreAppleStore

SELECT COUNT(DISTINCT ID) AS UniqueAppIDs
FROM AppleStore

SELECT COUNT(DISTINCT ID) AS UniqueAppIDs
FROM appleStore_description_combined

--Check for any missing values in key fields

SELECT COUNT(*) AS MissingValues
FROM AppleStore
WHERE track_name IS NULL OR user_rating IS NULL OR prime_genre IS NULL

SELECT COUNT(DISTINCT ID) AS UniqueAppIDs
FROM appleStore_description_combined
WHERE app_desc IS NULL

--Find out the number of apps per genre

SELECT prime_genre, COUNT(*) as NumApps
FROM AppleStore
GROUP BY prime_genre
ORDER BY NumApps DESC

--Get an overview of the Apps' ratingsAppleStore

SELECT min(user_rating) as MinRating,
       max(user_rating) as MaxRating,
       avg(user_rating) as AvgRating
FROM AppleStore


** DATA ANALYSIS **


--Determine whether paid apps have higher ratings than free apps

SELECT CASE
			WHEN price>0 THEN 'PAID'
            ELSE 'FREE'
        END AS App_Type,
        avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY App_Type

-- Check if apps with more supported languages have higher ratings

SELECT CASE
			WHEN lang_num < 10 THEN '<10 Languages'
            WHEN lang_num between 10 and 30 then '10-30 languages'
            ELSE '>30 Languages'
         end as language_bucket,
         avg(user_rating) as Avg_Rating
From AppleStore
GROUP by language_bucket
ORDER BY Avg_Rating DESC

--Check genres with low ratings

SELECT prime_genre,
		avg(user_rating) as Avg_Rating
FROM AppleStore
GROUP BY prime_genre
ORDER BY Avg_Rating ASC
LIMIT 10 

--check if there is coorelation between the length of the app description and the user rating 

SELECT CASE
			WHEN length(b.app_desc) <500 THEN 'SHORT'
            WHEN length(b.app_desc) BETWEEN 500 AND 1000 THEN 'MEDIUM'
            ELSE 'LONG'
          END AS description_length_bucket,
          avg(a.user_rating) AS average_rating
          
FROM 
	AppleStore AS A

join 
	appleStore_description_combined as b 

on 
	a.id = b.id 

group by description_length_bucket
order by average_rating DESC

--Check the top-rated apps for each genre

SELECT 
	prime_genre,
    track_name,
    user_rating
    
from ( 
  		select 
  		prime_genre,
  		track_name,
  		user_rating,
  		RANK() OVER(PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) AS rank
  		FROM 
  		AppleStore
  	)AS a 
  where 
  a.rank = 1