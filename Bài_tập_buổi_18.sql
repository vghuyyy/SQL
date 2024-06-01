-- ex1
with 
a as (select delivery_id, customer_id,
first_value(order_date) 
over(partition by customer_id order by order_date) as first_order,
customer_pref_delivery_date
from Delivery),

b as (select *, row_number() over(partition by customer_id order by first_order) rank from a)

select
round(sum(case 
when rank = 1 and first_order = customer_pref_delivery_date then 1
else 0
end)*100.0/
sum(case 
when rank = 1 then 1
else 0
end),2) as immediate_percentage
from b

-- ex2
with a as (select player_id, event_date, 
event_date - first_value(event_date) over(partition by player_id order by event_date) diff
from Activity)
select 
round(cast((select count(player_id) from a
where diff = 1) as decimal)/(select count(distinct player_id) from a),2) as fraction

-- ex3
select 
case
when id = (select max(id) from Seat) and (select max(id) from Seat)%2 = 1 then (select max(id) from Seat)
when id%2 = 1 then id+1
when id%2 = 0 then id-1
end as id, student
from Seat
order by id

-- ex4

-- ex5
with a as(select count(concat(lat,lon)), concat(lat,lon) as lat_lon from Insurance
group by concat(lat,lon)
having count(concat(lat,lon)) = 1),

b as (select count(tiv_2015), tiv_2015 from Insurance
group by tiv_2015
having count(tiv_2015) > 1),

c as (select *, concat(lat,lon) as lat_lon_2 from Insurance)

select round(cast(sum(tiv_2016) as decimal),2) as tiv_2016 from c
join a on c.lat_lon_2 = a.lat_lon
where c.tiv_2015 in (select b.tiv_2015 from b)

-- ex6
with a as 
(select Employee.name as Employee, Department.name as Department,salary, 
dense_rank() over(partition by departmentId order by salary desc) as rank from Employee
join Department
on Employee.departmentId = Department.id)

select Department, Employee, salary as Salary from a
where rank <=3

-- ex7
select person_name from (select person_name, 
sum(weight) over(order by turn) as total
from Queue)
where total <= 1000
order by total desc
limit 1

-- ex8
select product_id, new_price as price from(select *, rank() over(partition by product_id order by change_date desc) rank
from Products
where change_date <= '2019-08-16') 
where rank = 1
union
select product_id, 10 as price from(select *, rank() over(partition by product_id order by change_date) rank
from Products)
where change_date > '2019-08-16' and rank = 1

