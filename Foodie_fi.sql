--How many customers has Foodie-Fi ever had?
select count(distinct customer_id)
from subscriptions;

--What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
select count(s.plan_id) soluongplan, extract( month from s.start_date) thang
from plans p
         join  subscriptions s on s.plan_id=p.plan_id
where p.plan_name ='trial'
group by  extract( month from s.start_date)
order by extract( month from s.start_date);

--What is the customer count and percentage of customers who have churned rounded to 1 decimal place
select  year ( s.start_date ), p.plan_name, count(p.plan_name)
from subscriptions s
         left join plans p on p.plan_id=s.plan_id
where year ( s.start_date) > 2020
group by p.plan_name, year(s.start_date);

with table1 as(select count( s.customer_id) soluongcustomer, p.plan_name tenplan
               from subscriptions s
                        left join plans p on p.plan_id=s.plan_id
               where plan_name='churn')
select  round(soluongcustomer/(select count(customer_id) from subscriptions),1)*100 phantram, tenplan, soluongcustomer
from table1;


--How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number
select round((with rp as (with np as (select start_date trialday, customer_id
                                      from subscriptions s
                                               join plans p on p.plan_id=s.plan_id
                                      where p.plan_name='trial'), mp as (select start_date churnday, customer_id
                                                                         from subscriptions s
                                                                                  join plans p on p.plan_id=s.plan_id
                                                                         where p.plan_name='churn')
                          select n.trialday, m.churnday, m.customer_id id
                          from np n
                                   join mp m on m.customer_id=n.customer_id
                          where m.churnday > n.trialday)
              select count(distinct id) soluongchurn
              from rp)/count(distinct customer_id),1)*100 phantram
from subscriptions;





