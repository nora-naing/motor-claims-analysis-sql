-- Project	: MySQL - Motor Claims Analysis
-- File		: 01_database_setup_and_etl
-- Author	: Nora Thu Thu Htet Naing
-- Purpose	: Create database schema and load data from staging table into normalized tables.

DROP DATABASE IF EXISTS motor_claims_db;

CREATE DATABASE motor_claims_db;

USE motor_claims_db;


-- Create Database Schema

CREATE TABLE customers
(
	customer_id VARCHAR(25) NOT NULL,
	employment_status VARCHAR(25),
	gender ENUM('M', 'F'),
	state VARCHAR(50),
	education VARCHAR(25),
	marital_status VARCHAR(25),
	location VARCHAR(25),
	income INT,
    PRIMARY KEY (customer_id)
);

CREATE TABLE vehicles
(
	vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
	vehicle_class VARCHAR(25)
);

CREATE TABLE policies
(
	policy_id INT AUTO_INCREMENT PRIMARY KEY,
	coverage VARCHAR(25),
	policy_type VARCHAR(25)
);

CREATE TABLE sales_channels
(
	sales_channel_id INT AUTO_INCREMENT PRIMARY KEY,
	sales_channel VARCHAR(25)
);

CREATE TABLE claims
(
	claim_id INT AUTO_INCREMENT,
    customer_id VARCHAR(25),
	policy_id INT,
	vehicle_id INT,
	sales_channel_id INT,
	customer_lifetime_value DECIMAL(10,2),
	effective_to_date DATE NOT NULL,
	monthly_premium DECIMAL(10,2),
	months_since_last_claim INT,
	months_since_policy_inception INT,
	number_of_open_complaints INT NOT NULL,
	number_of_policies INT,
	total_claim_amount DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (claim_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (policy_id) REFERENCES policies(policy_id) ON DELETE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
    FOREIGN KEY (sales_channel_id) REFERENCES sales_channels(sales_channel_id) ON DELETE CASCADE
);


-- Validate Imported Staging Data

SELECT COUNT(*) FROM staging_claims;
SELECT * FROM staging_claims LIMIT 5;
DESCRIBE staging_claims;


-- Load Customers Dimension

INSERT INTO customers
(
	customer_id,
	employment_status,
	gender,
	state,
	education,
	marital_status,
	location,
	income
)
SELECT
	Customer,
	`Employment Status`,
	Gender,
	State,
	Education,
	`Marital Status`,
	Location,
	Income
FROM staging_claims;

SELECT COUNT(*) AS customer_count
FROM customers;


-- Load Vehicles Dimension
INSERT INTO vehicles(vehicle_class)
SELECT DISTINCT `Vehicle Class`
FROM staging_claims;

SELECT COUNT(*) AS vehicle_count
FROM vehicles;


-- Load Policies Dimension
INSERT INTO policies(coverage, policy_type)
SELECT DISTINCT Coverage, `Policy Type`
FROM staging_claims;

SELECT COUNT(*) policy_count
FROM policies;


-- Load Sales Channels Dimension
INSERT INTO sales_channels(sales_channel)
SELECT DISTINCT `Sales Channel`
FROM staging_claims;

SELECT COUNT(*) sales_channel_count
FROM sales_channels;


-- Load Claims Fact Table
# Use JOIN to retrieve the foreign keys from the dimension tables so that we can maintain the relationships in the fact table.

INSERT INTO claims
(
    customer_id,
	policy_id,
	vehicle_id,
	sales_channel_id,
	customer_lifetime_value,
	effective_to_date,
	monthly_premium,
	months_since_last_claim,
	months_since_policy_inception,
	number_of_open_complaints,
	number_of_policies,
	total_claim_amount
)
SELECT
    c.customer_id,
	p.policy_id,
	v.vehicle_id,
	sc.sales_channel_id,
	s.`Customer Lifetime Value`,
	STR_TO_DATE(s.`Effective To Date`, '%m/%d/%Y'),
	s.`Monthly Premium Auto`,
	s.`Months Since Last Claim`,
	s.`Months Since Policy Inception`,
	s.`Number Of Open Complaints`,
	s.`Number Of Policies`,
	s.`Total Claim Amount`
FROM staging_claims s
JOIN customers c
	ON s.Customer = c.customer_id
JOIN vehicles v
	ON s.`Vehicle Class` = v.vehicle_class
JOIN policies p
	ON s.Coverage = p.coverage
    AND s.`Policy Type` = p.policy_type
JOIN sales_channels sc
	ON s.`Sales Channel` = sc.sales_channel;


-- Validate ETL Results

SELECT * FROM claims;
SELECT * FROM customers;
SELECT * FROM policies;
SELECT * FROM sales_channels;
SELECT * FROM vehicles;
