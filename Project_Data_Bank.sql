--How many unique nodes are there on the Data Bank system?
select node_id, count(node_id)
from customer_nodes
group by node_id;
--What is the number of nodes per region?
select count(node_id) SoNodes, region_id
from customer_nodes
group by region_id;
--How many customers are allocated to each region?
select count(customer_id) SoNguoi, region_id
from customer_nodes
group by region_id;


--How many days on average are customers reallocated to a different node?
select avg(extract(day from( end_date-start_date)))from customer_nodes
where customer_id = 1;

SELECT
    a.customer_id,
    a.start_date AS start_date_a,
    a.end_date AS end_date_a,
    b.start_date AS start_date_b,
    b.end_date AS end_date_b,
    avg((b.start_date - a.start_date)) AS avg_start_date_difference,
    avg((b.end_date - a.end_date)) AS avg_end_date_difference
FROM
    customer_nodes a
        JOIN
    customer_nodes b
    ON
        a.customer_id = b.customer_id
            AND a.node_id < b.node_id
group by a.customer_id, a.start_date, a.end_date, b.start_date, b.end_date;


select a.start_date,
       a.end_date,
       b.start_date,
       b.end_date,
       a.customer_id,
       b.customer_id
from customer_nodes a
join customer_nodes b on a.customer_id=b.customer_id;
--What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

SELECT
    a.customer_id,
    a.start_date AS start_date_a,
    a.end_date AS end_date_a,
    b.start_date AS start_date_b,
    b.end_date AS end_date_b,
    avg((b.start_date - a.start_date)) AS avg_start_date_difference,
    avg((b.end_date - a.end_date)) AS avg_end_date_difference
FROM
    customer_nodes a
        JOIN
    customer_nodes b
    ON
        a.customer_id = b.customer_id
            AND a.node_id < b.node_id
group by a.customer_id, a.start_date, a.end_date, b.start_date, b.end_date;

select avg(end_date-start_date),
    percentile_cont(0.8) within group (order by end_date - start_date),
       percentile_cont(0.95) within group (order by end_date - start_date)
from customer_nodes;

--What is the unique count and total amount for each transaction type?
    select count(txn_type), sum(txn_amount), txn_type
    from customer_transactions
    group by txn_type;

--What is the average total historical deposit counts and amounts for all customers?
with np as (select count(customer_transactions.txn_type) a, sum(txn_amount) b, customer_id c, txn_type d
    from customer_transactions
        where txn_type = 'deposit'
group by customer_id, txn_type)
select avg(a), avg(b), c, d
from np
group by c, d;
--For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
  select count(customer_id) a, count(txn_type) b, extract(month from txn_date)
    from customer_transactions
    where txn_type = 'deposit' and txn_type ='purchase' or txn_type='withdrawal'
  group by extract(month from txn_date);

--What is the closing balance for each customer at the end of the month?
with np as  (select sum(txn_amount) p, extract(month from txn_date) e
from customer_transactions
where txn_type ='purchase'
group by extract(month from txn_date)), mp as (select sum(txn_amount) d, extract(month from txn_date) e
                               from customer_transactions where txn_type ='deposit'
                                                          group by extract(month from txn_date)),
    kp as (select sum(customer_transactions.txn_amount) w, extract(month from txn_date) e
        from customer_transactions
            where txn_type='withdrawal'
                group by extract(month from txn_date))
               select to_char((m.d - n.p-k.w), '999G999D99')||'VND' tien_con_lai, concat(N'tháng',' ',m.e) thang, m.d
           from mp m
               join np n on m.e=n.e
               join kp k on k.e=m.e;

select sum(txn_amount) p, extract(month from txn_date) e
from customer_transactions
where txn_type ='purchase'
group by extract(month from txn_date);

select sum(txn_amount) d, extract(month from txn_date) e
from customer_transactions where txn_type ='deposit'
group by extract(month from txn_date);

--c2
 select    (select sum(customer_transactions.txn_amount)
    from customer_transactions
    where txn_type='deposit'
    group by extract(month from txn_date))-(select sum(txn_amount)
    from customer_transactions
    where txn_type ='purchase'
    group by extract(month from txn_date))
 from customer_transactions
;

select to_char(sum(customer_transactions.txn_amount),'999G999D99')|| 'VND'
from customer_transactions
where txn_type ='withdrawals';
update customer_transactions
set txn_amount=coalesce(txn_amount,0) where txn_type='withdrawals';

