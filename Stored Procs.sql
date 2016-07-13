use SI2

if OBJECT_ID('initCountries') IS NOT NULL
	drop proc dbo.initCountries
go
Create proc initCountries 
as 
	SET NOCOUNT on
	insert into dbo.Country values('Portugal', 620)
	insert into dbo.Country values('Spain', 724)
	insert into dbo.Country values('Afghanistan', 004)
	insert into dbo.Country values('Åland Islands', 248)
	insert into dbo.Country values('Albania', 008)
	insert into dbo.Country values('Algeria', 012)
	insert into dbo.Country values('American Samoa', 016)
	insert into dbo.Country values('Andorra', 020)
	insert into dbo.Country values('Australia', 036)
	insert into dbo.Country values('Uruguay', 858)
	insert into dbo.Country values('Belgium', 056)
	insert into dbo.Country values('Brazil', 076)
	insert into dbo.Country values('Czech Republic', 203)
	insert into dbo.Country values('Denmark', 208)
	insert into dbo.Country values('France', 250)
	insert into dbo.Country values('Germany', 276)
	insert into dbo.Country values('Hong Kong', 344)
	insert into dbo.Country values('United States of America', 840)
	insert into dbo.Country values('United Kingdom of Great Britain and Northern Ireland', 826)
	-- outros paises
go

if OBJECT_ID('initShippingPrices') IS NOT NULL
	drop proc dbo.initShippingPrices
go
Create proc initShippingPrices 
as 
	SET NOCOUNT on
	insert into dbo.Shipping values (620, 724, 10)
	insert into dbo.Shipping values (724, 620, 10)
	insert into dbo.Shipping values (276, 620, 25)
	insert into dbo.Shipping values (620, 276, 20)

go

if OBJECT_ID('insertUser') IS NOT NULL
	drop proc dbo.insertUser
go
Create proc insertUser @countryCode numeric(3), @addr varchar(255), @mail varchar(255), @name varchar(255), @pw varchar(255) 
as 	
	SET NOCOUNT on
	exec dbo.insertLocation @countryCode, @addr 
	insert into dbo.Users values (@@IDENTITY, @mail, @name, dbo.MD5(@pw))	
go

if OBJECT_ID('updateUser') IS NOT NULL
	drop proc dbo.updateUser
go
Create proc updateUser @uId int, @countryCode numeric(3) = null, @addr varchar(255) = null, @name varchar(255) = null, @pw varchar(255) = null 
as 	
	SET NOCOUNT on
	begin try
	begin tran
		if(@countryCode IS NOT NULL OR @addr IS NOT NULL)
		begin
			exec dbo.updateUserAddress @uId, @addr, @countryCode	
		end
		if(@name IS NOT NULL)
		begin
			update dbo.Users
			set userName = @name
			where userId = @uId		
		end
		if(@pw IS NOT NULL)
		begin
			update dbo.Users
			set userPassword = dbo.MD5(@pw)
			where userId = @uId		
		end		
	commit
	end try
	begin catch
		raiserror('error updating User', 16, 16,1)
		rollback
	end catch 
go

if OBJECT_ID('removeUser') IS NOT NULL
	drop proc dbo.removeUser
go
Create proc removeUser @uId int 
as 	
	SET NOCOUNT on
	begin tran
		declare @ta table 
		(
			loc int
		)
		insert into @ta select addrHistUserLocation from AddressHistory where addrHistUserId = @uId
		delete from dbo.AddressHistory where addrHistUserId = @uId
		delete from dbo.Location where locationId IN (select * from @ta)

		insert into @ta select itemId from Item where itemUserId = @uId
		delete from dbo.ItemSaleType where itemSaleTypeItemId in (select * from @ta)

		insert into @ta select itemLocationId from Item where itemUserId = @uId
		delete from dbo.Item where itemLocationId in (select * from @ta)
		delete from dbo.Location where locationId in (select * from @ta)
		
		Declare @aux int
		select @aux = userLocation from dbo.Users where userId = @uId
		delete from dbo.Users where userId = @uId
		delete from dbo.Location where locationId = @aux
	
	commit
go


if OBJECT_ID('insertAddressHistory') IS NOT NULL
	drop proc dbo.insertAddressHistory
