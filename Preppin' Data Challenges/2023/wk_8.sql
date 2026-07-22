--Preppin' Data 2023 Week 7

with unioned_months as (
    select *
        ,1 as mon
    from pd2023_wk08_01
    union all 
    select *
        ,2 as mon
    from pd2023_wk08_02
    union all 
    select *
        ,3 as mon
    from pd2023_wk08_03
    union all 
    select *
        ,4 as mon
    from pd2023_wk08_04
    union all 
    select *
        ,5 as mon
    from pd2023_wk08_05
    union all 
    select *
        ,6 as mon
    from pd2023_wk08_06
    union all 
    select *
        ,7 as mon
    from pd2023_wk08_07
    union all 
    select *
        ,8 as mon
    from pd2023_wk08_08
    union all 
    select *
        ,9 as mon
    from pd2023_wk08_09
    union all 
    select *
        ,10 as mon
    from pd2023_wk08_10
    union all 
    select *
        ,11 as mon
    from pd2023_wk08_11
    union all 
    select *
        ,12 as mon
    from pd2023_wk08_12
)

,cleaned_fields as (
    select 
        *
        ,date_from_parts(2032,mon,1) as file_date
        ,case
            when market_cap like '%B' 
                then replace(replace(market_cap, '$', ''), 'B', '')::float* 1000000000
            when market_cap like '%M' 
                then replace(replace(market_cap, '$', ''), 'M', '')::float * 1000000
        end::int as market_capitalisation
        ,replace(purchase_price, '$', '')::float as purchase_price_cleaned
    from unioned_months
    where market_cap <> 'n/a'
)

,categories as (
    select *
        ,case
            when market_capitalisation < 100000000
                then 'Small'
            when market_capitalisation < 1000000000
                then 'High'
            when market_capitalisation < 100000000000
                then 'Large'
            else 'Huge'
        end as market_capitalisation_category
        ,case
            when purchase_price_cleaned <= 24999.99 
                then 'Low'
            when purchase_price_cleaned <= 49999.99 
                then 'Medium'
            when purchase_price_cleaned <= 74999.99
                then 'High'
            when purchase_price_cleaned <= 100000
                then 'Very High'
        end as purchase_price_category
    from cleaned_fields
)

select market_capitalisation_category  
    ,purchase_price_category
    ,file_date
    ,ticker
    ,sector 
    ,market 
    ,stock_name
    ,market_capitalisation
    ,purchase_price_cleaned as purchase_price
    ,dense_rank() over (
            partition by file_date, market_capitalisation_category, purchase_price_category
            order by purchase_price_cleaned desc
        ) as purchase_rank
from categories
qualify purchase_rank <= 5;