--What is the percentage of customers who increase their closing balance by more than 5%?
with a as (with np as  (select sum(txn_amount) p, extract(month from txn_date) e, count(customer_id) x, customer_id
             from customer_transactions
             where txn_type ='purchase'
             group by extract(month from txn_date), customer_id),
    mp as (select sum(txn_amount) d, extract(month from txn_date) e, count(customer_id) y, customer_id
                                                            from customer_transactions where txn_type ='deposit'
                                                            group by extract(month from txn_date), customer_id),
     kp as (select sum(customer_transactions.txn_amount) w, extract(month from txn_date) e, count(customer_id) z, customer_id
            from customer_transactions
            where txn_type='withdrawal'
            group by extract(month from txn_date), customer_id)
select (m.d - n.p-k.w) tien_con_lai, m.e thang, m.d tongtien, m.y soluong, m.customer_id id
from mp m
         join np n on m.e=n.e
         join kp k on k.e=m.e),
    b as (select count(customer_id) h, extract(month from txn_date) e
          from customer_transactions
          group by extract(month from txn_date))
select (a.tien_con_lai::float/a.tongtien::float)*100 phan_tram_balance , (a.soluong::float/b.h::float)*100 phan_tram_nguoi, a.id
from a
join b on a.thang=b.e
where (a.tien_con_lai::float/a.tongtien::float)*100 >5;

--To test out a few different hypotheses - the Data Bank team wants to run an experiment
-- where different groups of customers would be allocated data using 3 different options:

--Option 1: data is allocated based off the amount of money at the end of the previous month
select
       a.customer_id,
       a.node_id,
       b.node_id,
       a.start_date begin1,
       b.start_date begin2,
       extract(month from a.end_date ) end1,
       extract(month from b.end_date) end2,
       a.region_id,
       r.region_name,
       ct.txn_type,
       ct.txn_amount,
       ct.txn_date
from customer_nodes a
join customer_nodes b on a.customer_id=b.customer_id
inner join regions r on r.region_id=a.region_id
inner join customer_transactions ct on ct.customer_id=a.customer_id;
--Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
select
    a.customer_id,
    a.node_id,
    b.node_id,
    a.start_date begin1,
    b.start_date begin2,
    a.end_date  end1,
    b.end_date end2,
    a.region_id,
    r.region_name,
    ct.txn_type,
    ct.txn_amount,
    ct.txn_date
from customer_nodes a
         join customer_nodes b on a.customer_id=b.customer_id
         inner join regions r on r.region_id=a.region_id
         inner join customer_transactions ct on ct.customer_id=a.customer_id;
--Option 3: data is updated real-time
select
    a.customer_id,
    a.node_id,
    b.node_id,
    a.start_date begin1,
    b.start_date begin2,
    a.end_date  end1,
    b.end_date end2,
    a.region_id,
    r.region_name,
    ct.txn_type,
    ct.txn_amount,
    ct.txn_date
from customer_nodes a
         join customer_nodes b on a.customer_id=b.customer_id
         inner join regions r on r.region_id=a.region_id
         inner join customer_transactions ct on ct.customer_id=a.customer_id
where a.last_update = now() - interval  '1 minute' ;
--For this multi-part challenge question - you\ have been requested to generate the following data elements
-- to help the Data Bank team estimate how much data will need to be provisioned for each option:
--running customer balance column that includes the impact each transaction
--customer balance at the end of each month
--minimum, average and maximum values of the running balance for each customer
--Using all of the data available - how much data would have been required for each option on a monthly basis?

alter table customer_transactions
add factors varchar(255);

update  customer_transactions
set factors =(with np as  (select sum(txn_amount) p, extract(month from txn_date) e
                            from customer_transactions
                            where txn_type ='purchase'
                            group by extract(month from txn_date)), mp as (select sum(txn_amount) d, extract(month from txn_date) e
                                                                           from customer_transactions where txn_type ='deposit'
                                                                           group by extract(month from txn_date)),
                    kp as (select sum(customer_transactions.txn_amount) w, extract(month from txn_date) e
                           from customer_transactions
                           where txn_type='withdrawal'
                           group by extract(month from txn_date))
               select to_char((m.d - n.p-k.w), '999G999D99')||'VND' tien_con_lai
               from mp m
                        join np n on m.e=n.e
                        join kp k on k.e=m.e)
