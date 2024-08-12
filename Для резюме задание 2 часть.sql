--SQL 2-я часть продвинутый курс
--Домашнее задание "Командная строка. DCL и TCL"

-- createdb -h localhost -p 5432 -U postgres -T template0 argotest
-- psql -h localhost -p 5432 -U postgres -d argotest < "C:\Users\User\Desktop\hr.sql"
-- psql -h localhost -p 5432 -U postgres -d argotest
-- set search_path to hr

-------

select * from pg_catalog.pg_roles pr;
create role MyUser;
alter role MyUser Password '1234' valid until '31.03.2023 23:59:59';
grant connect on database "argotest" to MyUser;
grant usage on schema hr to MyUser;
grant select on hr.address, hr.city to MyUser;
revoke select on hr.address, hr.city from MyUser;
revoke usage on schema hr from MyUser;
revoke connect on database "argotest" from MyUser;
drop role MyUser;


------

Begin;
insert into projects (project_id, name, employees_id, amount, assigned_id, created_at) values (129, 'ВДНХy', '{"34", "345", "555"}', 65000000, 500, '2019-02-12 02:03:12.000');
savepoint my_save;

delete from projects 
where name = 'ВДНХy'

rollback to my_save;
commit;

select * from projects p 

--Домашнее задание процедуры и функции
--Задание 1. Напишите функцию, которая принимает на вход название должности (например, стажер), а также даты периода поиска, и возвращает количество вакансий, опубликованных по этой должности в заданный период.

--Задание 2. Напишите триггер, срабатывающий тогда, когда в таблицу position добавляется значение grade, которого нет в таблице-справочнике grade_salary. Триггер должен возвращать предупреждение пользователю о несуществующем значении grade.

--Задание 3. Создайте таблицу employee_salary_history с полями:

--emp_id - id сотрудника
--salary_old - последнее значение salary (если не найдено, то 0)
--salary_new - новое значение salary
--difference - разница между новым и старым значением salary
--last_update - текущая дата и время
--Напишите триггерную функцию, которая срабатывает при добавлении новой записи о сотруднике или при обновлении значения salary в таблице employee_salary, и заполняет таблицу employee_salary_history данными.

--Задание 4. Напишите процедуру, которая содержит в себе транзакцию на вставку данных в таблицу employee_salary. Входными параметрами являются поля таблицы employee_salary.

--Задание №1-----------------------------------------------------

Create function tuk2(start_date date, end_date date, vac_name text) returns table (results integer) as $$
begin
	if start_date is null 
		then start_date = (select min(create_date::date) from vacancy);
	elseif end_date is null 
		then end_date = (select max(closure_date::date) from vacancy);
	end if;
	return query select
	count (vac_title)::int
	from vacancy
	where create_date::date between start_date and end_date and vac_name = vac_title;
end;
$$ language plpgsql

select tuk2('01.04.2015', '05.06.2020', 'специалист');

drop function tuk2(date, date, text);

--Задание №2----------------------------------------------------------------------------

Create trigger chek_grade 
	before insert or update on "position"
	for each row
	execute function chek_grade_insert();

create function chek_grade_insert() returns trigger as $$
	begin
		if new.grade not in (select grade from grade_salary)
			then raise exception 'значения поля grade не существует';
		end if;
		return new;
	end;
$$ language plpgsql


insert into "position" 
values (4600, 'QA-инженер', 'Производственный', 204, 8, 20, 1001)

insert into "position" 
values (4601, 'QA-инженер', 'Производственный', 204, 6, 20, 1001)

delete from "position" 
	where pos_id = 4600 or pos_id = 4601
	
select * from grade_salary gs 

select * from "position" p 

drop function chek_grade_insert() cascade;	
	
--Задание №3------------------------------------------------------------------
create table employee_salary_history 
(
emp_id integer, -- id сотрудника
salary_old integer default 0, -- последнее значение salary (если не найдено, то 0)
salary_new integer, -- новое значение salary
difference integer generated always as (salary_old - salary_new) stored, -- разница между новым и старым значением salary
last_update timestamp default now() -- текущая дата и время
);

Create trigger chek_emp2
	after insert or update of salary on employee_salary 
	for each row 
	execute function chek_emp_update();
	
