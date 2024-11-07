CREATE SCHEMA dannys_diner;


CREATE TABLE sales (
                       "customer_id" VARCHAR(1),
                       "order_date" DATE,
                       "product_id" INTEGER
);

INSERT INTO sales
("customer_id", "order_date", "product_id")
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
                      "product_id" INTEGER,
                      "product_name" VARCHAR(5),
                      "price" INTEGER
);

INSERT INTO menu
("product_id", "product_name", "price")
VALUES
    ('1', 'sushi', '10'),
    ('2', 'curry', '15'),
    ('3', 'ramen', '12');


CREATE TABLE members (
                         "customer_id" VARCHAR(1),
                         "join_date" DATE
);

INSERT INTO members
("customer_id", "join_date")
VALUES
    ('A', '2021-01-07'),
    ('B', '2021-01-09');

--What is the total amount each customer spent at the restaurant?
with np as (select count(s.product_id) soluong, n.product_name
            from sales s
                     join menu n on s.product_id=n.product_id
            group by s.product_id, n.product_name), mp as (select max(soluong) as max
                                                           from np)
select mp.max, np.product_name
from np
         join mp on np.soluong=mp.max;

--How many days has each customer visited the restaurant?
select count(distinct order_date) songay, customer_id
from sales
group by customer_id;

--What was the first item from the menu purchased by each customer?
select m.product_name, s.order_date
from menu m
         left join sales s on s.product_id=m.product_id
where s.order_date ='2021-01-01';

--What is the most purchased item on the menu and how many times was it purchased by all customers?
select m.product_name, count(s.product_id)
from menu m
         left join sales s on s.product_id=m.product_id
group by m.product_name;

with np as (select m.product_name, count(s.product_id) soluong
            from menu m
                     left join sales s on s.product_id=m.product_id
            group by m.product_name),  mp as (select max(soluong) max
                                              from np)
select np.soluong, np.product_name
from np
         join mp on np.soluong=mp.max;

--Which item was the most popular for each customer?
with np as (select m.product_name, count(s.product_id) soluong, s.customer_id
            from menu m
                     left join sales s on s.product_id=m.product_id
            group by s.customer_id, m.product_name), mp as (select max(soluong) max
                                                            from np
)
select np.soluong, np.customer_id, np.product_name
from np
         join mp on np.soluong=mp.max
group by np.customer_id, np.soluong, np.product_name;

--Which item was purchased first by the customer after they became a member?
with np as (select m.product_name, s.order_date date
            from members ms
                     left join sales s on ms.customer_id=s.customer_id
                     left join menu m on m.product_id=s.product_id
            where  s.order_date > ms.join_date
            group by m.product_name, s.order_date), mp as (select min(date) mindate
                                                           from np)
select np.date, np.product_name
from np
         join mp on np.date=mp.mindate;

--Which item was purchased just before the customer became a member?
select m.product_name, s.order_date date
from members ms
         left join sales s on ms.customer_id=s.customer_id
         left join menu m on m.product_id=s.product_id
where  s.order_date <= ms.join_date
group by m.product_name, s.order_date;

--What is the total items and amount spent for each member before they became a member?
select count(m.product_name) total, s.order_date date, m.product_name, count(m.product_name)*m.price amount
from members ms
         left join sales s on ms.customer_id=s.customer_id
         left join menu m on m.product_id=s.product_id
where  s.order_date <= ms.join_date
group by m.product_name, s.order_date, m.price;
-----------------------------------------------------------------------
select count(m.product_name) total, m.product_name, count(m.product_name)*m.price amount
from members ms
         left join sales s on ms.customer_id=s.customer_id
         left join menu m on m.product_id=s.product_id
where  s.order_date <= ms.join_date
group by m.product_name, m.price;

--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have
select  customer_id, product_name,
        sum( case when product_name ='sushi' then price*2*10
                  else price*10
            end ) as points
from sales s
         left join menu m on m.product_id=s.product_id
group by customer_id, product_name;

--In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
select ms.customer_id,
       sum(case when s.order_date between ms.join_date and ms.join_date + interval'7days' then price*2*10
                else price*10
           end ) points
from members ms
         left join sales s on s.customer_id=ms.customer_id
         left join menu m on m.product_id=s.product_id
where ms.customer_id in ('A', 'B')
group by  ms.customer_id;




