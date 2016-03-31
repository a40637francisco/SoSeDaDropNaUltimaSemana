use SI2

if OBJECT_ID('initItemType') IS NOT NULL
	drop proc dbo.initItemType
create proc initItemType 
as 
	insert into dbo.ItemType values(1, 'Direct')
	insert into dbo.ItemType values(2, 'Auction')
go

if OBJECT_ID('initCountries') IS NOT NULL
	drop proc dbo.initCountries
Create proc initCountries 
as 
	insert into dbo.Country values('Portugal', 620)
	insert into dbo.Country values('Spain', 724)

	// outros paises
go


if OBJECT_ID('insertUser') IS NOT NULL
	drop proc dbo.insertUser
go
Create proc insertUser @addr varchar(255), @mail varchar(255), @name varchar(255), @pw varchar(255) 
as 
	
	insert into dbo.Users values (@addr, @mail, @name, dbo.MD5(@pw))
	
go




if OBJECT_ID('insertAddressHistory') IS NOT NULL
	drop proc dbo.insertAddressHistory
go
Create proc insertAddressHistory @userId int, @userAddress varchar(255)
as
	insert into dbo.AddressHistory values(@userId, @userAddress, GETDATE())
go


if OBJECT_ID('deleteAllTables') IS NOT NULL
	drop proc dbo.deleteAllTables
create proc deleteAllTables
as	
	delete from dbo.Direct
	delete from dbo.Auction
	delete from dbo.Item
	delete from dbo.Users
go


if OBJECT_ID('dropAllTables') IS NOT NULL
	drop proc dbo.dropAllTables
create proc dropAllTables
as	
	drop table dbo.Direct
	drop table dbo.Auction	
	drop table dbo.Bid
	drop table dbo.Item
	drop table dbo.ItemType
	drop table dbo.Users
go

if OBJECT_ID('setTestValues') IS NOT NULL
	drop proc dbo.setTestValues
create proc setTestValues
as
	declare @user1Id int
	insert into dbo.Users  values('Lisboa', 'la@hotmail.com', 'André','123321')
	select @user1Id = userId from Users where userName='André'
	insert into dbo.Users  values('Porto', 'joao95@hotmail.com', 'João', 'qwerty')

	insert into dbo.Item values('surf board', 'New', 289, 1, '2016-03-13', '2016-04-14', @user1Id)

go

if OBJECT_ID('tests') IS NOT NULL
	drop proc dbo.tests
create proc tests
as
	Begin transaction
	declare @user1Id int
	insert into dbo.Users  values('Lisboa', 'la@hotmail.com', 'André')
	select @user1Id = userId from Users where userName='André'
	insert into dbo.Item values('surf board', 'New', 289, 50, '2016-03-13', '2016-04-14', @user1Id)


	rollback
go