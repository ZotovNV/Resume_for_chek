--=============== МОДУЛЬ 2. РАБОТА С БАЗАМИ ДАННЫХ =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите уникальные названия городов из таблицы городов.

select distinct city from city

--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания, чтобы запрос выводил только те города,
--названия которых начинаются на “L” и заканчиваются на “a”, и названия не содержат пробелов.

select distinct city from city
where city like'L%a' and city not like '% %'

--ЗАДАНИЕ №3
--Получите из таблицы платежей за прокат фильмов информацию по платежам, которые выполнялись 
--в промежуток с 17 июня 2005 года по 19 июня 2005 года включительно, 
--и стоимость которых превышает 1.00.
--Платежи нужно отсортировать по дате платежа.

select payment_id, amount, payment_date from payment p 
where payment_date::date between '17.06.2005' and '19.06.2005' and amount > 1.00
order by payment_date 

--ЗАДАНИЕ №4
-- Выведите информацию о 10-ти последних платежах за прокат фильмов.

select payment_id, payment_date, amount from payment order by payment_date desc limit 10

--ЗАДАНИЕ №5
--Выведите следующую информацию по покупателям:
--  1. Фамилия и имя (в одной колонке через пробел)
--  2. Электронная почта
--  3. Длину значения поля email
--  4. Дату последнего обновления записи о покупателе (без времени)
--Каждой колонке задайте наименование на русском языке.

select concat(last_name,' ', first_name) as "Фамилия Имя", email as "Электронный адресс", character_length(email) as "Длина значения поля", cast(last_update as date) as "Дата" from customer

--ЗАДАНИЕ №6
--Выведите одним запросом только активных покупателей, имена которых KELLY или WILLIE.
--Все буквы в фамилии и имени из верхнего регистра должны быть переведены в нижний регистр.

select lower(first_name) as first_name, lower(last_name) as last_name, active  from customer
where (first_name = 'KELLY' or first_name = 'WILLIE') and active > 0

--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите одним запросом информацию о фильмах, у которых рейтинг "R" 
--и стоимость аренды указана от 0.00 до 3.00 включительно, 
--а также фильмы c рейтингом "PG-13" и стоимостью аренды больше или равной 4.00.

select film_id, title, description, rating, rental_rate  from film
where rating = 'R' and rental_rate  between '0.00' and '3.00' or rating = 'PG-13' and rental_rate >= '4.00'

--ЗАДАНИЕ №2
--Получите информацию о трёх фильмах с самым длинным описанием фильма.

select film_id, title, description, character_length(description) from film f 
order by character_length(description) desc limit 3

--ЗАДАНИЕ №3
-- Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
--в первой колонке должно быть значение, указанное до @, 
--во второй колонке должно быть значение, указанное после @.

select customer_id, email, split_part(email, '@', 1) as "Email before @", split_part(email, '@', 2) as "Email after @" from customer

--ЗАДАНИЕ №4
--Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: 
--первая буква должна быть заглавной, остальные строчными.

select customer_id, email, 
	concat(upper(left(split_part(email, '@', 1),1)),
	lower(substr(split_part(email, '@', 1),2))) as "Email before @", 
	concat(upper(left(split_part(email, '@', 2),1)),
	substr(split_part(email, '@', 2),2)) as "Email after @" 
from customer

--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.

select cu.address_id, concat(cu.first_name,' ', cu.last_name) as "Имя Фамилия", a.address, ci.city, co.country  
from customer cu
	join address a on cu.address_id = a.address_id 
	join city ci on a.city_id = ci.city_id
	join country co on ci.country_id = co.country_id 

--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.

select store_id as "Магазин", count(customer_id) as "Количество покупателей"
from customer c
group by store_id 

--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.

select store_id as "Магазин", count(customer_id) as "Количество покупателей"
from customer c
group by store_id having count(customer_id)>300

-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.

select c.store_id as "Магазин", count(c.customer_id) as "Количество покупателей", ci.city as "город", concat(st.first_name,' ', st.last_name) as "Имя сотрудника"
from customer c
	join store s on c.store_id = s.store_id 
	join staff st on s.store_id = st.store_id 
	join address a on s.address_id  = a.address_id
	join city ci on a.city_id = ci.city_id 	
