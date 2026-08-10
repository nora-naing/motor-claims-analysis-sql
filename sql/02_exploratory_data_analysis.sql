-- Project	: MySQL - Motor Claims Analysis
-- File		: 02_exploratory_data_analysis
-- Author	: Nora Thu Thu Htet Naing
-- Purpose	: Explore the dataset, validate data quality, and
-- 			understand customer, policy, vehicle, and financial information before analysis.

USE motor_claims_db;

-- 1. Dataset Overview

-- Total number of customers, claims, policies, vehicles, and sales_channels
SELECT
    (SELECT COUNT(*) FROM customers) AS customer_count,
    (SELECT COUNT(*) FROM claims) AS claim_count,
    (SELECT COUNT(*) FROM policies) AS policy_count,
    (SELECT COUNT(*) FROM vehicles) AS vehicle_count,
    (SELECT COUNT(*) FROM sales_channels) AS sales_channel_count;

-- Policy effective date range
SELECT
    MIN(effective_to_date) AS first_policy_date,
    MAX(effective_to_date) AS last_policy_date
FROM claims;

-- Date range Count
SELECT
    YEAR(effective_to_date) AS policy_year,
    MONTH(effective_to_date) AS policy_month,
    COUNT(*) AS policy_count
FROM claims
GROUP BY YEAR(effective_to_date), MONTH(effective_to_date)
ORDER BY policy_year, policy_month ASC;


-- 2. Data Quality Assessment

-- Check missing values in customer table
SELECT
    SUM(customer_id IS NULL) AS customer_id_nulls,
    SUM(employment_status IS NULL) AS employment_status_nulls,
    SUM(gender IS NULL) AS gender_nulls,
    SUM(state IS NULL) AS state_nulls,
    SUM(education IS NULL) AS education_nulls,
    SUM(marital_status IS NULL) AS marital_status_nulls,
    SUM(location IS NULL) AS location_nulls,
    SUM(income IS NULL) AS income_nulls
FROM customers;

-- Check missing values in claims table
SELECT
    SUM(customer_lifetime_value IS NULL) AS clv_nulls,
    SUM(effective_to_date IS NULL) AS effective_date_nulls,
    SUM(monthly_premium IS NULL) AS premium_nulls,
    SUM(months_since_last_claim IS NULL) AS last_claim_nulls,
    SUM(months_since_policy_inception IS NULL) AS policy_inception_nulls,
    SUM(number_of_open_complaints IS NULL) AS complaint_nulls,
    SUM(number_of_policies IS NULL) AS policy_count_nulls,
    SUM(total_claim_amount IS NULL) AS claim_amount_nulls
FROM claims;

-- Check duplicate customers
SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Check for negative amounts
SELECT
	(SELECT COUNT(*) FROM customers WHERE income < 0) AS customer_income_invalid,
    (SELECT COUNT(*) FROM claims WHERE monthly_premium < 0) AS premium_invalid,
	(SELECT COUNT(*) FROM claims WHERE total_claim_amount < 0) AS claim_invalid;


-- 3. Customer Overview

-- Gender distribution
SELECT
    gender,
    COUNT(*) AS customer_count
FROM customers
GROUP BY gender
ORDER BY customer_count DESC;

-- State distribution
SELECT
    state,
    COUNT(*) AS customer_count
FROM customers
GROUP BY state
ORDER BY customer_count DESC;

-- Marital status distribution
SELECT
    marital_status,
    COUNT(*) AS customer_count
FROM customers
GROUP BY marital_status
ORDER BY customer_count DESC;

-- Employment status distribution
SELECT
    employment_status,
    COUNT(*) AS customer_count
FROM customers
GROUP BY employment_status
ORDER BY customer_count DESC;

-- Income statistics
SELECT
    MIN(income) AS minimum_income,
    MAX(income) AS maximum_income,
    AVG(income) AS average_income
FROM customers;


-- 4. Claim Overview

-- Customer Lifetime Value statistics
SELECT
    MIN(customer_lifetime_value) AS minimum_clv,
    MAX(customer_lifetime_value) AS maximum_clv,
    AVG(customer_lifetime_value) AS average_clv
FROM claims;

-- Claim amount statistics
SELECT
    MIN(total_claim_amount) AS minimum_claim_amount,
    MAX(total_claim_amount) AS maximum_claim_amount,
    AVG(total_claim_amount) AS average_claim_amount
FROM claims;

-- Monthly premium statistics
SELECT
    MIN(monthly_premium) AS minimum_monthly_premium,
    MAX(monthly_premium) AS maximum_monthly_premium,
    AVG(monthly_premium) AS average_monthly_premium
FROM claims;

-- Number of policies statistics
SELECT
    MIN(number_of_policies) AS minimum_policies,
    MAX(number_of_policies) AS maximum_policies,
    AVG(number_of_policies) AS average_policies
FROM claims;


-- 5. Policy Overview

-- Coverage distribution
SELECT
    coverage,
    COUNT(*) AS policy_count
FROM policies
GROUP BY coverage
ORDER BY policy_count DESC;

-- Policy type distribution
SELECT
    policy_type,
    COUNT(*) AS policy_count
FROM policies
GROUP BY policy_type
ORDER BY policy_count DESC;


-- 6. Vehicle Overview

-- Vehicle class distribution
SELECT
    vehicle_class,
    COUNT(*) AS vehicle_count
FROM vehicles
GROUP BY vehicle_class
ORDER BY vehicle_count DESC;
