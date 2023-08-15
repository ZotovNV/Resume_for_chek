--=============== ������ 2. ������ � ������ ������ =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--�������� ���������� �������� ������� �� ������� �������.

select distinct city from city

--������� �2
--����������� ������ �� ����������� �������, ����� ������ ������� ������ �� ������,
--�������� ������� ���������� �� �L� � ������������� �� �a�, � �������� �� �������� ��������.

select distinct city from city
where city like'L%a' and city not like '% %'

--������� �3
--�������� �� ������� �������� �� ������ ������� ���������� �� ��������, ������� ����������� 
--� ���������� � 17 ���� 2005 ���� �� 19 ���� 2005 ���� ������������, 
--� ��������� ������� ��������� 1.00.
--������� ����� ������������� �� ���� �������.

select payment_id, amount, payment_date from payment p 
where payment_date::date between '17.06.2005' and '19.06.2005' and amount > 1.00
order by payment_date 

--������� �4
-- �������� ���������� � 10-�� ��������� �������� �� ������ �������.

select payment_id, payment_date, amount from payment order by payment_date desc limit 10

--������� �5
--�������� ��������� ���������� �� �����������:
--  1. ������� � ��� (� ����� ������� ����� ������)
--  2. ����������� �����
--  3. ����� �������� ���� email
--  4. ���� ���������� ���������� ������ � ���������� (��� �������)
--������ ������� ������� ������������ �� ������� �����.

select concat(last_name,' ', first_name) as "������� ���", email as "����������� ������", character_length(email) as "����� �������� ����", cast(last_update as date) as "����" from customer

--������� �6
--�������� ����� �������� ������ �������� �����������, ����� ������� KELLY ��� WILLIE.
--��� ����� � ������� � ����� �� �������� �������� ������ ���� ���������� � ������ �������.

select lower(first_name) as first_name, lower(last_name) as last_name, active  from customer
where (first_name = 'KELLY' or first_name = 'WILLIE') and active > 0

--======== �������������� ����� ==============

--������� �1
--�������� ����� �������� ���������� � �������, � ������� ������� "R" 
--� ��������� ������ ������� �� 0.00 �� 3.00 ������������, 
--� ����� ������ c ��������� "PG-13" � ���������� ������ ������ ��� ������ 4.00.

select film_id, title, description, rating, rental_rate  from film
where rating = 'R' and rental_rate  between '0.00' and '3.00' or rating = 'PG-13' and rental_rate >= '4.00'

--������� �2
--�������� ���������� � ��� ������� � ����� ������� ��������� ������.

select film_id, title, description, character_length(description) from film f 
order by character_length(description) desc limit 3

--������� �3
-- �������� Email ������� ����������, �������� �������� Email �� 2 ��������� �������:
--� ������ ������� ������ ���� ��������, ��������� �� @, 
--�� ������ ������� ������ ���� ��������, ��������� ����� @.

select customer_id, email, split_part(email, '@', 1) as "Email before @", split_part(email, '@', 2) as "Email after @" from customer

--������� �4
--����������� ������ �� ����������� �������, �������������� �������� � ����� ��������: 
--������ ����� ������ ���� ���������, ��������� ���������.

select customer_id, email, 
	concat(upper(left(split_part(email, '@', 1),1)),
	lower(substr(split_part(email, '@', 1),2))) as "Email before @", 
	concat(upper(left(split_part(email, '@', 2),1)),
	substr(split_part(email, '@', 2),2)) as "Email after @" 
from customer

--=============== ������ 3. ������ SQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--�������� ��� ������� ���������� ��� ����� ����������, 
--����� � ������ ����������.

select cu.address_id, concat(cu.first_name,' ', cu.last_name) as "��� �������", a.address, ci.city, co.country  
from customer cu
	join address a on cu.address_id = a.address_id 
	join city ci on a.city_id = ci.city_id
	join country co on ci.country_id = co.country_id 

--������� �2
--� ������� SQL-������� ���������� ��� ������� �������� ���������� ��� �����������.

select store_id as "�������", count(customer_id) as "���������� �����������"
from customer c
group by store_id 

--����������� ������ � �������� ������ �� ��������, 
--� ������� ���������� ����������� ������ 300-��.
--��� ������� ����������� ���������� �� ��������������� ������� 
--� �������������� ������� ���������.

