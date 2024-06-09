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
