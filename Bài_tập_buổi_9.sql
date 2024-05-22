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
