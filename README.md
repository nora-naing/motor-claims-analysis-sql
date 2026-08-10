# Motor Claims Analysis - MySQL

## Overview
This project analyzes motor insurance claims using MySQL to identify customer risk patterns, claim severity, policy performance, sales channel performance, and vehicle-level risk.

The analysis progresses from exploratory data analysis to business questions, advanced SQL analysis, and business recommendations.

## Business Objectives
- Identify customer segments associated with higher claim costs.
- Analyze claim severity across vehicle classes and policy types.
- Evaluate loss ratios across vehicle and geographic segments.
- Compare sales channels based on customer value and claim performance.
- Identify high-value, high-risk customer segments.
- Assess concentration of claim costs across customers.

## Tools Used
- MySQL 8.0
- MySQL Workbench
- SQL
  
## Skills Used
- Relational data modeling
- Primary and foreign keys
- Fact and dimension tables
- JOINs
- Aggregations and GROUP BY
- CASE expressions
- Subqueries
- CTEs
- Window functions
- RANK() and ROW_NUMBER()
- NTILE() segmentation
- Cumulative calculations
- Contribution analysis
- Loss-ratio analysis
- Customer risk segmentation
- Data quality validation

## Key Business Insights
- Four-Door Cars contributed approximately 41% of total claim costs.
- Luxury Car and Luxury SUV segments showed the highest loss ratios.
- High Value - High Risk customers represented an important value-risk segment.
- Approximately 28% of customers accounted for 50% of total claim costs.
- Washington and California showed loss ratios above the overall portfolio level.

## Recommendations
- Review pricing and underwriting for vehicle classes with elevated loss ratios.
- Investigate High Value - High Risk customers through targeted risk analysis.
- Conduct deeper analysis of customers residing in Washington and California.
- Use risk segmentation rather than applying broad portfolio-wide strategies.

## Limitations
- One record per customer.
- No transaction history available for customer lifetime value analysis.
- No claim occurrence date field for trend analysis.

## Project Structure
### Database Schema
![Motor Claims EER Diagram](images/database_schema.png)

- [Download Database Schama sql File](sql/01_create_database.sql)

### 1. Exploratory Data Analysis
- [Download Exploratory Data Analysis sql File](sql/02_exploratory_data_analysis.sql)

Covered:
- Dataset overview
- Data quality checks
- Customer analysis
- Claim analysis
- Policy analysis
- Vehicle analysis

### 2. Business Questions
- [Download Business Questions sql File](sql/03_business_questions.sql)

Analyzed:
- Customer risk segments
- Geographic claim costs
- Income segments
- Customer lifetime value
- Policy performance
- Sales channel performance
- Vehicle class performance
- Cross-dimensional risk patterns

### 3. Advanced SQL Analysis
- [Download Advanced Analysis sql File](sql/04_advanced_analysis.sql)

Applied:
- CTEs
- Window functions
- Ranking
- `NTILE()`
- Cumulative contribution analysis
- Loss ratio analysis
- Customer segmentation
- Portfolio benchmarking

### 4. Business Insights
- [Download Business Insights sql File](sql/05_business_insights.sql)
