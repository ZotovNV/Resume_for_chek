--�������� ������ �� SQL ��������

-- ������� �1 ==============================================================================================================
--����� �������� ����� ����� 50 ���������� ����?
with cte_seat as 
(
	select 
		aircraft_code, 
		count(aircraft_code) as "����������� ����"
	from seats s
	group by aircraft_code
) 
select 
	a.model,
	"����������� ����" 
	from aircrafts a 
		join cte_seat s on a.aircraft_code = s.aircraft_code
where "����������� ����" > 50

--������� �2================================================================================================================
--� ����� ���������� ���� �����, � ������ ������� ����� ��������� ������ - ������� �������, ��� ������ - �������?
with price as --������� 1
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
		min(min_business) as "�������", max(max_economy) as "������" from price
	group by flight_id
	having max(max_economy) is not null and  min(min_business) is not null
)
	select 
		fl.flight_id, 
		a.airport_name 
	from fli fl
		join flights f on fl.flight_id = f.flight_id 
		join airports a on f.arrival_airport = a.airport_code
	where "�������" < "������"
				



with mas as --������� 2
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
		min(amount) as "�������" 
	from mas 
	where fare_conditions = 'Business'
	group by 1,2
),
	eco as
(
	select 
		flight_id, 
		fare_conditions, 
		max(amount) as "������" 
	from mas
	where fare_conditions = 'Economy'
	group by 1,2
),
	fli as
(
	select 
		b.flight_id, 
		b.�������, 
		e.������ 
	from bus b
		join eco e on e.flight_id = b.flight_id 
)
select 
	fl.flight_id, 
	a.airport_name 
from fli fl
	join flights f on fl.flight_id = f.flight_id 
	join airports a on f.arrival_airport = a.airport_code
where "�������" < "������"


--������� �3========================================================================================================================
--���� �� ��������, �� ������� ������ - ������?
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
	
--������� �4========================================================================================================================
--������� ���������� ������� ���� ��� ������� �����, ���������� ��������� ���������� ������� ���� � ������ ���������� ���� � ��������, �������� ������������� ���� ���������� ���������� �� ������� ��������� �� ������ ����.
with a as 
(
select                                 
	a.flight_id,
	a.actual_departure,
	a.airport_name,
	"����� ���������� ����"
 from 
(
	select 
		f.flight_id,
		a2.airport_name,
		f.actual_departure,
		count(s.seat_no)over(partition by f.flight_id) as "����� ���������� ����" 
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
	"������� ���� � ��������"  
from    
(
	select 
		f.flight_id,
		count(ticket_no) over (partition by f.flight_id) as "������� ���� � ��������"
	from flights f 
			left join boarding_passes bp on bp.flight_id = f.flight_id
) as b
group by b.flight_id,"������� ���� � ��������"
)
select 
	a.flight_id,
	a.actual_departure::date,
	a.airport_name,
	a."����� ���������� ����",
	b."������� ���� � ��������",
	round((b."������� ���� � ��������"/a."����� ���������� ����"::numeric)*100, 2) as procent,
	sum(b."������� ���� � ��������")over(partition by a.airport_name order by a.actual_departure)
from a 
	join b on a.flight_id = b.flight_id

--������� �5========================================================================================================
--������� ���������� ����������� ��������� �� ��������� �� ������ ���������� ���������. 
--�������� � ��������� �������� ���������� � ���������� ���������.

	select distinct 
		concat(departure_airport,'-', arrival_airport) as "�������",
		count(flight_id)over(partition by concat(departure_airport,'-', arrival_airport)) as "�������� �� ���������",
		count(flight_id)over() as "����� ���-�� ���������",
		round((count(flight_id)over(partition by concat(departure_airport,'-', arrival_airport))/count(flight_id)over()::numeric)*100, 2) 
	from flights f 


--������� �6=======================================================================================================
--�������� ���������� ���������� �� ������� ���� �������� ���������, ���� ������, ��� ��� ��������� - ��� ��� ������� ����� +7	
	select
		left(split_part(contact_data::text,'"phone": "+7', 2),3) as "��� ���������",
		count(left(split_part(contact_data::text,'"phone": "+7', 2),3)) as "����������"
	from tickets t
	group by left(split_part(contact_data::text,'"phone": "+7', 2),3)
	
--������� �7=======================================================================================================
--����� ������ �������� �� ���������� ���������?

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
	tab.departure as "�������� �����������",
	tab.arrival as "�������� ��������",
	a2.city as "����� �����������",
	a.city as "����� ��������",
	concat(a2.city, ' - ', a.city) as "�������"
from tab 
	join airports a on tab.arrival = a.airport_code 
	join airports a2 on tab.departure = a2.airport_code
	
--������� �8=======================================================================================================
--��������������� ���������� ������� (����� ��������� �������) �� ���������:
--�� 50 ��� - low
--�� 50 ��� ������������ �� 150 ��� - middle
--�� 150 ��� ������������ - high
--�������� � ��������� ���������� ��������� � ������ ������.

with route as 
(
	select 
		concat(f.departure_airport, ' - ', f.arrival_airport) as "�������",
		sum(amount) as "�����"
	from flights f
		join ticket_flights tf on tf.flight_id = f.flight_id
	group by concat(f.departure_airport, ' - ', f.arrival_airport)
),
	classific as
(
	select 
		"�������",
		"�����",
		case when 0 < "�����"  and "�����" < 50000000 then 'low'
			 when "�����" >= 50000000 and "�����" < 150000000 then 'middle' 
			 else 'high' end "Class"	
	from route
)
select 
	"Class",
	count("�������")
from classific
group by "Class"

--������� �9======================================================================================================
--�������� ���� ������� ����� �������� ���������� ����� 5000 ��
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
	round(6371*(acos(sin(latitude_a)*sin(latitude_b) + cos(latitude_a)*cos(latitude_b)*(cos(longitude_a - longitude_b))))::numeric, 0) as "���������� ����� ��������"
from city
where round(6371*(acos(sin(latitude_a)*sin(latitude_b) + cos(latitude_a)*cos(latitude_b)*(cos(longitude_a - longitude_b))))::numeric, 0) > 5000