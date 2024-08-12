--Г€ГІГ®ГЈГ®ГўГ Гї Г°Г ГЎГ®ГІГ  ГЇГ® SQL Г®ГЎГ»Г·Г­Г®Г¬Гі

-- Г‡Г Г¤Г Г­ГЁГҐ В№1==============================================================================================================
with cte_seat as 
(
	select 
		aircraft_code, 
		count(aircraft_code) as "ГЉГ®Г«Г«ГЁГ·ГҐГ±ГІГўГ® Г¬ГҐГ±ГІ"
	from seats s
	group by aircraft_code
) 
select 
	a.model,
	"ГЉГ®Г«Г«ГЁГ·ГҐГ±ГІГўГ® Г¬ГҐГ±ГІ" 
	from aircrafts a 
		join cte_seat s on a.aircraft_code = s.aircraft_code
where "ГЉГ®Г«Г«ГЁГ·ГҐГ±ГІГўГ® Г¬ГҐГ±ГІ" > 50

--Г‡Г Г¤Г Г­ГЁГҐ В№2================================================================================================================

with price as --Г‚Г Г°ГЁГ Г­ГІ 1
(	
	select 
		flight_id, 
		fare_conditions,
		case when fare_conditions  = 'Business' then min(amount) end min_business,
		case when fare_conditions  = 'Economy' then max(amount) end max_economy
	from ticket_flights
	where fare_conditions = 'Business' or fare_conditions = 'Economy'
	group by 1,2
),	
	fli as
(
	select 
		flight_id, 
		min(min_business) as "ГЃГЁГ§Г­ГҐГ±Г±", max(max_economy) as "ГќГЄГ®Г­Г®Г¬" from price
	group by flight_id
	having max(max_economy) is not null and  min(min_business) is not null
)
	select 
		fl.flight_id, 
		a.airport_name 
	from fli fl
		join flights f on fl.flight_id = f.flight_id 
		join airports a on f.arrival_airport = a.airport_code
	where "ГЃГЁГ§Г­ГҐГ±Г±" < "ГќГЄГ®Г­Г®Г¬"
				



with mas as --Г‚Г Г°ГЁГ Г­ГІ 2
(
	select 
		flight_id, 
		fare_conditions, 
		amount 
	from ticket_flights tf
	group by 1,2,3
),
	bus as
(
	select 
		flight_id, 
		fare_conditions, 
		min(amount) as "ГЃГЁГ§Г­ГҐГ±Г±" 
	from mas 
	where fare_conditions = 'Business'
	group by 1,2
),
	eco as
(
	select 
		flight_id, 
		fare_conditions, 
		max(amount) as "ГќГЄГ®Г­Г®Г¬" 
	from mas
	where fare_conditions = 'Economy'
	group by 1,2
),
	fli as
(
	select 
		b.flight_id, 
		b.ГЃГЁГ§Г­ГҐГ±Г±, 
		e.ГќГЄГ®Г­Г®Г¬ 
	from bus b
		join eco e on e.flight_id = b.flight_id 
)
select 
	fl.flight_id, 
	a.airport_name 
from fli fl
	join flights f on fl.flight_id = f.flight_id 
	join airports a on f.arrival_airport = a.airport_code
where "ГЃГЁГ§Г­ГҐГ±Г±" < "ГќГЄГ®Г­Г®Г¬"


--Г‡Г Г¤Г Г­ГЁГҐ В№3========================================================================================================================

with bus as 
(
	select 
		flight_id, 
		fare_conditions 
	from ticket_flights 
	where (fare_conditions != 'Business')
	group by 1,2
)
select 
	array_agg(distinct(aircraft_code)) 
from flights f
	join bus b on f.flight_id = b.flight_id
	
--Г‡Г Г¤Г Г­ГЁГҐ В№4========================================================================================================================

with a as 
(
select                                 
	a.flight_id,
	a.actual_departure,
	a.airport_name,
	"Г‚Г±ГҐГЈГ® ГЇГ®Г±Г Г¤Г®Г·Г­Г»Гµ Г¬ГҐГ±ГІ"
 from 
(
	select 
		f.flight_id,
		a2.airport_name,
		f.actual_departure,
		count(s.seat_no)over(partition by f.flight_id) as "Г‚Г±ГҐГЈГ® ГЇГ®Г±Г Г¤Г®Г·Г­Г»Гµ Г¬ГҐГ±ГІ" 
	from flights f
			join aircrafts ai on f.aircraft_code  = ai.aircraft_code 
			join seats s on ai.aircraft_code = s.aircraft_code
			join airports a2 on f.departure_airport = a2.airport_code
) as a
group by 1,2,3,4
),
b as 
(
select                             
	b.flight_id,
	"Г§Г Г­ГїГІГ»Гµ Г¬ГҐГ±ГІ Гў Г±Г Г¬Г®Г«ГҐГІГҐ"  
from    
(
	select 
		f.flight_id,
		count(ticket_no) over (partition by f.flight_id) as "Г§Г Г­ГїГІГ»Гµ Г¬ГҐГ±ГІ Гў Г±Г Г¬Г®Г«ГҐГІГҐ"
	from flights f 
			left join boarding_passes bp on bp.flight_id = f.flight_id
) as b
group by b.flight_id,"Г§Г Г­ГїГІГ»Гµ Г¬ГҐГ±ГІ Гў Г±Г Г¬Г®Г«ГҐГІГҐ"
)
select 
	a.flight_id,
	a.actual_departure::date,
	a.airport_name,
	a."Г‚Г±ГҐГЈГ® ГЇГ®Г±Г Г¤Г®Г·Г­Г»Гµ Г¬ГҐГ±ГІ",
	b."Г§Г Г­ГїГІГ»Гµ Г¬ГҐГ±ГІ Гў Г±Г Г¬Г®Г«ГҐГІГҐ",
	round((b."Г§Г Г­ГїГІГ»Гµ Г¬ГҐГ±ГІ Гў Г±Г Г¬Г®Г«ГҐГІГҐ"/a."Г‚Г±ГҐГЈГ® ГЇГ®Г±Г Г¤Г®Г·Г­Г»Гµ Г¬ГҐГ±ГІ"::numeric)*100, 2) as procent,
	sum(b."Г§Г Г­ГїГІГ»Гµ Г¬ГҐГ±ГІ Гў Г±Г Г¬Г®Г«ГҐГІГҐ")over(partition by a.airport_name order by a.actual_departure)
