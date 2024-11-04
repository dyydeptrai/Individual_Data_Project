select *
from product_details;
--What was the total quantity sold for all products?
select sum(qty::integer)
from sales;
-- What is the total generated revenue for all products before discounts?
select sum(qty::integer * price::integer)
from sales;

select *
from sales;
-- What was the total discount amount for all products?
select sum(discount/100::numeric * price * qty)
from sales;
-- How many unique transactions were there?
select count(txn_id)::integer, txn_id
from sales
group by txn_id;

-- What is the average unique products purchased in each transaction?
alter table sales
alter column start_txn_time
set data type date using start_txn_time::date;
select avg(count::integer)::numeric, start_txn_time
from (select count(sales.txn_id)::integer count, start_txn_time
      from sales
      group by start_txn_time) as subquery
group by start_txn_time;

-- What is the top selling product for each segment?
select sum(qty), product_name,segment_name
from (
select *
from product_details p
inner join sales s on p.product_id = s.prod_id) as subquery
group by product_name, segment_name
order by 1 DESC;

-- What is the total quantity, revenue and discount for each category?
select sum(qty) quantity
     , sum(qty*price) revenue
     , sum(discount/100::numeric*qty*price) discount
     , category_name
from (select p.price as price, category_name
           , qty
           , discount
    from product_details p
inner join sales s on p.product_id = s.prod_id) as subquery
group by category_name
order by 1 DESC;

-- What is the top selling product for each category?
select sum(qty*price) -sum(discount/100::numeric*qty*price) revenue
     , category_name
     , product_name
from (select p.price as price, category_name, product_name
           , qty
           , discount
      from product_details p
               inner join sales s on p.product_id = s.prod_id) as subquery
group by category_name, product_name
order by 1 DESC;

-- What are the 25th, 50th and 75th percentile values for the revenue per transaction?
with np as (select qty*price revenue, start_txn_time
from (select p.price as price, category_name, product_name
           , start_txn_time
           , qty
           , discount
      from product_details p
               inner join sales s on p.product_id = s.prod_id) as subquery
group by start_txn_time, qty, price)
select percentile_cont(0.25) within group (order by revenue::numeric) q_25,
        percentile_cont(0.5) within group (order by revenue::numeric) median
        ,percentile_cont(0.75) within group (order by revenue::numeric) q_75
     , start_txn_time
from np
group by start_txn_time;
--  What is the average discount value per transaction
select avg(price*qty*discount/100::numeric), start_txn_time
from (select p.price as price, category_name, product_name
           , start_txn_time
           , qty
           , discount
      from product_details p
               inner join sales s on p.product_id = s.prod_id) as subquery
group by start_txn_time
order by 1 DESC;

-- What is the percentage split of all transactions for members vs non-members?
with np as (select count(sales.start_txn_time)::integer total
            from sales), mp as (select count(sales.start_txn_time)::integer count
                                     , member
                                from sales
                                group by member)
select round((count/total::numeric*100)::numeric, 2) percent
     , member
from np
   , mp
group by count
       , total
       , member;
-- What is the average revenue for member transactions and non-member transactions?
with np as(select sum((qty*price*(1-discount/100::numeric))::numeric) total
           from sales)
   , mp as (select sum((qty*price*(1-discount/100::numeric))::numeric) revenue
                                    , member
from sales
group by member)
select round((revenue/total::numeric*100)::numeric, 2), member
from np, mp;

-- What are the top 3 products by total revenue before discount?

with np as (select sum(qty*s.price) total, product_name
            from product_details p
            left join sales s on s.prod_id=p.product_id
            group by product_name), mp as (select  total max
                                           from np
                                           order by 1 DESC
                                           )
select  total, product_name
from np
join mp on np.total=mp.max;


with np as (select dense_rank() over (order by sum(qty*s.price) DESC) ranking
                 , product_name
                 , sum(qty*s.price) revenue
from product_details p
inner join sales s on p.product_id = s.prod_id
group by product_name)
select product_name, revenue, ranking
from np
where ranking <=3;

-- What is the total quantity, revenue and discount for each segment?
select sum(qty), sum(qty*p.price), sum(qty*p.price*discount/100::numeric), segment_name
from product_details p
inner join sales s on p.product_id = s.prod_id
group by segment_name;

--What is the top selling product for each segment?
select dense_rank() over (order by sum(qty) DESC), segment_name, sum(qty)
from product_details p
inner join sales s on p.product_id = s.prod_id
group by segment_name;
--What is the total quantity, revenue and discount for each category?
select  category_name, sum(qty), sum(qty*price)
from product_details p
     inner join sales s on p.product_id = s.prod_id
group by category_name;

--What is the top selling product for each category?
select sum(qty), category_name
from product_details p
inner join sales on p.product_id = sales.prod_id
group by category_name;