select store_id as "�������", count(customer_id) as "���������� �����������"
from customer c
group by store_id having count(customer_id)>300

-- ����������� ������, ������� � ���� ���������� � ������ ��������, 
--� ����� ������� � ��� ��������, ������� �������� � ���� ��������.

select c.store_id as "�������", count(c.customer_id) as "���������� �����������", ci.city as "�����", concat(st.first_name,' ', st.last_name) as "��� ����������"
from customer c
	join store s on c.store_id = s.store_id 
	join staff st on s.store_id = st.store_id 
	join address a on s.address_id  = a.address_id
	join city ci on a.city_id = ci.city_id 	
group by c.store_id, ci.city, concat(st.first_name,' ', st.last_name)
having count(customer_id)>300
	 
--������� �3
--�������� ���-5 �����������, 
--������� ����� � ������ �� �� ����� ���������� ���������� �������

select concat(c.first_name,' ', c.last_name) as "��� �������", count(c.customer_id) as count, c.customer_id 
from customer c
	join rental r on c.customer_id = r.customer_id 
group by concat(c.first_name,' ', c.last_name), c.customer_id  
order by count desc
limit 10

--������� �4
--���������� ��� ������� ���������� 4 ������������� ����������:
--  1. ���������� �������, ������� �� ���� � ������
--  2. ����� ��������� �������� �� ������ ���� ������� (�������� ��������� �� ������ �����)
--  3. ����������� �������� ������� �� ������ ������
--  4. ������������ �������� ������� �� ������ ������

select concat(c.first_name,' ', c.last_name) as "��� ������� ����������", count(r.rental_id) as "���������� ������ � ������", round(sum(p.amount),0) as "����� ��������� ��������", min(p.amount) as "����������� ��������� �������", max(p.amount) as "������������ ��������� �������" 
from rental r 
	join payment p on r.rental_id = p.rental_id
	join customer c on p.customer_id = c.customer_id
group by r.customer_id, concat(c.first_name,' ', c.last_name)

--������� �5
--��������� ������ �� ������� ������� ��������� ����� �������� ������������ ���� ������� ����� �������,
 --����� � ���������� �� ���� ��� � ����������� ���������� �������. 
 --��� ������� ���������� ������������ ��������� ������������.
 
select t1.city as "����� 1", t2.city as "����� 2"
from city t1 
	cross join city t2
where t1.city != t2.city

--������� �6
--��������� ������ �� ������� rental � ���� ������ ������ � ������ (���� rental_date)
--� ���� �������� ������ (���� return_date), 
--��������� ��� ������� ���������� ������� ���������� ����, �� ������� ���������� ���������� ������.
 
select customer_id as "ID ����������", round(avg(return_date::date - rental_date::date), 2) as "������� ���������� ���� �� �������"  -- ��� �� ������� ������� ������ �� ������.
from rental	 
group by customer_id
order by customer_id

--======== �������������� ����� ==============

--������� �1
--���������� ��� ������� ������ ������� ��� ��� ����� � ������ � �������� ����� ��������� ������ ������ �� �� �����.

select f.title, f.rating, c."name" as "����", f.release_year as "��� ������", l."name", sum(p.amount) as "����� ��������� ������", count(r.rental_id) as "���������� �����"
from film f 
	left join inventory i on f.film_id = i.film_id 
	left join rental r on i.inventory_id = r.inventory_id 
	left join payment p on r.rental_id = p.rental_id
	left join film_category fc on f.film_id = fc.film_id 
	left join category c on fc.category_id = c.category_id
	Left join "language" l on f.language_id = l.language_id 
group by f.film_id, c."name", l."name" 
order by f.title asc

--������� �2
--����������� ������ �� ����������� ������� � �������� � ������� ������� ������, ������� �� ���� �� ����� � ������.

select f.title, f.rating, c."name" as "����", f.release_year as "��� ������", l."name", sum(p.amount) as "����� ��������� ������", count(r.rental_id) as "���������� �����"
from film f 
	left join inventory i on f.film_id = i.film_id 
	left join rental r on i.inventory_id = r.inventory_id 
	left join payment p on r.rental_id = p.rental_id
	left join film_category fc on f.film_id = fc.film_id 
	left join category c on fc.category_id = c.category_id
	Left join "language" l on f.language_id = l.language_id 
