create database healthcare_db
use healthcare_db



CREATE TABLE healthcare (
    patient_id VARCHAR(20),
    age VARCHAR(10),
    gender VARCHAR(10),
    blood_type VARCHAR(10),
    medical_condition VARCHAR(50),
    admission_date VARCHAR(20),
    discharge_date VARCHAR(20),
    hospital_stay_days VARCHAR(10),
    hospital VARCHAR(50),
    doctor VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    admission_type VARCHAR(20),
    medication VARCHAR(50),
    insurance_provider VARCHAR(50),
    treatment_cost VARCHAR(20),
    test_result VARCHAR(20),
    readmission VARCHAR(10)
);

BULK INSERT healthcare
FROM 'C:\Users\piyus\OneDrive\Documents\Desktop\HealthCare Project\india_healthcare_500k.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

SELECT COUNT(*) FROM healthcare;

-- 1. View first 10 records
SELECT TOP 10 * FROM healthcare;

-- 2. Total number of patients
SELECT COUNT(*) AS total_patients FROM healthcare;

-- 3. Count of patients by gender
SELECT gender, COUNT(*) AS total_patients
FROM healthcare
GROUP BY gender;

-- 4. Count of patients by medical condition
SELECT medical_condition, COUNT(*) AS total_patients
FROM healthcare
GROUP BY medical_condition
ORDER BY total_patients DESC;

-- 5. Count of patients by state
SELECT state, COUNT(*) AS total_patients
FROM healthcare
GROUP BY state
ORDER BY total_patients DESC;

-- 6. Average treatment cost by medical condition
SELECT medical_condition, 
       ROUND(AVG(CAST(treatment_cost AS FLOAT)), 2) AS avg_cost
FROM healthcare
GROUP BY medical_condition
ORDER BY avg_cost DESC;

-- 7. Total revenue by hospital
SELECT hospital,
       COUNT(*) AS total_patients,
       ROUND(SUM(CAST(treatment_cost AS FLOAT)), 2) AS total_revenue
FROM healthcare
GROUP BY hospital
ORDER BY total_revenue DESC;

-- 8. Readmission rate by medical condition
SELECT medical_condition,
       COUNT(*) AS total_patients,
       SUM(CASE WHEN readmission = 'Yes' THEN 1 ELSE 0 END) AS readmitted,
       ROUND(100.0 * SUM(CASE WHEN readmission = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS readmission_rate_pct
FROM healthcare
GROUP BY medical_condition
ORDER BY readmission_rate_pct DESC;

-- 9. Most common medication by condition
SELECT medical_condition, medication, COUNT(*) AS prescribed_count
FROM healthcare
GROUP BY medical_condition, medication
ORDER BY medical_condition, prescribed_count DESC;

-- 10. Patient count by insurance provider
SELECT insurance_provider,
       COUNT(*) AS total_patients,
       ROUND(AVG(CAST(treatment_cost AS FLOAT)), 2) AS avg_treatment_cost
FROM healthcare
GROUP BY insurance_provider
ORDER BY total_patients DESC;


-- 11. Rank hospitals by total revenue using Window Function
SELECT hospital,
       ROUND(SUM(CAST(treatment_cost AS FLOAT)), 2) AS total_revenue,
       RANK() OVER (ORDER BY SUM(CAST(treatment_cost AS FLOAT)) DESC) AS revenue_rank
FROM healthcare
GROUP BY hospital;

-- 12. Top 3 most expensive conditions per state using CTE
WITH ConditionCost AS (
    SELECT state, medical_condition,
           ROUND(AVG(CAST(treatment_cost AS FLOAT)), 2) AS avg_cost,
           RANK() OVER (PARTITION BY state ORDER BY AVG(CAST(treatment_cost AS FLOAT)) DESC) AS rnk
    FROM healthcare
    GROUP BY state, medical_condition
)
SELECT state, medical_condition, avg_cost
FROM ConditionCost
WHERE rnk <= 3
ORDER BY state, rnk;

-- 13. Year wise patient admission trend
SELECT LEFT(admission_date, 4) AS admission_year,
       COUNT(*) AS total_admissions,
       ROUND(SUM(CAST(treatment_cost AS FLOAT)), 2) AS total_revenue
FROM healthcare
GROUP BY LEFT(admission_date, 4)
ORDER BY admission_year;

-- 14. Running total of revenue by state using Window Function
SELECT state,
       medical_condition,
       ROUND(SUM(CAST(treatment_cost AS FLOAT)), 2) AS condition_revenue,
       ROUND(SUM(SUM(CAST(treatment_cost AS FLOAT))) OVER (PARTITION BY state ORDER BY medical_condition), 2) AS running_total
FROM healthcare
GROUP BY state, medical_condition
ORDER BY state, medical_condition;

-- 15. Patients with above average treatment cost
WITH AvgCost AS (
    SELECT AVG(CAST(treatment_cost AS FLOAT)) AS overall_avg
    FROM healthcare
)
SELECT medical_condition,
       COUNT(*) AS high_cost_patients,
       ROUND(AVG(CAST(treatment_cost AS FLOAT)), 2) AS avg_cost
FROM healthcare, AvgCost
WHERE CAST(treatment_cost AS FLOAT) > overall_avg
GROUP BY medical_condition
ORDER BY high_cost_patients DESC;

