--Preppin' Data 2023 Week 7

select a.transaction_id
    ,a.account_to
    ,b.transaction_date
    ,b.value
    ,c.ACCOUNT_NUMBER
    ,c.account_type
    ,c.balance_date
    ,c.balance
    ,d.name
    ,d.date_of_birth
    ,d.first_line_of_address
from pd2023_wk07_transaction_path as a
join pd2023_wk07_transaction_detail as b on a.transaction_id = b.transaction_id
join pd2023_wk07_account_information as c on a.account_from = c.account_number,
    lateral split_to_table(account_holder_id,',') as sp
join pd2023_wk07_account_holders as d on TRIM(sp.value)::int = d.account_holder_id
where cancelled_ = 'N' and b.value > 1000 and account_type != 'Platinum'