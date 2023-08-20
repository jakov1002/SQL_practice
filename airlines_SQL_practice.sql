SELECT a.aircraft_code, f.status FROM aircrafts_data a
INNER JOIN flights f ON f.aircraft_code = a.aircraft_code
where scheduled_departure between '2017-08-31 00:00:00' 
and '2017-08-31 23:59:59' and arrival_airport = 'DME'


--Highest-grossing airports by tickets sold (in EUR) in the month of August (2017)
select f.departure_airport, sum(tf.amount*0.0142) from flights f
inner join ticket_flights tf on tf.flight_id = f.flight_id 
where actual_departure between '2017-08-01 00:00:00' and '2017-08-31 23:59:00'
group by 1
order by 2 desc

UPDATE airports_data 
SET airport_name = (airport_name ->>'en')::text
WHERE airport_name IS NOT NULL;

UPDATE airports_data 
SET airport_name = airport_name ->>'en'
WHERE airport_name IS NOT NULL;

UPDATE airports_data 
SET airport_name = jsonb_set(airport_name, '{en}', (airport_name ->> 'en')::jsonb)
WHERE airport_name IS NOT NULL;

UPDATE airports_data 
SET airport_name = airport_name -> 'en'::text
WHERE airport_name IS NOT NULL
  AND airport_name->'en' IS NOT NULL;
 
UPDATE airports_data 
SET city = city -> 'en'::text
WHERE city  IS NOT NULL
  AND city ->'en' IS NOT NULL;

 --Highest-grossing aircraft models by tickets sold (in EUR) in the month of August (2017)
select acd.model, sum(tf.amount*0.0142) from aircrafts_data acd
inner join flights f on f.aircraft_code = acd.aircraft_code 
inner join ticket_flights tf on tf.flight_id = f.flight_id 
where actual_departure between '2017-08-01 00:00:00' and '2017-08-31 23:59:00'
group by 1
order by 2 desc

--Highest-grossing aircraft classes from each aircraft model by tickets sold (in EUR) in the month of August (2017)
select acd.model, tf.fare_conditions, sum(tf.amount*0.0142) from aircrafts_data acd
inner join flights f on f.aircraft_code = acd.aircraft_code 
inner join ticket_flights tf on tf.flight_id = f.flight_id 
where actual_departure between '2017-08-01 00:00:00' and '2017-08-31 23:59:00'
group by 1, 2
order by 3 desc

--Top 10 passengers with the largest amount spent on flight tickets
--who flew more than 3 times in the month of August (2017)
select t.passenger_id, count(t.passenger_id) as times_flown, t.passenger_name, sum(tf.amount*0.0142) from tickets t
inner join ticket_flights tf on tf.ticket_no  = t.ticket_no 
inner join flights f on f.flight_id = tf.flight_id
where actual_departure between '2017-08-01 00:00:00' and '2017-08-31 23:59:00'
group by 1, 3 
having count(t.passenger_id) > 3
order by 4 desc
limit 10


--Average number of seats for each aircraft model 
--that flew from one of the airports in the city of Moscow in
--the month of August 2017.
with no_of_seats as (
	select ad.model, count(distinct seat_no) as nr
	from aircrafts_data ad
	inner join seats s on s.aircraft_code = ad.aircraft_code
	inner join flights f on f.aircraft_code = s.aircraft_code
	where departure_airport = 'DME' 
	and scheduled_departure between '2017-08-01 00:00:00' and '2017-08-31 23:59:00'
	group by 1
	order by 2 desc);
	select avg (nr) from no_of_seats as avg_no_of_seats
	
-- Aircraft models whose flights have been cancelled the most times	
select acd.model, count(*) as no_cancelled, f.aircraft_code 
from aircrafts_data acd
inner join flights f on f.aircraft_code = acd.aircraft_code
where status = 'Cancelled' 
group by 1, 3
order by 2 desc


-- The number of times each aircraft model flew 
-- and from which airport it flew the most times
-- in the month of August 2017
select acd.model, count(f.aircraft_code) as no_of_flights, max (departure_airport) 
from aircrafts_data acd
inner join flights f on f.aircraft_code = acd.aircraft_code
and actual_departure between '2017-08-01 00:00:00' and '2017-08-31 23:59:00'
group by 1
order by 2 desc

-- Airports with the most flights in the month of August 2017
-- (excluding cancelled flights)
select departure_airport, count (flight_id) as no_of_flights
from flights 
where actual_departure between '2017-08-01 00:00:00' and '2017-08-31 23:59:00'
group by 1
order by 2 desc





	









