-- Project : MySQL - Motor Claims Analysis
-- File    : 05_business_insights.sql
-- Author  : Nora Thu Thu Htet Naing
-- Purpose : Summarize key business insights, implications, recommendations,
--           and analytical limitations identified from the motor claims analysis.

-- ============================================================
-- 1. Business Insights
-- ============================================================

-- 1. Four-Door Cars contribute approximately 41% of total claim costs due to their volume,
--    while Luxury Car and Luxury SUV segments exhibit the highest loss ratios.

-- 2. High Value, High Risk customers have significantly higher average CLV and loss ratios,
--    highlighting them as critical segments for targeted risk assessment.

-- 3. Claim costs are moderately concentrated, with approximately 28% of
--    customers accounting for 50% of total claim costs.

-- 4. Washington and California which are customers' residential locations,
--    have loss ratios above the overall portfolio loss ratio.


-- ============================================================
-- 2. Business Recommendations
-- ============================================================

-- 1. Prioritize investigation of high-value, high-risk customers and review their claim patterns,
--    premiums, and risk characteristics before making underwriting decisions.

-- 2. Review pricing strategies and vehicle classes with elevated loss ratios
--    to assess whether premiums adequately reflect claim costs.

-- 3. Conduct deeper analysis of customers residing in Washington and California,
--   focusing on customer mix, vehicle composition, claim severity, and
--   pricing adequacy before making geographic underwriting or pricing decisions.

-- 4. Use customer risk segmentation to support targeted interventions rather than
--    applying broad portfolio-wide actions, while monitoring high-cost customer groups over time.


-- ============================================================
-- 3. Data Limitations
-- ============================================================

-- 1. Each customer appears only once in the dataset,
--    limiting the analysis of repeat claims and customer-level claim frequency.

-- 2. The effective_to_date represents the policy effective date, not the claim occurrence date.
--    Therefore, time-based claim analysis should be interpreted carefully.

-- 3. The dataset does not provide sufficient information to establish
--    causal relationships between customer characteristics and claims.

-- 4. Customer and vehicle risk segments are relative to this dataset
--    and should not be treated as universal insurance risk thresholds.