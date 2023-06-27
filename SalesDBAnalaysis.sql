--reframe these questions to make them less generlized


--Q. What are the total sales of the store?
select sum(sales)
from sales;

--Q. What are the total number of product sold?
select count(*)
from sales
where not sales.sales=0;

--Q. What are the total Number of stores?
select count(*)
from stores;

--Q. Number of cities with stores.
select count(distinct city)
from stores;

--Q. Number of states with stores.
select count(distinct state)
from stores;

--Q. Number of unique product families.
select count(distinct family)
from sales;

--Q. Give total sales and number products solds for each year
select extract(year from date) as year, round(sum(sales)), count(*)
from sales
where not sales.sales=0
group by year;

--Q. Give different store types and thier count.
select type, count(type)
from stores
group by type;

--Q. Calculate total sales by each store.
select store_nbr, round(sum(sales))
from sales
group by store_nbr;

--Q. Calculate total sales by each store type.
select str.type, sum(str_sales.total_sales) as total_sale
from stores str
join (select store_nbr, round(sum(sales)) as total_sales
from sales
group by store_nbr) as str_sales
on str_sales.store_nbr=str.store_nbr
group by str.type
order by total_sale desc;

--Q. Calculate the total sales and number of products sold for each product family.
select family, round(sum(sales)) as total_sales, count(*) as products_sold
from sales
where not sales.sales=0
group by family
order by total_sales desc;

--Q. Which product family is the costliest?
select fam.family, fam.total_sales/fam.products_sold as average_price
from (select family, round(sum(sales)) as total_sales, count(*) as products_sold
from sales
where not sales.sales=0
group by family
order by products_sold desc) as fam
order by average_price desc;

--Q. Which state has the highest total sales and products sold?
select str.state, round(sum(sl.sales)) as total_sales, count(*) as products_sold
from sales sl
join stores str on  str.store_nbr = sl.store_nbr
where not sl.sales=0
group by str.state
order by total_sales desc;

--Q. Which city has the highest total sales and products sold?
select str.city, round(sum(sl.sales)) as total_sales, count(*) as products_sold
from sales sl
join stores str on  str.store_nbr = sl.store_nbr
where not sl.sales=0
group by str.city
order by total_sales desc;

--Q. Which store type has the highest total sales and products sold?
select str.type, round(sum(sl.sales)) as total_sales, count(*) as products_sold
from sales sl
join stores str on  str.store_nbr = sl.store_nbr
where not sl.sales=0
group by str.type
order by total_sales desc;

--Q. Which store has the highest total sales and products sold?
select str.store_nbr, round(sum(sl.sales)) as total_sales, count(*) as products_sold
from sales sl
join stores str on  str.store_nbr = sl.store_nbr
where not sl.sales=0
group by str.store_nbr
order by total_sales desc;