where factors is null;

with np as  (select sum(txn_amount) p, extract(month from txn_date) e
             from customer_transactions
             where txn_type ='purchase'
             group by extract(month from txn_date)), mp as (select sum(txn_amount) d, extract(month from txn_date) e
                                                            from customer_transactions where txn_type ='deposit'
                                                            group by extract(month from txn_date)),
     kp as (select sum(customer_transactions.txn_amount) w, extract(month from txn_date) e
            from customer_transactions
            where txn_type='withdrawal'
            group by extract(month from txn_date))
update customer_transactions
set factors = (select to_char((m.d - n.p-k.w), '999G999D99')||'VND'
               from mp m
                        join np n on m.e=n.e
                        join kp k on k.e=m.e)
where extract(month from customer_transactions.txn_date) = (select e from mp limit 1);



alter table customer_transactions
drop column factors;


WITH
    np AS (
        SELECT sum(txn_amount) p, extract(month FROM txn_date) e
        FROM customer_transactions
        WHERE txn_type = 'purchase'
        GROUP BY extract(month FROM txn_date)
    ),
    mp AS (
        SELECT sum(txn_amount) d, extract(month FROM txn_date) e
        FROM customer_transactions
        WHERE txn_type = 'deposit'
        GROUP BY extract(month FROM txn_date)
    ),
    kp AS (
        SELECT sum(txn_amount) w, extract(month FROM txn_date) e
        FROM customer_transactions
        WHERE txn_type = 'withdrawal'
        GROUP BY extract(month FROM txn_date)
    )
UPDATE customer_transactions ct
SET factors = (
    SELECT to_char((m.d - n.p - k.w), '999G999D99') || ' VND'
    FROM mp m
             JOIN np n ON m.e = n.e
             JOIN kp k ON k.e = m.e
)
WHERE extract(month FROM ct.txn_date) = (
    SELECT e FROM mp LIMIT 1
);


WITH
    np AS (
        SELECT customer_id, sum(txn_amount) p, extract(month FROM txn_date) e
        FROM customer_transactions
        WHERE txn_type = 'purchase'
        GROUP BY customer_id, extract(month FROM txn_date)
    ),
    mp AS (
        SELECT customer_id, sum(txn_amount) d, extract(month FROM txn_date) e
        FROM customer_transactions
        WHERE txn_type = 'deposit'
        GROUP BY customer_id, extract(month FROM txn_date)
    ),
    kp AS (
        SELECT customer_id, sum(txn_amount) w, extract(month FROM txn_date) e
        WHERE txn_type = 'withdrawal'
        GROUP BY customer_id, extract(month FROM txn_date)
    )
UPDATE customer_transactions ct
SET factors = (
    SELECT to_char((m.d - n.p - k.w), '999G999D99') || ' VND'
    FROM mp m
             JOIN np n ON m.customer_id = n.customer_id AND m.e = n.e
             JOIN kp k ON k.customer_id = m.customer_id AND k.e = m.e
    WHERE m.customer_id = ct.customer_id
      AND m.e = extract(month FROM ct.txn_date)
)
WHERE EXISTS (
    SELECT 1
    FROM mp m
             JOIN np n ON m.customer_id = n.customer_id AND m.e = n.e
             JOIN kp k ON k.customer_id = m.customer_id AND k.e = m.e
    WHERE m.customer_id = ct.customer_id
      AND m.e = extract(month FROM ct.txn_date)
);

create table factors (
    so_du numeric,
    anh_huong numeric,
    trung_binh_so_du numeric,
    toi_thieu numeric,
    toi_da numeric
);

truncate table factors;
with np as  (select sum(txn_amount) p, extract(month from txn_date) e, customer_id c
             from customer_transactions
             where txn_type ='purchase'
             group by extract(month from txn_date), customer_id), mp as (select sum(txn_amount) d, extract(month from txn_date) e, customer_id c
                                                                         from customer_transactions where txn_type ='deposit'
                                                                         group by extract(month from txn_date), customer_id),
     kp as (select sum(customer_transactions.txn_amount) w, extract(month from txn_date) e, customer_id c
            from customer_transactions
            where txn_type='withdrawal'
            group by extract(month from txn_date), customer_id)
insert into factors(so_du)
 select to_char((m.d - n.p-k.w), '999G999D99')||'VND'
             from mp m
                      join np n on m.e=n.e
                      join kp k on k.e=m.e;

