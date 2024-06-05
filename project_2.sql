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

-- Theo kết quả từ bảng trên, ta thấy số lượng khách mua hàng tăng qua từng năm cho thấy những chính sách hay những thay đổi của công ty là có hiệu quả 

-------
-- Bảng orders: ghi lại đơn hàng mà khách đã đặt
-- Bảng order_items: ghi lại danh sách các mặt hàng đã mua trong mỗi order ID
-- Bảng products: ghi lại chi tiết các sản phẩm được bản trên The Look, bao gồm: Price, Brand, & Product categories

with a as (select * from bigquery-public-data.thelook_ecommerce.order_items
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


select * from bigquery-public-data.thelook_ecommerce.order_items
where status = 'Complete' and (created_at between '2019-01-01' and '2022-04-30')
order by created_at
