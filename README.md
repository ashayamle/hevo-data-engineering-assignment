# Hevo Take-Home Assignment  
PostgreSQL → Snowflake Data Pipeline, Cleaning & Modeling

---

## Overview

This project demonstrates an end-to-end data engineering workflow using PostgreSQL, Hevo, and Snowflake.  
It is divided into two parts:

- **Assignment 1**: Pipeline setup, ingestion, and transformations  
- **Assignment 2**: Data cleaning, deduplication, and analytics-ready modeling  

The objective is to ingest data reliably, handle real-world data quality issues, and produce clean datasets suitable for analytics.

---

## Tech Stack

- Source Database: PostgreSQL (local, Docker)
- Ingestion Tool: Hevo (Logical Replication)
- Data Warehouse: Snowflake
- Transformations: Hevo SQL Models
- Scheduling: Hourly

---

## Assignment 1 – Pipeline Setup & Transformations

### Source Setup (PostgreSQL)

A local PostgreSQL database was created using Docker with the following tables:

- customers  
- orders  
- feedback  

While loading data, duplicate `order_id` values were detected in the feedback dataset.  
To resolve this:

- Data was first loaded into a staging table  
- Records were deduplicated  
- Clean data was inserted into the final feedback table  

This ensured data integrity while preserving realistic data issues.

---

### Pipeline Creation (PostgreSQL → Snowflake)

- PostgreSQL was connected to Hevo using Logical Replication  
- Snowflake was connected using Hevo Partner Connect  
- Only core business tables were ingested:
  - customers
  - orders
  - feedback
- Staging tables were intentionally excluded

All tables were ingested into Snowflake with the prefix `pg_`.

---

### Assignment 1 Transformations (Hevo Models)

#### customers_with_username

- Derived a `username` field from email
- Username is the substring before `@`
- Standardized usernames to lowercase

#### order_events

- Converted order status into event-style records
- Status-to-event mapping:
  - placed → order_placed
  - shipped → order_shipped
  - delivered → order_delivered
  - cancelled → order_cancelled

Both models are scheduled to run hourly.

---

## Assignment 2 – Data Cleaning & Modeling

### Dataset Constraints

The provided dataset does **not** include:
- Product-level tables or attributes
- Order amounts or currency information

Rather than fabricating data, the solution adapts to the **actual available schema** and documents these constraints explicitly.

---

### customers_cleaned

Built from the ingested `pg_customers` table.

Cleaning logic:
- Deduplicated customers by ID
- Standardized email addresses
- Parsed phone and country from semi-structured address JSON when available
- Filled missing values with "Unknown"
- Flagged invalid customers instead of dropping them

Output table:
- customers_cleaned

---

### orders_cleaned

Built from the ingested `pg_orders` table.

Cleaning logic:
- Deduplicated orders using ingestion timestamp
- Standardized order status values
- Flagged deleted records using Hevo metadata
- Preserved all rows for auditability

Output table:
- orders_cleaned

---

### orders_analytics_final

Final analytics-ready dataset.

Modeling logic:
- LEFT JOIN between orders_cleaned and customers_cleaned
- Preserved all orders
- Handled orphan customers using default labels

Output table:
- orders_analytics_final

---

## Validation Queries

### Ingestion Validation

```sql
SELECT COUNT(*) FROM pg_customers;
SELECT COUNT(*) FROM pg_orders;
SELECT COUNT(*) FROM pg_feedback;

```
### Assignment 1 – Transformation Validation

```sql
-- Validate username derivation from email
SELECT email, username
FROM customers_with_username
WHERE email IS NOT NULL
LIMIT 10;

-- Validate order event generation
SELECT event_type, COUNT(*) AS event_count
FROM order_events
GROUP BY event_type;
```

### Assignment 2 – Cleaning Validation

```sql
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT customer_id) AS distinct_customers
FROM customers_cleaned;

-- Validate order status normalization
SELECT order_status, COUNT(*) AS status_count
FROM orders_cleaned
GROUP BY order_status;
```
---

## Assumptions & Design Decisions

- The source dataset did not contain product-level tables or attributes.  
  Product-related transformations were therefore intentionally omitted rather than fabricating data.

- Rows were **flagged instead of dropped** to preserve auditability and transparency.

- Fully qualified table names were used in Hevo models to avoid schema ambiguity during execution.

- Incremental models were avoided to keep transformations simple and easy to validate.

---

## How to Reproduce

1. Set up PostgreSQL locally using Docker  
2. Load the provided sample CSV data into PostgreSQL tables  
3. Configure a PostgreSQL → Snowflake pipeline using Hevo (Logical Replication)  
4. Ingest tables into Snowflake with a `pg_` prefix  
5. Create Hevo SQL Models as documented for Assignments 1 and 2  
6. Run the validation queries in Snowflake to confirm correctness  

---

## Issues Faced & Resolutions

- Encountered duplicate order IDs in feedback data; resolved via staging and deduplication.
- Assignment 2 schema differed from the spec; adapted models to actual available tables.
- Missing product data was documented instead of fabricated.

---

## Conclusion

This project demonstrates an end-to-end data engineering workflow including reliable ingestion, realistic data issue handling, and analytics-ready modeling.  

The solution prioritizes correctness, transparency, and real-world decision-making over assumptions, resulting in a clean and defensible data pipeline suitable for downstream analytics.




