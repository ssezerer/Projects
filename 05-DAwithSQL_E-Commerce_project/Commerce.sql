select * from [dbo].[market_fact]
select * from [dbo].[cust_dimen]
select * from [dbo].[orders_dimen]
select * from [dbo].[prod_dimen]
select * from [dbo].[shipping_dimen]

--from order_dimen to orders

SELECT REPLACE([Ord_id],'Ord_','') as ord_id,
		[Order_Date],
		[Order_Priority]
into [dbo].[orders]
from [dbo].[orders_dimen]
order by ord_id

select * from [dbo].[orders]

alter table [dbo].[orders]
alter column [ord_id] int PRIMARY KEY not null 
			 

--from cust_dimen to customers

select * from [dbo].[cust_dimen]

SELECT REPLACE([Cust_id],'Cust_','') as cust_id,
		[Customer_Name],
		[Province],
		[Region],
		[Customer_Segment]
into [dbo].[customers]
from [dbo].[cust_dimen]
order by cust_id

select * from [dbo].[customers]

alter table [dbo].[customers]
alter column cust_id int

--from shipping_dimen to shipping

select * from [dbo].[shipping_dimen]

SELECT REPLACE([Ship_id],'SHP_','') as ship_id,
		[Order_ID],
		[Ship_Mode],
		[Ship_Date]
into [dbo].[shipping]
from [dbo].[shipping_dimen]
order by ship_id

select * from [dbo].[shipping]

alter table [dbo].[shipping]
alter column ship_id int

--from shipping_dimen to shipping

select * from [dbo].[prod_dimen]

SELECT STUFF([Prod_id], 1 , CHARINDEX('_', [Prod_id]), '') as prod_id,
		[Product_Category],
		[Product_Sub_Category]
into [dbo].[product]
from [dbo].[prod_dimen]
order by prod_id

select * from [dbo].[product]

alter table [dbo].[product]
alter column prod_id int

--from market_fact to market

select * from [dbo].[market_fact]

SELECT STUFF([Ord_id], 1 , CHARINDEX('_', [Ord_id]), '') as ord_id,
		STUFF([Prod_id], 1 , CHARINDEX('_', [Prod_id]), '') as prod_id,
		STUFF([Ship_id], 1 , CHARINDEX('_', [Ship_id]), '') as ship_id,
		STUFF([Cust_id], 1 , CHARINDEX('_', [Cust_id]), '') as cust_id,
		[Sales],
		[Discount],
		[Order_Quantity],
		[Profit],
		[Shipping_Cost],
		CASE [Product_Base_Margin]
			when 'NA' then NULL
			else [Product_Base_Margin]
		END [Product_Base_Margin]
into [dbo].[market]
from [dbo].[market_fact]
order by ord_id

select * from [dbo].[market]

alter table [dbo].[market]
alter column ord_id int
alter table [dbo].[market]
alter column prod_id int
alter table [dbo].[market]
alter column ship_id int
alter table [dbo].[market]
alter column cust_id int
alter table [dbo].[market]
alter column [Product_Base_Margin] float


drop table [dbo].[orders_dimen]
drop table [dbo].[cust_dimen]
drop table [dbo].[market_fact]
drop table [dbo].[prod_dimen]
drop table [dbo].[shipping_dimen]

/*
1. Join all the tables and create a new table with all of the columns, called combined_table.
--(market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)
*/

select m.*, c.Customer_Name, c.Customer_Segment, c.Province, c.Region, o.Order_Date, o.Order_Priority,
		p.Product_Category, p.Product_Sub_Category, s.Order_ID, s.Ship_Date, s.Ship_Mode
into combined_table
from market m
join customers c on m.cust_id = c.cust_id
join orders o on m.ord_id = o.ord_id
join product p on m.prod_id = p.prod_id
join shipping s on m.ship_id = s.ship_id

--Find the top 3 customers who have the maximum count of orders.

select top 3 Customer_Name, sum(Order_Quantity) Order_Quantity
from combined_table
group by Customer_Name
order by sum(Order_Quantity) desc; 

select top 3 cust_id, Customer_Name, count(distinct ord_id) Order_Count
from combined_table
group by cust_id, Customer_Name
order by count(distinct ord_id) desc; 

--Create a new column at combined_table as DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.

alter table combined_table
add DaysTakenForDelivery int

update combined_table
set DaysTakenForDelivery = datediff(day, order_date, Ship_date)

