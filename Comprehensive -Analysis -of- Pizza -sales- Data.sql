use pizza;
SELECT * FROM pizza.pizza_types;
create table orders
(
 order_id int not null,
 order_date date not null,
 order_time time not null,
 primary key(order_id)
);

select * from orders;

create table order_details
(
 order_details_id int not null,
 order_id int not null,
 pizza_id text not null,
 quantity  int not null,
 primary key(order_details_id)
);
select * from order_details;
select * from pizzas;
select * from orders;
select * from pizza_types;

-- Retrieve the total number of orders placed.
select count(order_id)as total_number_of_orders from orders;

-- Calculate the total revenue generated from pizza sales.
select round(sum((order_details.quantity * pizzas.price)),3) as total_revenue from order_details
join pizzas on order_details.pizza_id=pizzas.pizza_id;

-- Identify the highest-priced pizza.
select * from pizzas
order by price desc
limit 1;

-- Identify the most common pizza size ordered.
select pizzas.size,count(order_details.order_details_id)as order_count from pizzas 
join order_details on pizzas.pizza_id = order_details.pizza_id 
group by pizzas.size 
order by order_count  desc 
limit 1;

-- List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name,sum(order_details.quantity)as sum_order from pizza_types
join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.name 
order by sum_order desc
limit 5;

 -- INTERMEDIATE LEVEL
 
-- Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category,sum(order_details.quantity) as 'quantity' from pizzas
join pizza_types on pizzas.pizza_type_id=pizza_types.pizza_type_id
join order_details on  pizzas.pizza_id=order_details.pizza_id
group by pizza_types.category
order by  pizza_types.category desc;


-- Determine the distribution of orders by hour of the day.

select hour(order_time)as 'hour',count(order_id)as 'order_count' from orders
group by hour
order by order_count desc;

-- Join relevant tables to find the category-wise distribution of pizzas.

select category,count(name) from pizza_types
group by category
order by count(name) desc;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select ceil(avg(orders)) as avg_no_pizzas_ord from
(select order_date,count(order_details.quantity) as 'orders' from orders
join order_details on orders.order_id=order_details.order_id
group by order_date) as order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name,sum(pizzas.price*order_details.quantity)as 'revenue' from pizza_types
join pizzas on pizzas.pizza_type_id=pizza_types.pizza_type_id
join order_details on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.name
order by revenue desc
limit 3;


-- ADVANCED LEVEL QUERIES

-- Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types.category,(round(sum(pizzas.price*order_details.quantity)/(select round(sum((order_details.quantity * pizzas.price)),3) as total_revenue from order_details
join pizzas on order_details.pizza_id=pizzas.pizza_id)*100,2)) as revenue from  
pizza_types join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join  order_details
on pizzas.pizza_id = order_details.pizza_id
group by category
order by revenue desc;

-- Analyze the cumulative revenue generated over time.

select order_date,sum(revenue)over(order by order_date) as cum_revenue
from
(select orders.order_date,round(sum(pizzas.price*order_details.quantity),2)as revenue from orders
join order_details  on order_details.order_id=orders.order_id
join pizzas on order_details.pizza_id=pizzas.pizza_id
group by orders.order_date)as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category,name,revenue from
(select category,name,revenue,rank() over(partition by  category order by revenue desc)as rnk from
(select pizza_types.name,pizza_types.category,sum(pizzas.price*order_details.quantity)as revenue from pizza_types
join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.name,pizza_types.category) as rev) as reve
where rnk<=3;


 
