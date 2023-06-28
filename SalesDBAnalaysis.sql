--Beginner Level

--Q. What are the total sales of the store?
select sum(sales)
from sales;

--Q. What are the total number of product sold?
select count(*)
from sales s
where not s.sales=0;

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

--Q. Give different store types and thier count.
select type, count(type)
from stores
group by type;

--Q. Calculate total sales by each store.
select store_nbr, round(sum(sales))
from sales
group by store_nbr;

--Q. Give total sales and number products solds for each year
select extract(year from date) as year, round(sum(sales)), count(*)
from sales
where not sales.sales=0
group by year;

--Q. Find out total number of holidays/events.
select type, count(*)
from holidays_events
group by type;

--Q. Give average price of oil over the years.
select extract(year from date) as year, avg(dcoilwtico)
from oil
group by year
order by year;

--Q. Which 10 products were on promotion for maximum number of days?
select family, sum(onpromotion) as days_of_promotion
from sales
group by family
order by days_of_promotion desc
limit 10;

--Q. Give total number of transactions from each store.
select store_nbr, sum(transactions) as total_transactions
from transactions
group by store_nbr
order by total_transactions desc;

--Q. Calculate the total sales and number of products sold for each product family.
select family, round(sum(sales)) as total_sales, count(*) as products_sold
from sales
where not sales.sales=0
group by family
order by total_sales desc;

--Intermediate level

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

--Q. Find out sales on each holiday.
select h.date, round(s.total_sales) as total_sales
from holidays_events h
left join (select s.date, sum(s.sales) as total_sales
from sales s
group by s.date
order by s.date) as s on s.date=h.date
where h.type='Holiday' and total_sales is not null;

--Q. What are the total sales done by each store type?
select str.type, sum(str_sales.total_sales) as total_sale
from stores str
join (select store_nbr, round(sum(sales)) as total_sales
from sales
group by store_nbr) as str_sales
on str_sales.store_nbr=str.store_nbr
group by str.type
order by total_sale desc;

--Q. Which product family is the costliest?
select fam.family, fam.total_sales/fam.products_sold as average_price
from (select family, round(sum(sales)) as total_sales, count(*) as products_sold
from sales
where not sales.sales=0
group by family
order by products_sold desc) as fam
order by average_price desc;

--Q. Combine total sales, number of products sold, average oil prices, total transactions in a single table over dates.
select s.date, round(sum(s.sales)) as total_sales, 
count(s.family) as products_sold, 
avg(o.dcoilwtico) as oil_prices, 
sum(tr.total_transactions) as total_transactions
from sales s
left join oil o on o.date=s.date
left join (select t.date, sum(t.transactions) as total_transactions
from transactions t
group by t.date
order by t.date) as tr on tr.date=s.date
where not s.sales=0
group by s.date;

--Advance level

--Q. Give list of top performing stores from each state.
with state_store_sales as (
select str.state, str.store_nbr, sum(s.sales) as total_sales,
row_number() over(partition by str.state order by sum(s.sales) desc) as rowno
from stores str
join sales s on s.store_nbr=str.store_nbr
group by str.state, str.store_nbr
order by str.state, total_sales desc)
select state, store_nbr, round(total_sales) as total_sales
from state_store_sales
where rowno=1
order by total_sales desc;

--Q. Which product family is popular from each store?
with store_pfamily_psold as(
select s.store_nbr, s.family, count(*) as products_sold,
row_number() over(partition by s.store_nbr order by count(*) desc) as rowno
from sales s
where not s.sales=0
group by s.store_nbr, s.family
order by s.store_nbr, products_sold desc)
select store_nbr, family as popular_product, products_sold
from store_pfamily_psold
where rowno=1;

--Q. Which product family is popular from each state?
with state_pfam_psold as (
select st.state, s.family, count(*) as products_sold,
row_number() over(partition by st.state order by count(*) desc) as rowno
from sales s
join stores st on st.store_nbr=s.store_nbr
where not s.sales=0
group by st.state, s.family
order by products_sold desc)
select state, family as popular_product, products_sold
from state_pfam_psold
where rowno=1;

--Q. Which store has their total sales below average and which stores have their sales above average?
with store_wise_sales as 
	( select s.store_nbr, round(sum(s.sales)) as total_sales
	from sales s
	group by s.store_nbr )
select s.store_nbr, round(sum(s.sales)) as total_sales,
case
	when sum(s.sales) < (select avg(total_sales) from store_wise_sales) then 'less than average'
	when sum(s.sales) > (select avg(total_sales) from store_wise_sales) then 'greater than average'
	else 'equal to average'
end as sales_type
from sales s
group by s.store_nbr 
order by s.store_nbr;

--Q. Which state has their total sales below average and which state have their sales above average?
with state_wise_sales as (select st.state, round(sum(s.sales)) as total_sales
						 from sales s
						 join stores st on st.store_nbr=s.store_nbr
						 group by st.state)						 
select st.state, round(sum(s.sales)) as total_sales,
case
	when sum(s.sales) < (select avg(total_sales) from state_wise_sales) then 'less than average'
	when sum(s.sales) > (select avg(total_sales) from state_wise_sales) then 'greater than average'
	else 'equal to average'
end as sales_type
from sales s
join stores st on st.store_nbr=s.store_nbr
group by st.state;

--Q. Find out how long each shop has been opened for.
with rowsr as(
select distinct date, store_nbr, (select max(date) from sales) as last_date,
row_number() over(partition by store_nbr order by date ) as rowno
from sales s
where not s.sales=0
order by date)
select age(last_date,date) as duration, store_nbr
from rowsr
where rowno=1
order by duration;
