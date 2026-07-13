--Data with Danny: Case Study #1 - Danny's Diner

--1. What is the total amount each customer spent at the restaurant?
select customer_id
    ,sum(price) as total_spend
from sales 
join menu on sales.product_id=menu.product_id
group by 1;

--2. How many days has each customer visited the restaurant?
select customer_id
    ,count (distinct order_date) as days_visited
from sales 
group by 1;

--3. What was the first item from the menu purchased by each customer?
with cte as (
    select customer_id
        ,order_date
        ,product_name
        ,dense_rank() over(
            partition by customer_id
            order by order_date asc
        ) as order_sequence
    from sales
    join menu on sales.product_id=menu.product_id
)

select customer_id
    ,product_name as first_item_purchased
from cte
where order_sequence=1;

--4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select product_name
    ,count(product_name) as times_purchased
from sales
join menu on sales.product_id=menu.product_id
group by product_name
order by count(product_name) desc
limit 1;

--5. Which item was the most popular for each customer?
with cte as (
    select customer_id 
        ,product_name 
        ,count(product_name)
        ,dense_rank() over(
            partition by customer_id 
            order by count(product_name) desc) as popularity
    from sales 
    join menu on sales.product_id = menu.product_id
    group by customer_id
        ,product_name
)

select customer_id 
    ,product_name as most_popular_product
from cte
where popularity=1;

--6. Which item was purchased first by the customer after they became a member?
with cte as (
    select sales.customer_id
        ,order_date
        ,sales.product_id
        ,product_name
        ,join_date
        ,dense_rank() over(
            partition by sales.customer_id
            order by order_date asc
        ) as ranking
    from sales
    join members on members.customer_id=sales.customer_id
    join menu on sales.product_id=menu.product_id
    where order_date >= join_date 
)

select customer_id
    ,product_name as first_purchase_as_member
from cte
where ranking = 1;

--7. Which item was purchased just before the customer became a member?
with cte as (
    select sales.customer_id
        ,order_date
        ,sales.product_id
        ,product_name
        ,dense_rank() over(
            partition by sales.customer_id
            order by order_date desc
        ) as ranking
        ,join_date
    from sales
    join members on members.customer_id=sales.customer_id
    join menu on sales.product_id=menu.product_id
    where order_date < join_date
)

select customer_id
    ,product_name as last_purchase_before_becoming_member
from cte
where ranking = 1;

--8. What is the total items and amount spent for each member before they became a member?
select sales.customer_id
    ,count(sales.product_id) as total_items
    ,sum(price) as total_amount_spent
from sales
join members on members.customer_id=sales.customer_id
join menu on sales.product_id=menu.product_id
where order_date < join_date
group by sales.customer_id;

--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with cte as (
    select customer_id
        ,product_name
        ,price,
    case
        when product_name = 'sushi' then price*10*2
        else price*10*1
    end as points_per_order
    from sales
    join menu on sales.product_id=menu.product_id
)

select customer_id
    ,sum(points_per_order) as total_points
from cte
group by customer_id;

--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customers A and B have at the end of January?
with cte as (
    select sales.customer_id
        ,order_date
        ,join_date
        ,product_name
        ,price
        ,datediff(day,join_date,order_date) as date_diff,
    case
        when date_diff between 0 and 6 then 2
        else 1
    end as new_member_multiplier,
    case
        when product_name = 'sushi' and new_member_multiplier = 1 then 2
        else 1
    end as sushi_multiplier
    from sales
    join members on sales.customer_id=members.customer_id
    join menu on sales.product_id=menu.product_id
    where month(order_date) = 1
)
select customer_id
    ,sum(price*10*new_member_multiplier*sushi_multiplier) as total_points
from cte
group by customer_id;

--Bonus Q: Join all the things
select sales.customer_id
    ,sales.order_date
    ,menu.product_name
    ,menu.price
    ,join_date,
case
    when order_date>=join_date then 'Y'
    else 'N'
end as member
from sales
join menu on sales.product_id=menu.product_id
full join members on sales.customer_id=members.customer_id;

--Bonus Q: Rank all the things
select sales.customer_id
    ,sales.order_date
    ,menu.product_name
    ,menu.price
    ,join_date,
case
    when order_date>=join_date then 'Y'
    else 'N'
end as member,
case
    when member = 'Y' then dense_rank() over(
        partition by sales.customer_id
        order by order_date asc
        ) 
    else null
end as ranking
from sales
join menu on sales.product_id=menu.product_id
full join members on sales.customer_id=members.customer_id;

--but dense rank is including the nulls