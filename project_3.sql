-- Question 1:
select productLine, year_id, dealsize, sum(quantityordered * priceeach) as revenue 
from sales_dataset_rfm_prj_clean
group by productLine, year_id, dealsize
order by year_id, dealsize desc,revenue

-- Question 2:
with a as (select ordernumber, productLine, year_id, month_id, dealsize, sum(quantityordered * priceeach) as revenue 
from sales_dataset_rfm_prj_clean
group by ordernumber, productLine, year_id, month_id, dealsize
order by year_id,month_id, dealsize desc,revenue),

	b as (select month_id, year_id, sum(revenue) as total_revenue_per_month from a
	group by month_id, year_id),

	c as (select month_id, year_id, total_revenue_per_month from b as c
	where total_revenue_per_month in (select max(total_revenue_per_month) from b group by year_id )),
	
	d as ((select ordernumber, productLine, month_id, year_id, dealsize, sum(quantityordered * priceeach) as revenue from sales_dataset_rfm_prj_clean 
	group by ordernumber, productLine, month_id, year_id, dealsize)),
	
	e as (select *, sum(revenue) over(partition by month_id, year_id) as total_revenue_per_month from d)

select c.month_id, c.total_revenue_per_month, e.ordernumber from e
join c 
on e.month_id = c.month_id
order by c.total_revenue_per_month

-- Question 3:
with 
	d as ((select ordernumber, productLine, month_id, year_id, dealsize, sum(quantityordered * priceeach) as revenue from sales_dataset_rfm_prj_clean 
	group by ordernumber, productLine, month_id, year_id, dealsize)),
	
	e as (select productLine,month_id, year_id, sum(revenue) as total_revenue from d
where month_id = 11
group by productLine,month_id, year_id),
	
	f as (select productLine, month_id, year_id, total_revenue from e
	where total_revenue in (select max(total_revenue) from e group by month_id, year_id)),
	
	g as (select ordernumber, productLine,month_id, year_id, sum(revenue) over(partition by productLine,month_id, year_id) as total_revenue from d
where month_id = 11)

select g.month_id, g.total_revenue, g.ordernumber from g
join f
on g.total_revenue = f.total_revenue

-- Question 4:
with 
	d as ((select ordernumber, productLine, month_id, year_id, dealsize, sum(quantityordered * priceeach) as revenue from sales_dataset_rfm_prj_clean 
	where country = 'UK'
	group by ordernumber, productLine, month_id, year_id, dealsize)),
	
	e as (select productLine, year_id, sum(revenue) as total_revenue from d
group by productLine, year_id)

select *, rank() over(partition by year_id order by total_revenue desc) as rank from e

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
