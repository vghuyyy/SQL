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
