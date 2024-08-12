--==========================================
--Итоговая работа в 2-ух вариантах:

select * from pg_catalog.pg_roles;


drop role netocourier;
create role netocourier with login password 'NetoSQL2022';
revoke all privileges on database postgres from netocourier;
revoke all privileges on database postgres from public;
revoke all privileges on schema information_schema, pg_catalog, public from netocourier;
revoke all privileges on schema information_schema, pg_catalog, public from public;
revoke all on all tables in schema public from netocourier;
grant connect on database postgres to netocourier;
grant usage on schema information_schema, pg_catalog, public to netocourier;
grant select on all tables in schema information_schema, pg_catalog  to netocourier;
grant all on schema public to netocourier;

create type status as enum('Выполняется', 'Выполнено', 'Отменен', 'В очереди');  -- присвоение значений статуса

create table "user" (
id uuid default uuid_generate_v4 (), --uuid PK
last_name varchar(20) not null, --фамилия сотрудника
first_name varchar(20) not null, --имя сотрудника
dismissed boolean default false,--уволен или нет, значение по умолчанию "нет"
primary key (id)
);

create table account (
id uuid default uuid_generate_v4(),--uuid PK
"name" varchar(20) not null, --название контрагента
primary key(id)
);

create table contact (
id uuid default uuid_generate_v4(), --uuid PK
last_name varchar(20) not null, --фамилия контакта
first_name varchar(20) not null, --имя контакта
account_id uuid, -- uuid FK id контрагента
primary key(id),
foreign key(account_id) references account(id)
);

create table courier(
id uuid default uuid_generate_v4(), -- uuid PK
from_place varchar(255) not null, --откуда
where_place varchar(255) not null, --куда
"name" varchar(50) not null, --название документа
account_id uuid not null, --uuid FK id контрагента
contact_id uuid not null,--uuid FK id контакта 
description text, --описание
user_id uuid not null, --uuid FK id сотрудника отправителя
status status default ('В очереди'), -- статусы 'В очереди', 'Выполняется', 'Выполнено', 'Отменен'. По умолчанию 'В очереди'
created_date date default now(), --дата создания заявки, значение по умолчанию now()
primary key(id),
foreign key(account_id) references account(id),
foreign key(contact_id) references contact(id),
foreign key(user_id) references "user"(id)
);


drop table courier;
drop table contact;
drop table account;
drop table "user";

--create or replace function rndm_uuid() returns uuid 
--as $$
--begin
--	return uuid_generate_v4(); 
--end;
--$$ language plpgsql;

--select rndm_uuid()

--drop function rndm_uuid()


