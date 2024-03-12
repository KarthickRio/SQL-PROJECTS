SELECT category,
ROUND(((SUM(`quantity_sold(after_promo)`) - SUM(`quantity_sold(before_promo)`))/SUM(`quantity_sold(before_promo)`))*100 ,2) as perc_isi,
RANK() OVER(order by ((SUM(`quantity_sold(before_promo)`) - SUM(`quantity_sold(after_promo)`))/SUM(`quantity_sold(before_promo)`)) DESC) AS rnk
FROM fact_events as f
JOIN dim_products as p
on f.product_code=p.product_code
WHERE campaign_id ='CAMP_DIW_01'
GROUP BY category;


