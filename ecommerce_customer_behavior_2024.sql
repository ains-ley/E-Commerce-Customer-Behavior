

--- Questions: 
-- 1. Which customer segments show the highest total spend?
-- 2. How does customer satisfaction vary across different segments?

--- Data Preparation
alter table ecommerce_customer_behavior 
rename column "Customer ID" to customer_id;

alter table ecommerce_customer_behavior 
rename column "Membership Type" to membership_type;

alter table ecommerce_customer_behavior 
rename column "Total Spend" to total_spend;

alter table ecommerce_customer_behavior 
rename column "Items Purchased" to items_purchased;

alter table ecommerce_customer_behavior 
rename column "Average Rating" to average_rating;

alter table ecommerce_customer_behavior 
rename column "Discount Applied" to discount_applied;

alter table ecommerce_customer_behavior 
rename column "Days Since Last Purchase" to days_since_last_purchase;

alter table ecommerce_customer_behavior 
rename column "Satisfaction Level" to satisfaction_level;

select * from ecommerce_customer_behavior ecb;

-- Check inconsistencies in categorical columns
select distinct gender from ecommerce_customer_behavior ecb ;
select distinct city from ecommerce_customer_behavior ecb ;
select distinct "membership_type" from ecommerce_customer_behavior ecb ;

--- Data Analysis
alter table ecommerce_customer_behavior 
add column age_group varchar;

update ecommerce_customer_behavior 
set age_group = case
	when age < 18 then 'Under 18'
	when age between 18 and 24 then '18-24'
	when age between 25 and 34 then '25-34'
	when age between 35 and 44 then '35-44'
	when age between 45 and 54 then '45-54'
	when age >=55 then '55+'
	else 'Unknown'
end;

select gender, count(*)
from ecommerce_customer_behavior ecb 
group by gender;

select gender, sum(total_spend) as sum_spend
from ecommerce_customer_behavior ecb 
group by gender
order by sum_spend desc ;
--> male spent more than female.

select gender, age_group, membership_type,
sum(total_spend) sum_spend,
avg(total_spend) avg_spend_per_customer,
count(customer_id) customer_count
from ecommerce_customer_behavior ecb 
group by gender, age_group, membership_type
order by sum_spend desc;
--> Gold members in the 25-34 age range are high spenders (male > female).

-- expenditure by age group and membership:
select age_group, membership_type,
sum(total_spend) sum_spend,
avg(total_spend) avg_spend_per_customer,
count(customer_id) customer_count
from ecommerce_customer_behavior ecb 
group by age_group, membership_type
order by sum_spend desc;
--> younger customers tend to choose gold memebership, 25-34 gold members are a high-value segment both in terms of volume and per-customer spend.

-- satisfaction and spending correlation:
select gender, age_group, membership_type,
avg(case
	when satisfaction_level = 'Unsatisfied' then 1
	when satisfaction_level = 'Neutral' then 2
	when satisfaction_level = 'Satisfied' then 3
	else null
	end) avg_satisfaction,
sum(total_spend) sum_spend
from ecommerce_customer_behavior ecb 
group by gender, age_group, membership_type
order by sum_spend desc;
--> 25-34 aged-gold members are both high spenders and highly satisfied. Outlier: this gold member is highly satisfied but represents low total spend.

-- Churn risk analysis:
select gender, age_group, membership_type,
avg(days_since_last_purchase) avg_days_since_last_purchase,
sum(total_spend) sum_spend
from ecommerce_customer_behavior ecb
group by gender, age_group, membership_type
order by avg_days_since_last_purchase desc;
--> 25-34 aged-group female silver membership has the longest time since their last purchase, with very low total spend -> at high rish of churn

-- Discount responsiveness:
select distinct discount_applied from ecommerce_customer_behavior;

select gender, age_group, membership_type,
case when discount_applied = 'true' then 1
     when discount_applied = 'false' then 0 
     else null
end as discount_applied_num,
count(customer_id) customer_count,
sum(total_spend) sum_spend,
avg(total_spend) avg_spend_per_customer
from ecommerce_customer_behavior ecb 
group by gender, age_group, membership_type,
case when discount_applied = 'true' then 1
     when discount_applied = 'false' then 0 
     else null
end
order by sum_spend desc;

    

