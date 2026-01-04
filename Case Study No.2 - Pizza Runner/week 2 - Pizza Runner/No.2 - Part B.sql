use pizza_runner;
 -- 1,2,3,5 problems
-- Part B Runner and Customer Experience
# 1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
# p0 = runners, p1 = DATE_TRUNC('week', registration_date), p2 = GROUP BY week

SELECT 
  DATEPART(WEEK, registration_date) AS registration_week,
  COUNT(runner_id) AS runner_signup
FROM runners
GROUP BY DATEPART(WEEK, registration_date);


# 2.What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
# p0 = runner_orders, p1 = pickup_time - order_time (JOIN with customer_orders), p2 = AVG(minutes)

-- date problem 
WITH time_taken_cte AS(
select c.order_id, c.order_time, r.pickup_time, 
DATEDIFF(minute, c.order_time, r.pickup_time) as pickup_minutes
from customer_orders AS c inner join runner_orders as r on using (order_id) -- c.order_id = r.order_id
where r.distance != 0
group by c.order_id, c.order_time, r.pickup_time
)
select 
  ang(pickup_minutes) as avg_pickup_minutes
from time_taken_cte where pickup_minutes > 1;


# 3.Is there any relationship between the number of pizzas and how long the order takes to prepare?
#p0 = customer_orders JOIN runner_orders, p1 = COUNT(pizza_id) per order, p2 = pickup_time - order_time

-- not able to date parameter 
with prep_time_cte as (
select c.order_id, count(c.order_id) as piz_order,
c.order_time,r.pickup_time,
datediff(minute, c.order_time, r.pickup_time) as prep_time_min
from customer_orders as c
inner join runner_orders as r using(order_id) -- on c.order_id = r.order_id
where r.distance !=0
group by c.order_id, c.order_time, r.pickup_time)

select  pizza_order, 
  avg(prep_time_min) as avg_prep_time_minutes
from prep_time_cte
where prep_time_min > 1
group by pizza_order;

# 4.What was the average distance travelled for each customer?
# p0 = runner_orders JOIN customer_orders, p1 = GROUP BY customer_id, p2 = AVG(distance)

select c.customer_id,
avg(r.distance) as avg_distance 
from customer_orders as c 
inner join runner_orders as r using (order_id) -- on c.order_id = r.order_id
where r.distance !=0
group by c.customer_id;

# 5.What was the difference between the longest and shortest delivery times for all orders?
# p0 = runner_orders, p1 = MAX(duration) - MIN(duration)
-- error again 
select order_id, duration
from runner_orders
where duration not like ' ';

select max(duration:: numeric) - min(duration::numeric) as delivery_time_diff
from runner_orders2
where duration not like ' '; 

# 6.What was the average speed for each runner for each delivery and do you notice any trend for these values?
# p0 = runner_orders and join, p1 = distance/duration, p2 = group by runner_id

select r.runner_id, c.customer_id, c.order_id,
count(c.order_id) as pizza_count, r.distance,
(r.duration / 60) as duration_hr,
round((r.distance/ r.duration * 60),2) as avg_speed
from runner_orders as r 
inner join customer_orders as c using (order_id) -- on c.order_id = r.order_id
where distance !=0
group by r.runner_id, c.customer_id, c.order_id, r.distance, r.duration
order by c.order_id;

# 7.What is the successful delivery percentage for each runner?
# p0 = runner_orders, p1 = COUNT(successful)/COUNT(total)

select runner_id, round(100 * sum(case when distance = 0 then 0 else 1 end)/ count(*),0) as success_perc 
from runner_orders
group by runner_id;
