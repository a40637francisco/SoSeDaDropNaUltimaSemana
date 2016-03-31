use SI2

drop table dbo.Country
Create table Country
(
	name varchar(255) not null,
	code numeric(3) not null,
	Primary key(code)
)


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


if OBJECT_ID('Users') IS NOT NULL
	drop table Users
Create table Users
(
	userId int identity(1,1),
	userAddress varchar(255) not null,
	userEmail varchar(255) not null,
	userName varchar(255) not null,
	userPassword varchar(4000) not null,
	constraint uniqueEmail Unique(userEmail),
	Primary key(userId)
)

if OBJECT_ID('AddressHistory') IS NOT NULL
	drop table AddressHistory
Create table AddressHistory
(	
	addrHistUserId int not null,
	addrHistUserAddress varchar(255) not null,
	addrHistDateTime DateTime
	constraint fk_addrHist_userId foreign key(addrHistuserId) references dbo.Users(userId),
	Primary key(addrHistuserId, addrHistDateTime)
)



if OBJECT_ID('ItemType') IS NOT NULL
	drop table dbo.ItemType
Create table ItemType
(
	itemTypeId int,
	itemTypeDescription varchar(255),
	Primary key(itemTypeId)
)

exec dbo.initItemType

if OBJECT_ID('Item') IS NOT NULL
	drop table dbo.Item
Create table Item
(
	itemId int identity(1,1) not null,
	itemDescription varchar(255) not null,
	itemState varchar(255) not null,
	itemValue float not null,
	itemType int not null,
	itemBegginDate Date not null,
	itemEndDate Date not null,

	item_userId int not null,

	constraint invalid_itemType Foreign key (itemType) References ItemType(itemTypeId),
	constraint invalid_UserId_FK Foreign key(item_userId) References Users(userId), 
	constraint invalid_ItemSate Check(itemState ='New' OR itemState ='Used'),

	Primary key(itemId, itemType) -- itemType in pk is dumb, but add to in the specific types
)



if OBJECT_ID('Direct') IS NOT NULL
	drop table dbo.Direct
Create table Direct
(
	directId int not null,
	directItemId int not null,
	directDate Date not null,
	Constraint direct_item_fk Foreign key(directItemId, directId) references dbo.Item(itemId, itemType),
	Primary key(directItemId)
)

if OBJECT_ID('Auction') IS NOT NULL
	drop table dbo.Auction
Create table Auction
(
	auctionId int not null,
	auctionItemId int not null,
	auctionDate Date not null,
	Constraint auction_item_fk Foreign key(auctionItemId, auctionId) references dbo.Item(itemId, itemType),
	Primary key(auctionItemId)
)

if OBJECT_ID('Bid') IS NOT NULL
	drop table dbo.Bid
Create table Bid
(
	bidId int identity(1,1),
	bidItemId int not null,
	bidDate DateTime not null,
	bidValue float not null,
	bidAlive int default 1,

	constraint bid_item_fk Foreign key(bidItemId) references dbo.Item(itemId),
	constraint unique_bidDate_item UNIQUE(bidDate, bidItemId),
	primary key(bidId)
)







/*
if OBJECT_ID('Sale') IS NOT NULL
	drop table Sale
Create table Sale
(
	saleId int identity(1,1),
	endDate Date not null,
	begginDate Date not null,
	value float not null,

	userId int not null,

	itemId int not null,

	saleType int not null,

	constraint fk_saleType Foreign key(saleType) references ItemType(saleTypeId),
	constraint fk_item Foreign key(itemId) references Item(itemId),
	constraint uniqueSaleType unique (saleId, saleType),

	Primary key(saleId, userId, itemId)
)*/