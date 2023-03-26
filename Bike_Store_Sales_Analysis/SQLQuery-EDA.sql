/** EXPLORATORY DATA ANALYSIS **/

SELECT DISTINCT category_name -- DISTINCT CATEGORIES
FROM [production].[categories]
SELECT DISTINCT product_name -- DISTINCT PRODUCT
FROM [production].[products]
SELECT DISTINCT order_status -- DISTINCT ORDER STATUS
FROM [sales].[orders]
SELECT COUNT(DISTINCT product_name) -- NUMBER OF PRODUCTS
FROM [production].[products]
SELECT DISTINCT state -- DISTINCT STATE
FROM [sales].[customers]
SELECT DISTINCT city -- DISTINCT CiTY
FROM [sales].[customers]
SELECT COUNT(DISTINCT city) -- NUMBER OF CiTIES
FROM [sales].[customers]
SELECT MIN(order_date), MAX(order_date) -- FIRST AND LAST DATE
FROM [sales].[orders]
SELECT COUNT(DISTINCT order_id) -- NUMBER DISTINCT OF ORDERS
FROM [sales].[orders]
SELECT COUNT(DISTINCT customer_id) -- NUMBER DISTINCT OF CUSTOMERS
FROM [sales].[customers]


-- WHAT IS THE TOTAL SALE AND WHAT ARE THE TOP 10 HIGHEST SELLING PRODUCTS?
SELECT TOP 10 SUM(s.quantity * s.list_price ) total_revenue, p.product_name
FROM [sales].[order_items] as s
JOIN [production].[products] as p
ON s.product_id = p.product_id
GROUP BY product_name
ORDER BY total_revenue DESC

-- WHAT YEAR HAD THE HIGHEST SALES REVENUE
SELECT  YEAR(order_date) as year, SUM(s.quantity * s.list_price ) total_sales_revenue_by_year
FROM [sales].[order_items] s
JOIN [sales].[orders] o
ON s.order_id = o.order_id
GROUP BY YEAR(order_date)
ORDER BY 2 DESC


-- WHAT WAS THE BEST MONTH FOR SALES IN A SPECIFIC YEAR AND HOW MUCH WAS EARNED THAT MONTH?
SELECT DATEPART(month, o.order_date) as month_, COUNT(o.order_id) as order_count, SUM(s.quantity * s.list_price) as total_sales_revenue_by_month
FROM [sales].[order_items] s
JOIN [sales].[orders] o ON s.order_id = o.order_id
WHERE YEAR(o.order_date) = 2018
GROUP BY DATEPART(month, o.order_date)
ORDER BY total_sales_revenue_by_month DESC
OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY


-- 1.What percentage of total orders were shipped on the same date
SELECT 
  COUNT(*) * 100.0 / (SELECT COUNT(*) FROM [sales].[orders]) AS Same_Day_Shipping_Percentage
FROM [sales].[orders]
  WHERE 
  Order_Date = Shipped_Date;

 
-- 5. Give the name of customers who ordered highest and lowest orders from each city. 
select city, customer, bt.qauntity,
first_value(customer) over w Highest_qauntity_Customer,
last_value(customer) over w lowest_qauntity_Customer
from(select city, concat(cus.first_name, ' ', cus.last_name) customer,count(quantity) qauntity from [sales].[customers] cus
join [sales].[orders] o on cus.customer_id = o.customer_id
join [sales].[order_items] i on o.order_id = i.order_id
group by city, concat(cus.first_name, ' ', cus.last_name))bt
window w as  (partition by city order by bt.qauntity DESC
			range between unbounded preceding and unbounded following) 

-- WHAT IS THE MOST EXPENSIVE, LEAST EXPENSIVE AND SECOND MOST EXPENSIVE PRODUCT IN EACH CATEGORY
SELECT category_name, product_name, SUM(s.quantity * s.list_price ) total_revenue,
first_value(product_name) over w as most_expensive_product ,
LAST_VALUE(product_name) over w as least_expensive_product 
FROM [production].[products] P
JOIN [production].[categories] C
ON P.category_id = C.category_id
JOIN [sales].[order_items] s
ON P.product_id = s.product_id
GROUP BY category_name, product_name
window w as (partition by category_name order by SUM(s.quantity * s.list_price ) DESC rows between unbounded preceding and unbounded following)

-- alternative.
SELECT 
    category_name, 
    product_name, 
    SUM(s.quantity * s.list_price) AS total_revenue,
    FIRST_VALUE(product_name) OVER (PARTITION BY category_name ORDER BY SUM(s.quantity * s.list_price) DESC) AS most_expensive_product,
    LAST_VALUE(product_name) OVER (PARTITION BY category_name ORDER BY SUM(s.quantity * s.list_price) DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS least_expensive_product
  
FROM 
    [production].[products] P
    JOIN [production].[categories] C ON P.category_id = C.category_id
    JOIN [sales].[order_items] s ON P.product_id = s.product_id
GROUP BY 
    category_name, 
    product_name


select customer_id, count(order_id) c from [sales].[orders] group by customer_id order by c

-- Products that are always sold togther---Check again
SELECT t1.product_id,t2.product_id
FROM [sales].[order_items] t1
JOIN [sales].[order_items] t2 ON t1.order_id = t2.order_id AND t1.product_id < t2.product_id
WHERE NOT EXISTS (
  SELECT *
  FROM [sales].[order_items] t3
  WHERE t3.order_id = t1.order_id
    AND t3.product_id NOT IN (t1.product_id, t2.product_id)

)


-- Extract data for visualization
SELECT o.order_id 
	  ,o.order_date
	  ,o.customer_id
	  ,o.shipped_date
	  ,o.required_date
	  ,o.order_status
	  ,ite.product_id
	  ,p.product_name
	  ,c.city
	  ,c.state
	  ,c.zip_code
	  ,concat(c.first_name, '', c.last_name) customer_name
	  ,cat.category_name
	  ,st.store_name
	  ,concat(staff.first_name, '', staff.last_name) staff_name
	  ,ite.list_price as price
	  ,ite.discount
	  ,ite.quantity
	  ,ite.quantity * ite.list_price as revenue 
	  
from [sales].[orders] o
join [sales].[order_items] ite
on o.order_id = ite.order_id
join [sales].[customers] c
on o.customer_id = c.customer_id
join [production].[products] p
on ite.product_id = p.product_id
join [production].[categories] cat
on p.category_id = cat.category_id
join [sales].[stores] st
on o.store_id = st.store_id
join [sales].[staffs] staff
on st.store_id = staff.store_id