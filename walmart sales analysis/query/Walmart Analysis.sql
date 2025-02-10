CREATE TABLE sales (
    invoice_id VARCHAR(30) PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    quantity INTEGER NOT NULL,
    vat NUMERIC(6,4) NOT NULL,
    total NUMERIC(12,4) NOT NULL,
    date TIMESTAMP NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs NUMERIC(10,2) NOT NULL,
    gross_margin_pct NUMERIC(11,9),
    gross_income NUMERIC(12,4),
    rating NUMERIC(3,1)
);

SHOW client_min_messages;


-- Feature engineering
--Time_of_Day

SELECT time,
    CASE 
        WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN time BETWEEN '12:00:01' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day
FROM sales;


ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = 
    CASE 
        WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN time BETWEEN '12:00:01' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END;


-- Day_Name

SELECT date,
TO_CHAR(date,'day') AS day_name
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = TO_CHAR(date,'day');

-- Month Name
SELECT date,
TO_CHAR(date,'Month') AS month_name
FROM sales;


ALTER TABLE sales ADD COLUMN month_name VARCHAR(15);

UPDATE sales
SET month_name = TO_CHAR(date,'Month');



--- EDA----
-- Distinct city
SELECT DISTINCT city FROM sales;

--In which city is each branch is situated

SELECT DISTINCT branch,
       city
FROM sales;

-- Product Anlysis

-- How many distinct product lines are there in data set
SELECT COUNT(DISTINCT product_line) FROM sales;

-- what is the most common payment method
SELECT payment,COUNT(payment) AS common_payment_method
FROM sales
GROUP BY payment
ORDER BY COUNT(payment) DESC
LIMIT 1;

-- What is the mod=st selling productline ?
SELECT product_line, COUNT(product_line) AS most_selling_pl
FROM sales
GROUP BY product_line
ORDER BY COUNT(product_line)
LIMIT 1;

--What is total revenue by month?
SELECT month_name, SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY SUM(total);

-- Which month recorded the highest Cost of goods Sold
SELECT month_name, SUM(cogs) AS total_cogs
FROM sales
GROUP BY month_name
ORDER BY SUM(cogs);

--Which product line generated the highest revenue?
SELECT product_line, SUM(total) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY SUM(total) DESC;

-- Which city has the highest revenue?
SELECT city, SUM(total) AS total_revenue
FROM sales
GROUP BY city
ORDER BY SUM(total);

-- Which product Line incurred the highest VAT?
SELECT product_line, SUM(VAT) AS VAT
FROM sales
GROUP BY product_line
ORDER BY SUM(vat);

--Retrieve each product line and add a column product_category, indicating good or bad , based on it sales are above average

ALTER TABLE sales ADD COLUMN product_category VARCHAR(20);

UPDATE sales
SET product_category=
CASE 
      WHEN total>=(SELECT AVG(total) FROM sales) THEN 'GOOD'
	  ELSE 'BAD'
 END;

-- Which branch sold more products than the average product sold?

SELECT branch, SUM(quantity) AS quantity
FROM sales
GROUP BY branch
ORDER BY SUM(quantity) DESC;

-- What is the most common product line by gender?
SELECT gender, product_line, COUNT(gender) AS total_count
FROM sales
GROUP BY gender, product_line
ORDER BY COUNT(gender) DESC;

-- WHat is the average rating of each product line?
SELECT product_line, ROUND(AVG(rating),2)
FROM sales
GROUP BY product_line
ORDER BY ROUND(AVG(rating),2) DESC;

-- SALES ANALYSIS
-- Number of sales made in each time of the day per weekday?

SELECT day_name, time_of_day, COUNT(*) AS total_sales
FROM sales
WHERE day_name NOT IN ('Sunday', 'Saturday')
GROUP BY day_name, time_of_day;

-- Identify the customer type that generates the highest revenue
SELECT customer_type, SUM(total) AS total_sales
FROM sales
GROUP BY customer_type
ORDER BY total_sales DESC;

-- Which city has the highest tax percent/ vat
SELECT city, SUM(vat) AS total_VAT
FROM sales
GROUP BY city
ORDER BY SUM(vat) DESC;

-- Which customer_type pays the most VAT
SELECT  customer_type, SUM(VAT) AS totlal_VAT
FROM sales
GROUP BY customer_type;

-- Customer Analysis

-- 1.How many unique customer types does the data have?
SELECT COUNT(DISTINCT customer_type)
FROM sales;

-- 2.How many unique payment methods does the data have?
SELECT COUNT(DISTINCT payment) 
FROM sales;

-- 3.Which is the most common customer type?
SELECT customer_type, COUNT(customer_type) AS common_customer
FROM sales 
GROUP BY customer_type
ORDER BY common_customer DESC LIMIT 1;

-- 4.Which customer type buys the most?
SELECT customer_type, SUM(total) as total_sales
FROM sales 
GROUP BY customer_type 
ORDER BY total_sales LIMIT 1;

SELECT customer_type, COUNT(*) AS most_buyer
FROM sales 
GROUP BY customer_type 
ORDER BY most_buyer DESC LIMIT 1;

-- 5.What is the gender of most of the customers?
SELECT gender, COUNT(*) AS all_genders 
FROM sales 
GROUP BY gender
ORDER BY all_genders DESC LIMIT 1;

-- 6.What is the gender distribution per branch?
SELECT branch, gender, COUNT(gender) AS gender_distribution
FROM sales 
GROUP BY branch, gender 
ORDER BY branch;

-- 7.Which time of the day do customers give most ratings?
SELECT time_of_day, AVG(rating) AS average_rating
FROM sales GROUP BY time_of_day ORDER BY average_rating DESC LIMIT 1;

-- 8.Which time of the day do customers give most ratings per branch?
SELECT branch, time_of_day, AVG(rating) AS average_rating
FROM sales GROUP BY branch, time_of_day ORDER BY average_rating DESC;

SELECT branch, time_of_day,
AVG(rating) OVER(PARTITION BY branch) AS ratings
FROM sales GROUP BY branch;

-- 9.Which day of the week has the best avg ratings?
SELECT day_name, AVG(rating) AS average_rating
FROM sales GROUP BY day_name ORDER BY average_rating DESC LIMIT 1;

-- 10.Which day of the week has the best average ratings per branch?
SELECT  branch, day_name, AVG(rating) AS average_rating
FROM sales GROUP BY day_name, branch ORDER BY average_rating DESC;








