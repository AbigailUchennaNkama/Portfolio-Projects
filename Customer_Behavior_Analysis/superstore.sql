

--EXPLORATORY DATA ANALYSIS

-- CREATE CUSTOMER_ID COLUMN
ALTER TABLE [dbo].[Sales - Data Modelling Example] ADD Customer_ID INT;

;WITH CTE AS (
  SELECT Customer_Name, ROW_NUMBER() OVER (ORDER BY Customer_Name) AS row_num
  FROM [dbo].[Sales - Data Modelling Example]
  GROUP BY Customer_Name
)
select * from CTE
UPDATE [dbo].[Sales - Data Modelling Example]
SET Customer_ID = CTE.row_num
FROM [dbo].[Sales - Data Modelling Example] INNER JOIN CTE ON [dbo].[Sales - Data Modelling Example].Customer_Name = CTE.Customer_Name;
 

 -- CREATE PRODUCT_ID COLUMN
ALTER TABLE [dbo].[Sales - Data Modelling Example] ADD Product_ID INT;

;WITH CTE2 AS (
  SELECT Product_Name, ROW_NUMBER() OVER (ORDER BY Product_Name) AS row_num2
  FROM [dbo].[Sales - Data Modelling Example]
  GROUP BY Product_Name
)
UPDATE [dbo].[Sales - Data Modelling Example]
SET Product_ID = CTE2.row_num2
FROM [dbo].[Sales - Data Modelling Example] INNER JOIN CTE2 ON [dbo].[Sales - Data Modelling Example].Product_Name = CTE2.Product_Name;

-- 1. WHAT YEAR HAD THE HIGHEST SALES REVENUE
SELECT  YEAR(Order_Date) as year, SUM(Sales ) total_sales_revenue_by_year
FROM [dbo].[Sales - Data Modelling Example] 
GROUP BY YEAR(order_date)
ORDER BY 2 DESC


-- 2. WHAT WAS THE BEST MONTH FOR SALES IN A SPECIFIC YEAR AND HOW MUCH WAS EARNED THAT MONTH?
SELECT DATEPART(month, Order_Date) as month_, COUNT(Order_ID) as order_count, SUM(Sales) as total_sales_revenue_by_month
FROM [dbo].[Sales - Data Modelling Example] 
WHERE YEAR(Order_Date) = 2018
GROUP BY DATEPART(month, Order_Date)
ORDER BY total_sales_revenue_by_month DESC
OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY
 

-- 3. WHAT IS THE MOST EXPENSIVE AND LEAST EXPENSIVE PRODUCT IN EACH CATEGORY
SELECT Category, Product_Name, SUM(Sales) total_revenue,
first_value(Product_Name) over w as most_expensive_product ,
LAST_VALUE(Product_Name) over w as least_expensive_product 
FROM [dbo].[Sales - Data Modelling Example]
GROUP BY Category, Product_Name
window w as (partition by Category order by SUM(Sales) DESC rows between unbounded preceding and unbounded following)