go
Create proc insertAddressHistory @userId int, @userAddress varchar(255)
as
	insert into dbo.AddressHistory values(@userId, @userAddress, GETDATE())
go


if OBJECT_ID('updateUserAddress') IS NOT NULL
	drop proc dbo.updateUserAddress
go
Create proc updateUserAddress @uId int, @userAddress varchar(255), @countryCode numeric(3) = null
as
	SET NOCOUNT on
	
	declare @oldLoc int
	select @oldLoc = userLocation from dbo.Users where userId = @uId
	if(@countryCode IS NULL)
		select @countryCode = locationCountry from dbo.Location where locationId = @oldLoc

	--check if changes anything in location
	declare @aux int
	select @aux =  userId from dbo.Users inner join dbo.Location on( userLocation = locationId) where locationCountry =@countryCode AND locationAddress = @userAddress 
	if(@@ROWCOUNT = 1 )
		return
	begin try
	begin tran
		declare @newLoc int
		exec dbo.insertLocation @countryCode, @userAddress 
		set @newLoc = @@IDENTITY

		insert into dbo.AddressHistory (addrHistUserId, addrHistUserLocation) values(@uId, @oldLoc)
		update dbo.Users set userLocation = @newLoc where dbo.Users.userId = @uId  -- update with new location
		
	commit
	end try
	begin catch
		raiserror('error updating address', 16, 16,1)
		rollback
	end catch
go

if OBJECT_ID('insertItem') IS NOT NULL
	drop proc dbo.insertItem
go
create proc insertItem @uId int, @countryCode numeric(3), @address varchar(255),@desc varchar(255), @state varchar(255), @value float, @beginDate Date, @endDate Date ,@itemSaleType varchar(7), @auctionMinimumValue float = null 
as
	set NOCOUNT ON
	begin tran
		begin try
		exec dbo.insertLocation @countryCode, @address 
		insert into dbo.Item values (@desc, @state, @value, @beginDate, @endDate, @@IDENTITY , @uId)
		if(@itemSaleType = 'Auction') 
		begin
			if(@value > 10 AND @auctionMinimumValue <= @value * 0.1 AND @auctionMinimumValue >= 1 )
				insert into dbo.ItemSaleType values (SCOPE_IDENTITY(), @itemSaleType, @auctionMinimumValue, DEFAULT)
			else 
				begin
					rollback
					raiserror('invalid auction parameter', 16, 16,1)
					return
				end
			
		end
		if(@itemSaleType = 'Direct') 
		begin
			insert into dbo.ItemSaleType values (SCOPE_IDENTITY(), @itemSaleType, null, DEFAULT)
		end
	commit
	end try
	begin catch
		raiserror('error inserting item', 16, 16,1)
		rollback
	end catch
go

if OBJECT_ID('removeItem') IS NOT NULL
	drop proc dbo.removeItem
go
create proc removeItem @iId int
as
	set NOCOUNT ON
	delete from dbo.ItemSaleType where itemSaleTypeItemId = @iId	
	declare @aux int
	select @aux = itemLocationId from dbo.Item where itemId = @iId
	delete from dbo.Item where itemId = @iId
	delete from dbo.Location where locationId = @aux 
	
go

if OBJECT_ID('updateItem') IS NOT NULL
	drop proc dbo.updateItem
go
create proc updateItem @iId int, @desc varchar(255)
as
	set NOCOUNT ON	
	update dbo.Item
	set itemDescription = @desc
	where itemId = @iId
go


if OBJECT_ID('insertLocation') IS NOT NULL
	drop proc dbo.insertLocation
go
create proc insertLocation @country numeric(3), @addr varchar(255)
as
	set NOCOUNT ON
	insert into dbo.Location values (@country, @addr)
go

if OBJECT_ID('updateLocation') IS NOT NULL
	drop proc dbo.updateLocation
go
create proc updateLocation @lId int , @country numeric(3) = null, @addr varchar(255) = null
as
	set NOCOUNT ON
	if(@country IS NOT NULL)
	begin
		update dbo.Location
		set locationCountry = @country
		where locationId = @lId
	end
	if(@addr IS NOT NULL)
	begin
		update dbo.Location
		set locationAddress = @addr
		where locationId = @lId
	end	
go

if OBJECT_ID('removeLocation') IS NOT NULL
	drop proc dbo.removeLocation
