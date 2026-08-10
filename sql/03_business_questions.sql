-- Project	: MySQL - Motor Claims Analysis
-- File		: 03_business_questions.sql
-- Author	: Nora Thu Thu Htet Naing
-- Purpose	: Answer business questions related to customer risk, claim severity, policy performance, sales channels,
--            and vehicle segments using SQL.

USE motor_claims_db;

-- 1. Customer Analysis
-- Q1. Which customer segments generate the highest total claim amount?
-- Business Purpose: Identify customer characteristics associated with higher claim costs
-- 					to support customer risk assessment and segmentation.
SELECT
	c.gender,
    COUNT(*) AS customer_count,
    SUM(cl.total_claim_amount) AS total_claim_amount,
	AVG(cl.total_claim_amount) AS avg_claim_amount
FROM customers c
JOIN claims cl
	ON c.customer_id = cl.customer_id
GROUP BY c.gender
ORDER BY total_claim_amount DESC;

SELECT
	c.employment_status,
    COUNT(*) AS customer_count,
    SUM(cl.total_claim_amount) AS total_claim_amount,
    AVG(cl.total_claim_amount) AS avg_claim_amount
FROM customers c
JOIN claims cl
	ON c.customer_id = cl.customer_id
GROUP BY c.employment_status
ORDER BY total_claim_amount DESC;

SELECT
	c.education,
	COUNT(*) AS customer_count,
    SUM(cl.total_claim_amount) AS total_claim_amount,
    AVG(cl.total_claim_amount) AS avg_claim_amount
FROM customers c
JOIN claims cl
	ON c.customer_id = cl.customer_id
GROUP BY c.education
ORDER BY total_claim_amount DESC;

SELECT
	c.marital_status,
	COUNT(*) AS customer_count,
    SUM(cl.total_claim_amount) AS total_claim_amount,
    AVG(cl.total_claim_amount) AS avg_claim_amount
FROM customers c
JOIN claims cl
	ON c.customer_id = cl.customer_id
GROUP BY c.marital_status
ORDER BY total_claim_amount DESC;

-- Q2. Which states have the highest claim costs?
-- Business purpose: Identify geographic areas with higher claim costs
-- 					to support regional risk assessment and resource allocation.
SELECT
	c.state,
    SUM(cl.total_claim_amount) AS total_claim_amount
FROM customers c
JOIN claims cl
	ON c.customer_id = cl.customer_id
GROUP BY c.state
ORDER BY total_claim_amount DESC;

-- Q3. Which income groups generate the highest claim amount?
-- Business Purpose: Assess whether claim costs vary across income segments
-- 					to support customer risk segmentation.
SELECT
	CASE
		WHEN c.income <= 30000 THEN 'Low Income'
        WHEN c.income <= 60000 THEN 'Medium Income'
        WHEN c.income <= 100000 THEN 'High Income'
	ELSE 'Very High Income'
    END AS income_segment,
    COUNT(*) as customer_count,
    SUM(total_claim_amount) AS total_claim_amount,
    AVG(total_claim_amount) AS avg_claim_amount
FROM customers c
JOIN claims cl
	ON c.customer_id = cl.customer_id
GROUP BY income_segment
ORDER BY total_claim_amount DESC;

-- Q4. Do higher-income customers have higher Customer Lifetime Value?
-- Business Purpose: Evaluate whether customer income is associated with customer value
-- 					to identify potentially higher-value customer segments.
WITH customer_segment AS (
	SELECT
		customer_id,
		CASE
			WHEN income <= 30000 THEN 'Low Income'
			WHEN income <= 60000 THEN 'Medium Income'
			WHEN income <= 100000 THEN 'High Income'
			ELSE 'Very High Income'
		END AS income_segment
	FROM customers
)
SELECT
	cs.income_segment,
    COUNT(*) AS customer_count,
    AVG(cl.customer_lifetime_value) as avg_clv,
    SUM(cl.customer_lifetime_value) AS total_clv
FROM customer_segment cs
JOIN claims cl
	ON cs.customer_id = cl.customer_id
GROUP BY cs.income_segment
ORDER BY avg_clv DESC;


-- 2. Claim Analysis
-- Q5. What are the top 10 highest-cost claims?
-- Business Purpose: Identify the highest-cost claims and
-- 					examine the characteristics of customers associated with them.

SELECT
	c.customer_id,
    c.gender,
    c.employment_status,
    c.state,
    c.education,
    c.marital_status,
    c.location,
    c.income,
    cl.customer_lifetime_value,
    cl.monthly_premium,
    cl.total_claim_amount
