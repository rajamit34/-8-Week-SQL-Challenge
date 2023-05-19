CREATE DATABASE DANNYS_DINER;

USE DANNYS_DINER;

-- ------------ CREATING DATA SET ------------ --
CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

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

-- ------------ CASE STUDY QUESTIONS ------------ --


-- ------------ 1. What is the total amount each customer spent at the restaurant? ------------ --
SELECT s.customer_id, SUM(m.price)
FROM menu m
JOIN sales s
ON m.product_id = s.product_id
GROUP BY 1;

-- ------------ 2. How many days has each customer visited the restaurant? ------------ --
SELECT customer_id, 
	COUNT(distinct order_date) no_of_days
FROM sales
GROUP BY 1
ORDER BY 1;

-- ------------ 3. What was the first item from the menu purchased by each customer? ------------ --
SELECT s.customer_id, 
	MIN(s.order_date) AS first_order_date, 
    m.product_name AS first_item
FROM sales s
JOIN menu m 
ON s.product_id = m.product_id
GROUP BY 1
ORDER BY 2;

## 2nd Method:
SELECT 
  s.customer_id,
  m.product_name AS first_item_purchased
FROM (
  SELECT 
    customer_id,
    product_id,
    DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY order_date) AS purchase_rank
  FROM sales
) s
JOIN menu  m 
ON s.product_id = m.product_id
WHERE s.purchase_rank = 1
GROUP BY 1;

-- ------------ 4. What is the most purchased item on the menu and how many times was it purchased by all customers? ------------ ---- 
SELECT m.product_name, 
	COUNT(*) AS total_purchased
FROM menu  m 
JOIN sales  s 
ON m.product_id = s.product_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- ------------ 5. Which item was the most popular for each customer? ------------ --
SELECT
  s.customer_id,
  m.product_name AS most_popular_item
FROM (
  SELECT
    customer_id,
    product_id,
    COUNT(*),
    RANK() OVER (PARTITION BY customer_id ORDER BY COUNT(*) DESC) AS rn
  FROM sales
  GROUP BY customer_id, product_id
) AS s
JOIN menu AS m ON s.product_id = m.product_id
WHERE s.rn = 1
GROUP BY 1
ORDER BY 1
;

-- ------------ 6. Which item was purchased first by the customer after they became a member? ------------ --
SELECT s.customer_id, 
	menu.product_name
FROM sales s
JOIN members m 
ON s.customer_id = m.customer_id
JOIN menu
ON s.product_id = menu.product_id
WHERE m.join_date <= s.order_date
GROUP BY 1
ORDER BY 1;

-- ------------ 7. Which item was purchased just before the customer became a member? ------------ --
SELECT s.customer_id, 
	menu.product_name
FROM sales s
JOIN members m 
ON s.customer_id = m.customer_id
JOIN menu
ON s.product_id = menu.product_id
WHERE m.join_date > s.order_date
GROUP BY 1
ORDER BY 1;

-- ------------ 8. What is the total items and amount spent for each member before they became a member? ------------ --
SELECT s.customer_id,
	COUNT(*) AS total_items, 
	SUM(price) AS amount_spent
FROM sales s
JOIN members m 
ON s.customer_id = m.customer_id
JOIN menu
ON s.product_id = menu.product_id
WHERE m.join_date > s.order_date
GROUP BY 1
ORDER BY 1;

-- ------------ 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have? ------------ --
SELECT s.customer_id,
	SUM(CASE
		 WHEN  product_name = 'sushi' THEN 2*10*price
         ELSE 10*price END) AS total_points
FROM sales s
JOIN menu
ON s.product_id = menu.product_id
GROUP BY 1
ORDER BY 1;	

-- ------------ 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January? ------------ --

SELECT s.customer_id,
	SUM(CASE
		 WHEN  product_name = 'sushi' THEN 2*10*price
         WHEN s.order_date BETWEEN join_date and ADDDATE(join_date,6) THEN 2*10*price
         ELSE 10*price END) AS total_points
FROM sales s
JOIN members m 
ON s.customer_id = m.customer_id
JOIN menu
ON s.product_id = menu.product_id
WHERE MONTH(s.order_date) = 1
GROUP BY 1
ORDER BY 1;
