-- Question 1:
with cau1 as (
	select productline, year_id, dealsize, sum(revenue) as total_revenue 
	from sales_dataset_rfm_prj_clean
	group by productline, year_id, dealsize)

-- Question 2:
with cau2 as (
	select month_id, year_id, ordernumber, sum(revenue) over (partition by month_id, year_id) as total_revenue
	from sales_dataset_rfm_prj_clean),
	cau2_1 as (
	select month_id, year_id, ordernumber, total_revenue, 
	rank() over (partition by year_id order by total_revenue desc) as top1_revenue
	from cau2)
select distinct * from cau2_1 
where top1_revenue = 1

-- Question 3:
with cau3 as (
select month_id, year_id, productline, ordernumber, 
sum(quantityordered) over (partition by month_id, year_id, productline,ordernumber) as total_item,
row_number() over (partition by month_id, year_id, productline,ordernumber) as stt
from sales_dataset_rfm_prj_clean
),
	cau3_1 as (
	select * from cau3
	where stt = 1
	),

	cau3_2 as (
	select month_id, year_id, productline, ordernumber, total_item,
	rank() over (partition by month_id, year_id order by total_item desc) as rank
	from cau3_1)
select month_id, year_id, productline, ordernumber, total_item from cau3_2
where rank = 1 and month_id = 11

-- Question 4:
with cau4 as (
	select * from sales_dataset_rfm_prj_clean
	where country = 'UK'
	),
	cau4_1 as (
	select year_id, productline, sum(revenue) as total_revenue from cau4
	group by year_id, productline
	)
select *, dense_rank() over (partition by year_id order by total_revenue desc) from cau4_1

-- Question 5:
with RFM as (select customername,
	current_date - max(orderdate) as r,
	count(distinct ordernumber) as f,
	sum(sales) as m from sales_dataset_rfm_prj_clean
group by customername)
	
,rfm_score as (select customername,
	ntile(5) over(order by r desc) as r_score,
	ntile(5) over(order by f asc) as f_score,
	ntile(5) over(order by m asc) as m_score,
	r,f,m
	from RFM)

, rfm_final as (select customername, 
	cast(r_score as varchar)||cast(f_score as varchar)||cast(m_score as varchar) as rfm_sc,
	r,f,m
	from rfm_score)
	
select customername, segment from (select a.customername, r, f, m, b.segment, row_number() over(order by r asc, f desc, m desc) as rank from rfm_final as a
join segment_score as b
on a.rfm_sc = b.scores) a
where rank = 1