FROM claims cl
JOIN customers c
	ON cl.customer_id = c.customer_id 
ORDER BY cl.total_claim_amount DESC
LIMIT 10;


-- 3. Policy Analysis
-- Q6. Which coverage type has the highest average claim amount?
-- Business Purpose: Identify coverage categories associated with higher average claim costs.
SELECT
	p.coverage,
    AVG(c.total_claim_amount) AS avg_claim_amount
FROM policies p
JOIN claims c
	ON p.policy_id = c.policy_id
GROUP BY p.coverage
ORDER BY avg_claim_amount DESC;

-- Q7. How do policy types compare in average CLV and average monthly premium?
-- Business Purpose: Compare policy types by customer value and premium levels
-- 					to identify high-value policy types.
SELECT
	p.policy_type,
    COUNT(*) AS policy_count,
    AVG(c.customer_lifetime_value) AS avg_clv,
    AVG(c.monthly_premium) AS avg_monthly_premium
FROM policies p
JOIN claims c
	ON p.policy_id = c.policy_id
GROUP BY p.policy_type
ORDER BY avg_clv DESC;


-- 4. Sales Channel Analysis
-- Q8. How do sales channels compare in claim severity and customer value?
-- Business Purpose: Compare sales channels across claim cost and customer value
-- 					to identify channels that attract valuable customers
-- 					while maintaining favorable claim performance.
SELECT
	sc.sales_channel,
    COUNT(*) AS customer_count,
	AVG(total_claim_amount) AS avg_claim_amount,
    AVG(cl.customer_lifetime_value) AS avg_clv
FROM claims cl
JOIN sales_channels sc
	ON cl.sales_channel_id = sc.sales_channel_id
GROUP BY sc.sales_channel
ORDER BY avg_clv DESC;

-- Q9. Which sales channel serves customers with the highest average number of policies?
-- Business Purpose: Identify sales channels associated with customers who hold
-- 					multiple policies, supporting cross-selling and retention strategies.
SELECT
	sc.sales_channel,
    COUNT(*) AS customer_count,
    AVG(cl.number_of_policies) AS avg_policies_per_customer
FROM claims cl
JOIN sales_channels sc
	ON cl.sales_channel_id = sc.sales_channel_id
GROUP BY sc.sales_channel
ORDER BY avg_policies_per_customer DESC;


-- 5. Vehicle Analysis
-- Q10. How do vehicle classes compare across claim severity, premium, and customer value?
-- Business Purpose: Compare vehicle classes across key business metrics
-- 					to identify high-risk and high-value vehicle segments.
SELECT
    v.vehicle_class,
    COUNT(*) AS customer_count,
    AVG(c.total_claim_amount) AS avg_claim_amount,
    AVG(c.monthly_premium) AS avg_monthly_premium,
    AVG(c.customer_lifetime_value) AS avg_clv
FROM vehicles v
JOIN claims c
    ON v.vehicle_id = c.vehicle_id
GROUP BY v.vehicle_class
ORDER BY avg_claim_amount DESC;

-- 6. Cross-Dimensional Analysis
-- Q11. Which combination of vehicle class and sales channel has the highest average claim amount?
-- Business Purpose: Identify vehicle and sales channel combinations associated
-- 					with higher claim severity to support targeted risk analysis.
SELECT
	v.vehicle_class,
    sc.sales_channel,
    AVG(c.total_claim_amount) AS avg_claim_amount
FROM claims c
JOIN vehicles v
	ON c.vehicle_id = v.vehicle_id
JOIN sales_channels sc
	ON c.sales_channel_id = sc.sales_channel_id
GROUP BY
	v.vehicle_class,
    sc.sales_channel
ORDER BY avg_claim_amount DESC;

-- Q12. Which combination of customer characteristics is associated with the highest average claim amount?
-- Business Purpose: Identify customer segments associated with higher claim severity
-- 					while avoiding conclusions based on very small customer groups.
SELECT
    c.gender,
    c.employment_status,
    c.state,
    COUNT(*) AS customer_count,
    AVG(cl.total_claim_amount) AS avg_claim_amount
FROM customers c
JOIN claims cl
    ON c.customer_id = cl.customer_id
GROUP BY
    c.gender,
    c.employment_status,
    c.state
HAVING COUNT(*) > 10
ORDER BY avg_claim_amount DESC;