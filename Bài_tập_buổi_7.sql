-- ex1
select Name
from STUDENTS
where Marks > 75
order by right( Name, 3), ID asc

-- ex2
select user_id,
upper(left(name,1))||lower(right(name,length(name)-1))as name
from Users
order by user_id

-- ex3
SELECT manufacturer,
'$'||round(sum(total_sales/1000000))||' '||'million' as sale
FROM pharmacy_sales
group by manufacturer, total_sales
order by total_sales desc, manufacturer ASC

-- ex4
SELECT extract( month from submit_date) as mth,
product_id as product, round(avg(stars),2) as avg_stars
FROM reviews
group by product_id, extract( month from submit_date)
order by extract( month from submit_date), product_id

-- ex5
