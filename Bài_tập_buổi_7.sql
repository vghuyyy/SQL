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
select sender_id, 
count(message_id) as message_count
from messages
WHERE EXTRACT(month from sent_date) = 8 and 
extract(year from sent_date) =2022
group by sender_id
order by count(message_id) desc
limit 2

-- ex6
select tweet_id
from Tweets
where length(content) > 15

-- ex7
select activity_date as day, count(distinct user_id) as active_users from Activity
where activity_date between '2019-06-28' and '2019-07-27'
group by activity_date

-- ex8 
select count(id) as number_of_employee from employees
where extract(month from joining_date)
between 1 and 7 and extract(year from joining_date) = 2022

-- ex9
select first_name, position('a' in first_name) from worker

-- ex10
select country, 
substring(title,position('20' in title),4) from winemag_p2
where country = 'Macedonia' 
