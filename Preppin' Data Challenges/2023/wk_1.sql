--Preppin' Data 2023 Week 1

--Output 1: Total Values of Transactions by each bank
select
split_part(transaction_code,'-',1) as "Bank"
    ,sum(value) as "Value"
from pd2023_wk01
group by "Bank";

--Output 2: Total Values by Bank, Day of the Week and Type of Transaction
select
split_part(transaction_code,'-',1) as "Bank"
    ,replace(replace(online_or_in_person,'1','Online'),'2','In-Person') as "Online or In-Person"
    ,dayname(to_date(transaction_date, 'DD/MM/YYYY hh:mi:ss' )) as "Transaction Date"  
    ,sum(value) as "Value"
from pd2023_wk01
group by "Bank"
    ,"Online or In-Person"
    ,"Transaction Date";

--Output 3: Total Values by Bank and Customer Code
select
split_part(transaction_code,'-',1) as "Bank"
    ,customer_code as "Customer Code"
    ,sum(value) as "Value"
from pd2023_wk01
group by "Bank"
    ,"Customer Code";