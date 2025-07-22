Create Database Pizzaclub;

Create Table Orders(
order_ID INT NOT NULL,
date datetime not null,
order_time time not null,
Primary key(order_ID));

Alter Table Orders rename column date to order_date;

Create Table Order_detail(
order_details_id Int not Null,
order_id INT not null,
Pizza_id varchar(32) not null,
quantity int not null,
Primary Key(Pizza_id)
);

Alter Table Order_detail Drop Primary Key;

Alter table Order_detail add Primary Key(order_details_id);

-- Retrive the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;


-- Calculate the total revenue generated from pizza sales

SELECT 
    round(SUM(order_detail.quantity * pizzas.price) , 2) AS total_sales
FROM
    order_detail
        JOIN
    pizzas ON pizzas.pizza_id = order_detail.Pizza_id;

    
-- Identify the highest price pizza

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


-- List the top 5 most ordered pizza
-- types along with their quantities.

SELECT 
    pizza_types.name, SUM(order_detail.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_detail ON order_detail.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;


-- total quantity of each pizza category ordered

SELECT 
    pizza_types.category, SUM(order_detail.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_detail ON order_detail.Pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;


-- determine the distribution of orders by hours of the day

SELECT 
    HOUR(order_time), COUNT(order_ID)
FROM
    orders
GROUP BY HOUR(order_time);


-- join relevant tables to find the category- wise disstribution of pizzas

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;


-- group the orders by date and calculate the average number
-- of pizzas ordered per day

SELECT 
    AVG(quantity)
FROM
    (SELECT 
        orders.order_date, SUM(order_detail.quantity) AS quantity
    FROM
        orders
    JOIN order_detail ON orders.order_id = order_detail.order_id
    GROUP BY orders.order_date) AS order_quantity;

    
-- determine top3 most ordered pizza type based on revenue.

SELECT 
    pizza_types.name,
    SUM(order_detail.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_detail ON order_detail.Pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;


-- calculate the percentage of each pizza type 
-- to total revenue.

SELECT 
    pizza_types.category,
    (SUM(order_detail.quantity * pizzas.price) / (SELECT 
            ROUND(SUM(order_detail.quantity * pizzas.price),
                        2) AS total_sales
        FROM
            order_detail
                JOIN
            pizzas ON pizzas.pizza_id = order_detail.Pizza_id) )* 100 as revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_detail ON pizzas.pizza_id = order_detail.Pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;


--  Analyze the cumulative revenue generated over time.

select order_date,
sum(revenue) over(order by order_date) as cum_revenue
from
(select orders.order_date,
sum(order_detail.quantity * pizzas.price) as revenue
from order_detail join pizzas
on order_detail.Pizza_id = pizzas.pizza_id
join orders
on orders.order_ID = order_detail.order_id
group by orders.order_date)  as sales;


-- determine the top 3 pizza type on the base of revenue
-- in each categories
select name, revenue from 
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name,
sum((order_detail.quantity) * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_detail
on order_detail.Pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn<= 3;