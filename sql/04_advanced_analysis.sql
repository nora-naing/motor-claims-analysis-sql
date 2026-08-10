-- Project	: MySQL - Motor Claims Analysis
-- File		: 04_advanced_analysis.sql
-- Author	: Nora Thu Thu Htet Naing
-- Purpose	: Perform advanced SQL analysis using Window functions, CTEs, ranking, contribution analysis, and segmentation
--            to identify deeper patterns in motor claim performance.

USE motor_claims_db;

-- Q1: What percentage of total claim costs is contributed by each vehicle class?
-- Business Purpose: Identify the vehicle class responsible for the largest share of total claim costs.
WITH vehicle_claims AS (
	SELECT
		v.vehicle_class,
		COUNT(*) AS vehicle_count,
		SUM(c.total_claim_amount) AS total_claim_amount
	FROM claims c
	JOIN vehicles v
		ON c.vehicle_id = v.vehicle_id
	GROUP BY v.vehicle_class
)
SELECT
	vehicle_class,
    vehicle_count,
    total_claim_amount,
    ROUND(total_claim_amount / SUM(total_claim_amount) OVER() * 100, 2) AS claim_contribution_percentage,
	RANK() OVER(ORDER BY total_claim_amount DESC) AS claim_rank
FROM vehicle_claims
ORDER BY claim_rank;



-- Q2: Which customer segments have above-average claim severity?
-- Business Purpose: Identify customer segments with significantly higher claim severity
-- 					while controlling for small sample sizes,
-- 					supporting more reliable risk assessment and targeted underwriting analysis.
SELECT
	cu.gender,
    cu.employment_status,
    cu.state,
    COUNT(*) AS customer_count,
    ROUND(AVG(c.total_claim_amount), 2) AS avg_claim_amount,
    RANK() OVER(ORDER BY AVG(c.total_claim_amount) DESC) AS rank_num
FROM claims c
JOIN customers cu
	ON c.customer_id = cu.customer_id
GROUP BY
	cu.gender,
    cu.employment_status,
    cu.state
HAVING COUNT(*) >= 30
	AND avg_claim_amount > (
		SELECT AVG(total_claim_amount)
		FROM claims
	)
ORDER BY avg_claim_amount DESC;



-- Q3: Which vehicle classes have the highest loss ratio?
-- Business Purpose: Compare claim costs with annualized premium levels across vehicle classes
-- 					to identify segments with potentially unfavorable claim performance.
SELECT
	v.vehicle_class,
	ROUND(SUM(c.total_claim_amount), 2) AS total_claim_amount,
    ROUND(SUM(c.monthly_premium * 12), 2) AS total_annual_premium,
    ROUND(
		SUM(c.total_claim_amount) / 
        NULLIF(SUM(c.monthly_premium * 12), 0) * 100,
        2) AS loss_ratio_percentage
FROM claims c
JOIN vehicles v
	ON c.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_class
ORDER BY loss_ratio_percentage DESC;



-- Q4: Which customers are high-value but also high-risk?
-- Business Purpose: Identify customers who combine high Customer Lifetime Value with high loss ratios.
WITH customer_metrics AS (
	SELECT
		cu.customer_id,
        cu.gender,
        cu.state,
        c.customer_lifetime_value,
        c.monthly_premium,
        c.total_claim_amount,
        c.total_claim_amount / NULLIF(c.monthly_premium * 12, 0) AS loss_ratio
	FROM claims c
    JOIN customers cu
		ON c.customer_id = cu.customer_id
),
customer_quartiles AS (
	SELECT
		*,
        NTILE(4) OVER(ORDER BY customer_lifetime_value) AS clv_quartile,
        NTILE(4) OVER(ORDER BY loss_ratio) AS loss_ratio_quartile
	FROM customer_metrics
)
SELECT
	CASE
		WHEN clv_quartile >= 3 AND loss_ratio_quartile >= 3 THEN 'High Value - High Risk'
        WHEN clv_quartile >= 3 AND loss_ratio_quartile <= 2 THEN 'High Value - Low Risk'
        WHEN clv_quartile <= 2 AND loss_ratio_quartile >= 3 THEN 'Low Value - High Risk'
        ELSE 'Low Value - Low Risk'
	END AS customer_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(customer_lifetime_value), 2) AS avg_clv,
    ROUND(AVG(total_claim_amount), 2) AS avg_claim_amount,
    ROUND(AVG(loss_ratio) * 100, 2) AS avg_loss_ratio_percentage,
    (
		SELECT ROUND(SUM(total_claim_amount) / NULLIF(SUM(monthly_premium *12), 0) * 100, 2)
        FROM customer_metrics) AS portfolio_loss_ratio_percentage
FROM customer_quartiles
GROUP BY customer_segment
ORDER BY avg_loss_ratio_percentage DESC;



