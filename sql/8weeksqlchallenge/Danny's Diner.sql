-- Create Database 
create database sqlchallenge; 
-- use database 
use sqlchallenge;

-- create sales table
CREATE TABLE sales (
  customer_id VARCHAR(1),
   order_date DATE,
  product_id INT
);

-- insert values into sales table
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
  ('C', '2021-01-07', '3')
  
  -- create menu table
CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

-- insert values into menu table

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
-- create members table
 
CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);


-- insert values into members table
INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
 

-- 1. What is the total amount each customer spent at the restaurant ?
select 
s.customer_id,sum(m.price)
from 
sales s
inner join menu m
on s.product_id =m.product_id
group by s.customer_id;

-- 2. How many days has each customer visited the restaurant ?
select s.customer_id,count(s.order_date)
from 
sales s
group by s.customer_id 

-- 3. What was the first item from the menu purchased by each customer ?

-- Technique 1
select s.customer_id,min(s.order_date),s.product_id,m.product_name 
from 
sales s
inner join menu m 
on s.product_id = m.product_id 
group by s.customer_id 

-- Techique 2
with cte as 
(
select s.customer_id, 
       m.product_name,
       s.order_date,
       row_number() over (partition by customer_id order by order_date) as row_num 
   from sales s
   left join menu m
on s.product_id = m.product_id
order by s.customer_id
)

select customer_id,product_name from cte where row_num = 1


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers ?
with mycte
as 
(   select m.product_name,
	count(s.product_id) as count_sum,
		row_number () over (order by count(s.product_id) desc) row_num
	from sales s 
	left join menu m 
	on s.product_id = m.product_id 
	group by m.product_name 
)

select product_name,count_sum from mycte where row_num =1;


 -- 5. Which item was the most popular for each customer?
with mycte
as
(
	select s.customer_id,m.product_name,
	count(s.product_id) as count_sum,
	 	row_number () over (partition by s.customer_id order by count(s.product_id) desc) as row_num
	from sales s 
	left join menu m 
	on s.product_id = m.product_id 
	group by s.customer_id , m.product_name 
	order by s.customer_id 
 ) 
 
 select customer_id,product_name,count_sum from mycte where row_num=1;
 
-- 6. Which item was purchased first by the customer after they became a member?

with mycte
as 
(
	select s.customer_id,s.order_date,s.product_id,
	m.join_date,
		dense_rank () over (partition by s.customer_id order by s.order_date) d_rank
	from sales s 
	left join members m 
	on s.customer_id = m.customer_id 
	where s.order_date > m.join_date 
	order by s.customer_id ,m.join_date 
) 

select mycte.customer_id,me.product_name,mycte.order_date,mycte.join_date
from mycte
left join menu me 
on mycte.product_id = me.product_id 
where d_rank =1;


-- 7. Which item was purchased just before the customer became a member ?

with mycte2 as 
(
with mycte1 as 
(
	select s.customer_id,s.order_date,s.product_id,me.join_date,m.product_name 
	from sales s 
	left join members me 
	on s.customer_id = me.customer_id 
	left join menu m 
	on s.product_id = m.product_id
	where s.order_date < me.join_date 
)
select customer_id,order_date,product_id,
	join_date,product_name,
		dense_rank () over (partition by customer_id order by order_date desc) d_rank
	from mycte1
)

select customer_id,order_date,product_id,join_date,product_name from mycte2 where d_rank = 1; 


-- 8. What is the total items and amount spent for each member before they became a member?
	select s.customer_id,count(s.product_id) as total_items,sum(m.price) as total_amount 
	from sales s 
	left join members me 
	on s.customer_id = me.customer_id 
	left join menu m 
	on s.product_id = m.product_id
	where s.order_date < me.join_date 
	group by s.customer_id

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

with mycte 
as 
(
select s.customer_id,m.product_name,sum(m.price) as amount_spent
from 
sales s 
left join menu m 
on s.product_id = m.product_id 
group by s.customer_id , m.product_name 
)

select customer_id,
sum(case when product_name = 'sushi' then amount_spent*20 else amount_spent* 10 end) as points 
from mycte 
group by customer_id

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
-- not just sushi - how many points do customer A and B have at the end of January?