create or replace function rndm_string(integer) returns varchar -- генерация строки
as $$
begin
	return substring('абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 1, (random()*32+1)::integer), (random()*7+1)::integer;
end;
$$ language plpgsql;

select rndm_string(1)

drop function rndm_string

create or replace function rndm_bool() returns boolean -- генерация булева значения
as $$
begin
	return random()::int;
end;
$$ language plpgsql;

select rndm_bool()

drop function rndm_bool

create or replace function rnmd_date() returns timestamp -- генерация даты в формате timestamp
as $$
begin 
	return now() - interval '1 day' * round(random()*100) as timestamp;
end;
$$ language plpgsql;

select rnmd_date();

drop function rnmd_date

create or replace function rndm_id(varchar) returns uuid -- случайное id из таблицы в запросе
as $$
declare rndm_u uuid;
begin
	execute format('select id from %I order by random() limit 1', $1)
	into rndm_u;
return rndm_u;
end;
$$ language plpgsql;

select rndm_id('account');

drop function rndm_id

create or replace function rndm_status() returns status  -- случайная запись массива
as $$
begin 
	return rndst from (select unnest(enum_range(null::status)) as rndst) rnd order by random() limit 1;
end;
$$ language plpgsql;

select rndm_status();

drop function rndm_status

--6.Процедура заполнения тестовыми данными--

create or replace procedure insert_test_data(num integer)
as $$
declare
	i integer :=1;
	x_account_id uuid;
	y_contact_id uuid;
begin
	while i<= num*loop 
		insert into account ("name")
			values (left(rndm_string(5), 20));
		i:=i+1;
	end loop;
	i:=1;
	while i<= num*loop 
		insert into "user"(last_name, first_name, dismissed)
			values(left(rndm_string(5), 20), left(rndm_string(5), 20), rndm_bool());
		i:=i+1;
	end loop;
	i:=1;
	while i<= num*2 loop 
		insert into contact(last_name, first_name, account_id)
			values(left(rndm_string(5), 20), left(rndm_string(5), 20), rndm_id('account'));
		i:=i+1;
	end loop;
	i:=1;
	while i<= num*5 loop 
		x_account_id = rndm_id('account'); 
		y_contact_id = rndm_id('contact');
		insert into courier(from_place, where_place, "name", account_id, contact_id, description, user_id, "status", created_date)
			values(left(rndm_string(5), 255), left(rndm_string(5), 255), left(rndm_string(5), 50), x_account_id, y_contact_id, left(rndm_string(5), 255), rndm_id('user'), rndm_status(), rnmd_date());
		i:=i+1;
	end loop;
end;
$$ language plpgsql;

select * from contact;
select * from courier;
select * from account;
select * from "user";

call insert_test_data(10)

drop procedure insert_test_data

-- 7. Для удаления тестовых данных

create or replace procedure erase_test_data() 
as $$
	begin
		delete from courier;
		delete from contact; 
		delete from account; 
		delete from "user"; 
	end;
$$ language plpgsql;

call erase_test_data();

drop procedure erase_test_data

--8.Внесение новой записи в таблицу courier 

create or replace procedure add_courier(from_place varchar, where_place varchar, "name" varchar, account_id uuid, contact_id uuid, description text, user_id uuid)
as $$
begin
	insert into courier (from_place, where_place, "name", account_id, contact_id, description, user_id)
		values (from_place, where_place, "name", account_id, contact_id, description, user_id);
end;
$$ language plpgsql;

call add_courier(left(rndm_string(5), 255), left(rndm_string(5), 255), left(rndm_string(5), 50), rndm_id('account'), rndm_id('contact'), left(rndm_string(5), 255), rndm_id('user'))

drop procedure add_courier

--9.Функция по получению записей о заявках на курьера

create or replace function get_courier()
	returns table ( id uuid, from_place varchar, where_place varchar,
					"name" varchar, account_id uuid, account varchar, 
					contact_id uuid, contact varchar, description text, 
					user_id uuid, "user" varchar, "status" status, created_date date)
as $$
begin
	return query
		select
			cor.id,
			cor.from_place,
			cor.where_place,
			cor."name",
			cor.account_id,
			a."name",
			cor.contact_id,
			concat(c.last_name, ' ', c.first_name)::varchar,
			cor.description,
			cor.user_id,
			concat(u.last_name, ' ', u.first_name)::varchar,
			cor."status",
			cor.created_date 
		from courier cor
		join account a on cor.account_id = a.id
		join contact c on cor.contact_id = c.id 
		join "user" u on cor.user_id = u.id 
		order by cor."status", created_date desc;
end;
$$language plpgsql;

select * from get_courier();

drop function get_courier

--10.Функция по изменению статуса заявки

create or replace procedure change_status(status, uuid)
as $$
begin 
	update courier set status = $1
		where id = $2;
end;
$$ language plpgsql;

call change_status(rndm_status(), rndm_id('courier'));

drop procedure change_status

--11. Функция получения списка сотрудников компании.

create or replace function get_users() 
	returns table ("user" varchar)
as $$
begin
	return query
		select concat(last_name, ' ', first_name)::varchar from "user"
			where dismissed is false 
		order by last_name; 
end;
$$language plpgsql;

select * from get_users()

drop function get_users

--12.Функция получения списка контрагентов.

create or replace function get_accounts()
	returns table (account varchar)
as $$
begin
	return query
		select "name"
			from account
		order by "name";
end;
$$ language plpgsql;

select * from get_accounts();

drop function get_accounts

--13.Функция  получения списка контактов.

create or replace function get_contacts(account_id uuid default null)
	returns table (contact varchar)
as $$
begin
	if $1 is NULL then
		return query select 'Выберите контрагента'::varchar;
	else
		return query
			select concat(last_name, ' ', first_name)::varchar from contact
				where $1 = contact.account_id 
			order by last_name;
		end if;
	end;
$$ language plpgsql

select * from get_contacts(rndm_id('account'));
select * from get_contacts();
select * from contact;

drop function get_contacts

--14. Представление по получению статистики о заявках на курьера

create view courier_statistic as 
with 
	cte_courier as(
		select 
			account_id,
			count(case when "status" = 'Выполнено' then status end) as count_complete, --количество завершенных заказов для каждого контрагента
			count(case when "status" = 'Выполняется' then status end) as count_courier, --количество заказов на курьера для каждого контрагента
			count(case when "status" = 'Отменен' then status end) as count_canceled, --количество отмененных заказов для каждого контрагента
			array_remove(array_agg(case when "status" = 'Отменен' then user_id end), NULL) as cansel_user_array, --массив с идентификаторами сотрудников, по которым были заказы со статусом "Отменен" для каждого контрагента
			count(case when date_trunc('Month', created_date) = date_trunc('Month', current_date) then id end) as current_count, -- кол-во заказов в текущем месяце
			count(case when date_trunc('Month', created_date) = date_trunc('Month', current_date - interval '1 month') then id end) as last_count,-- Кол-во заказов в предыдущем месяце
			count(distinct where_place) as count_where_place --количество мест доставки для каждого контрагента
		from 
			courier
		group by account_id),
	cte_contact as(
		select
			account_id,
			count(id) as count_contact   --количество контактов по контрагенту, которым доставляются документы
		from
			contact
		group by account_id)
		select 
			a.id as account_id,
			a."name" as account,
			ccr.count_courier,
			ccr.count_complete,
			ccr.count_canceled,
		case
			when ccr.last_count = 0
			then 0
			else ccr.current_count::numeric / ccr.last_count * 100 
		end as percent_relative_prev_month,
		ccr.count_where_place,
		ccc.count_contact,
		ccr.cansel_user_array
	from account a
	join cte_courier ccr on a.id = ccr.account_id
	join cte_contact ccc on a.id = ccc.account_id		
			
select * from courier_statistic;

drop view courier_statistic

--===============
--Итоговая работа 

create role netocourier with login password 'NetoSQL2022';
revoke all privileges on database postgres from netocourier;
revoke all privileges on database postgres from public;
revoke all privileges on schema information_schema, pg_catalog, public from netocourier;
revoke all privileges on schema information_schema, pg_catalog, public from public;
revoke all on all tables in schema public from netocourier;
grant connect on database postgres to netocourier;
grant usage on schema information_schema, pg_catalog, public to netocourier;
grant all privileges on all tables in schema public to netocourier;
grant all privileges on schema public to netocourier;
grant select on all tables in schema information_schema, pg_catalog  to netocourier;

create type status as enum('Выполняется', 'Выполнено', 'Отменен', 'В очереди');  -- присвоение значений статуса

create table "user" (
id uuid not null default uuid_generate_v4(), --uuid PK
last_name varchar(40) not null, --фамилия сотрудника
first_name varchar(40) not null, --имя сотрудника
dismissed boolean not null default false,--уволен или нет, значение по умолчанию "нет"
primary key (id)
);

create table account (
id uuid  not null default uuid_generate_v4(),--uuid PK
"name" varchar(60) not null, --название контрагента
primary key(id)
);

create table contact (
id uuid not null default uuid_generate_v4(), --uuid PK
last_name varchar(40) not null, --фамилия контакта
first_name varchar(40) not null, --имя контакта
account_id uuid not null, -- uuid FK id контрагента
primary key(id),
foreign key(account_id) references account(id)
);

create table courier(
id uuid not null default uuid_generate_v4(), -- uuid PK
from_place varchar(200) not null, --откуда
where_place varchar(200) not null, --куда
"name" varchar(50) not null, --название документа
account_id uuid not null, --uuid FK id контрагента
contact_id uuid not null,--uuid FK id контакта 
description text, --описание
user_id uuid not null, --uuid FK id сотрудника отправителя
status status not null default ('В очереди'), -- статусы 'В очереди', 'Выполняется', 'Выполнено', 'Отменен'. По умолчанию 'В очереди'
created_date date not null default now(), --дата создания заявки, значение по умолчанию now()
primary key(id),
foreign key(account_id) references account(id),
foreign key(contact_id) references contact(id),
foreign key(user_id) references "user"(id)
);


drop table courier cascade;
drop table contact;
drop table account;
drop table "user";

--6.Процедура заполнения тестовыми данными--

create or replace procedure insert_test_data(num integer) 
as $$
declare
	i integer :=1;
begin
	while i<= num loop 
		insert into account ("name")
			values (left(repeat(substring('абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 1, (random()*32+1)::integer), (random()*1+1)::integer), 60));
		i:=i+1;
	end loop;
	i:=1;
	while i<= num loop 
		insert into "user"(last_name, first_name, dismissed)
			values(left(repeat(substring('абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 1, (random()*32+1)::integer), (random()*1+1)::integer), 40), 
				 left(repeat(substring('абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 1, (random()*32+1)::integer), (random()*1+1)::integer), 40),
				(select random()<0.5));
		i:=i+1;
	end loop;
	i:=1;
	while i<= num*2 loop 
		insert into contact(last_name, first_name, account_id)
			values(left(repeat(substring('абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 1, (random()*32+1)::integer), (random()*1+1)::integer), 40),
				 left(repeat(substring('абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 1, (random()*32+1)::integer), (random()*1+1)::integer), 40), 
				(select id from account order by random() limit 1));
		i:=i+1;
	end loop;
	i:=1;
	while i<= num*5 loop 
		insert into courier(from_place, where_place, "name", account_id, contact_id, description, user_id, "status", created_date)
			values(left(repeat(substring('абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 1, (random()*32+1)::integer), (random()*6+1)::integer), 200),
				left(repeat(substring('абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 1, (random()*32+1)::integer), (random()*6+1)::integer), 200),
				left(repeat(substring('абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 1, (random()*32+1)::integer), (random()*1+1)::integer), 50),
				(select id from account order by random() limit 1),
				(select id from contact order by random() limit 1),
				repeat(substring('абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 1, (random()*32+1)::integer), (random()*5+1)::integer),
				(select id from "user" order by random() limit 1),
				(select rndst from (select unnest(enum_range(null::status)) as rndst) rnd order by random() limit 1),
				(select now() - interval '1 day' * round(random()*100) as timestamp));
				i:=i+1;
				end loop;
end;
$$ language plpgsql;


select * from contact;
select * from courier;
select * from account;
select * from "user";

call insert_test_data(100)


drop procedure insert_test_data

-- 7. Для удаления тестовых данных

create or replace procedure erase_test_data() 
as $$
	begin
		delete from courier;
		delete from contact; 
		delete from account; 
		delete from "user"; 
	end;
$$ language plpgsql;

call erase_test_data();

drop procedure erase_test_data

--8.Внесение новой записи в таблицу courier 

create or replace procedure add_courier(from_place varchar, where_place varchar, "name" varchar, account_id uuid, contact_id uuid, description text, user_id uuid)
as $$
begin
	insert into courier (from_place, where_place, "name", account_id, contact_id, description, user_id)
		values (from_place, where_place, "name", account_id, contact_id, description, user_id);
end;
$$ language plpgsql;


call add_courier(repeat(substring('абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 1, (random()*32+1)::integer), (random()*5+1)::integer),
				repeat(substring('абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 1, (random()*32+1)::integer), (random()*5+1)::integer),
				repeat(substring('абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 1, (random()*32+1)::integer), (random()*1+1)::integer),
				rndm_id('account'),
				rndm_id('contact'),
				repeat(substring('абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 1, (random()*32+1)::integer), (random()*5+1)::integer),
				rndm_id('user'))

drop procedure add_courier;
				
create or replace function rndm_id(varchar) returns uuid -- случайное id из таблицы в запросе для вызова процедуры внесения новой записи 
as $$
declare rndm_u uuid;
begin
	execute format('select id from %I order by random() limit 1', $1)
	into rndm_u;
return rndm_u;
end;
$$ language plpgsql;

select rndm_id('account');

drop function rndm_id

--9.Функция по получению записей о заявках на курьера

create or replace function get_courier()
	returns table ( id uuid, from_place varchar, where_place varchar,
					"name" varchar, account_id uuid, account varchar, 
					contact_id uuid, contact varchar, description text, 
					user_id uuid, "user" varchar, "status" status, created_date date)
as $$
begin
	return query
		select
			cor.id,
			cor.from_place,
			cor.where_place,
			cor."name",
			cor.account_id,
			a."name",
			cor.contact_id,
			concat(c.last_name, ' ', c.first_name)::varchar,
			cor.description,
			cor.user_id,
			concat(u.last_name, ' ', u.first_name)::varchar,
			cor."status",
			cor.created_date 
		from courier cor
		join account a on cor.account_id = a.id
		join contact c on cor.contact_id = c.id 
		join "user" u on cor.user_id = u.id 
		order by cor."status", created_date desc;
end;
$$language plpgsql;

select * from get_courier();

drop function get_courier

--10.Функция по изменению статуса заявки

create or replace procedure change_status(status, uuid)
as $$
begin 
	update courier set status = $1
		where id = $2;
end;
$$ language plpgsql;

call change_status(rndm_status(), rndm_id('courier'));

drop procedure change_status

create or replace function rndm_status() returns status  -- случайная запись массива для проверки вызова процедуры статуса заявки.
as $$
begin 
	return rndst from (select unnest(enum_range(null::status)) as rndst) rnd order by random() limit 1;
end;
$$ language plpgsql;

select rndm_status();

drop function rndm_status

--11. Функция получения списка сотрудников компании.

create or replace function get_users() 
	returns table ("user" varchar)
as $$
begin
	return query
		select concat(last_name, ' ', first_name)::varchar from "user"
			where dismissed is false 
		order by last_name; 
end;
$$language plpgsql;

select * from get_users()

drop function get_users

--12.Функция получения списка контрагентов.

create or replace function get_accounts()
	returns table (account varchar)
as $$
begin
	return query
		select "name"
			from account
		order by "name";
end;
$$ language plpgsql;

select * from get_accounts();

drop function get_accounts

--13.Функция  получения списка контактов.

create or replace function get_contacts(account_id uuid default null)
	returns table (contact varchar)
as $$
begin
	if $1 is NULL then
		return query select 'Выберите контрагента'::varchar;
	else
		return query
			select concat(last_name, ' ', first_name)::varchar from contact
				where $1 = contact.account_id 
			order by last_name;
		end if;
	end;
$$ language plpgsql

select * from get_contacts(rndm_id('account'));
select * from get_contacts();
select * from contact;

drop function get_contacts

--14. Представление по получению статистики о заявках на курьера

create view courier_statistic as 
with 
	cte_courier as(
		select 
			account_id,
			count(case when "status" = 'Выполнено' then status end) as count_complete, --количество завершенных заказов для каждого контрагента
			count(case when "status" = 'Выполняется' then status end) as count_courier, --количество заказов на курьера для каждого контрагента
			count(case when "status" = 'Отменен' then status end) as count_canceled, --количество отмененных заказов для каждого контрагента
			array_remove(array_agg(case when "status" = 'Отменен' then user_id end), NULL) as cansel_user_array, --массив с идентификаторами сотрудников, по которым были заказы со статусом "Отменен" для каждого контрагента
			count(case when date_trunc('Month', created_date) = date_trunc('Month', current_date) then id end) as current_count, -- кол-во заказов в текущем месяце
			count(case when date_trunc('Month', created_date) = date_trunc('Month', current_date - interval '1 month') then id end) as last_count,-- Кол-во заказов в предыдущем месяце
			count(distinct where_place) as count_where_place --количество мест доставки для каждого контрагента
		from 
			courier
		group by account_id),
	cte_contact as(
		select
			account_id,
			count(id) as count_contact   --количество контактов по контрагенту, которым доставляются документы
		from
			contact
		group by account_id)
		select 
			a.id as account_id,
			a."name" as account,
			ccr.count_courier,
			ccr.count_complete,
			ccr.count_canceled,
		case
			when ccr.last_count = 0
			then 0
			else ccr.current_count::numeric / ccr.last_count * 100 
		end as percent_relative_prev_month,
		ccr.count_where_place,
		ccc.count_contact,
		ccr.cansel_user_array
	from account a
	join cte_courier ccr on a.id = ccr.account_id
	join cte_contact ccc on a.id = ccc.account_id