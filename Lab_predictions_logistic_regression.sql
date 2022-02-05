use sakila;

# checking first, which rental periods to look at (definition of next month/ last month, since
# database is not up to date

select distinct year(rental_date), month(rental_date), count(rental_id)
from rental
group by year(rental_date), month(rental_date);

# there is only enough data available for May to August 2005 and they are the only consecutive
# month as well

# checking which months in 2005 have rented/not rented movies, to get about equal class
# sizes for target (note: there are 1.000 movies in the database)

select month(r.rental_date), count(distinct f.film_id)
from rental as r
left join inventory as i
on r.inventory_id = i.inventory_id
left join film as f
on i.film_id = f.film_id
where year(r.rental_date) = 2005
group by month(r.rental_date);

# creating view with rental information for may 2005 as "previous month" and rental information for
# june 2005 as target month

create or replace view rentals_may_june as
with rentals_may as
(select f.film_id, f.title, f.release_year, f.rental_rate, f.length, f.rating,
c.category_id as category, count(r.rental_id) as times_rented_may
from film as f
left join film_category as c
on f.film_id = c.film_id
left join inventory as i
on f.film_id = i.film_id
left join rental as r
on i.inventory_id = r.inventory_id
and r.rental_date >= date('2005-05-01')
and r.rental_date < date('2005-06-01')
group by f.film_id)
select f.film_id, f.title, f.release_year, f.rental_rate, f.length, f.rating,
f.category, f.times_rented_may, count(r.rental_id) as times_rented_jun
from rentals_may as f
left join inventory as i
on f.film_id = i.film_id
left join rental as r
on i.inventory_id = r.inventory_id
and r.rental_date >= date('2005-06-01')
and r.rental_date < date('2005-07-01')
group by f.film_id;
