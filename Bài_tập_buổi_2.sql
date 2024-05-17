-- ex1
select NAME from CITY
where (COUNTRYCODE = "USA" and POPULATION > 120000)

-- ex2
select * from CITY
Where COUNTRYCODE = "JPN"

-- ex3
select CITY, STATE from STATION

-- ex4
  select distinct CITY from STATION 
where CITY like 'a%' or CITY like 'e%' or CITY like 'i%' or CITY like 'o%' or CITY like 'u%';

-- ex5
select distinct CITY from STATION 
where CITY like '%a' or CITY like '%e' or CITY like '%i' or CITY like '%o' or CITY like '%u';

-- ex6
  select distinct CITY from STATION 
where not( CITY like 'a%' or CITY like 'e%' or CITY like 'i%' or CITY like 'o%' or CITY like 'u%')
-- or
-- where CITY not like 'a%' and CITY not like 'e%' and CITY not like 'i%' and CITY not like 'o%' and CITY not like 'u%')

-- ex7
select name from Employee
order by name ASC 

-- ex8
select name from Employee
where salary > 2000 and months < 10
order by employee_id asc

-- ex9
select product_id from Products
where low_fats = 'Y' and recyclable = 'Y'

-- ex10
select name from Customer
where referee_id is null or referee_id <> 2

-- ex11
select name, population, area from World
where area >= 3000000 or population >= 25000000

-- ex12
select distinct author_id as id from Views
where author_id = viewer_id
order by author_id asc

-- ex13
SELECT part, assembly_step FROM parts_assembly
where finish_date is null

-- ex14
select * from lyft_drivers
where (yearly_salary <= 30000 or yearly_salary >= 70000)

-- ex15
select advertising_channel  from uber_advertising
where money_spent > 100000 and year = 2019