go
create proc removeLocation @lId int
as
	set NOCOUNT ON
	delete from dbo.AddressHistory where addrHistUserLocation = @lId
	
	declare @aux int
	select @aux =  userId from dbo.Users where userLocation = @lId
	if(@@ROWCOUNT <> 0)
	begin
		exec dbo.removeUser @aux
		return
	end

	select @aux = itemId from dbo.Item where itemLocationId = @lId
	if(@@ROWCOUNT <> 0)
	begin
		exec dbo.removeItem @aux
		return
	end

	select @aux = saleId from dbo.Sale where saleItemId = @lId
	if(@@ROWCOUNT <> 0)
	begin
		delete from dbo.Sale where saleId = @aux
		return
	end
	
	delete from dbo.Location where locationId = @lId 
		 
go


if OBJECT_ID('insertBid') IS NOT NULL
	drop proc dbo.insertBid
go
create proc insertBid @iId int, @value float, @uId int 
as	
	SET NOCOUNT ON
	Declare @intAux int
	if((select count(*) from dbo.Item where itemId = @iId) = 0)
	begin
		raiserror('Item does not exist', 16, 16, 1)
		return
	end
	if((select count(*) from dbo.Users where userId = @uId) = 0)
	begin
		raiserror('User does not exist', 16, 16, 1)
		return
	end
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ 
	begin tran
		if((select itemEndDate from dbo.Item where itemId = @iId) < GETDATE())
		begin
			raiserror('Item no longer allowed to bid', 16, 16, 1)
			commit
			return
		end
		--check if Direct
		select @intAux = count(*) from dbo.ItemSaleType where itemSaleTypeItemId = @iId AND itemSaleTypeDesc = 'Direct'
		if( @intAux > 0)
		begin
			if(@value <> (select itemValue from dbo.Item where itemId = @iId))
			begin
				raiserror('Value not correct to bid', 16, 16, 1)
				commit
				return
			end
			if(EXISTS ( select * from dbo.Bid where bidItemId = @iId))
			begin
				raiserror('item no longer available to bid', 16, 16, 1)
				commit
				return	
			end
			insert into dbo.Bid (bidItemId, bidUserId, bidDate, bidValue) values (@iId, @uId, GETDATE(), @value)
		end

		--check if Auction
		select @intAux = count(*) from dbo.ItemSaleType where itemSaleTypeItemId = @iId AND itemSaleTypeDesc = 'Auction'
		if( @intAux > 0)
		begin
			declare @lastBidValue float
			select @lastBidValue =  MAX(bidValue) from dbo.Bid where bidItemId = @iId AND bidAlive = 1
			if(@lastBidValue IS NULL)
			begin
				select @lastBidValue = itemValue from dbo.Item where itemId = @iId 
				if(@value < @lastBidValue)
				begin
					raiserror('Value not correct to bid', 16, 16, 1)
					commit
					return
				end
				insert into dbo.Bid (bidItemId, bidUserId, bidDate, bidValue) values (@iId, @uId, GETDATE(), @value)
				commit
				return
			end
			if(@value <= @lastBidValue OR @value < (select auctionMinimumBid from dbo.ItemSaleType where itemSaleTypeItemId = @iId) + @lastBidValue)
			begin
				raiserror('Value not correct to bid', 16, 16, 1)
				commit
				return
			end
			insert into dbo.Bid (bidItemId, bidUserId, bidDate, bidValue) values (@iId, @uId,GETDATE(), @value)

		end
	commit
go

if OBJECT_ID('removeBid') IS NOT NULL
	drop proc dbo.removeBid
go
create proc removeBid @bId int
as
	SET NOCOUNT ON
	if( (select count(*) from dbo.Sale where saleItemId = (select bidItemId from dbo.Bid where bidId = @bId)) > 0)
	begin	
		raiserror('Item has been sold, can not remove bid', 16, 16, 1)
		return		
	end
	update dbo.Bid
	set bidAlive = 0
	where bidId = @bId
go


if OBJECT_ID('concludeSale') IS NOT NULL
	drop proc dbo.concludeSale
