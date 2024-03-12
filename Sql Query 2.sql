SELECT COUNT(*) as no_Of_stores ,city FROM dim_stores
GROUP BY city
ORDER BY no_of_stores DESC;