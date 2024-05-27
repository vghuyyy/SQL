-- ex1
select count(*) 
from (SELECT count(company_id) from (SELECT company_id, count(job_id) duplicate_companies FROM job_listings
group by job_id, company_id) as a
group by company_id
having count(company_id) >=2) b

-- ex2
with table_1 
as (select category,product,sum(spend) as total_spend
FROM product_spend
where extract(year from transaction_date) = 2022
group by category,product),
    table_2
as (select category,product,sum(spend) as total_spend
FROM product_spend
where extract(year from transaction_date) = 2022
group by category,product)

(select * from table_1
where category = 'electronics'
order by total_spend desc
limit 2)
union 
(select * from table_2
where category = 'appliance'
order by total_spend desc
limit 2)

-- ex3
SELECT count(*) as policy_holder_count FROM 
(select count(*) from callers
group by policy_holder_id
having count(policy_holder_id) >=3) as a

-- ex4
select a.page_id
from pages as a
left join page_likes as b 
on a.page_id = b.page_id
where b.liked_date is not null
order by b.page_id asc

-- ex5
with june AS(SELECT user_id FROM user_action
where extract(month from event_date) = 6 and 
extract(year from event_date) = 2022 and 
event_type in('comment','sign-in', 'like')),

july AS(SELECT user_id FROM user_actions
where extract(month from event_date) = 7 and 
extract(year from event_date) = 2022 and 
event_type in('comment','sign-in', 'like'))

select (select 7 as month),count(distinct june.user_id) as monthly_active_users
 from june 
join july
on june.user_id = july.user_id

-- ex6

SELECT 
to_char(trans_date, 'yyyy-mm') as month,
country,
COUNT(id) AS trans_count,
SUM(CASE WHEN state = 'approved' THEN 1 ELSE 0 END) AS approved_count,
SUM(amount) AS trans_total_amount,
SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 END) AS approved_total_amount
FROM 
Transactions
GROUP BY 
to_char(trans_date, 'yyyy-mm'), country

-- ex7
select product_id, year as first_year, quantity, price from Sales 
where (product_id, year) in (select product_id, min(year) from Sales 
group by product_id)

-- ex8
select customer_id from Customer 
group by customer_id
having count(distinct product_key) = (select count(distinct product_key) from Product)

-- ex9
select employee_id from Employees a
where salary < 30000 
and
manager_id not in (select distinct employee_id from Employees)
order by employee_id

-- ex10
select count(*) 
from (SELECT count(company_id) from (SELECT company_id, count(job_id) duplicate_companies FROM job_listings
group by job_id, company_id) as a
group by company_id
having count(company_id) >=2) b

-- ex11
with t1 as (select user_id, count(movie_id) as so_luong from MovieRating 
group by user_id),
t2 as (select movie_id, avg(rating) avg_rating from MovieRating 
where extract(year from created_at) = 2020 and extract(month from created_at) = 2 group by movie_id)

select name as results from (select name, t1.so_luong from Users
join t1 
on t1.user_id = Users.user_id
order by t1.so_luong desc, Users.name asc
limit 1)
union all
select title as results from (select t2.movie_id, Movies.title, t2.avg_rating from t2
join Movies
on Movies.movie_id = t2.movie_id
order by t2.avg_rating desc, Movies.title asc
limit 1)

-- ex12
select id, count(id) as num from (select requester_id as id from RequestAccepted
union all
select accepter_id as id from RequestAccepted)
group by id
order by num desc
limit 1
