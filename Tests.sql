use SI2

exec dbo.dropAllTables
exec dbo.createTables

exec dbo.insertUser 620, 'Rua Cidade lobito' , 'blie@hotmail.com', 'ze', 'qwerty'
exec dbo.insertUser 620, 'Avenida Berlim' , 'metalicaRules@hotmail.com', 'chiquinho', 'benfica'
exec dbo.insertUser 620, 'Chelas' , 'tgis@hotmail.com', 'Pedro', '1234'
exec dbo.insertUser 620, 'Olivais' , 'soulinda91@hotmail.com', 'Maria', 'password1'

exec dbo.insertItem 1,  620, 'Rua Cidade lela', 'cafe', 'Novo', 20, '2016-05-01', '2016-06-01', 'Direct'
exec dbo.insertItem 1,  620, 'Rua Cidade bgta', 'gato', 'Novo', 30, '2016-05-01', '2016-06-01', 'Direct'
exec dbo.insertItem 1,  620, 'Vasco da Gama', 'Iphone75', 'Novo', 200, '2016-05-01', '2016-06-01', 'Auction', 1
exec dbo.insertItem 1,  620, 'Colombo', 'nokia7310', 'Novo', 1000, '2016-03-01', '2016-04-01', 'Auction', 2

exec dbo.updateItem 1, 'cafezinho do bom'

exec dbo.removeItem 4

exec dbo.updateUser @uId = 2, @countryCode = 620, @addr = 'Rua das Rosas', @name = 'Mestre', @pw ='kappa' 

exec dbo.removeUser 4

exec dbo.insertLocation 620, 'Rua teste'

exec dbo.updateLocation @lId = 9, @country = 276

exec dbo.removeLocation 9

exec dbo.insertBid 1, 20, 2

exec dbo.insertBid 3, 200, 2

exec dbo.removeBid 2

print dbo.BiddingPrice(3)

select * from dbo.LastNBids(1)

exec dbo.concludeSale 1, 2, 1234123412341234, 620, 'Bela vista' 

select * from NotConcludedAuction()

print dbo.checkPassword(1, 'qwerty')

select * from dbo.Users
select * from dbo.Location
select * from dbo.Bid


