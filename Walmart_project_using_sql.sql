#create database walmart;

select * from  walmart_project;
select  payment_method,count(*) as cnt
from walmart_project
group by payment_method
order by cnt desc;

select count(distinct Branch) from walmart_project;  
select max(quantity) from walmart_project;

# Business Problem
# Q1 - Find different payment method and no's of transactions , number of qty sold.

select  payment_method,count(*) as transcation_cnt, sum(quantity) as qty_sold
from walmart_project
group by payment_method
order by transcation_cnt desc;

# Q2 Identify the highest-rated category in each branch , displaying the branch, category , AVG rating

with cte as (
select  Branch , category ,round(avg(rating),2) as avg_rat, dense_rank() over(partition by Branch order by avg(rating) desc) as rn
 from walmart_project
group by Branch , category)
select Branch , category , avg_rat from cte 
where rn =1;

# Q3 Identify the busiest day for each branch based on the number of transcations

select * from (
select Branch, 
dayname(str_to_date (date, '%d/%m/%y')) as day_name, count(*) as no_of_transcation,
dense_rank() over(partition by Branch order by count(*) desc ) as rn
 from walmart_project
 group by branch , day_name) as sub_query
 where rn=1;
 # In case you don't want the rn column.
select Branch, day_name, no_of_transcation from (
select Branch, 
dayname(str_to_date (date, '%d/%m/%y')) as day_name, count(*) as no_of_transcation,
dense_rank() over(partition by Branch order by count(*) desc ) as rn
 from walmart_project
 group by branch , day_name) as sub_query
 where rn=1;
 
# Q4  calculate the total quantity of itmes sold per payment method .

select payment_method ,sum(quantity) as total_qty from walmart_project
group by payment_method
order by total_qty desc;
 
 # Q5 Determine the average, min and max rating of category for each city.
 select city,category, round(avg(rating),2) as average , min(rating) , max(rating) from walmart_project
 group by city , category;
 
 # Q6 calculate the total profit for each category by considering .
 
 select category , round(sum((unit_price * quantity * profit_margin)),2) as total_profit , sum(total) as revenue
 from walmart_project
 group by category
 order by total_profit desc;
 
 
 # Q7 Determine the most common payment method for each Branch.
 
 with cte as (
 select Branch , payment_method , count(*) as cnt  , rank() over(partition by branch order by count(*) desc) as rn
 from walmart_project
 group by Branch, payment_method
 ) 
 select * from cte 
 where rn =1;
 
 # Q8 Categorize sales into 3 group morning , afternoon , evening . Find out each of the shift and number of invoices
 
 select  branch,
 case  when hour(str_to_date (time, '%H:%i:%s'))<12 then 'morning' 
 when hour(str_to_date (time, '%H:%i:%s')) between 12 and 17 then "afternoon"
 else "evening"
 end as shift_time , count(*) as cnt 
 # str_to_date (time, '%H:%i:%s') as proper_time 
 from walmart_project
 group by shift_time , branch;
 
 # Q9 Identity  5 branch with highest decrease ratio in revenue compare to last year (current year 2023 and last year 2022)
 
 with cte as (
 select Branch, sum(total) as revenue from walmart_project
 where year(str_to_date (date, '%d/%m/%y')) =2022
 group by Branch
 ),
 cte_1  as 
 (select Branch, sum(total) as revenue from walmart_project
 where year(str_to_date (date, '%d/%m/%y')) =2023
 group by Branch)
 
 select ls.Branch ,ls.revenue as last_year_revenue,
 cs.revenue as current_year_revenue ,
round( (ls.revenue - cs.revenue) / ls.revenue * 100 ,2) as revenue_decrease
 from cte as ls
 join cte_1 as cs
 on ls.Branch =cs.Branch
where ls.revenue > cs.revenue 
order by revenue_decrease desc
limit 5;
 
 
 
 