with np as  (select sum(txn_amount) p, extract(month from txn_date) e, customer_id c
             from customer_transactions
             where txn_type ='purchase'
             group by extract(month from txn_date), customer_id), mp as (select sum(txn_amount) d, extract(month from txn_date) e, customer_id c
                                                                         from customer_transactions where txn_type ='deposit'
                                                                         group by extract(month from txn_date), customer_id),
     kp as (select sum(customer_transactions.txn_amount) w, extract(month from txn_date) e, customer_id c
            from customer_transactions
            where txn_type='withdrawal'
            group by extract(month from txn_date), customer_id)
insert into factors(id)
select m.c
from mp m
         join np n on m.e=n.e
         join kp k on k.e=m.e;

alter table factors
add id integer;

with np as  (select sum(txn_amount) p, extract(month from txn_date) e, customer_id c
             from customer_transactions
             where txn_type ='purchase'
             group by extract(month from txn_date), customer_id),
    mp as (select sum(txn_amount) d, extract(month from txn_date) e, customer_id c
                                                                         from customer_transactions where txn_type ='deposit'
                                                                         group by extract(month from txn_date), customer_id),
     kp as (select sum(customer_transactions.txn_amount) w, extract(month from txn_date) e, customer_id c
            from customer_transactions
            where txn_type='withdrawal'
            group by extract(month from txn_date), customer_id)
insert into factors(so_du)
select (m.d - n.p-k.w)
from mp m
         join np n on m.e=n.e and m.c=n.c
         join kp k on k.e=m.e and k.c=m.c;

select coalesce(id, 0),
       coalesce(so_du, 0),
     coalesce(trung_binh_so_du,0),
       coalesce(toi_thieu, 0),
       coalesce(toi_da, 0),
       coalesce(id,0)
from factors;

\d factors;
alter table factors
drop column trung_binh_so_du;

alter table factors
add column trung_binh_so_du numeric;

with np as  (select sum(txn_amount) p, extract(month from txn_date) e, customer_id c
             from customer_transactions
             where txn_type ='purchase'
             group by extract(month from txn_date), customer_id),
     mp as (select sum(txn_amount) d, extract(month from txn_date) e, customer_id c
            from customer_transactions where txn_type ='deposit'
            group by extract(month from txn_date), customer_id),
     kp as (select sum(customer_transactions.txn_amount) w, extract(month from txn_date) e, customer_id c
            from customer_transactions
            where txn_type='withdrawal'
            group by extract(month from txn_date), customer_id)
select (m.d - n.p-k.w)
from mp m
         join np n on m.e=n.e and m.c=n.c
         join kp k on k.e=m.e and k.c=m.c;

select *,case
    when factors.so_du is null then 0
when id is null then 0
when factors.trung_binh_so_du is null then 0
when toi_da is null then 0
when toi_thieu is null then 0
else  null
end
from factors;
select * from factors;

select coalesce(id,0)
from factors;

with np as  (select sum(txn_amount) p, extract(month from txn_date) e, customer_id c
             from customer_transactions
             where txn_type ='purchase'
             group by extract(month from txn_date), customer_id),
     mp as (select sum(txn_amount) d, extract(month from txn_date) e, customer_id c
            from customer_transactions where txn_type ='deposit'
            group by extract(month from txn_date), customer_id),
     kp as (select sum(customer_transactions.txn_amount) w, extract(month from txn_date) e, customer_id c
            from customer_transactions
            where txn_type='withdrawal'
            group by extract(month from txn_date), customer_id)
insert into factors(trung_binh_so_du)
select avg((m.d - n.p-k.w))
from mp m
         join np n on m.e=n.e and m.c=n.c
         join kp k on k.e=m.e and k.c=m.c
group by m.e, m.c;

select factors.trung_binh_so_du
from factors;

with np as  (select sum(txn_amount) p, extract(month from txn_date) e, customer_id c
             from customer_transactions
             where txn_type ='purchase'
             group by extract(month from txn_date), customer_id),
     mp as (select sum(txn_amount) d, extract(month from txn_date) e, customer_id c
            from customer_transactions where txn_type ='deposit'
            group by extract(month from txn_date), customer_id),
     kp as (select sum(customer_transactions.txn_amount) w, extract(month from txn_date) e, customer_id c
            from customer_transactions
            where txn_type='withdrawal'
            group by extract(month from txn_date), customer_id)
