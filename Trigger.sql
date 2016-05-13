
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


if OBJECT_ID('onEmailUpdate') IS NOT NULL
	drop trigger dbo.onEmailUpdate
go
create trigger onEmailUpdate
on dbo.Users 
after UPDATE 
as
begin
	IF UPDATE (userEmail)
	begin 
		RAISERROR ('email can not be changed', 16, 16, 1)
		rollback 
	end

end
go


