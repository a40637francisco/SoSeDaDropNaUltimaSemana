use SI2

if OBJECT_ID('createTables') IS NOT NULL
	drop proc dbo.createTables
go
create proc createTables
as
	if OBJECT_ID('Country') IS NOT NULL
	drop table dbo.Country
Create table Country
(
	name varchar(70) not null,
	code numeric(3) not null,
	Primary key(code) 
)

if OBJECT_ID('Shipping') IS NOT NULL
	drop table dbo.Shipping
Create table Shipping
(	
	codeFrom numeric(3) not null,
	codeTo numeric(3) not null,
	price float not null,
	foreign key(codeFrom) references Country(code),
	foreign key(codeTo) references Country(code),
	primary key(codeFrom, codeTo)
)



if OBJECT_ID('Location') IS NOT NULL
	drop table dbo.Location
Create table Location
(
	locationId int identity(1,1),
	locationCountry numeric(3) not null,
	locationAddress varchar(255) not null,
	constraint fk_countryCode foreign key(locationCountry) references dbo.Country(code),
	Primary key(locationId)
)


if OBJECT_ID('Users') IS NOT NULL
	drop table dbo.Users
Create table Users
(
	userId int identity(1,1),
	userLocation int not null,
	userEmail varchar(255) not null,
	userName varchar(255) not null,
	userPassword varchar(4000) not null,
	constraint uniqueEmail Unique(userEmail),
	constraint fk_LocationID foreign key(userLocation) references dbo.Location(locationId),
	Primary key(userId)
)

if OBJECT_ID('AddressHistory') IS NOT NULL
	drop table dbo.AddressHistory
Create table AddressHistory
(	
	addrHistId int identity(1,1),
	addrHistUserId int not null,
	addrHistUserLocation int not null,
	addrHistDateTime DateTime2 not null default GETDATE(),
	constraint fk_addrHist_userId foreign key(addrHistuserId) references dbo.Users(userId),
	constraint fk_addrHist_userLocation foreign key(addrHistUserLocation) references dbo.Location(locationId),
	Unique(addrHistuserId, addrHistUserLocation),
	Primary key(addrHistId)
)

if OBJECT_ID('Item') IS NOT NULL
	drop table dbo.Item
Create table Item
(
	itemId int identity(1,1) not null,
	itemDescription varchar(255) not null,
	itemState varchar(255) not null,
	itemValue float not null,

	itemBeginDate Date not null,
	itemEndDate Date not null,
	itemLocationId int not null,
	itemUserId int not null,


	constraint invalid_UserId_FK Foreign key(itemUserId) References Users(userId), 
	constraint invalid_ItemSate Check(itemState ='Novo' OR itemState ='Usado' OR itemState ='Como novo' OR itemState ='Velharia vintage'),
	constraint invalid_LocationId_FK Foreign key(itemLocationId) References Location(locationId), 

	Primary key(itemId) 
)

if OBJECT_ID('ItemSaleType') IS NOT NULL
	drop table dbo.ItemSaleType
Create table ItemSaleType
(
	itemSaleTypeId int identity(1,1),
	itemSaleTypeItemId int not null,
	itemSaleTypeDesc varchar(7) not null,
	auctionMinimumBid float,
	itemSaleTypeDate DateTime2 default GETDATE(),
	constraint itemSaleTypeDesc Check(itemSaleTypeDesc = 'Direct' OR itemSaleTypeDesc = 'Auction'),
	Constraint ItemSaleType_item_fk Foreign key(itemSaleTypeItemId) references dbo.Item(itemId),
	Primary key(itemSaleTypeId)
)

if OBJECT_ID('Bid') IS NOT NULL
	drop table dbo.Bid
Create table Bid
(
	bidId int identity(1,1),
	bidItemId int not null,
	bidUserId int not null,
	bidDate DateTime2 not null,
	bidValue float not null,
	bidAlive int default 1,

	constraint bid_item_fk Foreign key(bidItemId) references dbo.Item(itemId),
	constraint bid_user_fk Foreign key(bidItemId) references dbo.Users(userId),

	constraint unique_bidDate_item UNIQUE(bidDate, bidItemId),
	primary key(bidId)
)



exec dbo.initCountries
exec dbo.initShippingPrices


if OBJECT_ID('Sale') IS NOT NULL
	drop table dbo.Sale
Create table Sale
(
	saleId int identity(1,1),
	saleDate Date not null,
	saleItemId int not null,
	saleCreditCard  numeric(16) not null,
	saleFinalDestination int not null,

	constraint sale_item_fk Foreign key(saleItemId) references dbo.Item(itemId),
	constraint sale_location_fk Foreign key(saleFinalDestination) references dbo.Location(locationId),
	constraint sale_saleItemId_unique UNIQUE(saleItemId),
	Primary key(saleId)
)
go