group by f.film_id, c."name", l."name"
having count(r.rental_id) = 0
order by f.title asc

--=============== ������ 4. ���������� � SQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--���� ������: ���� ����������� � �������� ����, �� ������� ����� ����� � ��������� � --���� �������, �������� ������ ���� �� �������� � ������ �������� � ������� �������� --� ���� ����� �����, ���� ����������� � ���������� �������, �� ������� ����� ����� � --� ��� ������� �������.
 


--������������� ���� ������, ���������� ��� �����������:
--� ���� (����������, ����������� � �. �.);
--� ���������� (�������, ���������� � �. �.);
--� ������ (������, �������� � �. �.).
--��� ������� �� �������: ����-���������� � ����������-������, ��������� ������ �� ������. ������ ������� �� ������� � film_actor.
--���������� � ��������-������������:
--� ������� ����������� ��������� ������.
--� �������������� �������� ������ ������������� ���������������;
--� ������������ ��������� �� ������ ��������� null-��������, �� ������ ����������� --��������� � ��������� ���������.
--���������� � �������� �� �������:
--� ������� ����������� ��������� � ������� ������.

--� �������� ������ �� ������� �������� ������� �������� ������ � ������� �� --���������� � ������ ������� �� 5 ����� � �������.
 
--�������� ������� �����

create table language
(
	id_language serial primary key,
	language_of_communication varchar(50) UNIQUE not null
);

--�������� ������ � ������� �����

insert into language 
(language_of_communication) 
values 
('Russian'),
('German'),
('Latvian'),
('Korean'),
('Austrian'),
('English');

--�������� ������� ����������

create table nationalities
(
id_nationalities serial primary key,
"national" varchar(50) UNIQUE not null
);

--�������� ������ � ������� ����������

insert into nationalities 
("national") 
values 
('the Russians'),
('the Germans'),
('the Latvians'),
('the Koreans'),
('the Austrians'),
('the Brits');

--�������� ������� ������

create table country
(
id_country serial primary key,
country varchar(50) UNIQUE not null
);

--�������� ������ � ������� ������

insert into country 
(country) 
values 
('Russia'),
('Germany'),
('Latvia'),
('Korea'),
('Austria'),
('England');

--�������� ������ ������� �� �������

create table language_nationalities( 
id_language integer references language,
id_nationalities integer references nationalities,
primary key (id_language,id_nationalities)
);

--�������� ������ � ������� �� �������

insert into language_nationalities (id_language, id_nationalities)        -- ������ ����� ???
values  (1, 1),
		(2, 2),
		(3, 3),
		(4, 4),
		(5, 5),
		(6, 6);

insert into language_nationalities (id_language, id_nationalities)        -- ������ ����� ???
select id_language, id_nationalities from language, nationalities         
where id_language = id_nationalities;

--�������� ������ ������� �� �������

create table nationalities_country(
id_country integer not null references country,
id_nationalities integer not null references nationalities,
primary key (id_country, id_nationalities)
);

--�������� ������ � ������� �� �������

insert into nationalities_country (id_nationalities, id_country)
select n.id_nationalities, c.id_country
from nationalities as n
join country as c on n.id_nationalities = c.id_country; 


select *
from country c 
join nationalities_country nc on c.id_country = nc.id_country 
join nationalities n  on nc.id_nationalities  = n.id_nationalities                        -- �������� ������� �������
join language_nationalities ln2 on n.id_nationalities  = ln2.id_nationalities 
join "language" l on ln2.id_language = l.id_language; 

--======== �������������� ����� ==============


--������� �1 
--�������� ����� ������� film_new �� ���������� ������:
--�   	film_name - �������� ������ - ��� ������ varchar(255) � ����������� not null
--�   	film_year - ��� ������� ������ - ��� ������ integer, �������, ��� �������� ������ ���� ������ 0
--�   	film_rental_rate - ��������� ������ ������ - ��� ������ numeric(4,2), �������� �� ��������� 0.99
--�   	film_duration - ������������ ������ � ������� - ��� ������ integer, ����������� not null � �������, ��� �������� ������ ���� ������ 0
--���� ��������� � �������� ����, �� ����� ��������� ������� ������� ������������ ����� �����.

