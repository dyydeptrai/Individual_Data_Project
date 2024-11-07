--câu 1
--A
select * from supermarket_sales;
select count("Invoice_ID") total_orders from supermarket_sales;
--B
alter table supermarket_sales
alter column quantity
set Data type integer
using quantity::integer;

alter table supermarket_sales
    alter column quantity
        set Data type integer
        using quantity::integer;
alter table supermarket_sales
rename "Unit price" to "Unit_price";

alter table supermarket_sales
add column Sales float;
update supermarket_sales
set sales = null;

update supermarket_sales
set sales=round(("Unit_price" * quantity)::numeric,2)
where sales is null;
alter table supermarket_sales
rename "Product line" to "Product_line";

select  round(sum(sales)::numeric, 2)  Totalsales, branch  from supermarket_sales
group by branch;
--Câu 2
--A

select "Product_line", round(sum(sales)::numeric, 2) total_sales, count("Invoice_ID") total_orders
from supermarket_sales
group by "Product_line";
--B
select "Product_line", "Customer type"
     , round(sum(sales)::numeric, 2) total_sales
     , count("Invoice_ID") total_orders
     , sum(quantity) total_quantity
from supermarket_sales
group by "Product_line", "Customer type";
--Câu 3
--A
alter table supermarket_sales
alter column time
set data type time
using time::time;

alter table supermarket_sales
alter column date
set data type date
using date::date;

with mp as (select extract(hour from time) as hour, count("Invoice_ID") total_order
                       from supermarket_sales
                       group by extract(hour from time) , extract(month from date))
select max(total_order) max, hour
from mp
group by hour;
--B

with np as (select round(sum(sales)::numeric, 2) as totalsales, count("Invoice_ID") totalorder, "Customer type", "Product_line"
            from supermarket_sales
            group by "Customer type", "Product_line")
select totalsales, totalorder, "Customer type", "Product_line"
from np
where totalsales > (select MIN(totalsales) from np) and totalorder = (select min(totalorder) from np);

--Câu 4

with np as (select round(sum(sales)::numeric, 2) as totalsales, count("Invoice_ID") totalorder, extract(month from date) as month
from supermarket_sales
group by extract(month from date)), mp as (select round(sum(sales)::numeric, 2) as totalsalesbefore, count("Invoice_ID") totalorderbefore, extract(month from date) + 1 as month
                                           from supermarket_sales
                                           group by extract(month from date)+1)
select totalsales, totalorder, np.month, totalsalesbefore, totalorderbefore
from np
left join mp on np.month=mp.month;



