--Итоговая работа по SQL обычному

-- Задание №1 ==============================================================================================================
--Какие самолеты имеют более 50 посадочных мест?
with cte_seat as 
(
	select 
		aircraft_code, 
		count(aircraft_code) as "Колличество мест"
	from seats s
	group by aircraft_code
) 
select 
	a.model,
	"Колличество мест" 
	from aircrafts a 
		join cte_seat s on a.aircraft_code = s.aircraft_code
where "Колличество мест" > 50

--Задание №2================================================================================================================
--В каких аэропортах есть рейсы, в рамках которых можно добраться бизнес - классом дешевле, чем эконом - классом?
with price as --Вариант 1
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
		min(min_business) as "Бизнесс", max(max_economy) as "Эконом" from price
	group by flight_id
	having max(max_economy) is not null and  min(min_business) is not null
)
	select 
		fl.flight_id, 
		a.airport_name 
	from fli fl
		join flights f on fl.flight_id = f.flight_id 
		join airports a on f.arrival_airport = a.airport_code
	where "Бизнесс" < "Эконом"
				



with mas as --Вариант 2
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
		min(amount) as "Бизнесс" 
	from mas 
	where fare_conditions = 'Business'
	group by 1,2
),
	eco as
(
	select 
		flight_id, 
		fare_conditions, 
		max(amount) as "Эконом" 
	from mas
	where fare_conditions = 'Economy'
	group by 1,2
),
	fli as
(
	select 
		b.flight_id, 
		b.Бизнесс, 
		e.Эконом 
	from bus b
		join eco e on e.flight_id = b.flight_id 
)
select 
	fl.flight_id, 
	a.airport_name 
from fli fl
	join flights f on fl.flight_id = f.flight_id 
	join airports a on f.arrival_airport = a.airport_code
where "Бизнесс" < "Эконом"


--Задание №3========================================================================================================================
--Есть ли самолеты, не имеющие бизнес - класса?
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
	
--Задание №4========================================================================================================================
--Найдите количество занятых мест для каждого рейса, процентное отношение количества занятых мест к общему количеству мест в самолете, добавьте накопительный итог вывезенных пассажиров по каждому аэропорту на каждый день.
with a as 
(
select                                 
	a.flight_id,
	a.actual_departure,
	a.airport_name,
	"Всего посадочных мест"
 from 
(
	select 
		f.flight_id,
		a2.airport_name,
		f.actual_departure,
		count(s.seat_no)over(partition by f.flight_id) as "Всего посадочных мест" 
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
	"занятых мест в самолете"  
from    
(
	select 
		f.flight_id,
		count(ticket_no) over (partition by f.flight_id) as "занятых мест в самолете"
	from flights f 
			left join boarding_passes bp on bp.flight_id = f.flight_id
) as b
group by b.flight_id,"занятых мест в самолете"
)
select 
	a.flight_id,
	a.actual_departure::date,
	a.airport_name,
	a."Всего посадочных мест",
	b."занятых мест в самолете",
	round((b."занятых мест в самолете"/a."Всего посадочных мест"::numeric)*100, 2) as procent,
	sum(b."занятых мест в самолете")over(partition by a.airport_name order by a.actual_departure)
from a 
	join b on a.flight_id = b.flight_id

--Задание №5========================================================================================================
--Найдите процентное соотношение перелетов по маршрутам от общего количества перелетов. 
--Выведите в результат названия аэропортов и процентное отношение.

	select distinct 
		concat(departure_airport,'-', arrival_airport) as "Маршрут",
		count(flight_id)over(partition by concat(departure_airport,'-', arrival_airport)) as "Перелеты по маршрутам",
		count(flight_id)over() as "Общее кол-во перелетов",
		round((count(flight_id)over(partition by concat(departure_airport,'-', arrival_airport))/count(flight_id)over()::numeric)*100, 2) 
	from flights f 


--Задание №6=======================================================================================================
--Выведите количество пассажиров по каждому коду сотового оператора, если учесть, что код оператора - это три символа после +7	
	select
		left(split_part(contact_data::text,'"phone": "+7', 2),3) as "Код оператора",
		count(left(split_part(contact_data::text,'"phone": "+7', 2),3)) as "Пассажиров"
	from tickets t
	group by left(split_part(contact_data::text,'"phone": "+7', 2),3)
	
--Задание №7=======================================================================================================
--Между какими городами не существует перелетов?

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
	tab.departure as "Аэропорт отправления",
	tab.arrival as "Аэропорт прибытия",
	a2.city as "Город отправления",
	a.city as "Город прибытия",
	concat(a2.city, ' - ', a.city) as "Маршрут"
from tab 
	join airports a on tab.arrival = a.airport_code 
	join airports a2 on tab.departure = a2.airport_code
	
--Задание №8=======================================================================================================
--Классифицируйте финансовые обороты (сумма стоимости билетов) по маршрутам:
--До 50 млн - low
--От 50 млн включительно до 150 млн - middle
--От 150 млн включительно - high
--Выведите в результат количество маршрутов в каждом классе.

with route as 
(
	select 
		concat(f.departure_airport, ' - ', f.arrival_airport) as "Маршрут",
		sum(amount) as "Сумма"
	from flights f
		join ticket_flights tf on tf.flight_id = f.flight_id
	group by concat(f.departure_airport, ' - ', f.arrival_airport)
),
	classific as
(
	select 
		"Маршрут",
		"Сумма",
		case when 0 < "Сумма"  and "Сумма" < 50000000 then 'low'
			 when "Сумма" >= 50000000 and "Сумма" < 150000000 then 'middle' 
			 else 'high' end "Class"	
	from route
)
select 
	"Class",
	count("Маршрут")
from classific
group by "Class"

--Задание №9======================================================================================================
--Выведите пары городов между которыми расстояние более 5000 км
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
	round(6371*(acos(sin(latitude_a)*sin(latitude_b) + cos(latitude_a)*cos(latitude_b)*(cos(longitude_a - longitude_b))))::numeric, 0) as "Расстояние между городами"
from city
where round(6371*(acos(sin(latitude_a)*sin(latitude_b) + cos(latitude_a)*cos(latitude_b)*(cos(longitude_a - longitude_b))))::numeric, 0) > 5000