create table film_new 
(
film_name varchar(255) not null,
film_year integer check (film_year > 0),
film_rental_rate numeric(4,2) default 0.99,
film_duration integer not null check (film_duration > 0)
);

--������� �2 
--��������� ������� film_new ������� � ������� SQL-�������, ��� �������� ������������� ������� ������:
--�       film_name - array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List']
--�       film_year - array[1994, 1999, 1985, 1994, 1993]
--�       film_rental_rate - array[2.99, 0.99, 1.99, 2.99, 3.99]
--�   	  film_duration - array[142, 189, 116, 142, 195]

insert into film_new 
select * from unnest (array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List'],
array[1994, 1999, 1985, 1994, 1993], 
array[2.99, 0.99, 1.99, 2.99, 3.99],
array[142, 189, 116, 142, 195]
);

--������� �3
--�������� ��������� ������ ������� � ������� film_new � ������ ����������, 
--��� ��������� ������ ���� ������� ��������� �� 1.41

update film_new 
set film_rental_rate = film_rental_rate + 1.41;

--������� �4
--����� � ��������� "Back to the Future" ��� ���� � ������, 
--������� ������ � ���� ������� �� ������� film_new

delete from film_new
where film_name = 'Back to the Future';

--������� �5
--�������� � ������� film_new ������ � ����� ������ ����� ������

insert into film_new (film_name, film_year, film_rental_rate, film_duration)
values ('Pride & Prejudice', 2005, 7.8, 129);

--������� �6
--�������� SQL-������, ������� ������� ��� ������� �� ������� film_new, 
--� ����� ����� ����������� ������� "������������ ������ � �����", ���������� �� �������

select film_name, film_year, film_rental_rate, film_duration, round(film_duration / 60,1) as "������������ ������ � �����" from film_new;

--������� �7 
--������� ������� film_new

drop table film_new

--=============== ������ 5. ������ � POSTGRESQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--�������� ������ � ������� payment � � ������� ������� ������� �������� ����������� ������� �������� ��������:

--1.	������������ ��� ������� �� 1 �� N �� ����

--2.	������������ ������� ��� ������� ����������, ���������� �������� ������ ���� �� ����

--3.	���������� ����������� ������ ����� ���� �������� ��� ������� ����������, ���������� ������ 
--	���� ������ �� ���� �������, � ����� �� ����� ������� �� ���������� � �������

--4.	������������ ������� ��� ������� ���������� �� ��������� ������� �� ���������� � ������� 
--	���, ����� ������� � ���������� ��������� ����� ���������� �������� ������.
--	����� ��������� �� ������ ����� ��������� SQL-������, � ����� ���������� ��� ������� � ����� �������.

select 
	p.customer_id,
	p.payment_id,
	p.payment_date,
	row_number () over(order by p.payment_date) as "1",--�� ����",
	row_number () over(partition by p.customer_id  order by p.payment_date) as "2",--��� ������� ���������� �� ����",
	sum(p.amount) over(partition by p.customer_id  order by p.payment_date, p.amount) as "3",--����� ���� ��������",
	dense_rank () over (partition by p.customer_id order by p.amount) as "4"--�� ��������� ������� �� ����������� � ��������",
from 
	payment p;

--������� �2
--� ������� ������� ������� �������� ��� ������� ���������� ��������� ������� � ��������� 
--������� �� ���������� ������ �� ��������� �� ��������� 0.0 � ����������� �� ����.

select 
	customer_id, 
	payment_id, 
	amount,
	lag (amount, 1, 0.0) over(partition by customer_id order by payment_date)
from 
	payment;

--������� �3
--� ������� ������� ������� ����������, �� ������� ������ ��������� ������ ���������� ������ ��� ������ ��������.
	
select
	customer_id,
	amount as "������� ������",
	lead(amount, 1) over(partition by customer_id order by payment_date) as "��������� ������",
	(amount - (lead(amount, 1) over(partition by customer_id order by payment_date ))) as "������� - ��������� ������"
from
	payment p; 
	

--������� �4
--� ������� ������� ������� ��� ������� ���������� �������� ������ � ��� ��������� ������ ������.

select
	*
from (
	 select
		*,
		row_number () over(partition by customer_id order by payment_date desc) as "pay �"
	 from
		payment p
		) as order_pay
 where "pay �" = 1;



