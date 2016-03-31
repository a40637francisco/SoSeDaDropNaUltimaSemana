if OBJECT_ID('onItemInsert') IS NOT NULL
	drop trigger dbo.onItemInsert
create trigger onItemInsert
on dbo.Item after insert
as
begin
	Declare @type int
	Declare @id int
	select @id = itemId from inserted
	select @type = itemType from inserted
	print @id
	print @type
	if (@type = 1)
		insert into dbo.Direct values (1, @id, GETDATE())
	if (@type = 2) 
		insert into dbo.Auction values(2, @id, GETDATE())
end
go

if OBJECT_ID('onCountryInsert') IS NOT NULL
	drop trigger dbo.onCountryInsert
go
create trigger onCountryInsert
on dbo.Country 
after insert
as
begin
    declare @code numeric(3)
	select @code = code from inserted
	insert into dbo.Shipping values (@code, @code, 0)

end
go

if OBJECT_ID('onUserDelete') IS NOT NULL
	drop trigger dbo.onUserDelete
go
create trigger onUserDelete
on dbo.Users 
instead of delete 
as
begin	
   delete from dbo.AddressHistory where dbo.AddressHistory.addrHistUserId = (select userId from inserted) 
   delete from dbo.Users where dbo.Users.userId = (select userId from inserted) 
   
    -- add more later

end
go

if OBJECT_ID('onAddressUpdate') IS NOT NULL
	drop trigger dbo.onAddressUpdate
go
create trigger onAddressUpdate
on dbo.Users 
after update
as
begin	
   if(UPDATE(userAddress))
   begin
		declare @userId int
		declare @addr varchar(255)
		select @userId = userId from deleted
		select @addr = userAddress from deleted
		exec dbo.insertAddressHistory @userId, @addr
		
   end
 

end
go