-- Q5: Which vehicle classes are both high-value and high-risk?
-- Business Purpose: Identify vehicle classes that combine high customer lifetime value with elevated loss ratios.
WITH vehicle_metrics AS (
	SELECT
		v.vehicle_class,
		COUNT(*) AS vehicle_count,
		ROUND(AVG(customer_lifetime_value), 2) AS avg_clv,
		ROUND(AVG(total_claim_amount), 2) AS avg_claim_amount,
		ROUND(SUM(total_claim_amount) / NULLIF(SUM(monthly_premium * 12), 0) * 100, 2) AS loss_ratio_percentage
	FROM claims c
	JOIN vehicles v
		ON c.vehicle_id = v.vehicle_id
	GROUP BY v.vehicle_class
),
vehicle_quartiles AS (
	SELECT
		*,
        NTILE(2) OVER(ORDER BY avg_clv) AS clv_group,
        NTILE(2) OVER(ORDER BY loss_ratio_percentage) AS loss_ratio_group
	FROM vehicle_metrics
)
SELECT
	vehicle_class,
    vehicle_count,
    avg_clv,
    avg_claim_amount,
    loss_ratio_percentage,
    CASE
		WHEN clv_group = 2 AND loss_ratio_group = 2 THEN 'High Value - High Risk'
        WHEN clv_group = 2 AND loss_ratio_group = 1 THEN 'High Value - Low Risk'
        WHEN clv_group = 1 AND loss_ratio_group = 2 THEN 'Low Value - High Risk'
        ELSE 'Low Value - Low Risk'
	END AS vehicle_ranked
FROM vehicle_quartiles
ORDER BY loss_ratio_percentage DESC;



-- Q6: Which states have the highest risk relative to the overall portfolio?
-- Business Purpose: Identify geographic markets with unfavorable loss performance compared with the overall portfolio.
WITH state_metrics AS (
	SELECT
		cu.state,
		COUNT(*) AS customer_count,
		ROUND(AVG(c.customer_lifetime_value), 2) AS avg_clv,
		ROUND(AVG(c.total_claim_amount), 2) AS avg_claim_amount,
		ROUND(SUM(c.total_claim_amount) / NULLIF(SUM(c.monthly_premium * 12), 0) * 100, 2) AS loss_ratio_pct
	FROM claims c
	JOIN customers cu
		ON c.customer_id = cu.customer_id
	GROUP BY cu.state
),
portfolio_metrics AS (
	SELECT
		ROUND(SUM(total_claim_amount) / NULLIF(SUM(monthly_premium * 12), 0) * 100, 2) AS portfolio_loss_ratio_pct
	FROM claims
)
SELECT
	sm.state,
    sm.customer_count,
    sm.avg_clv,
    sm.avg_claim_amount,
    sm.loss_ratio_pct,
    pm.portfolio_loss_ratio_pct,
    ROUND((sm.loss_ratio_pct - pm.portfolio_loss_ratio_pct) / 
		NULLIF(pm.portfolio_loss_ratio_pct, 0) * 100, 2) AS relative_difference_pct,
    RANK() OVER(ORDER BY loss_ratio_pct DESC) AS risk_rank
FROM state_metrics sm
CROSS JOIN portfolio_metrics pm
WHERE sm.loss_ratio_pct > pm.portfolio_loss_ratio_pct
ORDER BY risk_rank;



-- Q7: How concentrated are total claim costs among customers?
-- Business Purpose: Assess claim-cost concentration to determine
-- 					whether a small group of customers accounts
-- 					for a disproportionate share of total claim costs.
WITH customer_claim_ranked AS (
	SELECT
		customer_id,
		total_claim_amount,
		ROW_NUMBER() OVER(ORDER BY total_claim_amount DESC) AS customer_rank
	FROM claims
),
customer_cumulative_claim AS (
	SELECT
		*,
		SUM(total_claim_amount) OVER(ORDER BY customer_rank ROWS UNBOUNDED PRECEDING) AS cumulative_claim_amount,
        SUM(total_claim_amount) OVER() AS overall_claim_amount
	FROM customer_claim_ranked
),
cumulative_claim_contribution_pct  AS (
	SELECT
		*,
		ROUND(cumulative_claim_amount/overall_claim_amount * 100, 2) AS cumulative_percentage
	FROM customer_cumulative_claim
)
SELECT
	MIN(CASE WHEN cumulative_percentage >= 50 THEN customer_rank END) AS customers_needed_for_50pct_claims,
    ROUND(
		MIN(CASE WHEN cumulative_percentage >= 50 THEN customer_rank END) / COUNT(*) * 100, 2) AS customer_pct_needed_for_50pct_claims,
    MIN(CASE WHEN cumulative_percentage >= 80 THEN customer_rank END) AS customers_needed_for_80pct_claims,
    ROUND(
		MIN(CASE WHEN cumulative_percentage >= 80 THEN customer_rank END) / COUNT(*) * 100, 2) AS customer_pct_needed_for_80pct_claims
FROM cumulative_claim_contribution_pct;



-- Q8: Which customers have a loss ratio above the portfolio loss ratio?
-- Business Purpose: Identify customers whose claim costs are disproportionately high relative to their annual premium.
SELECT
    c.customer_id,
    cu.gender,
    cu.state,
    cu.income,
    c.monthly_premium,
    c.total_claim_amount,
    ROUND(c.total_claim_amount / NULLIF(c.monthly_premium * 12, 0) * 100, 2) AS loss_ratio_percentage
FROM claims c
JOIN customers cu
    ON c.customer_id = cu.customer_id
WHERE c.monthly_premium > 0
	AND
	(c.total_claim_amount / NULLIF(c.monthly_premium * 12, 0)) > (
		SELECT
			SUM(total_claim_amount) / NULLIF(SUM(monthly_premium * 12), 0)
		FROM claims
)
ORDER BY loss_ratio_percentage DESC
LIMIT 20;