select   -- ��� � �� ����� ��� �������� last_value, ������ � ������ �� ��������� ��� ����� 
	*
from (
	 select
		*,
		last_value(payment_date) over(partition by customer_id order by payment_date desc) as b
	 from
		payment p
		) as pay
 where b = payment_date;



--======== �������������� ����� ==============

--������� �1
--� ������� ������� ������� �������� ��� ������� ���������� ����� ������ �� ������ 2005 ���� 
--� ����������� ������ �� ������� ���������� � �� ������ ���� ������� (��� ����� �������) 
--� ����������� �� ����.

select
	*
from (
	select 
		staff_id,
		payment_date::date,
		sum(amount)over(partition by staff_id, payment_date::date order by payment_date::date ) as "sum_amount",
		sum(amount)over(partition by staff_id order by payment_date::date) as "sum"	
	from payment
	where date_trunc('month', payment_date) = '2005-08-01'
) as h
group by staff_id, "sum", "sum_amount", payment_date::date
	
--������� �2
--20 ������� 2005 ���� � ��������� ��������� �����: ���������� ������� ������ ������� �������
--�������������� ������ �� ��������� ������. � ������� ������� ������� �������� ���� �����������,
--������� � ���� ���������� ����� �������� ������
	
select 
	*
from (
	select
		customer_id,
		payment_date,
		row_number()over(order by payment_date) as payment_number
	from
		payment	
	where 
		payment_date::date = '20-08-2005' 
) as b	
where payment_number % 100 = 0

--������� �3
--��� ������ ������ ���������� � �������� ����� SQL-�������� �����������, ������� �������� ��� �������:
-- 1. ����������, ������������ ���������� ���������� �������
-- 2. ����������, ������������ ������� �� ����� ������� �����
-- 3. ����������, ������� ��������� ��������� �����
select 
	max(gr),
	nano.customer_id,
	nan
from ( 
	select 
		sum(p.amount)over(partition by cu.customer_id order by p.amount) as gp,
		row_number ()over(partition by cu.customer_id order by r.inventory_id) as gr,
		cu.customer_id,
		r.rental_id,
		concat(cu.first_name,' ', cu.last_name) as nan
	from customer cu
		join address a on cu.address_id = a.address_id 
		join city ci on a.city_id = ci.city_id
		join country co on ci.country_id = co.country_id 
		join payment p on cu.customer_id = p.customer_id 
		join rental r on cu.customer_id = r.customer_id 
) as nano
group by nano.customer_id, nan	 
order by max(gr) desc limit 5

---------------------------------------------------------------

	select 
		--sum(p.amount)over(partition by cu.customer_id order by p.amount) as gp,
		--row_number ()over(partition by cu.customer_id order by r.inventory_id) as gr,
	
	select	
		*,
		concat(cu.first_name,' ', cu.last_name) as nan
	from customer cu
		join address a on cu.address_id = a.address_id 
		join city ci on a.city_id = ci.city_id
		join country co on ci.country_id = co.country_id 
		join payment p on cu.customer_id = p.customer_id 
		join rental r on cu.customer_id = r.customer_id 
		
--=============== ������ 6. POSTGRESQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--�������� SQL-������, ������� ������� ��� ���������� � ������� 
--�� ����������� ��������� "Behind the Scenes".

explain analyze
select * 
from film
where array_position(special_features, 'Behind the Scenes') is not null;

--������� �2
--�������� ��� 2 �������� ������ ������� � ��������� "Behind the Scenes",
--��������� ������ ������� ��� ��������� ����� SQL ��� ������ �������� � �������.

explain analyze
select *
from film f 
where special_features && '{"Behind the Scenes"}';

explain analyze
select * 
from film f 
where 'Behind the Scenes' = any(special_features);

explain analyze
select *
from film
where special_features @> '{"Behind the Scenes"}';

explain analyze
select *
from film f 
where array_to_string(special_features, ',') like '%Behind the Scenes%';


--������� �3
--��� ������� ���������� ���������� ������� �� ���� � ������ ������� 
--�� ����������� ��������� "Behind the Scenes.
	
--������������ ������� ��� ���������� �������: ����������� ������ �� ������� 1, 
--���������� � CTE. CTE ���������� ������������ ��� ������� �������.
	