group by c.store_id, ci.city, concat(st.first_name,' ', st.last_name)
having count(customer_id)>300
	 
--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов

select concat(c.first_name,' ', c.last_name) as "Имя Фамилия", count(c.customer_id) as count, c.customer_id 
from customer c
	join rental r on c.customer_id = r.customer_id 
group by concat(c.first_name,' ', c.last_name), c.customer_id  
order by count desc
limit 10

--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма

select concat(c.first_name,' ', c.last_name) as "Имя фамилия покупателя", count(r.rental_id) as "Количество взятых в прокат", round(sum(p.amount),0) as "Общая стоимость платежей", min(p.amount) as "Минимальная стоимость платежа", max(p.amount) as "Максимальная стоимость платежа" 
from rental r 
	join payment p on r.rental_id = p.rental_id
	join customer c on p.customer_id = c.customer_id
group by r.customer_id, concat(c.first_name,' ', c.last_name)

--ЗАДАНИЕ №5
--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
 --чтобы в результате не было пар с одинаковыми названиями городов. 
 --Для решения необходимо использовать декартово произведение.
 
select t1.city as "Город 1", t2.city as "Город 2"
from city t1 
	cross join city t2
where t1.city != t2.city

--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.
 
select customer_id as "ID покупателя", round(avg(return_date::date - rental_date::date), 2) as "Среднее количество дней на возврат"  -- тут не хватает размера строки на запись.
from rental	 
group by customer_id
order by customer_id

--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.

select f.title, f.rating, c."name" as "Жанр", f.release_year as "Год релиза", l."name", sum(p.amount) as "Общая стоимость аренды", count(r.rental_id) as "Количество аренд"
from film f 
	left join inventory i on f.film_id = i.film_id 
	left join rental r on i.inventory_id = r.inventory_id 
	left join payment p on r.rental_id = p.rental_id
	left join film_category fc on f.film_id = fc.film_id 
	left join category c on fc.category_id = c.category_id
	Left join "language" l on f.language_id = l.language_id 
group by f.film_id, c."name", l."name" 
order by f.title asc

--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью запроса фильмы, которые ни разу не брали в аренду.

select f.title, f.rating, c."name" as "Жанр", f.release_year as "Год релиза", l."name", sum(p.amount) as "Общая стоимость аренды", count(r.rental_id) as "Количество аренд"
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

--=============== МОДУЛЬ 4. УГЛУБЛЕНИЕ В SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--База данных: если подключение к облачной базе, то создаёте новую схему с префиксом в --виде фамилии, название должно быть на латинице в нижнем регистре и таблицы создаете --в этой новой схеме, если подключение к локальному серверу, то создаёте новую схему и --в ней создаёте таблицы.
 


--Спроектируйте базу данных, содержащую три справочника:
--· язык (английский, французский и т. п.);
--· народность (славяне, англосаксы и т. п.);
--· страны (Россия, Германия и т. п.).
--Две таблицы со связями: язык-народность и народность-страна, отношения многие ко многим. Пример таблицы со связями — film_actor.
--Требования к таблицам-справочникам:
--· наличие ограничений первичных ключей.
--· идентификатору сущности должен присваиваться автоинкрементом;
--· наименования сущностей не должны содержать null-значения, не должны допускаться --дубликаты в названиях сущностей.
--Требования к таблицам со связями:
--· наличие ограничений первичных и внешних ключей.

--В качестве ответа на задание пришлите запросы создания таблиц и запросы по --добавлению в каждую таблицу по 5 строк с данными.
 
--СОЗДАНИЕ ТАБЛИЦЫ ЯЗЫКИ

create table language
(
	id_language serial primary key,
	language_of_communication varchar(50) UNIQUE not null
);

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ ЯЗЫКИ

insert into language 
(language_of_communication) 
values 
('Russian'),
('German'),
('Latvian'),
('Korean'),
('Austrian'),
('English');

--СОЗДАНИЕ ТАБЛИЦЫ НАРОДНОСТИ

create table nationalities
(
id_nationalities serial primary key,
"national" varchar(50) UNIQUE not null
);

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ НАРОДНОСТИ

