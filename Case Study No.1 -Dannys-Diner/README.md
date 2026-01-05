# Danny’s Diner – Week 1 (SQL Case Study)

This document presents a structured **Question & Answer** walkthrough for the **Danny’s Diner** case study from the **8 Week SQL Challenge**. Each question includes the SQL query, explanation, and final result.

---

## 1. Total amount spent by each customer

### Question

What is the total amount each customer spent at Danny’s Diner?

### SQL Query

```sql
SELECT
  s.customer_id,
  SUM(m.price) AS total_sales
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
  ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;
```

### Answer

| customer_id | total_sales |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

---

## 2. Number of days each customer visited

### Question

How many distinct days did each customer visit the restaurant?

### SQL Query

```sql
SELECT
  customer_id,
  COUNT(DISTINCT order_date) AS visit_count
FROM dannys_diner.sales
GROUP BY customer_id;
```

### Answer

| customer_id | visit_count |
| ----------- | ----------- |
| A           | 4           |
| B           | 6           |
| C           | 2           |

---

## 3. First item purchased by each customer

### Question

What was the first item purchased by each customer?

### SQL Query

```sql
WITH ordered_sales AS (
  SELECT
    s.customer_id,
    s.order_date,
    m.product_name,
    DENSE_RANK() OVER (
      PARTITION BY s.customer_id
      ORDER BY s.order_date
    ) AS order_rank
  FROM dannys_diner.sales s
  JOIN dannys_diner.menu m
    ON s.product_id = m.product_id
)
SELECT customer_id, product_name
FROM ordered_sales
WHERE order_rank = 1;
```

### Answer

| customer_id | product_name |
| ----------- | ------------ |
| A           | sushi        |
| A           | curry        |
| B           | curry        |
| C           | ramen        |

---

## 4. Most purchased item overall

### Question

Which menu item was purchased the most times?

### SQL Query

```sql
SELECT
  m.product_name,
  COUNT(s.product_id) AS purchase_count
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
  ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY purchase_count DESC
LIMIT 1;
```

### Answer

| product_name | purchase_count |
| ------------ | -------------- |
| ramen        | 8              |

---

## 5. Most popular item for each customer

### Question

Which item was the most frequently purchased by each customer?

### SQL Query

```sql
WITH popularity AS (
  SELECT
    s.customer_id,
    m.product_name,
    COUNT(*) AS order_count,
    DENSE_RANK() OVER (
      PARTITION BY s.customer_id
      ORDER BY COUNT(*) DESC
    ) AS rank
  FROM dannys_diner.sales s
  JOIN dannys_diner.menu m
    ON s.product_id = m.product_id
  GROUP BY s.customer_id, m.product_name
)
SELECT customer_id, product_name, order_count
FROM popularity
WHERE rank = 1;
```

### Answer

| customer_id | product_name | order_count |
| ----------- | ------------ | ----------- |
| A           | ramen        | 3           |
| B           | sushi        | 2           |
| B           | curry        | 2           |
| B           | ramen        | 2           |
| C           | ramen        | 3           |

---

## 6. First purchase after becoming a member

### Question

Which item was purchased first after each customer became a member?

### SQL Query

```sql
WITH member_orders AS (
  SELECT
    m.customer_id,
    s.product_id,
    ROW_NUMBER() OVER (
      PARTITION BY m.customer_id
      ORDER BY s.order_date
    ) AS rn
  FROM dannys_diner.members m
  JOIN dannys_diner.sales s
    ON m.customer_id = s.customer_id
   AND s.order_date > m.join_date
)
SELECT mo.customer_id, me.product_name
FROM member_orders mo
JOIN dannys_diner.menu me
  ON mo.product_id = me.product_id
WHERE rn = 1;
```

### Answer

| customer_id | product_name |
| ----------- | ------------ |
| A           | ramen        |
| B           | sushi        |

---

## 7. Item purchased just before membership

### Question

Which item did each customer purchase immediately before joining?

### SQL Query

```sql
WITH pre_member AS (
  SELECT
    m.customer_id,
    s.product_id,
    ROW_NUMBER() OVER (
      PARTITION BY m.customer_id
      ORDER BY s.order_date DESC
    ) AS rn
  FROM dannys_diner.members m
  JOIN dannys_diner.sales s
    ON m.customer_id = s.customer_id
   AND s.order_date < m.join_date
)
SELECT pm.customer_id, me.product_name
FROM pre_member pm
JOIN dannys_diner.menu me
  ON pm.product_id = me.product_id
WHERE rn = 1;
```

