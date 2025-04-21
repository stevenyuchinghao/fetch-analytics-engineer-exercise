# fetch-analytics-engineer-exercise

## Overview

This repository contains my solution to the Analytics Engineering Coding exercise. The task includes analyzing unstructured JSON datasets, designing a relational data model, answering business questions, evaluate data quality issues and communication with stakeholders. 

## Contents 
- `data_model/` - Designed ERD and relational data model
- `sql/` - SQL queries answering business questions
- `notebook/` - Python Jupyter Notebook identifying data quality issues

## Explanation 

1. **Data Modeling**
  - Normalize the JSON datasets into a structured relational schema.
    - Design foreign key relationships and data types.

2. **SQL Queries and Business Questions Answered**
  - Located in the `/sql` folder, with comments explaining logic and assumptions.
  - Answering all business questions through SQL queries.
  - Tested the queries in BigQuery following the proposed data model.

3. **Data Quality Checks**
  - Identify and document issues such as duplicates, null values, or mismatches in Notebook using Python.


## Communicate with Stakeholders

Hi,

I’ve completed an initial profiling of the Fetch datasets and wanted to share key data quality issues I’ve uncovered, along with recommendations to ensure our analysis is accurate and scalable.

What I Found
Here’s a quick summary of what’s working well and what needs attention:
- ✅ receipt_id is unique — good for identifying transactions
- ✅ brandCode values match cleanly across relevant tables
- ❌ Some receipts are missing a user_id
- ❌ Some brands are missing a brandCode
- ❌ A few receipts reference users that don’t exist in the users table
- ❌ The users table contains duplicated user IDs

✅ Recommendations
To ensure data reliability and trust in our reporting, I recommend:

- Validating and cleaning records missing user_id and brandCode (missing brand_id in receipt data)
- Enforcing referential integrity between users and receipts to prevent orphaned records
- Setting up primary keys in the users and brands tables to catch duplication early
- Filtering out test or placeholder data when running analyses

🔄 What I Still Need
To proceed confidently, a few questions remain:

- hould we completely exclude receipts without valid users, or is there a fallback approach?
- Should we treat missing brandCode as unknown or remove those rows?

I’ll continue building a cleaned version of the dataset and can easily integrate business logic or filters as needed.

Happy to hop on a quick sync if you'd like to go over this in more detail!

Best,
Steven
