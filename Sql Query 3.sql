SELECT campaign_name,
round(sum(base_price*`quantity_sold(before_promo)`/1000000),2) as TOTAL_REVENUE_BEFORE_PROMOTION_IN_M,
round(sum((CASE
WHEN promo_type = '25% OFF' THEN base_price/4*`quantity_sold(after_promo)`
WHEN promo_type = '50% OFF' THEN base_price/2*`quantity_sold(after_promo)`
WHEN promo_type = '33% OFF' THEN base_price/0.33*`quantity_sold(after_promo)`
WHEN promo_type = 'BOGOF' THEN (base_price*`quantity_sold(after_promo)`)/2
WHEN promo_type = '500 Cashback' THEN (base_price-500)*`quantity_sold(after_promo)`
ELSE "no"
end)/1000000),2) as TOTAL_REVENUE_AFTER_PROMOTION_IN_M
from fact_events as f
join dim_campaigns as d on f.campaign_id = d.campaign_id
group by campaign_name;