create function chek_emp_update() returns trigger as $$
	begin
		if tg_op = 'INSERT' and old.salary = 0  -- новый сотрудник
			then insert into employee_salary_history(emp_id, salary_new)
				values(new.emp_id, new.salary);
		elseif tg_op = 'UPDATE' and new.emp_id = old.emp_id -- изменение по окладу
			then insert into employee_salary_history(emp_id, salary_old, salary_new)
				values(old.emp_id, old.salary, new.salary);
		elseif tg_op = 'UPDATE' and new.emp_id != old.emp_id -- изменение оклада, id
			then insert into employee_salary_history(emp_id, salary_old, salary_new)
				values(new.emp_id, old.salary, new.salary);
		end if;
		return null;
	end;
$$ language plpgsql;	
	
	
insert into employee_salary
values (29967, 2, 120000, '2020.08.13')

update employee_salary set salary = 100000, emp_id = 3
where order_id = 29967

delete from employee_salary 
where order_id = 29967

drop function chek_emp_update() cascade;
drop table employee_salary_history;
select * from employee_salary es;
select * from employee_salary_history;
select * from employee e 



--Задание №4----------------------------------------------------------

create procedure emp1 (_order_id integer, _emp_id integer, _salary integer, _effective_from date) as $$
	begin 
		insert into employee_salary(order_id, emp_id, salary, effective_from)
		values (_order_id, _emp_id, _salary, _effective_from);
	end;
$$ language plpgsql;


select * from employee_salary es 

drop procedure emp1

call emp1 (29967, 2, 100000, '2020.08.13')

delete from employee_salary
	where (order_id = 29967) and (emp_id = 2)

--Домашнее задание "Зависимости. Нормализация. Денормализация"


--Необходимо нормализовать исходную таблицу.
--Получившиеся отношения должны быть не ниже 3 Нормальной Формы.
--В результате должна быть диаграмма из не менее чем 5 нормализованных отношений и 1 таблицы с историчностью, соответствующей требованиям SCD4.
--Контролировать целостность данных в таблице с историчными данными необходимо с помощью триггерной функции.
--Результат работы должен быть в виде одного скриншота ER-диаграммы и sql запроса с триггером и функцией.


drop table public.city;
drop table public.address;
drop table public.vacancy;
drop table public.person;
drop table public.departament;
drop table employee;
drop table person_history;
drop function chek_person_data() cascade;



create table city 
(
city_id integer primary key,
city_name text
);

create table address
(address_id integer,
city_id integer,
full_address text,
primary key(address_id),
foreign key(city_id) references city
);

create table person
(person_id integer,
full_name text,
born_date date,
email text,
address_id integer,
primary key(person_id),
foreign key(address_id) references address
);

create table vacancy
(vac_id integer,
vac_name text,
salary integer,
primary key (vac_id)
);

create table employee
(employee_id integer,
vac_id integer,
person_id integer,
departament_id integer,
director integer,
start_date date,
end_date date,
foreign key(director) references person,
foreign key(person_id) references person,
foreign key(departament_id) references departament,
foreign key(vac_id) references vacancy,
primary key(employee_id)
);

create table departament
(departament_id integer,
departament_name text,
address_id integer,
primary key (departament_id),
foreign key(address_id) references address
);



create table person_history
(person_id integer,
full_name text,
born_date date,
email text,
address_id integer,
change_date timestamp default now()
);

Create trigger chek_person 
	after insert or update or delete on person
	for each row 
	execute function chek_person_data();

create function chek_person_data() returns trigger as $$
	begin
		if tg_table_name = 'person'
			then insert into person_history(person_id, full_name, born_date, email, address_id)
				values(new.person_id, new.full_name, new.born_date, new.email, new.address_id);
		end if;
		return null;
	end;
$$ language plpgsql;	



insert into city
	values (9, 'Аустерилиц')

insert into address
	values (9,9, 'ул. Багратиона д 28 кв 7')
	
insert into person  
	values (9, 'Иван Иванович Иванов', '06.03.1988', 'ivanov@mail.ru', 9)

update person set full_name = 'Егор Иванович Иванов'
	where person_id = 9

select * from person_history;
select * from person;


create table vacancy_history
(vac_id integer,
person_id integer,
departament_name varchar(255),
vac_name varchar(255)
)


--=================================
--Домашнее задание «PostgreSQL Extensions»
--Задание №1
--Создайте подключение к удаленному облачному серверу базы HR (база данных postgres, схема hr), используя модуль postgres_fdw.
--Напишите SQL-запрос на выборку любых данных используя 2 сторонних таблицы, соединенных с помощью JOIN.
--В качестве ответа на задание пришлите список команд, использовавшихся для настройки подключения, создания внешних таблиц, а также получившийся SQL-запрос
--Хост 51.250.106.132 порт 19001. Схема HR
create extension postgres_fdw

drop server pfdw cascade;
drop table temp_pfdw;
drop foreign table out_person;
drop foreign table out_employee


