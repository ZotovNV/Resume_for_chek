--SQL 2-� ����� ����������� ����
--�������� ������� "��������� ������. DCL � TCL"

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
insert into projects (project_id, name, employees_id, amount, assigned_id, created_at) values (129, '����y', '{"34", "345", "555"}', 65000000, 500, '2019-02-12 02:03:12.000');
savepoint my_save;

delete from projects 
where name = '����y'

rollback to my_save;
commit;

select * from projects p 

--�������� ������� ��������� � �������
--������� 1. �������� �������, ������� ��������� �� ���� �������� ��������� (��������, ������), � ����� ���� ������� ������, � ���������� ���������� ��������, �������������� �� ���� ��������� � �������� ������.

--������� 2. �������� �������, ������������� �����, ����� � ������� position ����������� �������� grade, �������� ��� � �������-����������� grade_salary. ������� ������ ���������� �������������� ������������ � �������������� �������� grade.

--������� 3. �������� ������� employee_salary_history � ������:

--emp_id - id ����������
--salary_old - ��������� �������� salary (���� �� �������, �� 0)
--salary_new - ����� �������� salary
--difference - ������� ����� ����� � ������ ��������� salary
--last_update - ������� ���� � �����
--�������� ���������� �������, ������� ����������� ��� ���������� ����� ������ � ���������� ��� ��� ���������� �������� salary � ������� employee_salary, � ��������� ������� employee_salary_history �������.

--������� 4. �������� ���������, ������� �������� � ���� ���������� �� ������� ������ � ������� employee_salary. �������� ����������� �������� ���� ������� employee_salary.

--������� �1-----------------------------------------------------

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

select tuk2('01.04.2015', '05.06.2020', '����������');

drop function tuk2(date, date, text);

--������� �2----------------------------------------------------------------------------

Create trigger chek_grade 
	before insert or update on "position"
	for each row
	execute function chek_grade_insert();

create function chek_grade_insert() returns trigger as $$
	begin
		if new.grade not in (select grade from grade_salary)
			then raise exception '�������� ���� grade �� ����������';
		end if;
		return new;
	end;
$$ language plpgsql


insert into "position" 
values (4600, 'QA-�������', '����������������', 204, 8, 20, 1001)

insert into "position" 
values (4601, 'QA-�������', '����������������', 204, 6, 20, 1001)

delete from "position" 
	where pos_id = 4600 or pos_id = 4601
	
select * from grade_salary gs 

select * from "position" p 

drop function chek_grade_insert() cascade;	
	
--������� �3------------------------------------------------------------------
create table employee_salary_history 
(
emp_id integer, -- id ����������
salary_old integer default 0, -- ��������� �������� salary (���� �� �������, �� 0)
salary_new integer, -- ����� �������� salary
difference integer generated always as (salary_old - salary_new) stored, -- ������� ����� ����� � ������ ��������� salary
last_update timestamp default now() -- ������� ���� � �����
);

Create trigger chek_emp2
	after insert or update of salary on employee_salary 
	for each row 
	execute function chek_emp_update();
	
create function chek_emp_update() returns trigger as $$
	begin
		if tg_op = 'INSERT' and old.salary = 0  -- ����� ���������
			then insert into employee_salary_history(emp_id, salary_new)
				values(new.emp_id, new.salary);
		elseif tg_op = 'UPDATE' and new.emp_id = old.emp_id -- ��������� �� ������
			then insert into employee_salary_history(emp_id, salary_old, salary_new)
				values(old.emp_id, old.salary, new.salary);
		elseif tg_op = 'UPDATE' and new.emp_id != old.emp_id -- ��������� ������, id
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



--������� �4----------------------------------------------------------

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

--�������� ������� "�����������. ������������. ��������������"


--���������� ������������� �������� �������.
--������������ ��������� ������ ���� �� ���� 3 ���������� �����.
--� ���������� ������ ���� ��������� �� �� ����� ��� 5 ��������������� ��������� � 1 ������� � �������������, ��������������� ����������� SCD4.
--�������������� ����������� ������ � ������� � ����������� ������� ���������� � ������� ���������� �������.
--��������� ������ ������ ���� � ���� ������ ��������� ER-��������� � sql ������� � ��������� � ��������.


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
	values (9, '����������')

