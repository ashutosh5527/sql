-- Creating Dabase Structure --

create database fnp_sales_data;

use fnp_sales_data;

create table customers(
	customer_id varchar(5) primary key,
    customer_name varchar(50) not null,
    city varchar(50) not null,
    contact_number varchar(15) not null,
    email_id varchar(100) not null,
    gender varchar(10) not null,
    address varchar(200) not null
);

create table products(
	product_id int primary key,
    product_name varchar(50) not null,
    category varchar(50) not null,
    price int not null,
    occasion varchar(30) not null
);

create table orders(
	order_id int primary key,
    customer_id varchar(5) not null,
    product_id int not null,
    quantity int not null,
    order_date varchar(15) not null,
    order_time time not null,
    delivery_date varchar(15) not null,
    delivery_time time not null,
    location varchar(50) not null,
    occasion varchar(30) not null,
    foreign key(customer_id) references customers(customer_id),
    foreign key(product_id) references products(product_id)
);

-- Quering the tables

select * from customers;

select * from products;

select * from orders;


-- Transforming Data
 #### ismein ham  order_date changekiye hai

-- new column add kr rahe hai purni column ke bgl mein
alter table orders add column order_date2 date  after order_date;

-- aba new column mein value put kre ge 
update orders set order_date2 = str_to_date(order_date , '%d-%m-%Y');

-- pahle wali column delete 
alter table orders
drop column order_date;

-- new bane hue table ko remane 
alter table orders rename column order_date2 to order_date;

 #### ismein ham  order_date changekiye hai




 ## ismein ham delivery_date ko change kre ge 

alter table orders add column delivery_date2 date after delivery_date;
update orders set delivery_date2 = str_to_date(delivery_date , '%d-%m-%Y');

alter table orders
drop column delivery_date;

alter table orders rename column delivery_date2 to delivery_date;

## ismein ham delivery_date ko change kre ge 

select * from orders;

alter table orders add column total_amount float;
update
products join orders on products.product_id = orders.product_id
set  orders.total_amount = products.price * orders.quantity;

-- Answers to find

# Q1. Find the total revenue generated across all the products.
    
SELECT 
    SUM(products.price * orders.quantity) AS 'total revenue generated'
FROM
    products
        JOIN
    orders ON products.product_id = orders.product_id;
              
# Q2. Find the average of customers spending on products.
	SELECT 
    ROUND(AVG(products.price * orders.quantity), 2) AS 'avge custum spending'
FROM
    products
        JOIN
    orders ON products.product_id = orders.product_id;
    
# Q3. Calculate the average time taken in days for orders to deliver.

    select
   round(avg( datediff(delivery_date , order_date)),2) as "time taken to deliver in avg "
    from 
    orders;
    
# Q4. List total revenue generated month by month.

      SELECT 
      month(order_date) as "order month",
    MONTHNAME(order_date) AS 'month name',
    SUM(total_amount) AS 'total amount'
FROM
    orders
GROUP BY MONTHNAME(order_date) , month(order_date)
order by  month(order_date);



--  --  SELECT 
-- --       month(order_date) as "order month",
-- --     MONTHNAME(order_date) AS 'month name',
-- --     SUM(total_amount) AS 'total amount'
-- -- FROM
-- --     orders
-- -- GROUP BY MONTHNAME(order_date) , month(order_date)
-- -- order by  sum(total_amount) desc;
    
# Q5. Determine which 10 products are giving the most revenue.
       SELECT 
    products.product_name AS 'product name',
    SUM(orders.total_amount) AS 'toal revenue'
FROM
    products
        JOIN
    orders ON products.product_id = orders.order_id
GROUP BY products.product_name
ORDER BY SUM(orders.total_amount) DESC
LIMIT 10;
               
# Q6. Calculate which product categories gave what revenue.
     select 
           products.category as "product categery",
           sum(orders.total_amount) as "total revenue"
           from 
              products
        JOIN
    orders ON products.product_id = orders.order_id
    group by products.category ;
# Q7. List which 10 cities are placing the highest number of orders.
    SELECT 
    customers.city AS 'customer city',
    COUNT(orders.order_id) AS 'number of orders'
FROM
    customers
        JOIN
    orders ON customers.customer_id = orders.customer_id
GROUP BY customers.city
ORDER BY COUNT(orders.order_id) desc
LIMIT 10;
	
# Q8. Find the average revenue by morning, afternoon and evening.
      select
      case
      when
            hour(order_time) < 12 then 'morning'
	 when  
		  hour(order_time) < 18  then 'afternoon'
          else  'evening'
          end as time_of_day,
          round (avg(total_amount),2) as "age revenue"
  from orders
  group by time_of_day ;
# Q9. Compare the total revenue generated from different occasions.
       select 
             occasion ,
             sum(total_amount) as "total revenue"
             from orders
             group by occasion;

# Q10. Find out which products are most popular during specific occasions.
	 --   with `Products Rank by Occasion` as(
-- 	SELECT 
-- 		products.occasion AS `Occasion`,
-- 		products.product_name AS `Product Name`,
-- 		SUM(orders.total_amount) AS 'Total Revenue',
-- 		dense_rank() over(partition by products.occasion order by SUM(orders.total_amount) desc) 
-- 		as `Rank`
-- 	FROM
-- 		products
-- 			JOIN
-- 		orders ON products.product_id = orders.product_id
-- 	GROUP BY `Occasion` , `Product Name`
-- )select * from `Products Rank by Occasion` where `Rank` <= 5;
-- 2 method ;

select
	*
from
(SELECT 
    products.occasion AS `Occasion`,
    products.product_name AS `Product Name`,
    SUM(orders.total_amount) AS 'Total Revenue',
    dense_rank() over(partition by products.occasion order by SUM(orders.total_amount) desc) 
    as `Rank`
FROM
    products
        JOIN
    orders ON products.product_id = orders.product_id
GROUP BY `Occasion` , `Product Name`) as `Products Rank by Occasion`
where `Rank` <= 5;