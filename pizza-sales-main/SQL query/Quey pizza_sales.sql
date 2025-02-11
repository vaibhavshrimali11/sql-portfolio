-- total Revenue 
SELECT SUM(quantity * price) AS Total_Revenue
FROM order_details AS o
JOIN pizzas AS p 
ON o.pizza_id = p.pizza_id;

-- 2) Average Order Value
SELECT 
ROUND(SUM(quantity * price)/COUNT(DISTINCT order_id),2) AS "Average Order Value"
FROM order_details AS o
JOIN pizzas AS p 
ON o.pizza_id = p.pizza_id;

-- 3) Total pizzas Sold
SELECT
SUM(quantity) AS "Total Pizza Sold"
FROM order_details;

--4) Total Order Details
SELECT
COUNT(DISTINCT order_id) AS "Total Orders"
FROM order_details;

-- 5) Average Pizza Per Order

SELECT 
ROUND(SUM(quantity)/COUNT(DISTINCT order_id),0) AS "Average Pizza Per Order"
FROM order_details;

--6) Daily Trends Of Total Orders
SELECT  
TO_CHAR(date, 'Day') AS "DayOfWeek",
COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY TO_CHAR(date, 'Day')
ORDER BY total_orders DESC;

-- 7) Hourly Trend For Total Orders
SELECT  
EXTRACT(HOUR FROM time) AS "Hour",
COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY EXTRACT(HOUR FROM time)
ORDER BY "Hour";

--8) Percentage Of Sales by pizza Category
--calculate total revenue per category
--% sales calculated as(a:/total revenue)*100
SELECT 
category,
SUM(quantity * price) AS revenue,
ROUND(SUM(quantity * price)*100/(
SELECT SUM(quantity*price)
FROM pizzas AS p2
JOIN order_details AS od2 ON od2.pizza_id = p2.pizza_id
),2) AS percentage_sales
FROM 
pizzas AS p
JOIN pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY category
ORDER BY percentage_sales DESC;

--9) Percentage Sales By Pizza Size
SELECT 
size,
SUM(quantity * price) AS revenue,
ROUND(SUM(quantity * price)*100/(
SELECT SUM(quantity*price)
FROM pizzas AS p2
JOIN order_details AS od2 ON od2.pizza_id = p2.pizza_id
),2) AS percentage_sales
FROM 
pizzas AS p
JOIN pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY size
ORDER BY percentage_sales DESC;

--10) Total pizza sold by each category
SELECT 
category,
SUM(quantity) AS quantity_sold
FROM 
pizzas AS p
JOIN pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY category
ORDER BY quantity_sold DESC;

--11) Top 5 Best Sellers
SELECT 
name,
SUM(quantity) AS quantity_sold
FROM 
pizzas AS p
JOIN pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY name
ORDER BY quantity_sold DESC
LIMIT 5;

--12) WORST 5 Pizza
SELECT 
name,
SUM(quantity) AS quantity_sold
FROM 
pizzas AS p
JOIN pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY name
ORDER BY quantity_sold ASC
LIMIT 5;


