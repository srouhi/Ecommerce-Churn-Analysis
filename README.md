# E-commerce Customer Churn Analysis & Dashboard

This project analyzes customer churn patterns in an e-commerce platform using SQL and Power BI. It includes data cleaning, SQL-driven exploration, and an interactive Power BI dashboard with actionable business insights.

---

## Project Structure

- **Source Data**: [Kaggle Dataset](https://www.kaggle.com/datasets/ankitverma2010/ecommerce-customer-churn-analysis-and-prediction/data)
- **SQL Analysis**: Used MySQL for data cleaning, transformation, and insight generation
- **Visualization**: Built an interactive dashboard using Power BI
- **Output**:
  - Cleaned dataset (`final_cleaned_ecommerce_data.csv`)
  - Power BI file (`.pbix`)
  - Screenshot of dashboard

---

## Files & Folders

| Folder        | Content                                   |
|---------------|--------------------------------------------|
| `/data/`      | Original and cleaned CSV files             |
| `/sql/`       | SQL script used in MySQL Workbench         |
| `/powerbi/`   | Power BI `.pbix` file and dashboard image  |

---

## Key Business Insights

- **Tenure Impact**: Customers with ≤6 months tenure churned the most.
- **Delivery Distance**: Longer warehouse-to-home distances correlate with higher churn.
- **Preferred Devices**: Users logging in via phones churn more than desktop users.
- **Complaints**: Customers who lodged complaints had higher churn rates.
- **Cashback Influence**: Moderate cashback amounts were linked to higher churn, suggesting a need to rethink incentive levels.

---

## Dashboard Preview
For a full view of the Power BI dashboard, check out the [PDF version here](./dashboard/ecommerce_churn_dashboard.pdf).



---

## Tools Used

- **SQL** (MySQL): For data wrangling, cleansing, transformation
- **Power BI**: For creating an interactive churn dashboard
- **Excel**: For initial inspection and formatting
- **GitHub**: For version control and project sharing

---

## Dataset Description

The dataset contains over 4,000 customer records with features like:
- Demographics (gender, marital status, city tier)
- Usage behavior (login device, number of orders, complaints)
- Financial metrics (cashback, coupon usage, hike in order amount)
- Target label: `Churn` (1 = churned, 0 = retained)

---

## What I Learned

- Cleaning messy categorical data (e.g., duplicate device labels like “Phone” and “Mobile Phone”)
- Creating new features for better segmentation (e.g., tenure ranges, cashback ranges)
- Writing intermediate SQL queries for customer segmentation and churn rate calculations
- Designing a compelling dashboard with KPIs, bar & pie charts in Power BI

---

## Future Improvements

- Apply machine learning to predict churn (e.g., logistic regression, decision trees)
- Build an automated report in Power BI with refreshable data
- Add DAX measures to show churn rate percentages alongside raw counts

---

## Author

**Shay - Shaghayegh Rouhi**  
Data Science, Machine Learning, AI  
[LinkedIn](https://www.linkedin.com/in/Shay-shaghayegh-rouhi-aba3892a1) | [Email](mailto:Shaghayegh.rouhi.sr@gmail.com)

---

## License

This project is for educational purposes only. Original dataset © Kaggle contributor.
