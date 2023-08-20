
-- Prep work before querying:
-- I updated the three columns of the JSON data type to only display
-- the text in English as they contained the text in Russian alphabet
-- as well.

UPDATE airports_data 
SET airport_name = airport_name -> 'en'::text
WHERE airport_name IS NOT NULL
  AND airport_name->'en' IS NOT NULL;
 
UPDATE airports_data 
SET city = city -> 'en'::text
WHERE city  IS NOT NULL
  AND city ->'en' IS NOT NULL;

UPDATE aircrafts_data 
SET model = model -> 'en'::text
WHERE model IS NOT NULL
  AND model ->'en' IS NOT NULL;

 --Highest-grossing airports by tickets sold (in EUR) in the month of August (2017)

select f.departure_airport, sum(ROUND(tf.amount*0.0142)) as sum_eur 
from flights f
inner join ticket_flights tf on tf.flight_id = f.flight_id 
where actual_departure between '2017-08-01 00:00:00' and '2017-08-31 23:59:00'
group by 1
order by 2 desc;

-- The total number of airports in Russia according to this dataset

select count(distinct departure_airport) as total_no_of_airports from flights;

-- Number of tickets sold by each Russian airport 
-- in the month of August 2017 (excluding cancelled flights)

select distinct(f.departure_airport), count(tf.ticket_no) as no_of_sold_tickets
from flights f
inner join ticket_flights tf on tf.flight_id = f.flight_id 
where actual_departure between '2017-08-01 00:00:00' and '2017-08-31 23:59:00'
group by 1
order by 2 desc;

-- Highest-grossing aircraft models by tickets sold (in EUR) 
-- in the month of August 2017 (excluding cancelled flights)

select acd.model, sum(ROUND(tf.amount*0.0142)) as sum_eur 
from aircrafts_data acd
inner join flights f on f.aircraft_code = acd.aircraft_code 
inner join ticket_flights tf on tf.flight_id = f.flight_id 
where actual_departure between '2017-08-01 00:00:00' and '2017-08-31 23:59:00'
group by 1
order by 2 desc;

--Highest-grossing aircraft classes from each aircraft model 
--by tickets sold (in EUR) in the month of August 2017 (excluding cancelled flights)

select acd.model, tf.fare_conditions, sum(ROUND(tf.amount*0.0142)) as sum_eur 
from aircrafts_data acd
inner join flights f on f.aircraft_code = acd.aircraft_code 
inner join ticket_flights tf on tf.flight_id = f.flight_id 
where actual_departure between '2017-08-01 00:00:00' and '2017-08-31 23:59:00'
group by 1, 2
order by 3 desc;

--Top 10 passengers with the largest amount spent on flight tickets
--who flew more than 3 times in the month of August 2017

select t.passenger_id, t.passenger_name, count(t.passenger_id) as times_flown,
sum(ROUND(tf.amount*0.0142)) as money_spent_EUR 
from tickets t
inner join ticket_flights tf on tf.ticket_no  = t.ticket_no 
inner join flights f on f.flight_id = tf.flight_id
where actual_departure between '2017-08-01 00:00:00' and '2017-08-31 23:59:00'
group by 1, 2 
having count(t.passenger_id) > 3
order by 4 DESC
limit 10;


--Average number of seats for all aircraft models 
--that flew or were supposed to fly 
--from one of the airports in the city of Moscow in
--the month of August 2017. This query could be used for different airports.

with no_of_seats as (
	select ad.model, count(distinct seat_no) as nr
	from aircrafts_data ad
	inner join seats s on s.aircraft_code = ad.aircraft_code
	inner join flights f on f.aircraft_code = s.aircraft_code
	where departure_airport = 'DME' 
	and scheduled_departure between '2017-08-01 00:00:00' and '2017-08-31 23:59:00'
	group by 1
	order by 2 desc
)
	select ROUND(avg(nr)) from no_of_seats as avg_no_of_seats;
	
-- Aircraft models by the number of cancelled flights	

select acd.model, count(*) as no_cancelled, f.aircraft_code 
from aircrafts_data acd
inner join flights f on f.aircraft_code = acd.aircraft_code
where status = 'Cancelled' 
group by 1, 3
order by 2 desc;


-- The number of times each aircraft model flew 
-- and from which airport it flew the most times
-- in the month of August 2017 (excluding canelled flights)

select acd.model, count(f.aircraft_code) as no_of_flights, max (departure_airport) 
from aircrafts_data acd
inner join flights f on f.aircraft_code = acd.aircraft_code
and actual_departure between '2017-08-01 00:00:00' and '2017-08-31 23:59:00'
group by 1
order by 2 desc;

-- Airports with the most flights in the month of August 2017
-- (excluding cancelled flights)

select departure_airport, count (flight_id) as no_of_flights
from flights 
where actual_departure between '2017-08-01 00:00:00' and '2017-08-31 23:59:00'
group by 1
order by 2 desc;

-- The number of airports in each Russian city according to this dataset

select city, count(airport_code) as no_of_airports 
from airports_data 
group by 1
order by 2 desc;

--Highest-grossing aircraft classes from each airport
--by tickets sold (in EUR) in the month of August 2017 
--(excluding cancelled flights)

select f.departure_airport, tf.fare_conditions, sum(ROUND(tf.amount*0.0142)) as sum_eur
from bookings.ticket_flights tf
inner join bookings.flights f on f.flight_id = tf.flight_id 
where actual_departure between '2017-08-01 00:00:00' and '2017-08-31 23:59:00'
group by 1, 2
order by 3 desc;

-- Passenger names and their contact data of those who flew 3 or more times
-- from one of Moscow's airports in the month of August 2017 

select t.passenger_name, count(t.passenger_id) as times_flown, t.contact_data 
from bookings.tickets t
inner join bookings.ticket_flights tf on tf.ticket_no = t.ticket_no
inner join bookings.flights f on f.flight_id = tf.flight_id
where actual_departure between '2017-08-01 00:00:00' and '2017-08-31 23:59:00'
and departure_airport IN ('DME', 'SVO', 'VKO')
group by 1, 3
having count(t.passenger_id) >= 3;

-- Russian airports ranked by the number of flights in the month of 
-- August 2017

select distinct(departure_airport), count(flight_id) as no_of_flights  
from bookings.flights
where actual_departure between '2017-08-01 00:00:00' and '2017-08-31 23:59:00'
group by 1
order by 2 desc;

-- Flights routes from airports in the city of Moscow
-- ranked by the number of delays in the month of 
-- August 2017

select flight_no, count(flight_no) as no_of_problems, departure_airport, arrival_airport 
from flights 
where actual_arrival != scheduled_arrival 
and departure_airport IN ('DME', 'SVO', 'VKO')
and scheduled_departure between '2017-08-01 00:00:00' and '2017-08-31 23:59:00'
and actual_arrival is not null 
group by 1, 3, 4
order by 2 desc;














