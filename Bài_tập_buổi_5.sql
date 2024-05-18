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


