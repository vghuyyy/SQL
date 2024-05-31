-- ex1
SELECT 
extract(year from transaction_date) as year, 
product_id, spend as curr_year_spend,
lag(spend) over(partition by product_id) as prev_year_spend, 
round((spend-lag(spend) over(partition by product_id))*100/lag(spend) over(partition by product_id),2) as yoy_rate 
FROM user_transactions

-- ex2
select a.card_name, a.issued_amount from (SELECT card_name,
RANK() over(partition by card_name order by issue_month||'/'||issue_year),issued_amount
FROM monthly_cards_issued) as a
where a.rank = 1
order by issued_amount desc
--or
SELECT distinct card_name,
first_value(issued_amount) 
over(partition by card_name order by issue_month||'/'||issue_year)
FROM monthly_cards_issued
order by issued_amount desc
 
-- ex3
SELECT a.user_id, a.spend, a.transaction_date  
FROM 
(select *,
rank() over( partition by user_id order by transaction_date
 )as rank from transactions) as a
where rank = 3

-- ex4
with a as (SELECT transaction_date, user_id, sum (spend) as total_spend
FROM user_transactions
group by transaction_date, user_id) 

select transaction_date, user_id, rank() over(partition by transaction_date order by total_spend) 
from a

-- ex5
WITH tab_1 as (SELECT user_id, tweet_date,
tweet_count as lag_0,
coalesce(LAG(tweet_count,1) OVER ( PARTITION BY user_id ORDER BY tweet_date), '0')AS lag_1,
coalesce(LAG(tweet_count,2) OVER ( PARTITION BY user_id ORDER BY tweet_date), '0') AS lag_2,
count(tweet_date) OVER ( PARTITION BY user_id ORDER BY tweet_date) as day
FROM tweets)

,tab_2 as (select *,
case
when day <= 2 THEN
round((lag_0+lag_1+lag_2)/cast(day as decimal),2)
else round ((lag_0+lag_1+lag_2)/3.0,2)
end as rolling_avg_3d FROM tab_1)

-- ex6
select count(*) from (SELECT transaction_id,
merchant_id,
credit_card_id,amount,transaction_timestamp,
lead(transaction_timestamp) over( PARTITION BY 
merchant_id, 
credit_card_id,amount),
extract( hour from lead(transaction_timestamp) over( PARTITION BY 
merchant_id, 
credit_card_id,amount)-first_value(transaction_timestamp) over( PARTITION BY 
merchant_id, 
credit_card_id,amount))*60 +
extract( minute from lead(transaction_timestamp) over( PARTITION BY 
merchant_id, 
credit_card_id,amount)-first_value(transaction_timestamp) over( PARTITION BY 
merchant_id, 
credit_card_id,amount)) as diff
FROM transactions) a
where a.diff <= 10

-- ex7
with a as (select category, product, sum(spend) as total_spend,
extract(year from transaction_date) as year,
RANK() OVER (PARTITION BY category ORDER BY SUM(spend) DESC) AS rank
from product_spend
where extract(year from transaction_date) = '2022'
group by 
category, product,extract(year from transaction_date)
order by category)

select category, product, total_spend from a 
where rank in ('1', '2')

-- ex8
with tab1 as 
(select a.artist_name, count(*) as so_lan
from global_song_rank c
join songs b on b.song_id = c.song_id
join artists a on a.artist_id = b.artist_id
where c.rank <=10
group by a.artist_name),

tab2 as 
(select *, dense_rank() over(order by so_lan desc) as rank
from tab1)

select artist_name, rank
from tab2
where rank <=5
order by rank,artist_name

