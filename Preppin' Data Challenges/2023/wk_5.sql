--Preppin' Data 2023 Week 5

with cte as (
select 
    split_part(transaction_code,'-',1) as Bank
    ,to_char(to_date(transaction_date, 'DD/MM/YYYY hh:mi:ss'), 'MMMM') as "Transaction Date"
    ,sum(value) as Value
    ,dense_rank() over(
        partition by "Transaction Date"
        order by sum(value) desc
    ) as "Bank Rank per Month"
from pd2023_wk01
group by 1
    ,2
)

,cte2 as (
select "Bank Rank per Month"
    ,avg(Value) as "Avg Transaction Value per Bank"
from cte
group by 1
)

,cte3 as (
select Bank
 ,avg("Bank Rank per Month") as "Avg Rank per Bank"
from cte
group by 1
)

select cte."Transaction Date"
    ,cte.Bank
    ,Value
    ,cte."Bank Rank per Month"
    ,"Avg Transaction Value per Bank"
    ,"Avg Rank per Bank"
from cte left join cte2 on cte."Bank Rank per Month"=cte2."Bank Rank per Month"
         left join cte3 on cte.Bank = cte3.Bank