-- What is the percentage split of revenue by product for each segment?
with np as (select sum(qty*p.price*(1-discount/100::numeric)) total
                   from product_details p
                   inner join sales s on p.product_id=s.prod_id
                   )
   , mp as (select sum(qty*p.price*(1-discount/100::numeric)) revenue,segment_name
                             from product_details p
                                      inner join sales s on p.product_id=s.prod_id
                             group by segment_name)
select round((revenue/total::numeric*100)::numeric, 2)
     , segment_name
from np
   , mp;

-- What is the percentage split of revenue by segment for each category?
select sum(qty*p.price*(1-discount/100::numeric)), segment_name, category_name
from product_details p
inner join sales s on s.prod_id=p.product_id
group by segment_name, category_name;

with np as (select sum(qty*p.price*(1-discount/100::numeric)) total
                 , category_name
from product_details p
inner join sales s on s.prod_id=p.product_id
group by category_name)
   , mp as (select sum(qty*p.price*(1-discount/100::numeric)) revenue
                 , segment_name
                 , category_name
            from product_details p
            inner join sales s on s.prod_id=p.product_id
            group by segment_name, category_name)
select round((revenue/total::numeric*100)::numeric,2)
     , mp.segment_name
     , mp.category_name
from np
join mp on np.category_name=mp.category_name;

-- What is the percentage split of revenue by product for each segment?
with np as (select sum(qty*p.price*(1-discount/100::numeric)) total
                 , segment_name
            from product_details p
            inner join sales s on s.prod_id=p.product_id
            group by segment_name),
    mp as (select sum(qty*p.price*(1-discount/100::numeric)) revenue
                , segment_name
                , product_name
           from product_details p
           inner join sales s on p.product_id = s.prod_id
           group by segment_name, product_name)
select round((revenue/total::numeric*100)::numeric, 2), mp.segment_name, mp.product_name
from np
join mp on np.segment_name=mp.segment_name;

--What is the percentage split of total revenue by category?
with np as (select sum(qty*p.price*(1-discount/100::numeric)) total
            from product_details p
            inner join sales s on s.prod_id=p.product_id),
    mp as (select sum(qty*p.price*(1-discount/100::numeric)) revenue, category_name
from product_details p
inner join sales s on s.prod_id=p.product_id
group by category_name)
select round((revenue/total::numeric*100)::numeric, 2), category_name
from np, mp;
-- What is the total transaction “penetration” for each product?
-- (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
with np as (select count(start_txn_time) count, product_name
from product_details p
inner join sales s on s.prod_id=p.product_id
where qty >=1
group by product_name)
   , mp as (select count(start_txn_time) total
            from product_details p
            inner join sales s on s.prod_id=p.product_id)
select round((count/total::numeric*100)::numeric, 2), product_name
from np, mp;

-- What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
with np as (select *
from product_details p
inner join sales s on p.product_id = s.prod_id)
select start_txn_time, product_name, sum(qty)
from np
group by start_txn_time, product_name;

select *
from product_prices pp
join product_hierarchy ph on pp.id=ph.id;


-- Bonus challenge
select *
from crosstab('select level_name, level_text
              from product_prices') as ct(category_name, segment_name, style_name);
CREATE EXTENSION IF NOT EXISTS tablefunc;
SELECT *
FROM crosstab(
             'SELECT id, level_name, level_text
              FROM product_hierarchy

            '
     ) AS ct(id int, category_name varchar(19), segment_name varchar(19), style_name varchar(19));

with np as (select level_text, level_name, id
            from product_hierarchy
            where level_text='Category')
select *
from crosstab('select id, level_text, level_name' ||
              'from np') as ct(id int, category_name;

with np as (select level_text, id, level_name
from product_hierarchy
where level_name='Category')
select *
from crosstab('select id, level_text, level_name ||
              from np
              order by 1,2') as ct(id int, category_name varchar(8), other_column varchar(8));

select *
from crosstab('select level_text, level_name, id from product_hierarchy order by 1,2')
as ct(category_name varchar(19), segment_name varchar(19), style_name varchar(19), id int)

with cte as (with product_detail2 as
    (with np as
        (select level_text Category_name
                      , id Category_id
            from product_hierarchy
            where level_name='Category')
   , mp as(select level_text Segment_name
                , id Segment_id
             from product_hierarchy
            where level_name='Segment')
   , kp as (select level_text Style_name
                 , id Style_id
            from product_hierarchy
            where level_name='Style')
select Category_name
     , Segment_name
     , Style_name, Category_id
     , Segment_id
     , Style_id
from np
   , mp
   , kp)
select *
from product_prices pp
inner join product_detail2 pd on pp.id= pd.Style_id)
select *
from cte
where case when category_id = 1 and segment_id = 3 then style_id in (7,8,9)
           when category_id = 1 and segment_id =4 then style_id in (10,11,12)
           when category_id = 2 and segment_id = 5 then style_id in (13,14,15)
           when category_id = 2 and segment_id = 6 then style_id in (16,17,18)
           else null
          end ;