create server pfdw
foreign data wrapper postgres_fdw
options (host '51.250.106.132', port '19001', dbname 'postgres');

create user mapping for postgres
server pfdw
options (user 'netology', password 'NetoSQL2019');

create foreign table out_person (
person_id int,
first_name varchar(250),
middle_name varchar(250),
last_name varchar(250)
)
server pfdw
options (schema_name 'hr', table_name 'person');

create foreign table out_employee (
emp_id int,
person_id int,
rate numeric
)
server pfdw
options (schema_name 'hr', table_name 'employee');

select
p.person_id,
p.first_name,
p.middle_name,
p.last_name,
y.rate
from out_person p
join out_employee y on p.person_id = y.person_id
where rate between 0.4 and 0.99

select * from out_person;
select * from out_employee


--Задание 2. С помощью модуля tablefunc получите из таблицы projects базы HR таблицу с данными, 
--колонками которой будут: год, месяцы с января по декабрь, общий итог по стоимости всех проектов за год.

drop foreign table out_projects;

create extension tablefunc;

create foreign table out_projects (
project_id int,
"name" varchar(250),
amount numeric,
assigned_id int,
created_at timestamp
)
server pfdw
options (schema_name 'hr', table_name 'projects');

select  
*
from out_projects
order by created_at;

		
select "Год" , coalesce("Январь", 0) Январь , coalesce("Февраль", 0) Февраль , coalesce("Март", 0) Март, coalesce("Апрель", 0) Апрель,
			coalesce("Май", 0) Май, coalesce("Июнь", 0) Июнь, coalesce("Июль", 0) Июль, coalesce("Август", 0) Август,
			coalesce("Сентябрь", 0) Сентябрь, coalesce("Октябрь", 0) Октябрь, coalesce("Ноябрь", 0) Ноябрь, coalesce("Декабрь", 0) Декабрь, "Итого" 
from crosstab($$
	select 
	coalesce(y::varchar, 'Итого'),
	coalesce(m::varchar, 'Итого'),
	"sum"
	from(
		select
			extract (year from "created_at") as y,
			extract (month from "created_at") as m,
		sum(amount) as "sum"
		from out_projects
			group by cube (1,2)
			order by 1, 2) ty
			where y is not null$$,
$$select a::varchar
	from (
		select distinct
		extract (month from "created_at" ) as a
		from out_projects
		order by 1) mes	
	union all 
	select 'Итого' $$) as tab ("Год" varchar, "Январь" numeric, "Февраль" numeric, "Март" numeric, "Апрель" numeric, "Май" numeric, "Июнь" numeric, "Июль" numeric, "Август" numeric,
			"Сентябрь" numeric, "Октябрь" numeric, "Ноябрь" numeric, "Декабрь" numeric, "Итого" numeric);
			
-- Задание №3 Настройте модуль pg_stat_statements на локальном сервере PostgresSQL и выполните несколько любых SQL-запросов к базе.		
		
create extension pg_stat_statements;		

drop extension pg_stat_statements;

select * from pg_stat_statements;	


--========================================
--Домашнее задание "Масштабирование"


--Задание 1. Выполните горизонтальное партиционирование для таблицы inventory учебной базы dvd-rental:
--
--создайте 2 партиции по значению store_id
--создайте индексы для каждой партиции
--заполните партиции данными из родительской таблицы
--для каждой партиции создайте правила на внесение, обновление, удаление данных. Напишите команды SQL для проверки работы правил.

create table dup_inventory as (select * from inventory);
truncate  dup_inventory;
select * from inventory i ;
select * from dup_inventory;
select * from inventory_store1;
select * from inventory_store2;
drop table dup_inventory;
drop table inventory_store1 cascade;
drop table inventory_store2 cascade;
drop rule inventory_insert_store1 on dup_inventory;
drop rule inventory_update_store1 on dup_inventory;
drop rule inventory_delete_store1 on dup_inventory;
drop rule inventory_insert_store2 on dup_inventory;
drop rule inventory_update_store2 on dup_inventory;
drop rule inventory_delete_store2 on dup_inventory;
drop index inventory_store1_idx;
drop index inventory_store2_idx;

------------------------------------------------------------------------------------

create table inventory_store1 (check (store_id = 1)) inherits (dup_inventory);
create table inventory_store2 (check (store_id = 2)) inherits (dup_inventory);
create index inventory_store1_idx on inventory_store1 (cast(last_update as date)); 
create index inventory_store2_idx on inventory_store2 (cast(last_update as date));

-------------------------------------------------------------------------------------

