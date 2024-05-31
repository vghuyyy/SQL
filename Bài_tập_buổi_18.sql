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