insert into factors(toi_da)
select max((m.d - n.p-k.w))
from mp m
         join np n on m.e=n.e and m.c=n.c
         join kp k on k.e=m.e and k.c=m.c
group by m.e,m.c;

with np as  (select sum(txn_amount) p, extract(month from txn_date) e, customer_id c
             from customer_transactions
             where txn_type ='purchase'
             group by extract(month from txn_date), customer_id),
     mp as (select sum(txn_amount) d, extract(month from txn_date) e, customer_id c
            from customer_transactions where txn_type ='deposit'
            group by extract(month from txn_date), customer_id),
     kp as (select sum(customer_transactions.txn_amount) w, extract(month from txn_date) e, customer_id c
            from customer_transactions
            where txn_type='withdrawal'
            group by extract(month from txn_date), customer_id)
insert into factors(toi_thieu)
select min((m.d - n.p-k.w))
from mp m
         join np n on m.e=n.e and m.c=n.c
         join kp k on k.e=m.e and k.c=m.c
group by m.e,m.c;

select factors.trung_binh_so_du, factors.toi_thieu, factors.toi_da
from factors
where factors.toi_thieu is not null or trung_binh_so_du is not null or toi_da is not null;

select a.trung_binh_so_du,
       a.id,
       a.toi_thieu,
       a.toi_da,
       b.id,
       b.trung_binh_so_du,
       b.toi_thieu,
       b.toi_da
from factors a
join factors b on a.id=b.id;

with np as  (select sum(txn_amount) p, extract(month from txn_date) e, customer_id c
             from customer_transactions
             where txn_type ='purchase'
             group by extract(month from txn_date), customer_id),
     mp as (select sum(txn_amount) d, extract(month from txn_date) e, customer_id c
            from customer_transactions where txn_type ='deposit'
            group by extract(month from txn_date), customer_id),
     kp as (select sum(customer_transactions.txn_amount) w, extract(month from txn_date) e, customer_id c
            from customer_transactions
            where txn_type='withdrawal'
            group by extract(month from txn_date), customer_id)
INSERT INTO factors(id, so_du, toi_thieu, trung_binh_so_du, toi_da)
SELECT
    m.c,                             -- customer_id hoặc id tương ứng
    (m.d-n.p-k.w),                            -- Giá trị `so_du`, nếu bạn không có dữ liệu ngay lập tức
    MIN(m.d - n.p - k.w),            -- Giá trị tối thiểu `toi_thieu`
    AVG(m.d - n.p - k.w),
    max(m.d-n.p-k.w)-- Giá trị trung bình `trung_binh_so_du`
FROM mp m
         JOIN np n ON m.e = n.e AND m.c = n.c
         JOIN kp k ON k.e = m.e AND k.c = m.c
GROUP BY m.c, m.e, (m.d-n.p-k.w);


create table laisuat (
    lai float,
    so_du_dau_ky numeric,
    so_du_cuoi_ky numeric,
    thoi_gian_lai int
);
insert into laisuat(la)
values (0.06)
with np as  (select sum(txn_amount) p, extract(month from txn_date) e, customer_id c
             from customer_transactions
             where txn_type ='purchase'
             group by extract(month from txn_date), customer_id),
     mp as (select sum(txn_amount) d, extract(month from txn_date) e, customer_id c
            from customer_transactions where txn_type ='deposit'
            group by extract(month from txn_date), customer_id),
     kp as (select sum(customer_transactions.txn_amount) w, extract(month from txn_date) e, customer_id c
            from customer_transactions
            where txn_type='withdrawal'
            group by extract(month from txn_date), customer_id)
INSERT INTO laisuat(thoi_gian_lai, so_du_dau_ky)
SELECT
    m.e,
    (m.d-n.p-k.w)
FROM mp m
         JOIN np n ON m.e = n.e AND m.c = n.c
         JOIN kp k ON k.e = m.e AND k.c = m.c
where (m.d-n.p-k.w) >0
GROUP BY m.c, m.e, (m.d-n.p-k.w);

update laisuat
set lai = 0.06/12 where lai is null;

truncate laisuat;

select *
from customer_nodes n
inner join customer_transactions t on n.customer_id=t.customer_id
inner join factors f on f.id=n.customer_id;




