insert into nationalities 
("national") 
values 
('the Russians'),
('the Germans'),
('the Latvians'),
('the Koreans'),
('the Austrians'),
('the Brits');

--СОЗДАНИЕ ТАБЛИЦЫ СТРАНЫ

create table country
(
id_country serial primary key,
country varchar(50) UNIQUE not null
);

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СТРАНЫ

insert into country 
(country) 
values 
('Russia'),
('Germany'),
('Latvia'),
('Korea'),
('Austria'),
('England');

--СОЗДАНИЕ ПЕРВОЙ ТАБЛИЦЫ СО СВЯЗЯМИ

create table language_nationalities( 
id_language integer references language,
id_nationalities integer references nationalities,
primary key (id_language,id_nationalities)
);

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ

insert into language_nationalities (id_language, id_nationalities)        -- Первый метод ???
values  (1, 1),
		(2, 2),
		(3, 3),
		(4, 4),
		(5, 5),
		(6, 6);

insert into language_nationalities (id_language, id_nationalities)        -- Второй метод ???
select id_language, id_nationalities from language, nationalities         
where id_language = id_nationalities;

--СОЗДАНИЕ ВТОРОЙ ТАБЛИЦЫ СО СВЯЗЯМИ

create table nationalities_country(
id_country integer not null references country,
id_nationalities integer not null references nationalities,
primary key (id_country, id_nationalities)
);

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ

insert into nationalities_country (id_nationalities, id_country)
select n.id_nationalities, c.id_country
from nationalities as n
join country as c on n.id_nationalities = c.id_country; 


select *
from country c 
join nationalities_country nc on c.id_country = nc.id_country 
join nationalities n  on nc.id_nationalities  = n.id_nationalities                        -- заполнил таблицу данными
join language_nationalities ln2 on n.id_nationalities  = ln2.id_nationalities 
join "language" l on ln2.id_language = l.id_language; 

--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============


--ЗАДАНИЕ №1 
--Создайте новую таблицу film_new со следующими полями:
--·   	film_name - название фильма - тип данных varchar(255) и ограничение not null
--·   	film_year - год выпуска фильма - тип данных integer, условие, что значение должно быть больше 0
--·   	film_rental_rate - стоимость аренды фильма - тип данных numeric(4,2), значение по умолчанию 0.99
--·   	film_duration - длительность фильма в минутах - тип данных integer, ограничение not null и условие, что значение должно быть больше 0
--Если работаете в облачной базе, то перед названием таблицы задайте наименование вашей схемы.

create table film_new 
(
film_name varchar(255) not null,
film_year integer check (film_year > 0),
film_rental_rate numeric(4,2) default 0.99,
film_duration integer not null check (film_duration > 0)
);

--ЗАДАНИЕ №2 
--Заполните таблицу film_new данными с помощью SQL-запроса, где колонкам соответствуют массивы данных:
--·       film_name - array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List']
--·       film_year - array[1994, 1999, 1985, 1994, 1993]
--·       film_rental_rate - array[2.99, 0.99, 1.99, 2.99, 3.99]
--·   	  film_duration - array[142, 189, 116, 142, 195]

insert into film_new 
select * from unnest (array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List'],
array[1994, 1999, 1985, 1994, 1993], 
array[2.99, 0.99, 1.99, 2.99, 3.99],
array[142, 189, 116, 142, 195]
);

--ЗАДАНИЕ №3
--Обновите стоимость аренды фильмов в таблице film_new с учетом информации, 
--что стоимость аренды всех фильмов поднялась на 1.41

update film_new 
set film_rental_rate = film_rental_rate + 1.41;

--ЗАДАНИЕ №4
--Фильм с названием "Back to the Future" был снят с аренды, 
--удалите строку с этим фильмом из таблицы film_new

delete from film_new
where film_name = 'Back to the Future';

--ЗАДАНИЕ №5
--Добавьте в таблицу film_new запись о любом другом новом фильме

insert into film_new (film_name, film_year, film_rental_rate, film_duration)
values ('Pride & Prejudice', 2005, 7.8, 129);

--ЗАДАНИЕ №6
--Напишите SQL-запрос, который выведет все колонки из таблицы film_new, 
--а также новую вычисляемую колонку "длительность фильма в часах", округлённую до десятых

