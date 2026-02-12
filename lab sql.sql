#creating a customer summary report
CREATE VIEW customer_rental_summary AS
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM customer c
LEFT JOIN rental r 
    ON c.customer_id = r.customer_id
GROUP BY 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email;

#create a temporary table 

CREATE TEMPORARY TABLE temp_customer_payments AS
SELECT 
    v.customer_id,
    v.first_name,
    v.last_name,
    v.email,
    v.rental_count,
    COALESCE(SUM(p.amount), 0) AS total_paid
FROM customer_rental_summary v
LEFT JOIN payment p 
    ON v.customer_id = p.customer_id
GROUP BY 
    v.customer_id,
    v.first_name,
    v.last_name,
    v.email,
    v.rental_count;
    
    #create a CTE and the customer summary report
    
WITH customer_summary_cte AS (
    SELECT 
        v.customer_id,
        CONCAT(v.first_name, ' ', v.last_name) AS customer_name,
        v.email,
        v.rental_count,
        t.total_paid
    FROM customer_rental_summary v
    INNER JOIN temp_customer_payments t
        ON v.customer_id = t.customer_id
)

SELECT 
    customer_name,
    email,
    rental_count,
    total_paid,
    CASE 
        WHEN rental_count > 0 
        THEN total_paid / rental_count
        ELSE 0
    END AS avg_payment_per_rental
FROM customer_summary_cte
ORDER BY total_paid DESC;

    