-- alternative.
SELECT 
    Category, 
    Product_Name, 
    SUM(Sales) AS total_revenue,
    FIRST_VALUE(Product_Name) OVER (PARTITION BY Category ORDER BY SUM(Sales) DESC) AS most_expensive_product,
    LAST_VALUE(Product_Name) OVER (PARTITION BY Category ORDER BY SUM(Sales) DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS least_expensive_product
  
FROM 
	[dbo].[Sales - Data Modelling Example]
GROUP BY 
    Category, 
    product_name

-- 4. WHAT IS THE TOTAL NUMBER OF ORDERS MADE BY EACH CUSTOMER
select Customer_ID, Customer_Name, count(Order_ID) from [dbo].[Sales - Data Modelling Example] group by Customer_ID, Customer_Name



-- 5. WHAT PERCENTAGE OF THE TOTAL ORDER WAS SHIPPED ON THE THE SAME DAY
SELECT 
  COUNT(*) * 100.0 / (SELECT COUNT(*) FROM [dbo].[Sales - Data Modelling Example] ) AS Same_Day_Shipping_Percentage
FROM 
  [dbo].[Sales - Data Modelling Example]
WHERE 
  Order_Date = Ship_Date;

 -- 6. LIST TOP 3 CUSTOMERS WITH HIGHEST ORDER VALUE
SELECT top 3 Customer_Name, SUM(Sales) AS total_order_value
FROM [dbo].[Sales - Data Modelling Example]
GROUP BY Customer_Name
ORDER BY total_order_value DESC;

-- . WHAT ARE THE TOP 10 PRODUCTS WITH THE HIGHEST AVERAGE SALES PER DAY.
SELECT top 10 Product_ID, Product_Name, AVG(Sales) AS Average_Sales
FROM [dbo].[Sales - Data Modelling Example]
GROUP BY Product_ID, Product_Name
ORDER BY Average_Sales DESC;

-- 7. FIND THE AVERAGE ORDER VALUE FOR EACH CUSTOMER AND RANK THE CUSTOMERS BY THEIR AVERAGE ORDER VALUE.
SELECT 
    Customer_ID,
	Customer_Name,
    AVG(Sales) AS avg_sale,
	rank() over (order by avg(Sales)) AS sales_rank
FROM [dbo].[Sales - Data Modelling Example]
group by Customer_ID, Customer_Name;


-- 8. WHICH CUSTOMERS MADE THE HIGHEST AND LOWEST ORDERS FROM EACH STATE
select State, Customer_Name, order_num, 
		first_value(Customer_Name) over (partition by State order by order_num DESC) max_Sales_Customer,
		last_value(Customer_Name) over (partition by State order by order_num DESC
range between unbounded preceding and unbounded following ) as min_Sales_Customer
from (select State, Customer_Name, count(*) order_num from [dbo].[Sales - Data Modelling Example] group by State,Customer_Name) s;


-- 9. WHAT IS THE MOST DEMANDED SUB-CATEGORY IN THE WEST REGION?
select top 1 Region, 
	Sub_Category, 
	Count(Sub_Category) as n 
from [dbo].[Sales - Data Modelling Example]  
group by Sub_Category, Region 
having Region = 'West' 
order by n DESC ; 


-- 10. WHICH ORDER HAS THE HIGHEST NUMBER OF ITEMS?
 select top 1 Order_ID as orders, 
		Count( Order_ID) as number_of_items 
 from [dbo].[Sales - Data Modelling Example] 
 group by Order_ID 
 order by number_of_items DESC;  

-- 11. WHICH ORDER HAS THE HIGHEST CUMULATIVE VALUE?
select top 4 t.*, 
		sum(cum_sum) over (partition by Order_ID order by Order_ID) Cum_value
from (select Order_ID, Sales,
		sum(Sales) OVER ( partition by Order_ID order by LineID) as cum_sum 
	  from [dbo].[Sales - Data Modelling Example]) t 
	  order by cum_value DESC;


-- 12. WHICH CATEGORY IS MORE LIKELY TO BE SHIPPED VIA FIRST CLASS?
select top 1 Category, 
	count(Category) as first_class_count  
from [dbo].[Sales - Data Modelling Example]
where Ship_Mode='First Class' 
group by Category 
order by first_class_count DESC;

-- 13. WHICH STATE IS LEAST CONTRIBUTING TO TOTAL REVENUE?
SELECT top 1 State, SUM(sales) as total_revenue,
	(select sum(Sales) from [dbo].[Sales - Data Modelling Example]) AS Overall_sales_revenue  
FROM [dbo].[Sales - Data Modelling Example]
GROUP BY State
ORDER BY total_revenue ASC;

-- 14. WHAT IS THE AVERAGE TIME FOR ORDERS TO GET SHIPPED AFTER IT IS PLACED?
SELECT AVG(DATEDIFF(DAY, Order_Date, Ship_Date)) AS avg_ship_time_in_days 
FROM [dbo].[Sales - Data Modelling Example];


--15. WHICH  CATEGORY PLACES THE HIGHEST NUMBER OF ORDERS FROM EACH STATE AND WHICH CATEGORYPLACES THE LARGEST INDIVIDUAL ORDERS FROM EACH STATE?

with count_orders as (select s.* ,
row_number() over (partition by State) order_count_num 
from (select distinct State, Category,
count(Order_ID) over (partition by State order by Category) order_count
FROM [dbo].[Sales - Data Modelling Example]) s) 
select State, Category, order_count from count_orders where order_count_num = 3;



-- 16. GROUP CUSTOMERS BASDED ON THEIR RFM SCORE - WHO ARE THE BEST, LOST AND HYBERNATING CUSTOMERS?

DROP TABLE IF EXISTS #rfm_table
;with rfm as 
(
	select 
		Customer_Name, 
		max(Order_Date) last_order_date,
		(select max(Order_Date) from [dbo].[Sales - Data Modelling Example]) max_order_date,
		sum(Sales) MonetaryValue,
		avg(Sales) AvgMonetaryValue,
		count(Order_ID) Frequency,
		DATEDIFF(DD, max(Order_Date), (select max(Order_Date) from [dbo].[Sales - Data Modelling Example])) Recency
	from [dbo].[Sales - Data Modelling Example]
	group by Customer_Name
),
rfm_calc as
(

	select r.*,
		NTILE(5) OVER (order by Recency desc) rfm_recency,
		NTILE(5) OVER (order by Frequency) rfm_frequency,
		NTILE(5) OVER (order by MonetaryValue) rfm_monetary
	from rfm r
)
select 
	c.*, rfm_recency+ rfm_frequency+ rfm_monetary as rfm_cell,
	cast(rfm_recency as varchar) + cast(rfm_frequency as varchar) + cast(rfm_monetary  as varchar)rfm_cell_string
into  #rfm_table
from rfm_calc c;

select * from  #rfm_table;

select Customer_Name , rfm_recency, rfm_frequency, rfm_monetary, cast(rfm_recency as varchar) + cast(rfm_frequency as varchar) + cast(rfm_monetary  as varchar)rfm_cell_string,
	case 
		when rfm_cell_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141,221,131,231) then 'lost_customers'  --lost customers
		when rfm_cell_string in (133, 134, 143, 244, 334, 343, 344, 144,341) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		when rfm_cell_string in (311, 411, 331,511,521,531,421) then 'new customers'
		when rfm_cell_string in (222, 223, 233, 322) then 'potential churners'
		when rfm_cell_string in (323, 333,321, 422, 332, 432,541,431) then 'active' --(Customers who buy often & recently, but at low price points)
		when rfm_cell_string in (434, 434, 443, 444,551) then 'loyal'
		when rfm_cell_string in (555, 554, 545, 543, 534, 455, 454) then 'VIP'
	end rfm_segment

from  #rfm_table


-- 17. WHAT PRODUCTS ARE MOST OFTEN SOLD TOGETHER? 

select distinct Order_ID, stuff(

	(select ',' + Product_Name
	from [dbo].[Sales - Data Modelling Example] p
	where Order_ID in 
		(

			select Order_ID
			from (
				select Order_ID, count(*) rn
				FROM [dbo].[Sales - Data Modelling Example]
				where Ship_Date is not Null
				group by Order_ID
			)m
			where rn = 3
		)
		and p.Order_ID = s.Order_ID
		for xml path (''))

		, 1, 1, '') Product_Name

from [dbo].[Sales - Data Modelling Example] s
order by 2 desc