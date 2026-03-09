# 📊 Sales Data Analysis | SQL + Power BI

## Project Overview

This project analyzes retail sales data to identify trends, regional performance, and key opportunities for business improvement.  

The analysis was performed using **SQL for data exploration and transformation** and **Power BI for interactive visualization and dashboard development**.

The goal of the project is to demonstrate how data analytics can support **data-driven decision making in a retail environment**.

---

## Dataset

The dataset used in this project comes from **Kaggle** and represents retail sales transactions including:

- Order ID
- Order Date
- Ship Date
- Customer Information
- Region and City
- Product Category and Subcategory
- Sales values

Example record:

Order ID: CA-2017-152156  
Customer: Claire Gute  
Segment: Consumer  
City: Henderson  
State: Kentucky  
Category: Furniture  
Subcategory: Bookcases  
Product: Bush Somerset Collection Bookcase  
Sales: 261.96

---

## Tools & Technologies

- SQL (Data exploration and analysis)
- Power BI (Data visualization and dashboard)
- Kaggle Dataset (Retail Sales Data)

---

## Data Analysis Process

The project followed a structured data analytics workflow:

### 1️⃣ Data Exploration
Initial exploration of the dataset to understand structure and key variables.

### 2️⃣ Data Cleaning
SQL queries were used to inspect the dataset and ensure data consistency.

### 3️⃣ Data Modeling
Creation of **SQL views** to organize relevant metrics for analysis.

### 4️⃣ Data Visualization
Development of an interactive **Power BI dashboard** to visualize key metrics and business insights.

---

## Dashboard Metrics

The dashboard includes several key performance indicators:

- **Total Sales:** 2.26 Million
- **Total Orders:** 4922
- **Total Customers:** 793
- **Average Order Value:** 459

---

## Key Dashboard Features

### 📈 Monthly Sales Trend
Shows sales evolution over time including a **3-month moving average** to highlight trends.

### 🌎 Sales Distribution by Region
Displays the proportion of sales across the four main regions:

- West
- East
- Central
- South

### 🏙 Top Cities by Sales
Highlights the **top 10 performing cities** in terms of sales.

### 🗺 Geographic Sales Analysis
Interactive map showing sales distribution across the United States.

### 📊 Regional Performance Table
Includes an analytical recommendation system:

- **INVEST MORE** → high-performing regions  
- **MAINTAIN** → stable performance  
- **REVIEW / REDUCE** → underperforming areas  

---

## Key Insights

Some relevant findings from the analysis:

- Sales show **consistent growth trends over time**.
- Certain regions contribute significantly more to overall revenue.
- Major cities represent a **large share of total sales**.
- Strategic focus on high-performing regions could increase profitability.

---

## Dashboard Preview

![Dashboard](images/dashboard.png)

---

## Repository Structure

sales-data-analysis
│
├── SQL
│ ├── data_cleaning.sql
│ ├── views.sql
│ └── analysis_queries.sql
│
├── powerbi
│ └── dashboard.pbix
│
├── imagenes
│ └── dashboard.png
│
└── README.md
---

## Future Improvements

Potential improvements for this project include:

- Profit analysis by category
- Customer segmentation analysis
- Predictive sales forecasting
- Automated data pipelines

---

## Author

Daniel Vallejo  

Aspiring Data Analyst focused on:

- Data Analytics
- SQL
- Business Intelligence
- Data Visualization
- Geospatial Analysis