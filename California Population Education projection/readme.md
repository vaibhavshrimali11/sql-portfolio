# 📊 Education & Workforce Demographics Analysis – PostgreSQL  

This project analyzes **California's educational attainment and income data**, helping identify workforce demand trends. The goal is to **understand education levels across age groups and predict workforce needs** using PostgreSQL.  

---

## 📂 **Dataset Overview**  

✔ **Source:** Cleaned dataset (2008-2014) with education & income stats.  
✔ **Size:** 6 columns, thousands of rows spanning multiple years.  
✔ **Fields:**  
   - `date_year` → Year of data entry.  
   - `age` → Age group of individuals.  
   - `gender` → Male or Female.  
   - `edu_attainment` → Highest education level attained.  
   - `income` → Reported income category.  
   - `population` → Total population in each category.  

---

## 🛠 **Data Processing Workflow**  

🔹 **Step 1:** **Table Creation** – Define schema for storing education and income data.  
🔹 **Step 2:** **Data Import** – Load CSV file into PostgreSQL using `COPY`.  
🔹 **Step 3:** **Calculate Education Distribution** – Compute percentage distribution of education levels per age group.  
🔹 **Step 4:** **Predict Workforce Demand** – Forecast future demand for each education level.  

---

## 🔍 **Key Insights & Analysis**  

✔ **Gender Breakdown** → Distribution of males & females across education categories.  
✔ **Educational Attainment by Age** → Identifies the most common education levels by age group.  
✔ **Income vs. Education Trends** → Examines how income correlates with education levels.  
✔ **Population Growth Trends** → Tracks demographic changes over time.  
✔ **Workforce Demand Forecast** → Estimates future job market needs based on education trends.  

---

## 🚀 **Use Cases & Business Impact**  

✅ **Educational Institutions** – Align curricula with labor market demand.  
✅ **Government & Policy Makers** – Plan workforce training initiatives.  
✅ **Businesses & Recruiters** – Understand availability of skilled labor over time.  

This project provides a **data-driven approach** to workforce and education planning using PostgreSQL. 📊  