--Find the customer whose order took the maximum time to get delivered.

select cust_id, order_date, Ship_date, DaysTakenForDelivery
from combined_table
where DaysTakenForDelivery = (
	select max(DaysTakenForDelivery)
	from combined_table)

--Retrieve total sales made by each product from the data (use Window function)

select distinct prod_id,
	sum(Sales) over(partition by prod_id) total_sales
from combined_table
order by prod_id

--Retrieve total profit made from each product from the data (use windows function)

SELECT distinct [Prod_id],
	SUM([Profit]) OVER(PARTITION BY [Prod_id]) AS 'TOTAL PROFIT BY PRODUCT'
FROM [dbo].[combined_table]
ORDER BY 2 DESC


--Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011

select distinct year(Order_Date) year, --yanlýþ çözüm
		month(Order_Date) month,
		count(cust_id) over (partition by month(Order_Date) order by month(Order_Date)) total_cust
from combined_table
where year(Order_Date)=2011 and 
	 cust_id in (
				select cust_id
				from combined_table
				where year(Order_Date) = 2011 and month(Order_Date) = 01
				)

select distinct year(Order_Date) year, -- doðru çözüm
		month(Order_Date) month,
		count(distinct cust_id) total_cust
from combined_table
where year(Order_Date)=2011 and 
	 cust_id in (
				select cust_id
				from combined_table
				where year(Order_Date) = 2011 and month(Order_Date) = 01
				)
group by year(Order_Date), month(Order_Date)
order by month(Order_Date)

/*
Find month-by-month customer retention ratei since the start of the business (using views).

1. Create a view where each user’s visits are logged by month, allowing for the
possibility that these will have occurred over multiple years since whenever
business started operations.
2. Identify the time lapse between each visit. So, for each person and for each
month, we see when the next visit is.
3. Calculate the time gaps between visits.
4. Categorise the customer with time gap 1 as retained, >1 as irregular and NULL
as churned.
5. Calculate the retention month wise.
*/

--1. Create a view where each user’s visits are logged by month, allowing for the possibility that these will have
--   occurred over multiple years since whenever business started operations.

select cust_id,
	   substring(cast(Order_Date as varchar), 1, 7) as month,
	   count(*)
from combined_table
group by cust_id,
     	 substring(cast(Order_Date as varchar), 1, 7)
order by cust_id;


select cust_id, year(Order_Date), month(Order_Date), count(*)
from combined_table
group by cust_id, year(Order_Date), month(Order_Date)
order by 1;

create view user_visit as
select cust_id, count_in_month, convert(date, month + '-1') month_date
from
(
select cust_id,
	   substring(cast(Order_Date as varchar), 1, 7) as month,
	   count(*) count_in_month
from combined_table
group by cust_id,
     	 substring(cast(Order_Date as varchar), 1, 7)
) a;

select * from user_visit

--2. Identify the time lapse between each visit. So, for each person and for each month, we see when the next visit is.

create view time_lapse as 
select *,
	   lead(month_date) over(partition by cust_id order by month_date) as next_visit
from user_visit

--3. Calculate the time gaps between visits.

create view time_gaps as
select *,
	   datediff(month, month_date, next_visit) as time_gap
from time_lapse

select * from time_gaps

--4. Categorise the customer with time gap 1 as retained, >1 as irregular and NULL as churned.

create view customer_segment as
select distinct cust_id, average_time_gap,
case
	when average_time_gap <=1 then 'retained'
	when average_time_gap >1  then 'irregular'
	when average_time_gap is null  then 'churn'
	end customer_segment
from
	(
	select cust_id, avg(time_gap) over (partition by cust_id) as average_time_gap 
	from customer_value
	) a

select * from customer_segment
where customer_segment = 'retained'

--5. Calculate the retention month wise.

select distinct next_visit as retention_rate,
	   sum(time_gap) over (partition by next_visit) as retention_sum_monthly
from time_gaps
where time_gap <= 1
order by retention_sum_monthly desc;

/*
windows fonksiyonlari kullanirken query neticesinde olusan verisetimizin coklandigina dikkat etmek gerekir.
Bu tip durumlarda distinct kullanmaya calismak gerekir.
Fakat over partition kullanimlarinda bazen distinct kullanimi mümkün olmayabilir ve hata verebilir.
O zaman da klasik group by li cözümü denemek gerekir.
*/


