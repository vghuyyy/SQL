--Câu 1:
alter table sales_dataset_rfm_prj
alter column ordernumber type integer using(trim(ordernumber)::integer)
	
alter table sales_dataset_rfm_prj
alter column quantityordered type integer using(trim(quantityordered)::integer)
	
alter table sales_dataset_rfm_prj
alter column priceeach type decimal using(trim(priceeach)::decimal)
	
alter table sales_dataset_rfm_prj
alter column orderlinenumber type integer using(trim(orderlinenumber)::integer)
	
alter table sales_dataset_rfm_prj
alter column sales type decimal using(trim(sales)::decimal)
	
alter table sales_dataset_rfm_prj
alter column orderdate type timestamp using(trim(orderdate)::timestamp without time zone)
	
alter table sales_dataset_rfm_prj
alter column status type text 
	
alter table sales_dataset_rfm_prj
alter column productline type text
	
alter table sales_dataset_rfm_prj
alter column msrp type integer using(trim(msrp)::integer)
	
alter table sales_dataset_rfm_prj
alter column productcode type text
	
alter table sales_dataset_rfm_prj
alter column customername type text
	
alter table sales_dataset_rfm_prj
alter column phone type text
	
alter table sales_dataset_rfm_prj
alter column addressline1 type text
	
alter table sales_dataset_rfm_prj
alter column addressline2 type text

alter table sales_dataset_rfm_prj
alter column city type text

alter table sales_dataset_rfm_prj
alter column state type text

alter table sales_dataset_rfm_prj
alter column postalcode type text

alter table sales_dataset_rfm_prj
alter column country type text

alter table sales_dataset_rfm_prj
alter column territory type text

alter table sales_dataset_rfm_prj
alter column contactfullname type text

alter table sales_dataset_rfm_prj
alter column dealsize type text

--Câu 2:
select *
	from sales_dataset_rfm_prj
where 
	ordernumber is null or 
	quantityordered is null or 
	priceeach is null or 
	orderlinenumber is null or 
	sales is null or 
	orderdate is null

--Câu 3:
alter table sales_dataset_rfm_prj
	add column contactfirstname varchar(50)

alter table sales_dataset_rfm_prj
	add column contactlastname varchar(50)

update sales_dataset_rfm_prj
	set contactfirstname = Upper(substring(contactfullname,1,1)) || Lower(substring(contactfullname,2, position('-' in contactfullname)-2))

update sales_dataset_rfm_prj
	set contactlastname = Upper(substring(contactfullname, position('-' in contactfullname)+1,1)) || Lower(substring(contactfullname, position('-' in contactfullname)+2))

--Câu 4:
alter table sales_dataset_rfm_prj
add column Quý int

alter table sales_dataset_rfm_prj
add column Tháng int

alter table sales_dataset_rfm_prj
add column Năm int

update sales_dataset_rfm_prj
set qtr_id= extract(quarter from orderdate)

update sales_dataset_rfm_prj
set month_id= extract(month from orderdate)

update sales_dataset_rfm_prj
set year_id= extract(year from orderdate)

--Câu 5:
-- Cách 1:
with a as(select
percentile_cont(0.25) within group( order by quantityordered) as Q1,
percentile_cont(0.75) within group( order by quantityordered) as Q3,
percentile_cont(0.75) within group( order by quantityordered) - percentile_cont(0.25) within group( order by quantityordered) as IQR,
percentile_cont(0.25) within group( order by quantityordered) - 1.5*(percentile_cont(0.75) within group( order by quantityordered) - percentile_cont(0.25) within group( order by quantityordered)) as min,
percentile_cont(0.75) within group( order by quantityordered) + 1.5*(percentile_cont(0.75) within group( order by quantityordered) - percentile_cont(0.25) within group( order by quantityordered)) as max
from sales_dataset_rfm_prj) 
	
select quantityordered from sales_dataset_rfm_prj
where quantityordered < (select a.min from a) or quantityordered > (select a.max from a)

-- Cách 2:
with 
c as ( select avg(quantityordered) as avg, stddev(quantityordered) as std from sales_dataset_rfm_prj),
d as ( select quantityordered, (select avg from c), (select std from c) from sales_dataset_rfm_prj)

select distinct quantityordered, (quantityordered-avg)/std as z_score from d
where (quantityordered-avg)/std > 3
