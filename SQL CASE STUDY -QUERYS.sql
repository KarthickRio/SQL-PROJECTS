SELECT * FROM artist;
SELECT * FROM canvas_size;
SELECT * FROM image_link;
SELECT * FROM  museum_hours;
SELECT * FROM museum;
SELECT * FROM product_size;
SELECT * FROM  subject;
SELECT * FROM work ;

# 10. Identify the museums which are open on both Sunday and Monday. Display museum name, city.


# ON WHICH DAY MUSEUM IS OPEN IS AVAILABLE IN museum Table
SELECT * FROM  museum_hours
WHERE DAY ='Sunday';
#57 MUSEUMS ARE OPEN IN SUNDAY
SELECT * FROM  museum_hours
WHERE DAY ='Monday';
#29 MUSEUMS ARE OPEN IN MONDAY
SELECT m.name as 'MUSEUM-NAME',m.city as'LOCATED CITY' FROM  museum_hours as mh1
JOIN museum as m on m.museum_id=mh1.museum_id
WHERE DAY ='SUNDAY' 
AND EXISTS(SELECT 1 FROM museum_hours as mh2
WHERE mh2.museum_id=mh1.museum_id
AND mh2.day='Monday');
# total 25 musems are open in both sunday and monday


#15. Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?

#MY OBSERVATION IS we derive the museum name and state from museum table 
#museum hour and day is derive from museum_hours
#both are joined by museum_id
#here open and close in text format 
SELECT * FROM(
SELECT m.name as Museum_name,m.state,mh.day,
    STR_TO_DATE(open, '%h:%i:%p') AS open_time,
    STR_TO_DATE(close, '%h:%i:%p') AS close_time,
    TIMEDIFF(STR_TO_DATE(close, '%h:%i:%p'), STR_TO_DATE(open, '%h:%i:%p')) AS duration_time,
    RANK() OVER (ORDER BY TIMEDIFF(STR_TO_DATE(close, '%h:%i:%p'), STR_TO_DATE(open, '%h:%i:%p')) DESC) AS rnk
FROM museum_hours AS mh 
JOIN museum as m on m.museum_id=mh.museum_id) AS x
WHERE rnk=1;


# 18.Display the country and the city with most no of museums. Output 2 seperatecolumns to mention the city and country. 
#If there are multiple value, seperate themwith comma.

#count the no of museums are located in the  each country 
SELECT country,count(*) FROM museum
GROUP BY country
ORDER BY count(*) DESC;

#count the no of museums are located in the  each cities 
SELECT city,count(*) FROM museum
GROUP BY city
ORDER BY count(*) DESC;

WITH cte_country AS (SELECT country,count(*),
RANK() OVER(ORDER BY count(*) DESC) AS rnk
FROM museum
GROUP BY country),
cte_city AS (SELECT city,count(*),
RANK() OVER(ORDER BY count(*) DESC) AS rnk
FROM museum
GROUP BY city)
SELECT country, GROUP_CONCAT(city SEPARATOR ', ') AS City
FROM cte_country
CROSS JOIN cte_city WHERE cte_city.rnk=1
AND cte_country.rnk=1
group by country;

/*  1. Fetch all the paintings which are not displayed on any museums */
SELECT name FROM work
WHERE museum_id IS NULL;

/* 2. Are there museums without any paintings?-NO  */
SELECT * FROM museum AS m
WHERE NOT EXISTS(
SELECT * FROM WORK AS W
WHERE w.museum_id =m.museum_id);

/* 3. How many paintings have an asking price of more than their regular price? NO PAINTINGS*/
SELECT * FROM product_size as w
WHERE w.sale_price > w.regular_price;

/* 4. Identify the paintings whose asking price is less than 50% of its regular price */
SELECT * FROM product_size as w
WHERE w.sale_price < (0.5* w.regular_price);