with film_cte
as
	(
	select *
	from film
	where array_position(special_features, 'Behind the Scenes') is not null
	)
select 
	r.customer_id,
	count(i.film_id) as "�����������"
from rental r
	 join inventory i on i.inventory_id = r.inventory_id 
	 join film_cte on film_cte.film_id = i.film_id 
group by 
	r.customer_id
order by
	r.customer_id;
	
	
--������� �4
--��� ������� ���������� ���������� ������� �� ���� � ������ �������
-- �� ����������� ��������� "Behind the Scenes".

--������������ ������� ��� ���������� �������: ����������� ������ �� ������� 1,
--���������� � ���������, ������� ���������� ������������ ��� ������� �������.

select 
	*
from (
	select 
		r.customer_id,
		count(f.film_id)over(partition by r.customer_id) as col
	from film f
		join inventory i on f.film_id = i.film_id 
		join rental r on i.inventory_id = r.inventory_id
	where array_position(special_features, 'Behind the Scenes') is not null
		) as abc
group by 
	abc.col, abc.customer_id
order by 
	abc.customer_id;
	
--������� �5
--�������� ����������������� ������������� � �������� �� ����������� �������
--� �������� ������ ��� ���������� ������������������ �������������

create materialized view film_uni as
	( 
	select 
		*
	from (
		select 
			r.customer_id,
			count(f.film_id)over(partition by r.customer_id) as col
		from film f
			join inventory i on f.film_id = i.film_id 
			join rental r on i.inventory_id = r.inventory_id
		where array_position(special_features, 'Behind the Scenes') is not null
			) as abc
	group by 
		abc.col, abc.customer_id
	order by 
		abc.customer_id		
	);
	
	
refresh materialized view film_uni;

--������� �6
--� ������� explain analyze ��������� ������ �������� ���������� ��������
-- �� ���������� ������� � �������� �� �������:

--1. ����� ���������� ��� �������� ����� SQL, ������������ ��� ���������� ��������� �������, 
--   ����� �������� � ������� ���������� �������
--2. ����� ������� ���������� �������� �������: 
--   � �������������� CTE ��� � �������������� ����������

explain analyze
with film_cte
as
	(
	select *
	from film
	where array_position(special_features, 'Behind the Scenes') is not null
	)
select 
	r.customer_id,
	count(i.film_id) as "�����������"
from rental r
	 join inventory i on i.inventory_id = r.inventory_id 
	 join film_cte on film_cte.film_id = i.film_id 
group by 
	r.customer_id
order by
	r.customer_id; 

--================================================

explain analyze	
select 
	*
from (
	select 
		r.customer_id,
		count(f.film_id)over(partition by r.customer_id) as col
	from film f
		join inventory i on f.film_id = i.film_id 
		join rental r on i.inventory_id = r.inventory_id
	where array_position(special_features, 'Behind the Scenes') is not null
		) as abc
group by 
	abc.col, abc.customer_id
order by 
	abc.customer_id;

--������:
--1. ������ �������� ��������� ��������� ����� ��������� && � any. (0.345, 0.319, 0.318, 0,348, 0.548)
--2.����� CTE ����������� ������� ��� ����� ��������� ����� � 2 ����. (7.455, 12.065)

 

--======== �������������� ����� ==============

--������� �1
--���������� ��� ������� � ����� ������ �� ����� ���������

explain analyze
select distinct cu.first_name  || ' ' || cu.last_name as name, 
	count(ren.iid) over (partition by cu.customer_id)
from customer cu
full outer join 
	(select *, r.inventory_id as iid, inv.sf_string as sfs, r.customer_id as cid
	from rental r 
	full outer join 
		(select *, unnest(f.special_features) as sf_string
		from inventory i
		full outer join film f on f.film_id = i.film_id) as inv 
		on r.inventory_id = inv.inventory_id) as ren 
	on ren.cid = cu.customer_id 
where ren.sfs like '%Behind the Scenes%'
order by count desc;

-- ����������� �� 47.928 ms
-- ����� ����� ������ �������� ���������� �� cu.customer_id � ���� "count(ren.iid) over (partition by cu.customer_id)"
--c 0.372 �� ���� �������� ����� 33.370, ���� ������� ��� � ������� �������� ���� c 33.382 �� 46.677, ���� �� ����� ��� ���������� ������ ���� �� ������ distinct.


