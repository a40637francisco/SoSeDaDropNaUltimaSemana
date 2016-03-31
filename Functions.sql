create function dbo.MD5(@pw varchar(255))
returns varchar(4000)
as
begin
	return SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('MD5',  @pw )),3,32) 

end
go