go
create proc concludeSale @iId int, @uId int, @credCard numeric(16), @countryCode numeric(3), @addr varchar(255)
as
	SET NOCOUNT ON
	begin tran
		if((select count(*) from dbo.Item where itemId = @iId) = 0)
		begin
			raiserror('Item does not exist', 16, 16, 1)
			commit
			return
		end
		if((select count(*) from dbo.Users where userId = @uId) = 0)
		begin
			raiserror('User does not exist', 16, 16, 1)
			commit
			return
		end
			
		Declare @bId int
		select @bId = MAX(bidId) from dbo.Bid where bidItemId = @iId AND bidAlive = 1
		if(@bId IS NULL)
		begin
			raiserror('No Bids for the item', 16, 16, 1)
			commit
			return
		end
		if((select bidUserId from dbo.Bid where bidId = @bId) <> @uId)
		begin
			raiserror('User trying to buy, does not correspond to the winning bid', 16, 16, 1)
			commit
			return
		end
		if((select itemEndDate from dbo.Item where itemId = @iId) > GETDATE() AND (select count(*) from dbo.ItemSaleType where itemSaleTypeItemId = @iId AND itemSaleTypeDesc = 'Auction') > 0)
		begin
			raiserror('Auction has not ended yet', 16, 16, 1)
			commit
			return
		end
		if(DATEADD(day, 2, (select itemEndDate from dbo.Item where itemId = @iId)) < GETDATE())
		begin
			raiserror('Sale expire date has passed (2days)', 16, 16, 1)
			commit
			return
		end

		exec dbo.insertLocation @countryCode, @addr
		insert into dbo.Sale values (GETDATE(), @iId, @credCard, @@IDENTITY)
	commit
go

if OBJECT_ID('LastNBids') IS NOT NULL
	drop proc dbo.LastNBids
go
create proc LastNBids @n int
as	
	select top (@n) bidId, bidItemId, bidDate, bidValue, bidAlive from dbo.Bid where bidAlive = 1 order by(bidDate) DESC
go


if OBJECT_ID('NotConcludedAuction') IS NOT NULL
	drop proc dbo.NotConcludedAuction
go
create proc NotConcludedAuction
as
	select  itemSaleTypeItemId, itemSaleTypeDesc, auctionMinimumBid, itemSaleTypeDate, itemEndDate  
	from dbo.ItemSaleType INNER JOIN dbo.Item on(itemSaleTypeItemId = itemId) 
	where itemSaleTypeDesc = 'Auction' AND itemEndDate >= GETDATE()	
go


if OBJECT_ID('BidsInfoFromConcludedAuction') IS NOT NULL
	drop proc dbo.BidsInfoFromConcludedAuction
go
create proc BidsInfoFromConcludedAuction @iId int
as
	if(exists( select * from dbo.Item where itemId = @iId))
	begin
		if(exists( select * from dbo.ItemSaleType where itemSaleTypeItemId = @iId AND itemSaleTypeDesc = 'Auction'))
		begin
			select bidUserId, bidDate
			from dbo.Bid
			where bidItemId = @iId
			order by bidDate ASC
		end
		else
		 raiserror('This item was not sold by auction', 16, 16, 1)
	end
	else
	 raiserror('No such item with that id', 16, 16, 1)

go


if OBJECT_ID('AuctionInfoFromConcludedAuction') IS NOT NULL
	drop proc dbo.AuctionInfoFromConcludedAuction
go
create proc AuctionInfoFromConcludedAuction @iId int
as
	if(exists( select * from dbo.Item where itemId = @iId))
	begin
		if(exists( select * from dbo.ItemSaleType where itemSaleTypeItemId = @iId AND itemSaleTypeDesc = 'Auction'))
		begin
			select itemSaleTypeId, auctionMinimumBid, itemSaleTypeDate, itemValue
			from dbo.ItemSaleType Inner join dbo.Item on (itemId = itemSaleTypeItemId)
			where itemSaleTypeItemId = @iId
		end
		else
		 raiserror('This item was not sold by auction', 16, 16, 1)
	end
	else
	 raiserror('No such item with that id', 16, 16, 1)
go


if OBJECT_ID('dropAllTables') IS NOT NULL
	drop proc dbo.dropAllTables
go
create proc dropAllTables
as	
	drop table dbo.Sale
	drop table dbo.Bid
	drop table dbo.ItemSaleType
	drop table dbo.Item
	drop table dbo.AddressHistory
	drop table dbo.Users
	drop table dbo.Location
	drop table dbo.Shipping
	drop table dbo.Country
go

