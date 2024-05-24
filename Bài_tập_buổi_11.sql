-- ex1
select COUNTRY.Continent,floor(avg(CITY.Population)) from CITY 
inner join COUNTRY 
on CITY.CountryCode  = COUNTRY.Code
group by COUNTRY.Continent

-- ex2
SELECT 
round(
cast(sum(case 
when texts.signup_action='Confirmed' then 1
else 0
end) as decimal)/count(texts.signup_action),2) as confirm_rate
FROM emails
inner join texts
on emails.email_id = texts.email_id

-- ex3
SELECT age_breakdown.age_bucket,
round(sum(CASE when activities.activity_type = 'send' then activities.time_spent
ELSE 0
end)/(sum(CASE when activities.activity_type = 'send' then activities.time_spent
ELSE 0
end)+sum(CASE when activities.activity_type = 'open' then activities.time_spent
ELSE 0
end)) *100, 2) as send_perc,
round(sum(CASE when activities.activity_type = 'open' then activities.time_spent
ELSE 0
end)/(sum(CASE when activities.activity_type = 'send' then activities.time_spent
ELSE 0
end)+sum(CASE when activities.activity_type = 'open' then activities.time_spent
ELSE 0
end)) *100,2) as open_perc
FROM activities
INNER JOIN  age_breakdown
ON activities.user_id =  age_breakdown.user_id
GROUP BY age_breakdown.age_bucket, send_perc, open_perc

-- ex4
SELECT customer_contracts.customer_id
FROM customer_contracts
inner join products
on customer_contracts.product_id = products.product_id
WHERE products.product_name like 'Azure%'
GROUP BY customer_contracts.customer_id
having count(products.product_name) >=1
ORDER BY customer_contracts.customer_id

-- ex5
select a.employee_id, a.name, 
count(b.reports_to) as reports_count, round(avg(b.age),0) as average_age
from Employees as a
inner join Employees as b
on a.employee_id = b.reports_to
group by a.employee_id, a.name
order by a.employee_id

-- ex6
select Products.product_name,
sum(case when Orders.order_date between '2020-02-01' and '2020-02-29' then Orders.unit else 0 end) as unit
from Orders
inner join Products
on Orders.product_id = Products.product_id
group by Orders.product_id,Products.product_name
having sum(case when Orders.order_date between '2020-02-01' and '2020-02-29' then Orders.unit else 0 end) >= 100
-- or
select Products.product_name,
sum(Orders.unit) as unit
from Orders
inner join Products
on Orders.product_id = Products.product_id
where extract(month from Orders.order_date) = '02' and extract(year from Orders.order_date) = '2020' 
group by Orders.product_id,Products.product_name
having sum(unit) >= 100

-- ex7
select a.page_id
from pages as a
left join page_likes as b 
on a.page_id = b.page_id
where b.liked_date is not null
order by b.page_id asc

