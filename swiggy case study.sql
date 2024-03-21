create database swiggy;
use swiggy;
-- 1) find the customer who never orderd
SELECT user_id
FROM users
WHERE user_id NOT IN (SELECT user_id FROM orders);

-- 2)avarage price dish
SELECT f.f_name, AVG(m.price) AS avg_price
FROM menu m
JOIN food f ON m.f_id = f.f_id
GROUP BY f.f_name;

-- 3) find the top retorant in terms of no order in terms of given orders

SET SESSION sql_mode = '';
SELECT r.r_name, COUNT(*) AS count
FROM orders o
JOIN restaurants r ON r.r_id = o.r_id
WHERE MONTHNAME(date) LIKE "june"
GROUP BY r.r_id
ORDER BY count DESC
LIMIT 1;

-- 4) resorant with june sales >500 and restorant name wise
select r.r_name,sum(amount) as revenue from orders o 
join restaurants r on o.r_id=r.r_id 
where monthname(date) like 'june'
group by o.r_id having revenue>500;

-- 5)show all order with all order detail for 
-- particular custor for particular data range
SELECT o.order_id, r.r_name, f.f_name
FROM orders o
JOIN restaurants r ON r.r_id = o.r_id
JOIN order_details od ON o.order_id = od.order_id
JOIN food f ON f.f_id = od.f_id
WHERE o.user_id = (SELECT user_id FROM users WHERE name LIKE 'Ankit')
  AND o.date BETWEEN '2022-06-10' AND '2022-07-10';

-- 6)find restaureants with most repeted orders
SELECT r.r_name, COUNT(*) AS 'loyal_customers'
FROM (SELECT r_id, user_id, COUNT(*) AS 'visits'
FROM orders
GROUP BY r_id, user_id
HAVING visits > 1) t
JOIN restaurants r ON r.r_id = t.r_id
GROUP BY t.r_id, r.r_name
ORDER BY loyal_customers DESC
LIMIT 1;

-- 7)month over momth revenue growth of swiggy
select month,((revenue-prev)/prev)*100  as mom_growth from (
with sales as 
(
  select monthname(date) as month,sum(amount) as revenue
from orders
group by month order by month(date))
select month, revenue,lag(revenue,1) over(order by revenue) as prev
 from sales
) t;
-- 8) customers faveriot food
SELECT u.user_id, u.name, f.f_name, COUNT(*) AS order_count
FROM order_details od
JOIN orders o ON od.order_id = o.order_id
JOIN food f ON od.f_id = f.f_id
JOIN users u ON o.user_id = u.user_id
GROUP BY u.user_id, f.f_name
ORDER BY u.user_id, order_count DESC;
-- 9) find most loyel customer for every restaurents
SELECT
  r.r_name AS restaurant_name,
  u.name AS customer_name,
  COUNT(o.order_id) AS order_count
FROM orders o
INNER JOIN users u ON o.user_id = u.user_id
INNER JOIN restaurants r ON o.r_id = r.r_id
GROUP BY r.r_name, u.name
ORDER BY r.r_name, order_count DESC;

-- 10) most paired products orderd by customer
SELECT
    od1.f_id AS product_1_id,
    f1.f_name AS product_1_name,
    od2.f_id AS product_2_id,
    f2.f_name AS product_2_name,
    COUNT(*) AS pair_count
FROM order_details od1
INNER JOIN order_details od2
    ON od1.order_id = od2.order_id
    AND od1.f_id < od2.f_id  -- Avoid duplicate pairs (e.g., (1, 2) and (2, 1))
INNER JOIN food f1 ON od1.f_id = f1.f_id
INNER JOIN food f2 ON od2.f_id = f2.f_id
GROUP BY product_1_id, product_1_name, product_2_id, product_2_name
ORDER BY pair_count DESC;