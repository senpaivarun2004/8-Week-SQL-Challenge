-- SQL solutions for Danny's Diner

/* drop database dannys_diner;
CREATE database dannys_diner;
use dannys_diner;

CREATE TABLE sales (
  Customer_ID varchar(5),
  order_date date,
  product_id int);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  /*
  Case Study Questions
Each of the following case study questions can be answered using a single SQL statement:*/

show tables;
select * from sales;
select * from menu;
select * from members;

# 1.What is the total amount each customer spent at the restaurant?
select Customer_id, sum(price) as total_amount
from sales as s 
inner join menu as m using (product_id) # on s.product_id = m.product_id 
group by customer_id;

# 2.How many days has each customer visited the restaurant?
select customer_id, count(distinct order_date) as visited_days 
from sales
group by customer_id;

# 3.What was the first item from the menu purchased by each customer?
select customer_id, order_date, product_name,
rank() over(partition by customer_id order by order_date asc) as rnk
from sales as s 
inner join menu as m using(product_id); # on s.product_id = m.product_id

select * from (
select *,
row_number() over(partition by customer_id order by order_date asc) as rn
from sales as s 
inner join menu as m using(product_id) ) as t where rn = 1; 

# 4.What is the most purchased item on the menu and how many times was it purchased by all customers?
select product_name,count(*) as cnt 
from sales as s 
inner join menu as m using(product_id) 
group by product_name order by cnt desc limit 1;

# 5.Which item was the most popular for each customer?
 select * from(
 select customer_id, product_name,count(*) as cnt,
 rank() over(partition by customer_id order by count(*)desc) as rn 
 from sales as s 
 inner join menu as m using(product_id)
 group by customer_id,product_name) as t where rn = 1;
 
with product_sales as(
select customer_id, product_name,count(*) as cnt
from sales as s 
inner join menu as m using(product_id)
group by customer_id,product_name)

select * from product_sales;

with product_sales as(
select customer_id, product_name,count(*) as cnt
from sales as s 
inner join menu as m using(product_id)
group by customer_id,product_name),rnk_CTE as (
select *, rank() over(partition by customer_id order by cnt desc) as rn
from product_sales)
select * from rnk_CTE where rn = 1;

# 6.Which item was purchased first by the customer after they became a member?
 
 with CRE1 as (
 select S.*,m.price,m.product_name,mb.joining_date from sales as s inner join menu as m using(product_id)
 inner join members as mb on s.costomer_id = mb.customer_id where order_date > join_date) 
 select * from CTE1;
 
with CRE1 as (
select S.*,m.price,m.product_name,mb.join_date from sales as s inner join menu as m using(product_id) 
inner join members as mb on s.customer_id = mb.customer_id and order_date > join_date), CTE2 as(

select *,rank() over(partition by customer_id order by order_date asc) as rn from CTE1)
select customer_id,product_name from CTE2 where rn = 1;
 
 #write a queray to print the no.of orders placed by the customer after the become the members   --its worng and it not running also for 6th one question too
 
 select customer_id,count(order_date) as num_of_orders from(
 select * from sales as s inner join member as mb using(customer_id) where order_date > join_date)
 as t group by customer_id;
 
 
# 7.Which item was purchased just before the customer became a member?
  -- select customer_id, order_date, product_name from(

with CTE1 as (
select s.*,m.product_name, mb.join_date from sales as s inner join menu as m using (product_id) 
inner join members as mb on s.customer_id = mb.customer_id and s.order_date < mb.join_date), CTE2 as(

select *,rank() over (partition by customer_id order by order_date desc) as rnk from CTE1)
select customer_id, product_name from CTE2 where rnk = 1;

# 8.What is the total items and amount spent for each member before they became a member?
-- method 1
select s.customer_id, count(*) as total_items, sum(price) as total_amount_spent 
from sales as s 
inner join menu as m using (product_id)
inner join members as mb on s.customer_id = mb.customer_id and order_date < join_date 
group by s.customer_id order by customer_id;

-- method 2
select s.customer_id, count(*) as total_items, sum(price) as total_amount_spent 
from sales as s 
inner join menu as m using (product_id)
left join members as mb on s.customer_id = mb.customer_id and order_date < join_date 
group by s.customer_id order by customer_id;

-- method 3
with CTE1 as (
select s.customer_id, count(*) as total_items, sum(price) as total_amount_spent 
from sales as s 
inner join menu as m using (product_id)
left join members as mb on s.customer_id = mb.customer_id and order_date < join_date 
group by s.customer_id order by customer_id)
select * from CTE1
union all
select s.customer_id, count(*) as total_items, sum(price) as total_amount_spent 
from sales as s 
inner join menu as m using (product_id)
left join members as mb on s.customer_id = mb.customer_id and order_date < join_date 
where s.customer_id = "C"
group by s.customer_id order by customer_id;
  
# 9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select customer_id, sum(case when product_name = 'sushi' then price*10*2 else price* 10 end) as total_points
from sales as s inner join menu as m using (product_id) 
group by customer_id;

with CTE1 as (
select customer_id, sum(case when product_name = 'sushi' then price*10*2 else price* 10 end) as total_points
from sales as s inner join menu as m using (product_id) 
group by customer_id)

select *, case when total_points <500 then 'Low' when total_points between 500 and 900 then 'Avg' else 'High' end as status from CTE1;

# 10.In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi 
-- how many points do customer A and B have at the end of January?

select *,case when s.order_date between join_date and date_add(join_date,interval 6 day) then price * 20 
when product_name='sushi' then price * 20 else price *10 end as points
from sales as s inner join menu as m using (product_id)
inner join members as mb using (customer_id);

select customer_id,sum(case when s.order_date between join_date and date_add(join_date,interval 6 day) then price * 20 
when product_name='sushi' then price * 20 else price *10 end) as total_points
from sales as s inner join menu as m using (product_id)
inner join members as mb using (customer_id)
where order_date <="2021-01-31"
group by customer_id;

#Date Add
select date_add(curdate(),interval 7 day);
select date_add(curdate(),interval -7 day); */

