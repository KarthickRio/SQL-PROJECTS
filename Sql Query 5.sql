SELECT DISTINCT product_name ,category,
((base_price*(`quantity_sold(after_promo)`)) - (base_price*(`quantity_sold(before_promo)`))) *100 /(base_price*(`quantity_sold(before_promo)`))AS iri,
RANK() OVER ( order by ((base_price*(`quantity_sold(after_promo)`)) - (base_price*(`quantity_sold(before_promo)`))) *100 /(base_price*(`quantity_sold(before_promo)`))DESC) AS rnk
FROM dim_products as d
join fact_events f using (product_code)
join dim_campaigns c using(campaign_id)
LIMIT 5;