/* 5. Which canva size costs the most? -48" x 96"(122 cm x 244 cm) */
SELECT cs.label AS Canva, ps.sale_price
FROM (
    SELECT *, RANK() OVER (ORDER BY sale_price DESC) AS rnk
    FROM product_size
) ps
JOIN canvas_size AS cs ON cs.size_id = ps.size_id
WHERE ps.rnk = 1;

/* 6. Delete duplicate records from work, product_size, subject and image_link tables */
SET SQL_SAFE_UPDATES = 0;
#FOR WORK
DELETE FROM work
WHERE work_id NOT IN (
       SELECT work_id
       FROM (
             SELECT MIN(work_id) AS id
             FROM work
             GROUP BY work_id
    ) AS subquery
);
#FOR PRODUCT SIZE
DELETE FROM product_size
WHERE work_id NOT IN (
         SELECT work_id 
         FROM (
                 SELECT MIN(work_id) AS id
                 FROM work 
                 GROUP BY work_id
			   ) AS subquery
 );
 #FOR SUBJECT
DELETE FROM work 
WHERE work_id NOT IN (
               SELECT work_id 
               FROM (
                       SELECT MIN(work_id) AS id
                       FROM work
                       GROUP BY work_id
					) AS subquery
);
 #FOR IMAGE LINK
DELETE FROM image_link 
WHERE work_id NOT IN (
               SELECT work_id 
               FROM (
                       SELECT MIN(work_id) AS id
                       FROM image_link
                       GROUP BY work_id
					) AS subquery
);
/* 7. Identify the museums with invalid city information in the given dataset */
 SELECT * FROM museum 
 WHERE city REGEXP '^[0-9]+$';
 
 /* 8.. Museum_Hours table has 1 invalid entry. Identify it and remove it.*/
 #FIRST IDENTIFY THE INVALID ENTRY
SELECT museum_id,day,COUNT(*)
FROM museum_hours
GROUP BY museum_id,day
HAVING COUNT(*) > 1;
#SECOND DELETE THE THAT INVALID ENTRY
DELETE FROM museum_hours 
WHERE museum_id NOT IN (
    SELECT * FROM (
        SELECT MIN(museum_id)
        FROM museum_hours
        GROUP BY museum_id, day
    ) AS subquery
);

 /*9. *Fetch the top 10 most famous painting subject */         
 SELECT * FROM(
               SELECT s.subject,COUNT(*) AS NO_OF_PAINTINGS,
               RANK() OVER(ORDER BY COUNT(*) DESC) AS rnk
               FROM work as w
               JOIN subject as s on s.work_id = w.work_id
               GROUP BY s.subject) as x
where rnk <=10;

/* 11.How many museums are open every single day*- 18 museum */
 SELECT COUNT(*) FROM(
            SELECT museum_id,count(*)
            FROM museum_hours
            GROUP BY museum_id
            having COUNT(*) =7) AS x;
            
/* 12. Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum) */        
SELECT m.name AS MUSEUM_NAME, m.city,m.country,x.no_of_paintings FROM
(
	SELECT m.museum_id ,COUNT(*) AS no_of_paintings ,
	rank() over(order by COUNT(*) DESC) AS rnk
	from work as w
	join museum as m on m.museum_id = w.museum_id
	group by m.museum_id) as x
join  museum as m on m.museum_id =x.museum_id
WHERE x.rnk <=5;
/*13. Who are the top 5 most popular artist? (Popularity is defined based on most no of
paintings done by an artist)*/

SELECT a.full_name as ARTIST_NAME, a.nationality as NATION ,x.no_of_paintings_byartists FROM
(
	SELECT a.artist_id,COUNT(*)AS no_of_paintings_byartists,
    rank() over(order by COUNT(*)DESC) AS rnk
    from work as w
    join artist as a on a.artist_id=w.artist_id
    group by a.artist_id)as x
JOIN artist as a on a.artist_id=x.artist_id
WHERE x.rnk <=5;

