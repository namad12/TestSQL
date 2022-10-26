use master
go

create database testsql
go 

use testsql
go

-- create tables
create table Customers(
	customer_id int identity(1,1) primary key,
	[name] nvarchar(100) not null,
	[address] nvarchar(200) not null,
	website nvarchar(200) not null,
	credit_limit nvarchar(200) not null
)

create table Contacts(
	contact_id int identity(1,1) primary key,
	first_name nvarchar(100) not null,
	last_name nvarchar(100) not null,
	email nvarchar(100) not null,
	phone nvarchar(100) not null,
	customer_id int foreign key references Customers(customer_id)
)

create table Managers(
	manager_id int identity(1,1) primary key,
	first_name nvarchar(100) not null,
	last_name nvarchar(100) not null,
	phone nvarchar(100) not null,
	[address] nvarchar(100) not null
)

create table Employees(
	employee_id int identity(1,1) primary key,
	first_name nvarchar(100) not null,
	last_name nvarchar(100) not null,
	email nvarchar(100) not null,
	phone nvarchar(20) not null,
	hire_date date not null,
	manager_id int foreign key references Managers(manager_id),
	job_title nvarchar(200) not null
)

create table Regions(
	region_id int identity(1,1) primary key,
	region_name nvarchar(100) not null
)

create table Countries(
	country_id int identity(1,1) primary key,
	country_name nvarchar(100) not null,
	region_id int foreign key references Regions(region_id)
)

create table Locations(
	location_id int identity(1,1) primary key,
	[address] nvarchar(200) not null,
	postal_code int not null,
	city nvarchar(100) not null,
	state int not null,
	country_id int foreign key references Countries(country_id)
)

create table Warehouses(
	warehouse_id int identity(1,1) primary key,
	warehouse_name nvarchar(100) not null,
	location_id int foreign key references Locations(location_id)
)

create table Inventories(
	product_id int not null,
	warehouse_id int not null,
	constraint pk_Inventory primary key (product_id, warehouse_id),
	quantity int not null
)

create table Product_Categories(
	category_id int identity(1,1) primary key,
	category_name nvarchar(100) not null
)

create table Products(
	product_id int identity(1,1) primary key,
	product_name nvarchar(100) not null,
	[description] text null,
	standard_cost money not null,
	list_price money not null,
	category_id int foreign key references Product_Categories(category_id)
)

create table Orders(
	order_id int identity(1,1) primary key,
	customer_id int foreign key references Customers(customer_id),
	[status] int null,
	salesman_id int foreign key references Employees(employee_id),
	order_date date not null,
	total money not null
)

create table Order_Items(
	order_id int not null,
	item_id int identity(1,1),
	constraint pk_OrderItem primary key (order_id, item_id),
	product_id int foreign key references Products(product_id),
	quantity int not null,
	unit_price money not null
)

-- insert values into tables
insert into Managers(first_name, last_name, phone, [address]) 
values(N'Mgr', N'Nguyễn', N'0886 127 297', N'Hà Nội')
go 6

insert into Employees(first_name, last_name, email, phone, hire_date, manager_id, job_title)
values(N'Empl', N'Nguyễn', N'nam11220506@gmail.com', N'0886 127 297', '2022-10-20', 1, N'Nhân viên bán hàng')
go 10

insert into Customers([name], [address], website, credit_limit)
values(N'Cust', N'Bắc Ninh', N'www.google.com', N'15.000.000')
go 20

insert into Contacts(first_name, last_name, email, phone, customer_id)
values (N'Nam', N'Nguyễn', N'nam11220506@gmail.com', N'0886 127 297', 1)
go 50

insert into Regions(region_name) values(N'Asian') 
go 6

insert into Countries(country_name, region_id) values(N'Việt Nam', 1)
go 22

insert into Locations([address], postal_code, city, [state], country_id)
values(N'Thanh Xuân', 10000, N'Hà Nội', 1, 1)
go 54

insert into Warehouses(warehouse_name, location_id) values(N'WHS', 1)
go 5

insert into Product_Categories(category_name) values(N'cat')
go 3

insert into Products(product_name, [description], standard_cost, list_price, category_id)
values(N'Prod', N'Thông tin về sản phẩm', 20, 20, 1)
go 30

insert into Inventories(product_id, warehouse_id, quantity)
values(1, 2, 30)
-- select * from Inventories

insert into Orders(customer_id, [status], salesman_id, order_date, total)
values(1, 1, 1, '2022-10-22', 1000)
go 100
-- select * from Orders

insert into Order_Items(order_id, product_id, quantity, unit_price)
values(1, 61, 10, 100)
-- select * from Order_Items

