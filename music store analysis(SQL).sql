Create database music_DB;
use music_DB;

 /*Q1: Who is the senior most employee based on job title? */

SELECT first_name, last_name, title 
FROM employee
ORDER BY levels DESC
LIMIT 1;


/* Q2: Which countries have the most Invoices? */

SELECT COUNT(*) AS c, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY c DESC;


/* Q3: What are top 3 values of total invoice? */

SELECT total 
FROM invoice
ORDER BY total DESC
limit 3;


/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_city,SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT c.first_name, c.last_name, c.city, sum(i.total) AS Total_spend
FROM customer as c
JOIN invoice as i ON c.customer_id = i.customer_id
GROUP BY c.first_name, c.last_name, c.city
ORDER BY Total_spend DESC
LIMIT 1;



/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */


select c.email, c.first_name, c.last_name,g.name
from customer as c join invoice as i on c.customer_id=i.customer_id
join invoice_line il on i.invoice_id=il.invoice_id
join track as t on il.track_id=t.track_id
join genre as g on t.genre_id = g.genre_id
where g.name ="Rock" order by c.email;

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select a.name,g.name, count(t.track_id) as Total_track
from artist as a join album as al on a.artist_id=al.artist_id
join track as t on al.album_id=t.album_id
join genre as g on t.genre_id=g.genre_id
where g.name = "Rock"
group by a.name,g.name
order by Total_track DESC limit 10;


/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT t.name, g.name,t.milliseconds
from track as t join genre as g on t.genre_id=g.genre_id
where t.milliseconds>(select avg(milliseconds)from track)
group by t.name,g.name,t.milliseconds
order by t.milliseconds desc;




/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */



select c.first_name, c.last_name, ar.name as artist_name, sum(in_l.unit_price*in_l.quantity) as Total_sales
from customer as c join invoice as i on c.customer_id=i.customer_id
join invoice_line as in_l on i.invoice_id=in_l.invoice_id
join track as t on in_l.track_id=t.track_id
join album as al on t.album_id=al.album_id
join artist as ar on al.artist_id=ar.artist_id
group by c.first_name, c.last_name, ar.name;


/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY customer.country, genre.name, genre.genre_id
	ORDER BY customer.country ASC, purchases DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;


/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */


WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY customer.customer_id,first_name,last_name,billing_country
		ORDER BY billing_country ASC,total_spending DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1;