/* 14.  Display the 3 least popular canva sizes*/
SELECT label ,ranking, no_of_paintings FROM
(
    SELECT cs.size_id,cs.label,COUNT(*) AS no_of_paintings,
	dense_rank() over(ORDER BY COUNT(*) ) AS ranking
    FROM product_size as ps
    JOIN canvas_size as cs on cs.size_id=ps.size_id
    group by cs.size_id,cs.label) as x
where x.Ranking <=3;

/* 16 Which museum has the most no of most popular painting style? */
   WITH pop_style AS (
    SELECT style, 
           RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
      FROM work 
     GROUP BY style
),

	cte as
        (select w.museum_id,m.name as museumname,ps.style, count(1) as no_of_paintings,
         rank() OVER(ORDER BY count(*) DESC) as rnk
         FROM work w
         JOIN museum as m on m.museum_id = w.museum_id
         JOIN pop_style as ps on ps.style =w.style
		 WHERE w.museum_id is not null
		and ps.rnk=1
			group by w.museum_id, m.name,ps.style)
    SELECT museumname, style, no_of_paintings
    from cte 
    where rnk=1;
    
 /* 17. Identify the artists whose paintings are displayed in multiple country*/
WITH cte as (
SELECT DISTINCT a.full_name as artist_name,
w.name as painting_name ,m.name as museum,
m.country as country 
FROM work as w
JOIN artist as a on a.artist_id =w.artist_id
JOIN museum as m on m.museum_id =w.museum_id
)
SELECT artist_name ,COUNT(*)  AS no_of_countries
from cte
group by artist_name
having count(*)>1
order by no_of_countries DESC;

/* 19. Identify the artist and the museum where the most expensive and least expensive
painting is placed. Display the artist name, sale_price, painting name, museum
name, museum city and canvas label */
WITH cte as (
SELECT *,
RANK() OVER(ORDER BY sale_price DESC) AS rnk,
RANK() OVER(ORDER BY sale_price ) AS rnk_asc
FROM  product_size)
SELECT
a.full_name as artist, cte.sale_price,
w.name as painting_name,m.name as museum_name 
,m.city as city ,cz.label as canvas
FROM cte
JOIN work as w on w.work_id =cte.work_id
JOIN museum as m on m.museum_id =w.museum_id
join artist a on a.artist_id=w.artist_id
join canvas_size cz on cz.size_id = cte.size_id
where rnk=1 or rnk_asc=1;

/*20.  Which country has the 5th highest no of paintings? */
 SELECT * FROM(
               SELECT m.country,COUNT(*) AS NO_OF_PAINTINGS,
               RANK() OVER(ORDER BY COUNT(*) DESC) AS rnk
               FROM work as w
               JOIN museum as m on  m.museum_id=w.museum_id 
               GROUP BY m.country) as x
where rnk =5;

/* 21.   Which are the 3 most popular and 3 least popular painting styles? */
with cte as (
				Select style,COUNT(*)AS cnt,
                RANK() OVER(ORDER BY COUNT(*) DESC) AS rnk,
                COUNT(*) OVER() AS no_of_records
                FROM work
                WHERE style IS NOT NULL 
                GROUP BY style
			)
SELECT style,
case when rnk <=3 then 'Most Popular' else 'Least Popular' end as remarks 
FROM cte 
where rnk <=3
	or rnk > no_of_records - 3;
  
/* 22.. Which artist has the most no of Portraits paintings outside USA?. Display artist
name, no of paintings and the artist nationality */
select full_name as artist_name, nationality, no_of_paintings
	from (
		SELECT a.full_name ,a.nationality,
		COUNT(*) AS no_of_paintings ,
		RANK() OVER( ORDER BY COUNT(*) DESC) as rnk
		FROM work as w
		JOIN artist as a on a.artist_id =w.artist_id
		JOIN subject as s on s.work_id = w.work_id
		JOIN museum as m on m.museum_id =w.museum_id
		WHERE s.subject ='Portraits'
		and m.country != 'USA'
		group by a.full_name, a.nationality)  as x
	where rnk=1;	
