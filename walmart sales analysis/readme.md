# 🏪 Walmart Sales Data Analysis - SQL Project

## 📌 Project Overview  
This project focuses on analyzing Walmart's sales data using **PostgreSQL (pgAdmin 4)** to gain insights into **sales trends, customer behavior, and product performance**. The dataset contains transactions from Walmart branches in **Mandalay, Yangon, and Naypyitaw**.  

## 🎯 Objectives  
- 🔹 Identify **top-selling products and branches**  
- 🔹 Analyze **customer purchasing behavior**  
- 🔹 Evaluate **sales performance by time, product line, and location**  
- 🔹 Optimize **sales strategies based on data-driven insights**  

## 📂 Dataset Information  
The dataset, sourced from the **Kaggle Walmart Sales Forecasting Competition**, contains **1,000 rows** and **17 columns**.  

| Column Name        | Description                                      | Data Type         |
|--------------------|--------------------------------------------------|-------------------|
| `invoice_id`      | Unique identifier for each transaction           | `VARCHAR(30)`    |
| `branch`          | Walmart branch where the sale occurred           | `VARCHAR(5)`     |
| `city`            | Location of the branch                           | `VARCHAR(30)`    |
| `customer_type`   | Type of customer (Member/Normal)                 | `VARCHAR(30)`    |
| `gender`          | Gender of the customer                           | `VARCHAR(10)`    |
| `product_line`    | Category of the product sold                     | `VARCHAR(100)`   |
| `unit_price`      | Price per unit of the product                    | `DECIMAL(10,2)`  |
| `quantity`        | Number of items purchased                        | `INT`            |
| `VAT`            | Value-added tax applied to the purchase          | `FLOAT(6,4)`     |
| `total`           | Total cost including VAT                         | `DECIMAL(12,4)`  |
| `date`            | Date of purchase                                 | `DATETIME`       |
| `time`            | Time of purchase                                 | `TIME`           |
| `payment`         | Payment method used                              | `VARCHAR(20)`    |
| `cogs`            | Cost of Goods Sold                               | `DECIMAL(10,2)`  |
| `gross_margin_pct`| Gross margin percentage                          | `FLOAT(11,9)`    |
| `gross_income`    | Gross profit from the sale                       | `DECIMAL(12,4)`  |
| `rating`          | Customer rating for the purchase (1-10)         | `FLOAT(2,1)`     |

## 🔎 Analysis Performed  
### 📌 **Product Analysis**
- ✅ Determine **top-performing product lines**  
- ✅ Identify **most common payment methods**  
- ✅ Find **which product categories generate the highest revenue**  
- ✅ Calculate **total revenue by month and VAT distribution**  

### 📌 **Sales Analysis**
- ✅ Analyze **sales trends based on time of day and weekdays**  
- ✅ Identify **branches with the highest and lowest sales**  
- ✅ Determine **the impact of VAT on total revenue**  
- ✅ Find **the busiest sales periods for each branch**  

### 📌 **Customer Analysis**
- ✅ Segment customers by **gender, purchase behavior, and loyalty type**  
- ✅ Find out **which gender dominates each product line**  
- ✅ Identify **which customer type contributes most to revenue**  
- ✅ Evaluate **customer ratings and their distribution by branch**  

## 🛠 **Project Workflow**  
1️⃣ **Data Preparation**  
   - Loaded dataset into **PostgreSQL (pgAdmin 4)**  
   - Checked for **missing values and inconsistencies**  

2️⃣ **Feature Engineering**  
   - Created **new columns** such as:  
     - `time_of_day` (Morning, Afternoon, Evening)  
     - `day_name` (Monday-Sunday)  
     - `month_name` (January-December)  

3️⃣ **Exploratory Data Analysis (EDA)**  
   - Generated **SQL queries to answer business questions**  
   - Used **aggregations, joins, and window functions** to extract insights  

## 🚀 Technologies Used  
- **Database**: PostgreSQL (pgAdmin 4)  
- **Query Language**: SQL  
- **Data Analysis**: Aggregations, Joins, CTEs, Window Functions  


  
