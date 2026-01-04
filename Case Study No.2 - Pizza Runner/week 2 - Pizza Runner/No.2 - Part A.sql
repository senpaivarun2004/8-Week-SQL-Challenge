CREATE database pizza_runner;
use pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, topping)
VALUES
  (1, "1, 2, 3, 4, 5, 6, 8, 10"),
  (2, "4, 6, 7, 9, 11, 12");


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

-- PART A  Pizza Metrics
# 1.How many pizzas were ordered?
# p0 = customer_orders, p1 = COUNT(*) 

select count(*) as pizza_order_count		
from customer_orders;

# 2.How many unique customer orders were made?
# p0 = customer_orders, p1 = COUNT(DISTINCT order_id)

select count(distinct order_id) as unique_order_count     
from customer_orders;

# 3.How many successful orders were delivered by each runner?
# p0 = runner_orders, p1 = cancellation IS NULL, p2 = GROUP BY runner_id

select runner_id, count(order_id) as suceessful_orders      
from runner_orders
where distance !=0
group by runner_id;

# 4.How many of each type of pizza was delivered? 			
# p0 = customer_orders JOIN runner_orders, p1 = filter cancellation IS NULL, p2 = GROUP BY pizza_id

select c.customer_id, p.pizza_name, count(p.pizza_name) as order_count
from customer_orders as c inner join pizza_names as p using (pizza_id) -- on c.pizza_id = p.pizza_id
group by c.customer_id, p.pizza_name
order by c.customer_id;

# 5.How many Vegetarian and Meatlovers were ordered by each customer?
# p0 = customer_orders JOIN pizza_names, p1 = GROUP BY customer_id, pizza_name

select c.customer_id, p.pizza_name, count(p.pizza_name) as order_count
from customer_orders as c 
inner join pizza_names as p using(pizza_id) -- on c.pizza_id= p.pizza_id
group by c.customer_id, p.pizza_name
order by c.customer_id;

# 6.What was the maximum number of pizzas delivered in a single order?
# p0 = customer_orders JOIN runner_orders, p1 = filter cancellation IS NULL, p2 = GROUP BY order_id, p3 = MAX(COUNT(*))

with cte1 as (
select c.order_id, count(c.pizza_id) as piz_ord
from customer_orders as c 
join runner_orders as r using(order_id) -- on c.order_id = r.order_id
where r.distance !=0
group by c.order_id)

select max(piz_ord) as piz_max_count
from cte1;

# 7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
/* p0 = customer_orders JOIN runner_orders, p1 = filter cancellation IS NULL, 
p2 = CASE WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 'changed' ELSE 'unchanged' END, p3 = GROUP BY customer_id */

select c.customer_id, 
sum(case when c.exclusions <> '' or c.extras <> '' then 1 else 0 end ) as at_least_1_change,
sum(case when c.exclusions <> '' and c.extras <> '' then 1 else 0 end) as no_change
from customer_orders as c 
inner join runner_orders as r using(order_id) -- on c.order_id = r.order_id 
where r.distance !=0
group by c.customer_id
order by c.customer_id;

# 8.How many pizzas were delivered that had both exclusions and extras?
# p0 = customer_orders JOIN runner_orders, p1 = filter cancellation IS NULL, p2 = exclusions IS NOT NULL AND extras IS NOT NULL
 
 -- need to check this again need to check the query again 
select sum(
case when exclusions <> ' ' and extras <> ' ' then 1 else 0 end) as piz_count_exc_ext
from customer_orders as c
inner join runner_orders as r using(order_id) -- on c.order_id = r.order_id
where r.distance >=1 and excelusions <> ' ' and extras <> ' ';

# 9.What was the total volume of pizzas ordered for each hour of the day?
# p0 = customer_orders, p1 = EXTRACT(HOUR FROM order_time), p2 = GROUP BY hour

-- needed to check this query too 
select format(date(hour,(order_time))) as hour_of_the_day
from customer_orders
group by date(hour,(order_time));

# 10.What was the volume of orders for each day of the week?
# p0 = customer_orders, p1 = TO_CHAR(order_time, 'Day'), p2 = GROUP BY weekday

-- needed to check this query too 
select formate(datedd(day, 2, order_time),'dddd') as day_of_week,
count(order_id)
from customer_orders
group by formate(datedd(day, 2, order_time),'dddd');


