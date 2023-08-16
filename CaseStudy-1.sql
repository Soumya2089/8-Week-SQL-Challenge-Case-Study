/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
SELECT 
	s.customer_id, 
    sum(m.price)
FROM dannys_diner.sales s
JOIN dannys_diner.menu m using(product_id)
GROUP BY s.customer_id;


-- 2. How many days has each customer visited the restaurant?
SELECT 
	s.customer_id, 
    count(s.order_date) As no_of_days
FROM dannys_diner.sales s
GROUP BY s.customer_id;


-- 3. What was the first item from the menu purchased by each customer?
With ranked_sales AS ( 
  SELECT 
	s.customer_id,
    s.product_id,
    m.product_name, 
    RANK () OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS Product_Rank
FROM dannys_diner.sales s
JOIN dannys_diner.menu m ON s.product_id = m.product_id
)
SELECT
	customer_id,
    product_id,
    product_name,
    Product_rank
FROM ranked_sales
WHERE Product_rank = 1;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT 
	m.product_name,
    COUNT(s.order_date) AS Total_Purchases
FROM dannys_diner.menu m
JOIN dannys_diner.sales s ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY COUNT(m.product_name) DESC 
LIMIT 1;


-- 5. Which item was the most popular for each customer?
SELECT 
	s.customer_id,
	m.product_name,
    COUNT(s.order_date) AS Total_Purchases,
    RANK () OVER (PARTITION BY s.customer_id ORDER BY COUNT(s.order_date) DESC) AS Product_Rank
FROM dannys_diner.menu m
JOIN dannys_diner.sales s ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name;


-- 6. Which item was purchased first by the customer after they became a member?
SELECT 
	mem.customer_id,
    mem.join_date,
    m.product_name,
    RANK () OVER (PARTITION BY mem.customer_id ORDER BY mem.join_date DESC) AS join_rank
FROM dannys_diner.members mem
JOIN dannys_diner.sales s ON mem.customer_id = s.customer_id
JOIN dannys_diner.menu m ON s.product_id = m.product_id;


-- 7. Which item was purchased just before the customer became a member?
SELECT
  	s.customer_id,
  	s.order_date,
  	m.product_name,
  	mem.join_date,
  	RANK () OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS purchase_rank
  FROM dannys_diner.sales s
  LEFT JOIN dannys_diner.menu m ON s.product_id = m.product_id
  LEFT JOIN dannys_diner.members mem ON s.customer_id = mem.customer_id
WHERE s.order_date = (
	SELECT
    	MAX(order_date)
    FROM dannys_diner.sales sub
  	WHERE sub.customer_id = s.customer_id AND sub.order_date < mem.join_date);

 

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT
  	s.customer_id,
    COUNT(m.product_name) AS Total_Items,
    SUM(m.price) AS Total_Spent
    FROM dannys_diner.sales s
LEFT JOIN dannys_diner.members mem ON s.customer_id = mem.customer_id 
LEFT JOIN dannys_diner.menu m ON s.product_id = m.product_id
  WHERE s.order_date < mem.join_date
  GROUP BY s.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
           
SELECT
    s.customer_id,
    SUM(
      CASE WHEN m.product_name = 'sushi' THEN m.price * 2 * 10
      ELSE m.price * 10 END) AS Points
FROM dannys_diner.sales s
JOIN dannys_diner.menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;

  
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT
    s.customer_id,
    SUM(
        CASE 
            WHEN s.order_date <= DATE_ADD(mem.join_date, INTERVAL 7 DAY) THEN m.price * 2 * 10
            ELSE m.price * 10
        END
    ) AS Points
FROM dannys_diner.sales s
JOIN dannys_diner.menu m ON s.product_id = m.product_id
JOIN dannys_diner.members mem ON s.customer_id = mem.customer_id
WHERE s.order_date <= '2020-01-31'
GROUP BY s.customer_id;


-- Example Query:
SELECT
  	product_id,
    product_name,
    price
FROM dannys_diner.menu
ORDER BY price DESC
LIMIT 5;



 
