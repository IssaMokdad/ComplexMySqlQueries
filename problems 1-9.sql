--question 1:
select actor.actor_id, concat(actor.first_name, '   ', actor.last_name) as ActorName, count(film_id) as 'Total number of movies' from 
sakila.film_actor inner join sakila.actor on film_actor.actor_id=actor.actor_id
group by actor_id;
--question 2:
select A.language_id,name, count(A.language_id)
from sakila.film as A inner join sakila.language as B on A.language_id = B.language_id
where release_year ='2006' 
group by A.language_id 
LIMIT 3; 
--question 3:
select country, count(distinct address_id) as CustomersNumber
from sakila.address as A inner join sakila.city as B on A.city_id = B.city_id
inner join sakila.country as C on B.country_id=C.country_id
group by country
order by CustomersNumber DESC
limit 3;
--question 4: sorted in decreasing order
select address2 from sakila.address
where address2 is not null
order by address2 DESC;
--question 5:
select C.first_name, C.last_name
from sakila.film as A inner join sakila.film_actor as B on A.film_id = B.film_id
inner join sakila.actor as C on B.actor_id=C.actor_id
where description like '%Crocodile%' or description like '%shark%'
order by C.last_name;
--question 6:
select A.category_id,name, count(film_id) as FilmsInThisCategory
from sakila.film_category as A inner join sakila.category as B on A.category_id = B.category_id 
group by category_id having (case when FilmsInThisCategory between 55 and 65 is not null then FilmsInThisCategory between 55 and 65
else FilmsInThisCategory END)
order by FilmsInThisCategory DESC;

--another solution (right solution):
/* 6 */

/* FIRST WAY */

SELECT

    C.*

FROM

    (

    SELECT

        c.name,

        COUNT(fc.film_id)

    FROM

        category c

    INNER JOIN film_category fc ON

        c.category_id = fc.category_id

    GROUP BY

        c.category_id

    HAVING

        (COUNT(fc.film_id) BETWEEN 55 AND 65)

    ORDER BY

        COUNT(fc.film_id) DESC) C /* WHERE

    EXISTS (

    SELECT

        c.name,

        COUNT(fc.film_id)

    FROM

        category c

    INNER JOIN film_category fc ON

        c.category_id = fc.category_id

    GROUP BY

        c.category_id

    HAVING

        (COUNT(fc.film_id) BETWEEN 55 AND 65)

    ORDER BY

        COUNT(fc.film_id) DESC) NOT NEEDED */

UNION

SELECT

    D.*

FROM

    (

    SELECT

        c.name,

        COUNT(fc.film_id)

    FROM

        category c

    INNER JOIN film_category fc ON

        c.category_id = fc.category_id

    GROUP BY

        c.category_id

    ORDER BY

        COUNT(fc.film_id) DESC

    LIMIT 1) D

WHERE

    NOT EXISTS (

    SELECT

        c.name,

        COUNT(fc.film_id)

    FROM

        category c

    INNER JOIN film_category fc ON

        c.category_id = fc.category_id

    GROUP BY

        c.category_id

    HAVING

        (COUNT(fc.film_id) BETWEEN 55 AND 65)

    ORDER BY

        COUNT(fc.film_id) DESC);

/* SECOND WAY */

SELECT

    c.name,

    COUNT(fc.film_id)

FROM

    category c

INNER JOIN film_category fc ON

    c.category_id = fc.category_id

GROUP BY

    c.category_id

HAVING

EXISTS(

    SELECT

        c.name,

        COUNT(fc.film_id)

    FROM

        category c

    INNER JOIN film_category fc ON

        c.category_id = fc.category_id

    GROUP BY

        c.category_id

    HAVING

        COUNT(fc.film_id) BETWEEN 55 AND 65 ) = (COUNT(fc.film_id) BETWEEN 55 AND 65)

ORDER BY

    COUNT(fc.film_id) DESC;
--question 7:
select CONCAT(first_name, '    ',  last_name) as CustomerName
from sakila.customer
where first_name=(select first_name from sakila.actor where actor_id=8)
UNION ALL
select CONCAT(first_name, '    ',  last_name) as ActorName
from sakila.actor
where first_name=(select first_name from sakila.actor where actor_id=8);
--question 8: here we must use execute sql script not sql query because of session variables
SET @row_number = 0, @row_num = 0; 
SET @row_number1 = 0, @row_num1 = 0; 
SET @row_number2 = 0, @row_num2 = 0; 
select * from 

(


select date_format(B.payment_date, '%Y') as YearDate, C.store_id as store, sum(B.amount) as ValuesPerYear, avg(B.amount) as AveragePerYear,
(@row_number:=@row_number + 1) AS num
from sakila.rental as A inner join sakila.payment as B on A.rental_id = B.rental_id
inner join sakila.inventory as C on A.inventory_id = C.inventory_id
where B.payment_date like '2005%'
group by YearDate, Store) as Y left join


(
select date_format(B.payment_date, '%M') as MonthDate, C.store_id as store,  sum(B.amount) as ValuesPerMonth, avg(B.amount) as AveragePerMonth,
(@row_num:=@row_num + 1) AS num
from sakila.rental as A inner join sakila.payment as B on A.rental_id = B.rental_id
inner join sakila.inventory as C on A.inventory_id = C.inventory_id
where B.payment_date like '2005%'
group by MonthDate, Store) as Z on Y.num=Z.num

union

select * from 

(


select date_format(B.payment_date, '%Y') as YearDate, C.store_id as store,  sum(B.amount) as ValuesPerYear, avg(B.amount) as AveragePerYear,
(@row_number1:=@row_number1 + 1) AS num
from sakila.rental as A inner join sakila.payment as B on A.rental_id = B.rental_id
inner join sakila.inventory as C on A.inventory_id = C.inventory_id
where B.payment_date like '2005%'
group by YearDate, Store) as Y right join


(
select date_format(B.payment_date, '%M') as MonthDate, C.store_id as store,  sum(B.amount) as ValuesPerMonth, avg(B.amount) as AveragePerMonth,
(@row_num1:=@row_num1 + 1) AS num
from sakila.rental as A inner join sakila.payment as B on A.rental_id = B.rental_id
inner join sakila.inventory as C on A.inventory_id = C.inventory_id
where B.payment_date like '2005%'
group by MonthDate, Store) as Z on Y.num=Z.num;



--question 9:
select CONCAT(first_name, '  ', last_name) as CustomerName , count(rental_id) as RentedMovies
from sakila.film as A inner join sakila.inventory as B on A.film_id = B.film_id
inner join sakila.rental as C on B.inventory_id = C.inventory_id
inner join sakila.customer as D on C.customer_id = D.customer_id
where rental_date like '2005%'
group by CustomerName
order by RentedMovies DESC
LIMIT 3;




