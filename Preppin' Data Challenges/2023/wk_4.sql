--Preppin' Data 2023 Week 4

--Create a CTE unioning all the months of data.
with months as (
select *
    ,'January' as Month
from pd2023_wk04_january
union all
select *
    ,'February' as Month
from pd2023_wk04_february
union all
select *
    ,'March' as Month
from pd2023_wk04_march
union all
select *
    ,'April' as Month
from pd2023_wk04_april
union all
select *
    ,'May' as May
from pd2023_wk04_may
union all
select *
    ,'June' as Month
from pd2023_wk04_june
union all
select *
    ,'July' as Month
from pd2023_wk04_july
union all
select *
    ,'August' as Month
from pd2023_wk04_august
union all
select *
    ,'September' as Month
from pd2023_wk04_september
union all
select *
    ,'October' as Month
from pd2023_wk04_october
union all
select *
    ,'November' as Month
from pd2023_wk04_november
union all
select *
    ,'December' as Month
from pd2023_wk04_december
)

--Create a CTE reshaping the data so there is a field for each demographic, for each new customer.
,months_pivoted as (
select *
from months
pivot(
MAX("VALUE")
for Demographic in ('Ethnicity','Account Type','Date of Birth')
) as headers
)

--Create 'Joining Date' field (minimum to take earliest joining date if a customer appears multiple times), select relevant fields to keep in output.
select ID 
    ,min(to_date(Joining_day||'-'||Month||'-2023', 'DD-MMMM-YYYY')) as "Joining Date"
    ,"'Ethnicity'"
    ,"'Account Type'"
    ,"'Date of Birth'"
from months_pivoted
group by ID
    ,"'Ethnicity'"
    ,"'Account Type'"
    ,"'Date of Birth'"