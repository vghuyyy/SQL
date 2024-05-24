-- ex1
SELECT 
sum (case
when device_type = 'tablet' then 1
else 0
end) as mobile_views,
sum (case
when device_type in ('tablet', 'phone') then 1
else 0
end) as laptop_views
FROM viewership

-- ex2
select x, y, z, 
case
when x+y>z then 'Yes'
else 'No'
end as triangle
from Triangle

-- ex3
SELECT 
ROUND(CAST(SUM(
CASE 
WHEN call_category = 'n/a' OR call_category IS NULL THEN 1 
END) as decimal) / COUNT(*) * 100, 1) AS percentage_uncategorized
FROM callers

-- ex4
select name
from Customer
where coalesce(referee_id,'1') <>2

-- ex5
select survived,
count(case
when pclass = 1 then 'first_class'
end),
count(case
when pclass = 2 then 'second_class'
end),
count(case
when pclass = 3 then 'third_class'
end)
from titanic
group by survived

-- ex1-mc
select distinct replacement_cost
from film
group by replacement_cost
order by replacement_cost asc

-- ex2-mc
select
case
when replacement_cost between 9.99 and 19.99 then 'low'
when replacement_cost between 20.00 and 24.99 then 'medium'
else 'high'
end as category, count(replacement_cost)
from film
where 
(case
when replacement_cost between 9.99 and 19.99 then 'low'
when replacement_cost between 20.00 and 24.99 then 'medium'
else 'high'
end) = 'low'
group by category
order by category asc

-- ex3-mc
select c.title, c.length, b.name from film_category as a
join category as b
on a.category_id = b.category_id
join film as c
on a.film_id = c.film_id
where b.name in ('Drama', 'Sports')
order by c.length desc

-- ex4-mc
select b.name ,count(c.title)from film_category as a
join category as b
on a.category_id = b.category_id
join film as c
on a.film_id = c.film_id
group by b.name
order by count(c.title) desc

-- ex5-mc
select b.first_name, b.last_name, count(a.film_id) from film_actor as a
inner join actor as b
on a.actor_id = b.actor_id
group by b.first_name, b.last_name
order by count(a.film_id) desc

-- ex6-mc
select count(*) from address as b
left join customer as a
on a.address_id = b.address_id
where b.address2 is null

-- ex7-mc
select ci.city, sum(p.amount)
from payment p
join customer cu
on p.customer_id = cu.customer_id
join address a
on cu.address_id = a.address_id
join city ci
on a.city_id = ci.city_id
group by ci.city
order by sum(p.amount) desc
limit 1

-- ex8-mc
select ci.city,co.country, sum(p.amount)
from payment p
join customer cu
on p.customer_id = cu.customer_id
join address a
on cu.address_id = a.address_id
join city ci
on a.city_id = ci.city_id
join country co
on ci.country_id = co.country_id
group by ci.city, co.country
order by sum(p.amount) asc
