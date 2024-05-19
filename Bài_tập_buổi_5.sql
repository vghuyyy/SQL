-- ex1
select distinct CITY
from STATION
where  ID%2=0

-- ex2
select count( CITY) - count( distinct CITY) 
from STATION

-- ex3

-- ex4
SELECT 
round(cast(sum(item_count*order_occurrences)/sum(order_occurrences) 
as decimal),1)
FROM items_per_order

-- ex5
SELECT candidate_id FROM candidates
where skill in ('Python', 'Tableau', 'PostgreSQL')
group by candidate_id
having count(skill)=3
order by candidate_id

-- ex6
SELECT user_id, date(max(post_date)) - date(Min(post_date)) as days_between 
FROM posts
where date(post_date) between '01/01/2021' and '01/01/2022'
group by user_id
having count(post_id) >= 2

-- ex7
SELECT card_name, max(issued_amount) - min(issued_amount) as difference
FROM monthly_cards_issued
group by card_name
order by max(issued_amount) - min(issued_amount) desc

-- ex8
SELECT manufacturer, 
abs(sum(cogs - total_sales)) as total_loss, 
count(drug) as drug_count
FROM pharmacy_sales
where total_sales < cogs
group by manufacturer
ORDER BY total_loss desc

-- ex9
select * from cinema
where id%2=1 and description <> 'boring'
order by rating desc

-- ex10
select  teacher_id, count(distinct subject_id) as cnt from Teacher
group by teacher_id

-- ex11
select user_id, count(follower_id) as followers_count from Followers
group by user_id
order by user_id asc

-- ex12
select class from Courses
group by class
having count(student)>=5
 