create rule inventory_insert_store1 as on insert to dup_inventory
where (store_id = 1)
do instead insert into inventory_store1 values (new.*);

create rule inventory_update_store1 as on update to dup_inventory
where (old.store_id = 1 and new.store_id != 1)
do instead (insert into dup_inventory values (new.*); delete from inventory_store1 where inventory_id = new.inventory_id);

create rule inventory_delete_store1 as on delete to dup_inventory
where (store_id = 1)
do instead delete from inventory_store1 where inventory_id = old.inventory_id ;

---------------------------------------------------------------------------------------
create rule inventory_insert_store2 as on insert to dup_inventory
where (store_id = 2)
do instead insert into inventory_store2 values (new.*);

create rule inventory_update_store2 as on update to dup_inventory
where (old.store_id = 2 and new.store_id != 2)
do instead (insert into dup_inventory values (new.*); delete from inventory_store2 where inventory_id = new.inventory_id);

create rule inventory_delete_store2 as on delete to dup_inventory
where (store_id = 2)
do instead delete from inventory_store2 where inventory_id = old.inventory_id;

-------------------------------------------------------------------------------------------
insert into dup_inventory select * from inventory; --внесение данных в таблицу из inventory.

select * from inventory_store1; -- проверка занесения данных из родительской таблицы в дочернюю где store_id = 1
select * from inventory_store2; -- проверка занесения данных из родительской таблицы в дочернюю где store_id = 2

delete from dup_inventory -- удаление строки в родительской таблице. 
where inventory_id = 7;

select * from inventory_store2 -- проверка удаления строки в дочерней таблице, после удаления в родительской.
where inventory_id = 7;

select * from dup_inventory -- проверка удаления строки в дочерней таблице, после удаления в родительской.
where inventory_id = 7;

select * from dup_inventory

update dup_inventory set store_id = 2 -- обновление значения строки в родительской таблице.
where inventory_id = 1

select * from inventory_store2 -- проверка записи в дочернюю таблице данных после обновления в родительской таблице.
where inventory_id = 1

select * from inventory_store1 -- проверка записи в дочерней таблице данных после обновления в родительской таблице. 
where inventory_id = 1



--Задание 2
--Создайте новую базу данных и в ней 2 таблицы для хранения данных по инвентаризации каждого магазина, 
--которые будут наследоваться из таблицы inventory базы dvd-rental. 
--Используя шардирование и модуль postgres_fdw создайте подключение к новой базе данных и необходимые 
--внешние таблицы в родительской базе данных для наследования. Распределите данные по внешним таблицам. 
--Напишите SQL-запросы для проверки работы внешних таблиц


select * from inventory i;
drop table inventory_s1;
drop table inventory_s2;
drop foreign table inventory_s_one;
drop foreign table inventory_s_two;
drop server study_server cascade;
drop function inventory_store_tg() cascade;

----------------------------------------------------------------------------------------------------------

create database study;
drop database study;

create table inventory_s1 (
	inventory_id int,
	film_id int2,
	store_id int2 check (store_id = 1),
	last_update timestamp DEFAULT now()
	);

select * from inventory_s1;

create table inventory_s2 (
	inventory_id int,
	film_id int2,
	store_id int2 check (store_id = 2),
	last_update timestamp DEFAULT now()
	);

select * from inventory_s2;

create extension postgres_fdw;
drop extension postgres_fdw;

create server study_server
foreign data wrapper postgres_fdw
options (host 'localhost', port '5432', dbname 'study');

create user mapping for postgres
server study_server
options (user 'postgres', password '123');

create foreign table inventory_s_one (
	inventory_id int,
	film_id int,
	store_id int,
	last_update timestamp DEFAULT now())
inherits (inventory)
server study_server
options (schema_name 'public', table_name 'inventory_s1');

create foreign table inventory_s_two (
	inventory_id int,
	film_id int,
	store_id int,
	last_update timestamp DEFAULT now())
inherits (inventory)
server study_server
options (schema_name 'public', table_name 'inventory_s2');

create or replace function inventory_store_tg() returns trigger
as $$
	begin 
		if new.store_id = 1 then 
			insert into inventory_s_one values (new.*);
		elsif new.store_id = 2 then 
			insert into inventory_s_two values (new.*);
		else raise exception 'Отсутствует партиция';
		end if;
		return null;
	end;
$$ Language plpgsql;
	end
	
create trigger inventory_insert_tg
before insert on inventory
for each row execute function inventory_store_tg()


select * from  inventory_s1;
select * from inventory i;

insert into inventory (inventory_id, film_id, store_id) values (6000, 300, 2);