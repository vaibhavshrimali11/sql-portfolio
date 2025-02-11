# Healthcare Data Analysis Using SQL

## Overview
This project involves SQL-based exploratory data analysis (EDA) and insights extraction from a healthcare dataset sourced from Kaggle ([Healthcare Dataset](https://www.kaggle.com/datasets/prasad22/healthcare-dataset)). The analysis provides key insights into patient demographics, medical conditions, hospital performance, financial aspects, and risk categorization, aiding in data-driven decision-making for healthcare management.

## Objectives
- Perform exploratory data analysis (EDA) to understand patient demographics and medical records.
- Analyze disease prevalence, medication patterns, and hospital efficiency.
- Evaluate the financial aspects of patient treatment, including billing trends and insurance coverage.
- Develop a risk categorization system to classify patients based on medical conditions and test results.


---

## Key Analyses & Findings

### 1. **Patient Demographics & Basic Statistics**
- Extracted key insights on total patient count, age distribution, and gender ratio.
- Identified the oldest and youngest admitted patients along with the average patient age.

### 2. **Medical Conditions & Medication Patterns**
- Analyzed common diseases and their occurrence rates.
- Mapped prescribed medications to specific medical conditions.
- Evaluated the frequency of medications administered to patients.

### 3. **Hospital Preferences & Insurance Providers**
- Determined patient admission trends across various hospitals.
- Identified the most frequently chosen hospitals and insurance providers.
- Analyzed patient preferences for specific insurance companies.

### 4. **Financial Analysis & Hospital Stay Duration**
- Examined average and total billing amounts across different conditions.
- Evaluated hospital stay durations to identify efficiency patterns.
- Mapped financial trends based on treatment costs and hospitalization periods.

### 5. **Blood Type Distribution & Donation Matching**
- Analyzed blood type distribution across different age groups.
- Developed a **Blood_Matcher** stored procedure to identify potential blood donors and recipients based on age, blood type compatibility, and hospital affiliation.

### 6. **Yearly Admissions & Insurance Trends**
- Evaluated admission patterns for different hospitals in specific years (2024 & 2025).
- Analyzed billing trends across various insurance providers to detect cost discrepancies.

### 7. **Patient Risk Categorization**
- Implemented a classification system categorizing patients into **High**, **Medium**, and **Low** risk groups based on medical conditions and test results.
- Provided a structured approach to identifying critical patients requiring urgent attention.

---

## Dataset Schema & Column Breakdown
Each column provides crucial details regarding patient information, hospital admissions, and treatment procedures. Below is a breakdown of key fields:

| Column | Description |
|--------|-------------|
| **Name** | Patient's name. |
| **Age** | Patient's age at the time of admission. |
| **Gender** | Patient’s gender (Male/Female). |
| **Blood Type** | Patient’s blood group (e.g., A+, O-, etc.). |
| **Medical Condition** | Primary medical condition or diagnosis (e.g., Diabetes, Hypertension). |
| **Date of Admission** | The date when the patient was admitted to the hospital. |
| **Doctor** | The attending doctor assigned to the patient. |
| **Hospital** | Name of the hospital where the patient was admitted. |
| **Insurance Provider** | Patient’s insurance provider (e.g., Aetna, Blue Cross, Medicare). |
| **Billing Amount** | Total cost incurred for the patient's treatment. |
| **Room Number** | Hospital room assigned to the patient. |
| **Admission Type** | Type of admission (Emergency, Elective, Urgent). |
| **Discharge Date** | Date when the patient was discharged from the hospital. |
| **Medication** | Medicines prescribed during hospitalization. |
| **Test Results** | Results from medical tests (Normal, Abnormal, Inconclusive). |

---

## Technologies Used
- **SQL** (for data analysis and query execution)
- **PostgreSQL** (for database management)
- **Stored Procedures** (for automation of donor matching)

## Conclusion
This SQL-driven analysis of healthcare data provides valuable insights into patient care, hospital performance, and financial trends. By leveraging SQL queries, stored procedures, and structured EDA, this project offers a robust framework for healthcare analytics and decision-making.

