show databases;
create database Pizza_Shop;
use Pizza_Shop;
show tables;

-- Q1 Total No of orders
SELECT 
    COUNT(order_id) AS Total_Orders
FROM
    order_details;

-- Q2 Calculate total revenue generated from Pizza Sales
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS Total_Revenue
FROM
    order_details AS od
        JOIN
    Pizzas AS p ON o.pizza_id = p.pizza_id;
    
-- Q3 Identify the Highest Price Pizza
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Identify the most common pizza size orderrd
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantity
SELECT 
    pizza_types.name, SUM(order_details.quantity) AS Quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Quantity DESC
LIMIT 5;

-- join the necessary table to find the total quantity of each pizza category
SELECT 
    pizza_types.category, SUM(order_details.quantity) AS Quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Quantity DESC;

-- Determine distribution of the order by hour of the day
SELECT 
    HOUR(time), COUNT(order_id)
FROM
    orders
GROUP BY HOUR(time)
ORDER BY HOUR(time);

-- join relevat tables to find category wise distribution of pizza
SELECT 
    category, COUNT(category)
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day
SELECT 
    ROUND(AVG(data), 2) AS Average_Orders
FROM
    (SELECT 
        orders.date, SUM(order_details.quantity) AS data
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.date) AS imp_table;
    
-- Determine the most 3 ordered Pizza Types based on revenue
SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY Revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue
SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    SUM(order_details.quantity * pizzas.price)
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,
            2) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY Revenue DESC;

-- Analyze the cumalative revenue generated over time
SELECT 
    date,
    round(SUM(revenue) OVER (ORDER BY date),2) AS cum_revenue
FROM
    (SELECT 
        orders.date,
        SUM(order_details.quantity * pizzas.price) AS revenue
     FROM 
        order_details
     JOIN 
        pizzas ON order_details.pizza_id = pizzas.pizza_id
     JOIN 
        orders ON orders.order_id = order_details.order_id
     GROUP BY 
        orders.date) AS sales;
        
-- Determine the top 3 most ordered pizza types based on Revenue for each pizza category
select name, revenue from
(select category, name, revenue,
rank() over (partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name,
sum((order_details.quantity) * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn <= 3;
