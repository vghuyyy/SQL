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

-- ex7
select product_id, year as first_year, quantity, price from Sales 
where (product_id, year) in (select product_id, min(year) from Sales 
group by product_id)
