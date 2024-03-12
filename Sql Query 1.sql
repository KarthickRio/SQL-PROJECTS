SELECT p.product_name,
f.base_price 
FROM dim_products as p
JOIN fact_events as f 
on f.product_code=p.product_code
WHERE base_price > 500
and promo_type= 'BOGOF';