-- drop database testsql

/**************************************************************************************************************
  * Bài 1: Lấy ra top 10 nhân viên có doanh thu cao nhất (Mã nhân viên, Họ và Tên nhân viên, Doanh thu).      *
  *        Sắp xếp theo doanh thu giảm dần                                                                    *
  **************************************************************************************************************/
select top 10 Employees.employee_id as [Mã nhân viên], 
              CONCAT(Employees.last_name, ' ',  Employees.first_name) as [Họ và tên nhân viên],
	    	  sum(total) as [Doanh thu]
from Employees
	   inner join Orders on Employees.employee_id = Orders.salesman_id
group by Employees.employee_id, Employees.last_name, Employees.first_name
order by [Doanh thu] desc


/**********************************************************************************************
  * Bài 2: Tính tổng doanh thu các đơn hàng đã mua của các khách hàng theo từng tháng, năm.   *
  *        Sắp xếp theo theo tên khách hàng, tháng, năm mua hàng                              *
  *********************************************************************************************/
  create function bai2_thang(@thang int, @nam int)
  returns @bang_thang table ( [Tên khách hàng] nvarchar(100), [Tổng doanh thu] money, [Tháng] int, [Năm] int)
  as
	begin
		insert into @bang_thang
			  select Customers.[name] as [Tên khách hàng], 
					 sum(Orders.total) as [Doanh thu theo tháng], 
					 MONTH(Orders.order_date) as [Tháng], YEAR(Orders.order_date) as [Năm]
			  from Orders
					inner join Customers on Orders.customer_id = Customers.customer_id
			  where MONTH(Orders.order_date) = @thang and YEAR(Orders.order_date) = @nam
			  group by Customers.[name], MONTH(Orders.order_date), YEAR(Orders.order_date)
			  order by Customers.[name]
		return
	end
-- TEST: Tổng doanh thu các đơn hàng đã mua của các khách hàng trong tháng 10 năm 2022
select * from bai2_thang(10, 2022)


create function bai2_nam(@nam int)
  returns @bang_nam table ( [Tên khách hàng] nvarchar(100), [Tổng doanh thu] money, [Năm] int )
  as
	begin
		insert into @bang_nam
			  select Customers.[name] as [Tên khách hàng], 
					 sum(Orders.total) as [Doanh thu theo năm],
					 YEAR(Orders.order_date) as [Năm]
			  from Orders 
					inner join Customers on Orders.customer_id = Customers.customer_id
			  where YEAR(Orders.order_date) = @nam
			  group by Customers.[name], YEAR(Orders.order_date)
			  order by Customers.[name]
		return
	end
-- TEST: Tổng doanh thu các đơn hàng đã mua của các khách hàng trong năm 2022
select * from bai2_nam(2022)
-- drop function bai2_nam


/*****************************************************************************************
  * Bài 3: Lấy ra top 100 sản phẩm đang tồn ít nhất theo mỗi quốc gia ( Mã sản phẩm,     *
  *        Tên sản phẩm, tên kho tồn, quốc gia kho, tổng sl tồn tại kho)                 *
  ****************************************************************************************/

-- TEST: Lấy ra top 100 sản phẩm đang tồn ít nhất của quốc gia 'Việt Nam'
create view bai3 as
	select top 100 Inventories.product_id as [Mã sản phẩm], Products.product_name as [Tên sản phẩm], 
		   Warehouses.warehouse_name as [Tên kho tồn], Countries.country_name as [Quốc gia], 
		   sum(Inventories.quantity) as [Tổng số lượng tồn tại kho]
	from Products
		inner join Inventories on Products.product_id = Inventories.product_id
		inner join Warehouses on Inventories.warehouse_id = Warehouses.warehouse_id
		inner join Locations on Warehouses.location_id = Locations.location_id
		inner join Countries on Locations.country_id = Countries.country_id
	where Countries.country_name = N'Việt Nam'
	group by Inventories.product_id, Products.product_name, Warehouses.warehouse_name, Countries.country_name
	order by [Tổng số lượng tồn tại kho]
-- select * from bai3

select top 100 [Mã sản phẩm], [Tên sản phẩm], 
	   string_agg([Tên kho tồn], ', ') within group 
	   (order by [Mã sản phẩm], [Tên sản phẩm], [Quốc gia])  as [Tên kho tồn], 
		[Quốc gia], sum([Tổng số lượng tồn tại kho]) as [Tổng số lượng tồn tại kho]
from bai3
group by [Mã sản phẩm], [Tên sản phẩm], [Quốc gia]

