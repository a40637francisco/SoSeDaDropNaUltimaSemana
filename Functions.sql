use SI2

if OBJECT_ID('MD5') IS NOT NULL
	drop function dbo.MD5
go
create function MD5(@pw varchar(255))
returns varchar(4000)
as
begin
	return SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('MD5',  @pw )),3,32) 

end
go


if OBJECT_ID('CheckPassword') IS NOT NULL
	drop function dbo.CheckPassword
go
create function CheckPassword(@uId int, @pw varchar(255))
returns bit
as
begin
	Declare @aux varchar(4000)
	Declare @curr varchar(4000)
	set @aux = dbo.MD5(@pw)
	select @curr = userPassword from dbo.Users where userId = @uId
	if(@curr = @aux) return 1
	return 0
end
go

if OBJECT_ID('CheckPassword_EF') IS NOT NULL
	drop function dbo.CheckPassword_EF
go
create function CheckPassword_EF(@uId int, @pw varchar(255))
returns @t table
(
	result bit not null
)
begin
	Declare @aux varchar(4000)
	Declare @curr varchar(4000)
	set @aux = dbo.MD5(@pw)
	select @curr = userPassword from dbo.Users where userId = @uId
	if(@curr = @aux) insert into @t values(1)
	insert into @t values(0)
	return
end
go

if OBJECT_ID('ShippingPrice') IS NOT NULL
	drop function dbo.ShippingPrice
go
create function ShippingPrice(@to numeric(3), @from numeric(3)) 
returns float
as
begin
	declare @p float
	select @p = price from dbo.Shipping where dbo.Shipping.codeTo = @to AND dbo.Shipping.codeFrom = @from
	return @p
end
go

if OBJECT_ID('ShippingPrice_EF') IS NOT NULL
	drop function dbo.ShippingPrice_EF
go
create function ShippingPrice_EF(@to numeric(3), @from numeric(3)) 
returns @t table
(
	result float not null
)
begin
	declare @p float
	select @p = price from dbo.Shipping where dbo.Shipping.codeTo = @to AND dbo.Shipping.codeFrom = @from
	insert into @t values(@p)
	return
end
go

if OBJECT_ID('BiddingPrice') IS NOT NULL
	drop function dbo.BiddingPrice
go
create function BiddingPrice(@iId int)
returns float
begin
	if((select count(*) from dbo.Item where itemId = @iId) = 0)
	begin
		return cast('Item does not exist' as int);
	end
	declare @lastBidValue float
	select @lastBidValue =  MAX(bidValue) from dbo.Bid where bidItemId = @iId AND bidAlive = 1
	if(@lastBidValue IS NULL)
			begin
				return (select itemValue from dbo.Item where itemId = @iId) 
			end

	else if((select count(*) from dbo.ItemSaleType where itemSaleTypeItemId = @iId AND itemSaleTypeDesc = 'Direct') > 0)
		begin
		 return cast('Item already sold' as int);
		end
	else
		return (select auctionMinimumBid from dbo.ItemSaleType where itemSaleTypeItemId = @iId) + @lastBidValue
	 return cast('Error in BiddingPrice function' as int);
end
go

if OBJECT_ID('BiddingPrice_EF') IS NOT NULL
	drop function dbo.BiddingPrice_EF
go
create function BiddingPrice_EF(@iId int)
returns @t table
(
	result float not null
)
begin
	if((select count(*) from dbo.Item where itemId = @iId) = 0)
	begin
		insert into @t values(cast('Item does not exist' as float));
		return
	end
	declare @lastBidValue float
	select @lastBidValue =  MAX(bidValue) from dbo.Bid where bidItemId = @iId AND bidAlive = 1
	if(@lastBidValue IS NULL)
			begin
				insert into @t values((select itemValue from dbo.Item where itemId = @iId)); 
				return
			end

	else if((select count(*) from dbo.ItemSaleType where itemSaleTypeItemId = @iId AND itemSaleTypeDesc = 'Direct') > 0)
		begin
		 insert into @t values(cast('Item already sold' as int));
		 return
		end
	else
		insert into @t values((select auctionMinimumBid from dbo.ItemSaleType where itemSaleTypeItemId = @iId) + @lastBidValue);
		return
	 insert into @t values(cast('Error in BiddingPrice function' as int));
	 return
end
go


--It has stored Proc version to use in c#
if OBJECT_ID('LastNBidsFunc') IS NOT NULL
	drop function dbo.LastNBidsFunc
go
create function LastNBidsFunc(@n int)
returns @t table
(
	bidId int not null,
	bidItemId int not null,
	bidDate DateTime2 not null,
	bidValue float not null,
	bidAlive int not null
)
begin
	insert into @t select top (@n) bidId, bidItemId, bidDate, bidValue, bidAlive from dbo.Bid where bidAlive = 1 order by(bidDate) DESC
	return 
end
go


--It has stored Proc version to use in c#
if OBJECT_ID('NotConcludedAuctionFunc') IS NOT NULL
	drop function dbo.NotConcludedAuctionFunc
go
create function NotConcludedAuctionFunc()
returns @t table
(
	itemSaleTypeItemId int not null,
	itemSaleTypeDesc varchar(7) not null,
	auctionMinimumBid float,
	itemSaleTypeDate DateTime2 default GETDATE(),
	auctionEndDate Date not null
)
begin
	insert into @t 
	select  itemSaleTypeItemId, itemSaleTypeDesc, auctionMinimumBid, itemSaleTypeDate, itemEndDate  
	from dbo.ItemSaleType INNER JOIN dbo.Item on(itemSaleTypeItemId = itemId) 
	where itemSaleTypeDesc = 'Auction' AND itemEndDate >= GETDATE()	
	return 
end
go