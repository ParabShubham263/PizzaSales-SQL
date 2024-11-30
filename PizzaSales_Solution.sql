-- Retrieve the total number of orders placed.

select count(order_id) as total_orders from orders;

-- Calculate the total revenue generated from pizza sales.

select round(sum(order_details.quantity * pizzas.price),2 )as total_sales 
from  order_details join pizzas
on pizzas.pizza_id = order_details.pizza_id;


-- Identify the highest-priced pizza.

select pizza_types.name, pizzas.price
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc limit 1;


-- Identify the most common pizza size ordered .

select pizzas.size, COUNT(order_details.quantity) as order_count
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size
order by order_count desc;

-- List the top 5 most ordered pizza types along with their quantities.

select pizza_types.name, sum(order_details.quantity) as quantity
from pizza_types 
				join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
				join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by quantity desc limit 5 ;


-- Join the necessary tables to find the total quantity of each pizza category ordered.

select pizza_types.category, sum(order_details.quantity) as quantity
from pizza_types 
				join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
				join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by quantity desc limit 5 ;


-- Determine the distribution of orders by hour of the day.

select hour(orders_time) as hour,count(order_id) as order_count
from orders
group by hour(orders.orders_time);


-- Join relevant tables to find the category-wise distribution of pizzas.

select category , count(name) from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

select avg(quantity) from 
(select orders.orders_date , sum(order_details.quantity) as quantity
from orders join order_details
on orders.order_id = order_details.order_id
group by orders.orders_date) as order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name, 
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types 
				join pizzas 
                on pizza_types.pizza_type_id = pizzas.pizza_type_id
                join order_details 
                on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by  revenue desc;


-- Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category, 
(sum(order_details.quantity * pizzas.price) / (select round(sum(order_details.quantity * pizzas.price),2 )as total_sales 
from  order_details join pizzas
on pizzas.pizza_id = order_details.pizza_id) ) * 100 as revenue
from pizza_types 
				join pizzas 
                on pizza_types.pizza_type_id = pizzas.pizza_type_id
                join order_details 
                on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by  revenue desc;

-- Analyze the cumulative revenue generated over time.

select orders_date,
sum(revenue) over(order by orders_date) as cum_revenue
from
(select orders.orders_date,
sum(order_details.quantity * pizzas.price)  as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on  orders.order_id = order_details.order_id
group by orders.orders_date)as sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name , revenue
from
(select category, name , revenue ,
rank() over(partition by category order by revenue desc)as ranking
from
(select pizza_types.category,pizza_types.name,
sum(order_details.quantity * pizzas.price)  as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category,pizza_types.name)as aa) as bb
 where ranking<=3;