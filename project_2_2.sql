-- Orders = o, Order_items = ot, products = p
with a as (select 
format_date('%y-%m', o.created_at) as Month, --1
format_date('%y', o.created_at) as Year, --2
p.category as Product_category, --3
sum(ot.sale_price) as TPV, --4
count(ot.order_id) as TPO, --5
sum(p.cost) as Total_cost --8
from bigquery-public-data.thelook_ecommerce.orders as o
join bigquery-public-data.thelook_ecommerce.order_items as ot
on o.user_id = ot.user_id
join bigquery-public-data.thelook_ecommerce.products as p
on ot.product_id = p.id
group by format_date('%y-%m', o.created_at),format_date('%y', o.created_at),p.category)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
select 
Month, --1
Year, --2
Product_category, --3
TPV, --4
TPO, --5
(-lag(TPV,1) over(partition by Product_category order by Year, Month)+TPV)*100.0/lag(TPV,1) over(partition by Product_category order by Year, Month) || '%' as Revenue_growth, --6
(-lag(TPO,1) over(partition by Product_category order by Year, Month)+TPO)*100.0/lag(TPO,1) over(partition by Product_category order by Year, Month) || '%' as Order_growth, --7
Total_cost, --8
TPV - Total_cost as Total_profit, --9
(TPV - Total_cost)/Total_cost as Profit_to_cost_ratio --10
from a
order by Month, Year, Product_category
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- All status
with b as (select user_id, amount,format_date('%Y-%m', first_date)as cohort_date, created_at,
(extract(year from created_at) - extract(year from first_date))*12 
+ (extract(month from created_at) - extract(month from first_date)) +1 as index from (select user_id, sale_price as amount, min(created_at) over(partition by user_id) as first_date, created_at from bigquery-public-data.thelook_ecommerce.order_items) a
order by user_id),

c as(select cohort_date, index, count(distinct user_id) as count, sum(amount) as revenue from b
group by cohort_date, index),

d as (select cohort_date,
	sum(case when index = 1 then count else 0 end) as m1,
	sum(case when index = 2 then count else 0 end) as m2,
	sum(case when index = 3 then count else 0 end) as m3,
  sum(case when index = 4 then count else 0 end) as m4
from c
group by cohort_date
order by cohort_date)

select 
cohort_date,
round(m1*100.0/m1,2) || '%' as m1,
round(m2*100.0/m1,2) || '%' as m2,
round(m3*100.0/m1,2) || '%' as m3,
round(m4*100.0/m1,2) || '%' as m4
from d
------------------
/*
- Từ kết quả trên ta dễ nhận thấy, số lượng người dùng mới qua các tháng có xu hướng tăng. Điều đó cho thấy những chính sách hay những thay đổi của công ty là có hiệu quả.
- Tuy vậy, trong giai đoạn 4 tháng đầu với tham chiếu là lần mua hàng đầu tiên thì tỷ lệ người dùng quay lại sử dụng trong tháng tiếp theo là khá thấp trong khoảng +-5% 
- Và con số này chỉ cải thiện trong giai đoạn quý 3 và quý 4 năm 2023.
* Vậy, công ty cần xem xét lại  chính sách hay những thay đổi của công ty giúp tối đa hoá lợi nhuận và giảm các chi phí dư thừa khác.
*/
-- Complete status
with 
b as (select user_id, amount,format_date('%Y-%m', first_date)as cohort_date, created_at,
(extract(year from created_at) - extract(year from first_date))*12 
+ (extract(month from created_at) - extract(month from first_date)) +1 as index from (select user_id, sale_price as amount, min(created_at) over(partition by user_id) as first_date, created_at from bigquery-public-data.thelook_ecommerce.order_items
where status = 'Complete') a
order by user_id),

c as(select cohort_date, index, count(distinct user_id) as count, sum(amount) as revenue from b
group by cohort_date, index),

d as (select cohort_date,
	sum(case when index = 1 then count else 0 end) as m1,
	sum(case when index = 2 then count else 0 end) as m2,
	sum(case when index = 3 then count else 0 end) as m3,
  sum(case when index = 4 then count else 0 end) as m4
from c
group by cohort_date
order by cohort_date)

select 
cohort_date,
round(m1*100.0/m1,2) || '%' as m1,
round(m2*100.0/m1,2) || '%' as m2,
round(m3*100.0/m1,2) || '%' as m3,
round(m4*100.0/m1,2) || '%' as m4
from d
------------------
/*
- Từ kết quả trên ta dễ nhận thấy, số lượng người dùng mới qua các tháng có xu hướng tăng. Điều đó cho thấy những chính sách hay những thay đổi của công ty là có hiệu quả.
- Tuy vậy, trong giai đoạn 4 tháng đầu với tham chiếu là lần mua hàng đầu tiên thì tỷ lệ người dùng quay lại sử dụng trong tháng tiếp theo là khá thấp trong khoảng +-4%
* Vậy, công ty cần xem xét lại  chính sách hay những thay đổi của công ty giúp tối đa hoá lợi nhuận và giảm các chi phí dư thừa khác.
*/

-- GG Sheet: https://docs.google.com/spreadsheets/d/1cpQd4mmYzNGF0hueAwh26iCYkA2bDkwXAQIeLrNiqRA/edit?usp=sharing
