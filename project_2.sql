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
-- 2. Giá trị đơn hàng trung bình (AOV) và số lượng khách hàng mỗi tháng
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
-- 3. Nhóm khách hàng theo độ tuổi
with d as (select * from bigquery-public-data.thelook_ecommerce.order_items
where status = 'Complete' and (created_at between '2019-01-01' and '2022-04-30')
order by created_at),
e as (select *, extract(month from created_at)|| '/' ||extract(year from created_at) as created, extract(month from created_at) as month, extract(year from created_at) as year from d),
f as (select *, 
count(order_id) over(partition by created order by created) as order_count, 
count(user_id) over(partition by created order by created) as user_count,
from e
order by year,month),
g as (select * from f
inner join bigquery-public-data.thelook_ecommerce.users b
on f.user_id = b.id),
h as (select first_name, last_name, gender, age from g
where age = (select min(age) from g) and gender = 'F'),
i as (select first_name, last_name, gender, age from g
where age = (select min(age) from g) and gender = 'M'),
k as (select first_name, last_name, gender, age from g
where age = (select max(age) from g) and gender = 'F'),
l as (select first_name, last_name, gender, age from g
where age = (select max(age) from g) and gender = 'M'),

m as (select * from h
union all
select * from i
union all
select * from k
union all
select * from l)

select *, 
case 
when age = 12 then 'youngest'
when age = 70 then 'oldest'
end as tag
from m
order by age, gender

-- Từ kết quả trên ta nhận thấy số lượng người trẻ tuổi (với độ tuổi là 12) =  203 và số lượng người cao tuổi (với độ tuổi là 70) = 144 
-- Tỷ lệ giữa nam và nữ trong nhóm người trẻ tuổi xấp xỉ 50%
-- Còn tỷ lệ giữa nam và nữ trong nóm người cao tuổi là 50%

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 4.Top 5 sản phẩm mỗi tháng
with a as (select *,
extract(month from created_at)|| '/' ||extract(year from created_at) as created, extract(month from created_at) as month, extract(year from created_at) as year
from bigquery-public-data.thelook_ecommerce.order_items a
join bigquery-public-data.thelook_ecommerce.products b
on a.product_id = b.id
where a.status = 'Complete'),
b as (select year, month, count(product_id) over(partition by product_id, created) as amount, created, product_id, name as product_name, sale_price, cost, sale_price - cost as profit from a),
c as (select amount * profit as total_profit, created, product_id, product_name, sale_price, cost, year, month from b),
d as (select distinct total_profit, created, product_id, product_name, sale_price, cost, 
dense_rank() over(partition by created order by total_profit desc) as rank_per_month ,year, month from c)

select  created, product_id, product_name, sale_price, cost, total_profit, rank_per_month 
from d
where rank_per_month < 6
order by year, month, rank_per_month

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 5.Doanh thu tính đến thời điểm hiện tại trên mỗi danh mục
with d as (select * from(select *,
extract(date from created_at) as dates
from bigquery-public-data.thelook_ecommerce.order_items a
join bigquery-public-data.thelook_ecommerce.products b
on a.product_id = b.id
where a.status = 'Complete') c
where dates between '2022-01-15' and '2022-04-15'),
e as (select distinct count(product_id) over(partition by product_id, dates) as amount, * from d)

select dates, category as product_categories, (sale_price * amount) as revenue from e

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- NEW
  with orders as (
  select *, format_date('%Y-%m', delivered_at) as month_year 
  from bigquery-public-data.thelook_ecommerce.orders
  where status = 'Complete'
  ),
-- Check null: Không có biến nào trong các biến quan tâm có dữ liệu thiếu
  orders_main as (
  select order_id, user_id, created_at, delivered_at, num_of_item, month_year 
  from orders
  ),
-- Check duplicate
/*
select * from (select row_number() over (partition by order_id, num_of_item order by month_year) as stt from orders_main) as a
where stt > 1
*/
  orders_item as (
  select *, format_date('%Y-%m', created_at) as month_year 
  from bigquery-public-data.thelook_ecommerce.order_items
  where status = 'Complete'
  ),

  orders_item_check as (
  select order_id, user_id, product_id, created_at, sale_price, month_year 
  from orders_item
  ),

  orders_item_main as (
  select * from (select *,row_number() over (partition by order_id, product_id order by month_year) as stt from orders_item_check) as a
  where stt = 1
  )
-- Câu 1:
-- Vì số lượng yêu cầu đơn hàng là đã hoàn thành nên sẽ sử dụng biến Delivered_date làm mốc thời gian ghi nhận
-- Câu 1: Từ kết quả của câu truy vấn ta thấy rõ số lượng đơn hàng và số lượng khách mua hàng có xu hướng tăng theo thời gian
-- Đặc biệt số lượng khách và số lượng đơn hàng có sự gia tăng đáng kể trong 3 tháng đầu năm 2022 cho thấy các chương trình giảm giá hay các chương trình tiếp thị của thelook là có ảnh hưởng đáng kể đến doanh số và doanh thu của công ty

/*
select month_year, count(distinct user_id) as total_user, count(order_id) as total_order from orders_main
where month_year between '2019-01' and '2022-04'
group by month_year
order by month_year
*/
-- Câu 2:
select month_year,
count(DISTINCT user_id) as distinct_users,
round(sum(sale_price)/count(distinct order_id),2) as average_order_value from orders_item_main
where month_year between '2019-01' and '2022-04'
group by month_year
order by month_year
