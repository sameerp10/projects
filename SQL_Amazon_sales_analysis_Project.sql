create database capstone;
use capstone;

CREATE TABLE amazon_sales(
invoice_id VARCHAR(30) PRIMARY KEY,
Branch VARCHAR(5) NOT NULL,
City VARCHAR(30) NOT NULL,
Customer_type VARCHAR(30) NOT NULL,
Gender VARCHAR(10) NOT NULL,
Product_line VARCHAR(100) NOT NULL, 
Unit_price DECIMAL(10, 2) NOT NULL,
Quantity INT NOT NULL,
Tax_pct FLOAT NOT NULL,
Total FLOAT NOT NULL,
Date DATE NOT NULL,
Time TIME NOT NULL,
payment_method VARCHAR(50) NOT NULL,
cogs DECIMAL(10, 2) NOT NULL,
gross_margin_percentage FLOAT NOT NULL,
gross_income FLOAT NOT NULL,
rating FLOAT NOT NULL
);

select * from amazon_sales;

-- add column time_of_day
alter table amazon_sales add time_of_day varchar(25);
update amazon_sales
set time_of_day=
case
when hour(Time) between 5 and 11 then "Morning"
when hour(Time) between 12 and 16 then "Afternoon"
when hour(Time) between 17 and 21 then "Evening"
end;

SET SQL_SAFE_UPDATES = 0;

-- add column day_of_name
alter table amazon_sales 
add column day_of_name varchar(20);

update amazon_sales
set day_of_name=
date_format(Date,'%a');

-- add column month_of_name
alter table amazon_sales
add column month_of_name varchar(20);

update amazon_sales
set month_of_name=
date_format(Date,"%b");

-- Q1. What is the count of distinct cities in the dataset?
select count(distinct(city)) as count_of_cities from amazon_Sales;

-- Q2. For each branch, what is the corresponding city?
select distinct branch, city from amazon_sales;

-- Q3. What is the count of distinct product lines in the dataset?
select count(distinct product_line) as product_line_distinct_count 
from amazon_sales;

-- Q4. Which payment method occurs most frequently?
select payment_method, count(payment_method) as count_payment from amazon_sales
group by payment_method
order by count_payment desc
limit 1;

-- Q5. Which product line has the highest sales?
select product_line, sum(total) as total_sales from amazon_sales
group by product_line
order by total_sales desc
limit 1;

-- Q6. How much revenue is generated each month?
select month_of_name, sum(total) as total_sales 
from amazon_sales
group by month_of_name
order by total_sales desc;

-- Q7. In which month did the cost of goods sold reach its peak?
select month_of_name, sum(cogs) as cost_of_goods from amazon_sales
group by month_of_name
order by cost_of_goods desc
limit 1;

-- Q8. Which product line generated the highest revenue?
select product_line, sum(total) as revenue
from amazon_sales
group by Product_line
order by revenue desc
limit 1;

-- Q9. In which city was the highest revenue recorded?
select city, sum(total) as revenue
from amazon_sales
group by city
order by revenue desc
limit 1; 

-- Q10. Which product line incurred the highest Value Added Tax?
select product_line, sum(tax_pct) as total_VAT
from amazon_sales
group by Product_line
order by total_VAT desc
limit 1;

-- Q11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
select product_line,
(case
when sum(total)>(select avg(total_sales) from (select sum(total) as total_sales from amazon_sales group by product_line) as avg_total_Sale) 
 then "Good"
else
"Bad"
end) as product_line_remark
from amazon_sales
group by Product_line;

-- Q12. Identify the branch that exceeded the average number of products sold.
with branch_total_sales as(
select branch, sum(quantity) as total_product_sold
from amazon_sales
group by branch),
branch_avg_sales as(
select avg(total_product_sold) as avg_product_sold
from branch_total_sales)
select branch, total_product_sold
from branch_total_sales, branch_avg_sales
where total_product_sold>avg_product_sold;

-- Q13. Which product line is most frequently associated with each gender?
with product_count as(
select count(*) as freq, product_line, gender,
row_number() over(partition by gender order by count(*) desc) as ranking
from amazon_sales
group by gender, product_line)
select gender, product_line, freq 
from product_count
where ranking=1;

-- Q14. Calculate the average rating for each product line.
select product_line, round(avg(rating),2) as avg_rating
from amazon_sales
group by product_line
order by avg(rating) desc;

-- Q15. Count the sales occurrences for each time of day on every weekday.
select count(*) as sales_count, time_of_day, day_of_name 
from amazon_sales
group by time_of_day, day_of_name
order by sales_count desc;

-- Q16. Identify the customer type contributing the highest revenue.
select customer_type, round(sum(total),2) as revenue 
from amazon_sales
group by Customer_type
order by revenue desc
limit 1;

-- Q17. Determine the city with the highest VAT percentage.
 select city, round(avg((tax_pct/cogs)*100),2) as vat_percentage
 from amazon_sales
 group by city
 order by vat_percentage desc
 limit 1;
 
 -- Q18. Identify the customer type with the highest VAT payments.
 select customer_type, round(sum(tax_pct),2) as total_vat
 from amazon_sales
 group by customer_type
 order by total_vat desc
 limit 1;
 
 -- Q19. What is the count of distinct customer types in the dataset?
 select count(distinct customer_type) as distinct_customer_type
 from amazon_sales;
 
 -- Q20. What is the count of distinct payment methods in the dataset?
 select count(distinct payment_method) as distinct_payment_method
 from amazon_sales;
 
 -- Q21. Which customer type occurs most frequently?
 select customer_type, count(*) as frequency
 from amazon_sales
 group by customer_type
 order by frequency desc
 limit 1;
 
 -- Q22. Identify the customer type with the highest purchase frequency.
 select customer_type, count(*) as purchase_frequency
 from amazon_sales
 group by customer_type
 order by purchase_frequency desc
 limit 1;
 
 -- Q23. Determine the predominant gender among customers.
 select gender, count(*) as customers_count
 from amazon_sales
 group by gender
 order by customers_count desc
 limit 1;
 
 -- Q24. Examine the distribution of genders within each branch.
 select branch, gender,  count(*) as count
 from amazon_sales
 group by gender,branch
 order by branch, count desc;
 
 -- Q25. Identify the time of day when customers provide the most ratings.
 select time_of_day, count(rating) as rating_count
 from amazon_sales
 group by time_of_day
 order by rating_count desc
 limit 1;
 
 -- Q26. Determine the time of day with the highest customer ratings for each branch.
 with rating_table as(
 select time_of_day, branch, count(rating) as rating_count
 from amazon_sales
 group by  branch, time_of_day
 order by rating_count desc)
 select branch, time_of_day, rating_count,rnk
 from (select *,
 rank() over(partition by branch order by rating_count desc) as rnk
 from rating_table) as rnk_table
 where rnk=1 ;

-- Q27. Identify the day of the week with the highest average ratings.
select day_of_name, round(avg(rating),2) as avg_rating
from amazon_sales
group by day_of_name
order by avg_rating desc;

-- Q28. Determine the day of the week with the highest average ratings for each branch.
with rating_table as(
select branch, day_of_name, avg(rating) as avg_rating
from amazon_sales
group by branch, day_of_name
order by avg_rating desc)
select branch, day_of_name, round((avg_rating),2) as avg_rating
from (select *,
rank() over (partition by branch order by avg_rating desc) as rnk
from rating_table) as rnk_table
where rnk=1 ;