### Answer

| customer_id | product_name |
| ----------- | ------------ |
| A           | sushi        |
| B           | sushi        |

---

## 8. Spending before membership

### Question

What were the total items and amount spent by each customer before joining?

### SQL Query

```sql
SELECT
  s.customer_id,
  COUNT(s.product_id) AS total_items,
  SUM(m.price) AS total_spent
FROM dannys_diner.sales s
JOIN dannys_diner.members mb
  ON s.customer_id = mb.customer_id
 AND s.order_date < mb.join_date
JOIN dannys_diner.menu m
  ON s.product_id = m.product_id
GROUP BY s.customer_id;
```

### Answer

| customer_id | total_items | total_spent |
| ----------- | ----------- | ----------- |
| A           | 2           | 25          |
| B           | 3           | 40          |

---

## 9. Customer loyalty points

### Question

If $1 = 10 points and sushi earns 2× points, how many points does each customer have?

### SQL Query

```sql
WITH points AS (
  SELECT
    product_id,
    CASE WHEN product_id = 1 THEN price * 20
         ELSE price * 10 END AS points
  FROM dannys_diner.menu
)
SELECT
  s.customer_id,
  SUM(p.points) AS total_points
FROM dannys_diner.sales s
JOIN points p
  ON s.product_id = p.product_id
GROUP BY s.customer_id;
```

### Answer

| customer_id | total_points |
| ----------- | ------------ |
| A           | 860          |
| B           | 940          |
| C           | 360          |

---

## 10. Points after first week bonus

### Question

How many points do customers A and B have at the end of January considering the first-week 2× bonus?

### Answer

| customer_id | total_points |
| ----------- | ------------ |
| A           | 1020         |
| B           | 320          |

---

## 🎨 Colorful Summary Tables

Below are **visually enhanced tables** for quick review. These are perfect for **presentations, GitHub previews, and interviews**.

---

### 🧾 Customer Spending

<table style="border-collapse:collapse;width:60%;">
<tr style="background:#4f46e5;color:white;"><th>Customer</th><th>Total Spent ($)</th></tr>
<tr style="background:#eef2ff;"><td>A</td><td><b>76</b></td></tr>
<tr style="background:#e0e7ff;"><td>B</td><td><b>74</b></td></tr>
<tr style="background:#eef2ff;"><td>C</td><td><b>36</b></td></tr>
</table>

---

### 📅 Visit Frequency

<table style="border-collapse:collapse;width:60%;">
<tr style="background:#16a34a;color:white;"><th>Customer</th><th>Visit Days</th></tr>
<tr style="background:#dcfce7;"><td>A</td><td>4</td></tr>
<tr style="background:#bbf7d0;"><td>B</td><td>6</td></tr>
<tr style="background:#dcfce7;"><td>C</td><td>2</td></tr>
</table>

---

### ⭐ Favourite Items

<table style="border-collapse:collapse;width:70%;">
<tr style="background:#f59e0b;color:white;"><th>Customer</th><th>Favourite Item(s)</th><th>Order Count</th></tr>
<tr style="background:#fffbeb;"><td>A</td><td>Ramen</td><td>3</td></tr>
<tr style="background:#fef3c7;"><td>B</td><td>Sushi, Curry, Ramen</td><td>2 each</td></tr>
<tr style="background:#fffbeb;"><td>C</td><td>Ramen</td><td>3</td></tr>
</table>

---

### 🎯 Loyalty Points

<table style="border-collapse:collapse;width:60%;">
<tr style="background:#db2777;color:white;"><th>Customer</th><th>Total Points</th></tr>
<tr style="background:#fce7f3;"><td>A</td><td><b>860</b></td></tr>
<tr style="background:#fbcfe8;"><td>B</td><td><b>940</b></td></tr>
<tr style="background:#fce7f3;"><td>C</td><td><b>360</b></td></tr>
</table>

---

### 🚀 Points After First-Week Bonus

<table style="border-collapse:collapse;width:60%;">
<tr style="background:#0ea5e9;color:white;"><th>Customer</th><th>Points (End of Jan)</th></tr>
<tr style="background:#e0f2fe;"><td>A</td><td><b>1020</b></td></tr>
<tr style="background:#bae6fd;"><td>B</td><td><b>320</b></td></tr>
</table>

---

## Conclusion

These colorful summary tables make the analysis **easy to scan**, **interview-ready**, and **portfolio-friendly** while keeping all SQL logic unchanged.
