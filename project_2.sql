-- 1. Số lượng đơn hàng và số lượng khách hàng mỗi tháng
with a as (select * from bigquery-public-data.thelook_ecommerce.orders
where status = 'Complete' and (created_at between '2019-01-01' and '2022-04-30')
order by created_at),
b as (select order_id, user_id, extract(month from created_at)|| '/' ||extract(year from created_at) as created, extract(month from created_at) as month, extract(year from created_at) as year from a),
c as (select distinct
month,year,
created, 
count(order_id) over(partition by created order by created) as order_count, 
count(user_id) over(partition by created order by created) as user_count
from b
order by year,month)
select created, order_count, user_count from c

-- Theo kết quả từ bảng trên ta thấy, số lượng khách mua hàng tăng qua từng năm cho thấy những chính sách hay những thay đổi của công ty là có hiệu quả 

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
with d as (select * from bigquery-public-data.thelook_ecommerce.order_items
where status = 'Complete' and (created_at between '2019-01-01' and '2022-04-30')
order by created_at),
e as (select sale_price, order_id, user_id, extract(month from created_at)|| '/' ||extract(year from created_at) as created, extract(month from created_at) as month, extract(year from created_at) as year from d),
f as (select distinct sum(sale_price) over(partition by user_id, created order by created) as saleprice, user_id, order_id,
month,year,
created, 
count(order_id) over(partition by created order by created) as order_count, 
count(user_id) over(partition by created order by created) as user_count,
from e
order by year,month),
g as (select user_id, created, round(saleprice/order_count,2) as aov, year,month from f order by year,month)
select user_id, created, aov, round(sum(aov) over(partition by created order by created),2) total_aov from g 
order by year,month

-- Từ kết quả trên ta thấy, tổng lượng mua hàng trung bình từ tháng 3/2019 đến tháng 4/2022 được cho là ổn định khi dao động trong khoảng từ 50 đến 70 
-- Trong khi tháng 1/2019 đạt tổng lượng mua hàng trung bình thấp nhất so với các tháng khác là 34.54
-- Và tháng 2/2019 đạt tổng lượng mua hàng trung bình cao nhất so với các tháng khác là 75.35

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