from a 
	join b on a.flight_id = b.flight_id

--Г‡Г Г¤Г Г­ГЁГҐ В№5========================================================================================================

	select distinct 
		concat(departure_airport,'-', arrival_airport) as "ГЊГ Г°ГёГ°ГіГІ",
		count(flight_id)over(partition by concat(departure_airport,'-', arrival_airport)) as "ГЏГҐГ°ГҐГ«ГҐГІГ» ГЇГ® Г¬Г Г°ГёГ°ГіГІГ Г¬",
		count(flight_id)over() as "ГЋГЎГ№ГҐГҐ ГЄГ®Г«-ГўГ® ГЇГҐГ°ГҐГ«ГҐГІГ®Гў",
		round((count(flight_id)over(partition by concat(departure_airport,'-', arrival_airport))/count(flight_id)over()::numeric)*100, 2) 
	from flights f 


--Г‡Г Г¤Г Г­ГЁГҐ В№6=======================================================================================================
	
	select
		left(split_part(contact_data::text,'"phone": "+7', 2),3) as "ГЉГ®Г¤ Г®ГЇГҐГ°Г ГІГ®Г°Г ",
		count(left(split_part(contact_data::text,'"phone": "+7', 2),3)) as "ГЏГ Г±Г±Г Г¦ГЁГ°Г®Гў"
	from tickets t
	group by left(split_part(contact_data::text,'"phone": "+7', 2),3)
	
--Г‡Г Г¤Г Г­ГЁГҐ В№7=======================================================================================================
with tab as
(
	select
		a.airport_code as departure, 
		a2.airport_code as arrival
	from airports a 
	cross join airports a2 
	where a.airport_code != a2.airport_code 
	except
	select distinct 
		departure_airport, 
		arrival_airport
	from flights f 
)
select
	tab.departure as "ГЂГЅГ°Г®ГЇГ®Г°ГІ Г®ГІГЇГ°Г ГўГ«ГҐГ­ГЁГї",
	tab.arrival as "ГЂГЅГ°Г®ГЇГ®Г°ГІ ГЇГ°ГЁГЎГ»ГІГЁГї",
	a2.city as "ГѓГ®Г°Г®Г¤ Г®ГІГЇГ°Г ГўГ«ГҐГ­ГЁГї",
	a.city as "ГѓГ®Г°Г®Г¤ ГЇГ°ГЁГЎГ»ГІГЁГї",
	concat(a2.city, ' - ', a.city) as "ГЊГ Г°ГёГ°ГіГІ"
from tab 
	join airports a on tab.arrival = a.airport_code 
	join airports a2 on tab.departure = a2.airport_code
	
--Г‡Г Г¤Г Г­ГЁГҐ В№8=======================================================================================================

with route as 
(
	select 
		concat(f.departure_airport, ' - ', f.arrival_airport) as "ГЊГ Г°ГёГ°ГіГІ",
		sum(amount) as "Г‘ГіГ¬Г¬Г "
	from flights f
		join ticket_flights tf on tf.flight_id = f.flight_id
	group by concat(f.departure_airport, ' - ', f.arrival_airport)
),
	classific as
(
	select 
		"ГЊГ Г°ГёГ°ГіГІ",
		"Г‘ГіГ¬Г¬Г ",
		case when 0 < "Г‘ГіГ¬Г¬Г "  and "Г‘ГіГ¬Г¬Г " < 50000000 then 'low'
			 when "Г‘ГіГ¬Г¬Г " >= 50000000 and "Г‘ГіГ¬Г¬Г " < 150000000 then 'middle' 
			 else 'high' end "Class"	
	from route
)
select 
	"Class",
	count("ГЊГ Г°ГёГ°ГіГІ")
from classific
group by "Class"

--Г‡Г Г¤Г Г­ГЁГҐ В№9======================================================================================================

select * from airports a 

with city as
(
	select
			a.airport_name as departure, 
			a2.airport_name as arrival,
			a.longitude as longitude_a,
			a.latitude as latitude_a,
			a2.longitude as longitude_b,
			a2.latitude as latitude_b
	from airports a 
	cross join airports a2 
	where a.airport_name != a2.airport_name
)
select 
	concat(departure, ' - ', arrival),
	round(6371*(acos(sin(latitude_a)*sin(latitude_b) + cos(latitude_a)*cos(latitude_b)*(cos(longitude_a - longitude_b))))::numeric, 0) as "ГђГ Г±Г±ГІГ®ГїГ­ГЁГҐ Г¬ГҐГ¦Г¤Гі ГЈГ®Г°Г®Г¤Г Г¬ГЁ"
from city
where round(6371*(acos(sin(latitude_a)*sin(latitude_b) + cos(latitude_a)*cos(latitude_b)*(cos(longitude_a - longitude_b))))::numeric, 0) > 5000