select film_name, film_year, film_rental_rate, film_duration, round(film_duration / 60,1) as "Длительность фильма в часах" from film_new;

--ЗАДАНИЕ №7 
--Удалите таблицу film_new

drop table film_new

--=============== МОДУЛЬ 5. РАБОТА С POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:

--1.	Пронумеруйте все платежи от 1 до N по дате

--2.	Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате

--3.	Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна 
--	быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей

--4.	Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим 
--	так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
--	Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.

select 
	p.customer_id,
	p.payment_id,
	p.payment_date,
	row_number () over(order by p.payment_date) as "1",--по дате",
	row_number () over(partition by p.customer_id  order by p.payment_date) as "2",--для каждого покупателя по дате",
	sum(p.amount) over(partition by p.customer_id  order by p.payment_date, p.amount) as "3",--Сумма всех платежей",
	dense_rank () over (partition by p.customer_id order by p.amount) as "4"--По стоимости платежа от наибольшего к меньшему",
from 
	payment p;

--ЗАДАНИЕ №2
--С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость 
--платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате.

select 
	customer_id, 
	payment_id, 
	amount,
	lag (amount, 1, 0.0) over(partition by customer_id order by payment_date)
from 
	payment;

--ЗАДАНИЕ №3
--С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.
	
select
	customer_id,
	amount as "Текущий платеж",
	lead(amount, 1) over(partition by customer_id order by payment_date) as "следующий платеж",
	(amount - (lead(amount, 1) over(partition by customer_id order by payment_date ))) as "Текущий - следующий платеж"
from
	payment p; 
	

--ЗАДАНИЕ №4
--С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.

select
	*
from (
	 select
		*,
		row_number () over(partition by customer_id order by payment_date desc) as "pay №"
	 from
		payment p
		) as order_pay
 where "pay №" = 1;



select   -- так и не понял как работает last_value, увидел и теперь не оставляет мне покоя 
	*
from (
	 select
		*,
		last_value(payment_date) over(partition by customer_id order by payment_date desc) as b
	 from
		payment p
		) as pay
 where b = payment_date;



--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года 
--с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) 
--с сортировкой по дате.

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
	
--ЗАДАНИЕ №2
--20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал
--дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей,
--которые в день проведения акции получили скидку
	
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

--ЗАДАНИЕ №3
--Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
-- 1. покупатель, арендовавший наибольшее количество фильмов
-- 2. покупатель, арендовавший фильмов на самую большую сумму
-- 3. покупатель, который последним арендовал фильм
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
		
--=============== МОДУЛЬ 6. POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".

explain analyze
select * 
from film
where array_position(special_features, 'Behind the Scenes') is not null;

--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.

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


--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.
	
--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.
	
with film_cte
as
	(
	select *
	from film
	where array_position(special_features, 'Behind the Scenes') is not null
	)
select 
	r.customer_id,
	count(i.film_id) as "Колличество"
from rental r
	 join inventory i on i.inventory_id = r.inventory_id 
	 join film_cte on film_cte.film_id = i.film_id 
group by 
	r.customer_id
order by
	r.customer_id;
	
	
--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.

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
	
--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления

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

--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ скорости выполнения запросов
-- из предыдущих заданий и ответьте на вопросы:

--1. Каким оператором или функцией языка SQL, используемых при выполнении домашнего задания, 
--   поиск значения в массиве происходит быстрее
--2. какой вариант вычислений работает быстрее: 
--   с использованием CTE или с использованием подзапроса

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
	count(i.film_id) as "Колличество"
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

--Ответы:
--1. Самыми шустрыми запросами оказались через операторы && и any. (0.345, 0.319, 0.318, 0,348, 0.548)
--2.Через CTE выполняется быстрее чем через подзапрос почти в 2 раза. (7.455, 12.065)

 

--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выполняйте это задание в форме ответа на сайте Нетологии

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

-- Выполнилось за 47.928 ms
-- Самым узким местом является сортировка по cu.customer_id в окне "count(ren.iid) over (partition by cu.customer_id)"
--c 0.372 на этой операции стало 33.370, плюс неплохо ест и склейка значений имен c 33.382 до 46.677, судя по всему они потребляли меньше если бы убрали distinct.


