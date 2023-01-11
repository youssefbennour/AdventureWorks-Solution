
/* Show the first name and the email address of customer with CompanyName 'Bike World' */
--, [store].[Name]
SELECT [p].[FirstName], [mail].[EmailAddress]
FROM [Person].[Person] p
INNER JOIN [Person].[EmailAddress] mail
ON [p].[BusinessEntityID] = [mail].[BusinessEntityID]
INNER JOIN [Sales].[Customer] c
ON [c].[CustomerID] = [p].[BusinessEntityID]
INNER JOIN [Sales].[Store] store
ON [c].[StoreID] = [c].[StoreID]
WHERE [store].[Name] = 'Bike World'

--Show the CompanyName for all customers with an address in City 'Dallas'.

SELECT [store].[Name]
FROM [Sales].[Store] store 
INNER JOIN [Sales].[Customer] c
ON [c].[StoreID] = [c].[StoreID]
INNER JOIN [Sales].[SalesOrderHeader] Soh
ON [c].[CustomerID] = [Soh].[CustomerID]
INNER JOIN  [Person].[Address] [address]
ON [address].[AddressID] = [Soh].[BillToAddressID]
WHERE [address].[City] = 'Dallas'

--How many items with ListPrice more than $1000 have been sold?

--SELECT COUNT(*) NumberOfOrders 
--FROM (
--	SELECT [product].ProductID, SUM([product].[ListPrice]) AS PriceForTotalSold
--	FROM [Production].[Product] product
--	INNER JOIN [Purchasing].[PurchaseOrderDetail] pod
--	ON [product].[ProductID] = [pod].ProductID
	
--	GROUP BY [product].ProductID
--	Having SUM([product].[ListPrice]) > 1000
--)FilteredOrders

SELECT  product.ListPrice, product.ProductID
FROM [Production].[Product] product
INNER JOIN [Purchasing].[PurchaseOrderDetail] pod
ON [product].[ProductID] = [pod].ProductID
ORDER BY ListPrice


SELECT COUNT(*)
FROM Production.Product
WHERE ListPrice > 1000