insert into address
	values (9,9, '��. ���������� � 28 �� 7')
	
insert into person  
	values (9, '���� �������� ������', '06.03.1988', 'ivanov@mail.ru', 9)

update person set full_name = '���� �������� ������'
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
--�������� ������� �PostgreSQL Extensions�
--������� �1
--�������� ����������� � ���������� ��������� ������� ���� HR (���� ������ postgres, ����� hr), ��������� ������ postgres_fdw.
--�������� SQL-������ �� ������� ����� ������ ��������� 2 ��������� �������, ����������� � ������� JOIN.
--� �������� ������ �� ������� �������� ������ ������, ���������������� ��� ��������� �����������, �������� ������� ������, � ����� ������������ SQL-������
--���� 51.250.106.132 ���� 19001. ����� HR
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


--������� 2. � ������� ������ tablefunc �������� �� ������� projects ���� HR ������� � �������, 
--��������� ������� �����: ���, ������ � ������ �� �������, ����� ���� �� ��������� ���� �������� �� ���.

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

		
select "���" , coalesce("������", 0) ������ , coalesce("�������", 0) ������� , coalesce("����", 0) ����, coalesce("������", 0) ������,
			coalesce("���", 0) ���, coalesce("����", 0) ����, coalesce("����", 0) ����, coalesce("������", 0) ������,
			coalesce("��������", 0) ��������, coalesce("�������", 0) �������, coalesce("������", 0) ������, coalesce("�������", 0) �������, "�����" 
from crosstab($$
	select 
	coalesce(y::varchar, '�����'),
	coalesce(m::varchar, '�����'),
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
	select '�����' $$) as tab ("���" varchar, "������" numeric, "�������" numeric, "����" numeric, "������" numeric, "���" numeric, "����" numeric, "����" numeric, "������" numeric,
			"��������" numeric, "�������" numeric, "������" numeric, "�������" numeric, "�����" numeric);
			
-- ������� �3 ��������� ������ pg_stat_statements �� ��������� ������� PostgresSQL � ��������� ��������� ����� SQL-�������� � ����.		
		
create extension pg_stat_statements;		

drop extension pg_stat_statements;

select * from pg_stat_statements;	


--========================================
--�������� ������� "���������������"


--������� 1. ��������� �������������� ����������������� ��� ������� inventory ������� ���� dvd-rental:
--
--�������� 2 �������� �� �������� store_id
--�������� ������� ��� ������ ��������
--��������� �������� ������� �� ������������ �������
--��� ������ �������� �������� ������� �� ��������, ����������, �������� ������. �������� ������� SQL ��� �������� ������ ������.

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
insert into dup_inventory select * from inventory; --�������� ������ � ������� �� inventory.

select * from inventory_store1; -- �������� ��������� ������ �� ������������ ������� � �������� ��� store_id = 1
select * from inventory_store2; -- �������� ��������� ������ �� ������������ ������� � �������� ��� store_id = 2

delete from dup_inventory -- �������� ������ � ������������ �������. 
where inventory_id = 7;

select * from inventory_store2 -- �������� �������� ������ � �������� �������, ����� �������� � ������������.
where inventory_id = 7;

select * from dup_inventory -- �������� �������� ������ � �������� �������, ����� �������� � ������������.
where inventory_id = 7;

select * from dup_inventory

update dup_inventory set store_id = 2 -- ���������� �������� ������ � ������������ �������.
where inventory_id = 1

select * from inventory_store2 -- �������� ������ � �������� ������� ������ ����� ���������� � ������������ �������.
where inventory_id = 1

select * from inventory_store1 -- �������� ������ � �������� ������� ������ ����� ���������� � ������������ �������. 
where inventory_id = 1



--������� 2
--�������� ����� ���� ������ � � ��� 2 ������� ��� �������� ������ �� �������������� ������� ��������, 
--������� ����� ������������� �� ������� inventory ���� dvd-rental. 
--��������� ������������ � ������ postgres_fdw �������� ����������� � ����� ���� ������ � ����������� 
--������� ������� � ������������ ���� ������ ��� ������������. ������������ ������ �� ������� ��������. 
--�������� SQL-������� ��� �������� ������ ������� ������


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
		else raise exception '����������� ��������';
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