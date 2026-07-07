--Preppin' Data 2023 Week 3

with transactions as (
select replace(replace(online_or_in_person,'1','Online'),'2','In-Person') as "Online or In-Person"
    ,quarter(to_date(transaction_date, 'DD/MM/YYYY hh:mi:ss' )) as "Quarter"
    ,sum(value) as Value
from pd2023_wk01
where transaction_code like 'DSB%'
group by "Quarter"
    ,"Online or In-Person"
order by "Quarter"
)

,targets as (
select online_or_in_person
    ,cast(replace(Quarter,'Q','') as integer) as Quarter
    ,"Quarterly Targets"
from pd2023_wk03_targets
unpivot
(
"Quarterly Targets" for Quarter in (Q1, Q2, Q3, Q4)
)
as t
 )

select transactions."Online or In-Person"
    ,transactions."Quarter"
    ,Value
    ,"Quarterly Targets"
    ,Value - "Quarterly Targets" as "Variance to Target"
from transactions 
join targets on transactions."Online or In-Person" = targets.online_or_in_person
    and transactions."Quarter" = targets.Quarter