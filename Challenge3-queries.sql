USE AdventureWorks2019;
/* Show the first name and the email address of customer with CompanyName 'Bike World' */
--, [store].[Name]

SELECT p.FirstName, mail.EmailAddress
FROM Person.Person p
INNER JOIN Person.EmailAddress mail
ON p.BusinessEntityID = mail.BusinessEntityID
INNER JOIN Sales.Customer c
ON c.PersonID = p.BusinessEntityID
INNER JOIN Sales.Store store
ON  c.StoreID = store.BusinessEntityID
WHERE store.[Name] = 'Bike World';

--Show the CompanyName for all customers with an address in City 'Dallas'.
SELECT DISTINCT store.[Name]
FROM Sales.Store store
INNER JOIN Sales.Customer c
ON c.StoreID = store.BusinessEntityID
INNER JOIN Sales.SalesOrderHeader soh
on soh.CustomerID = c.CustomerID
INNER JOIN Person.[Address] [address]
ON [address].AddressID = soh.BillToAddressID
WHERE [address].City = 'Dallas';


--How many items with ListPrice more than $1000 have been sold?
SELECT COUNT(DISTINCT product.ProductID)
FROM Production.Product product
JOIN Sales.SalesOrderDetail sod
ON product.ProductID = sod.ProductID
WHERE product.ListPrice > 1000;


--Give the CompanyName of those customers with orders over $100000. Include the subtotal plus tax plus freight.

SELECT store.[Name] as CompanyName
FROM Sales.SalesOrderHeader salesHeader
INNER JOIN Sales.Customer c
ON c.CustomerID = salesHeader.CustomerID
INNER JOIN Sales.Store store
ON store.BusinessEntityID = c.StoreID
WHERE salesHeader.TotalDue > 100000
GROUP BY  store.Name;



--Find the number of left racing socks ('Racing Socks, L') ordered by CompanyName 'Riding Cycles'
SELECT SUM(sod.OrderQty)
FROM Production.Product pr
INNER JOIN Sales.SalesOrderDetail sod
ON pr.ProductID = sod.ProductID
INNER JOIN Sales.SalesOrderHeader soh
ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Sales.Customer c
ON soh.CustomerID = c.CustomerID
INNER JOIN Sales.Store store
ON c.StoreID = store.BusinessEntityID
WHERE pr.[Name] = 'Racing Socks, L' and store.[Name] = 'Riding Cycles';


--A "Single Item Order" is a customer order where only one item is ordered. Show the SalesOrderID and the UnitPrice for every Single Item Order.

SELECT Sales.SalesOrderDetail.SalesOrderID, Sales.SalesOrderDetail.UnitPrice
FROM Sales.SalesOrderDetail
INNER JOIN Sales.SalesOrderHeader
ON Sales.SalesOrderDetail.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID
WHERE Sales.SalesOrderDetail.LineTotal = Sales.SalesOrderHeader.SubTotal;
--HAVING COUNT(Sales.SalesOrderDetail.SalesOrderID) = 1;

--Where did the racing socks go? List the product name and the CompanyName for all Customers who ordered ProductModel 'Racing Socks'.
SELECT Production.Product.[Name] ,Sales.Store.[Name]
FROM Production.ProductModel
INNER JOIN Production.Product
ON ProductModel.ProductModelID = Product.ProductModelID
INNER JOIN Sales.SalesOrderDetail
ON SalesOrderDetail.ProductID = Product.ProductID
INNER JOIN Sales.SalesOrderHeader
ON SalesOrderHeader.SalesOrderID = SalesOrderDetail.SalesOrderID
INNER JOIN Sales.Customer
ON SalesOrderHeader.CustomerID = Customer.CustomerID
INNER JOIN Sales.Store
ON Customer.StoreID = Store.BusinessEntityID
WHERE ProductModel.[Name] = 'Racing Socks'
GROUP BY Product.[Name], Store.[Name];


--Show the product description for culture 'fr' for product with ProductID 736.
SELECT Production.ProductDescription.[Description]
FROM Production.ProductModelProductDescriptionCulture
INNER JOIN Production.ProductDescription
ON ProductDescription.ProductDescriptionID = ProductModelProductDescriptionCulture.ProductDescriptionID
INNER JOIN Production.Product
ON Product.ProductModelID = ProductModelProductDescriptionCulture.ProductModelID

WHERE ProductModelProductDescriptionCulture.CultureID = 'fr'  AND Product.ProductID = 736;

--Use the SubTotal value in SaleOrderHeader to list orders from the largest to the smallest. For each order show the CompanyName and the SubTotal and the total weight of the order.

SELECT Sales.SalesOrderHeader.SubTotal, Store.[Name], CONCAT(SUM(Product.[Weight]*SalesOrderDetail.OrderQty),' ', Product.WeightUnitMeasureCode) AS TotalWeight
FROM Sales.SalesOrderHeader
INNER JOIN Sales.Customer
ON SalesOrderHeader.CustomerID = Customer.CustomerID
INNER JOIN Sales.Store
ON Store.BusinessEntityID = Customer.StoreID
INNER JOIN Sales.SalesOrderDetail
ON SalesOrderDetail.SalesOrderID = SalesOrderHeader.SalesOrderID
INNER JOIN Production.Product
ON Product.ProductID = SalesOrderDetail.ProductID
GROUP BY SalesOrderHeader.SalesOrderID, SalesOrderHeader.SubTotal, Store.[Name], Product.WeightUnitMeasureCode
ORDER BY SalesOrderHeader.SubTotal DESC;


--How many products in ProductCategory 'Cranksets' have been sold to an address in 'London'?
SELECT COUNT(*)

FROM Production.Product
INNER JOIN  Sales.SalesOrderDetail
ON SalesOrderDetail.ProductID = Product.ProductID
INNER JOIN Sales.SalesOrderHeader
ON SalesOrderDetail.SalesOrderID = SalesOrderHeader.SalesOrderID
INNER JOIN Production.ProductSubcategory
ON Product.ProductSubcategoryID = ProductSubcategory.ProductSubcategoryID
INNER JOIN Production.ProductCategory
ON  ProductSubcategory.ProductCategoryID = ProductCategory.ProductCategoryID
INNER JOIN Person.[Address]
ON SalesOrderHeader.ShipToAddressID = [Address].AddressID
WHERE ProductSubcategory.[Name] = 'Cranksets' ANd [Address].City = 'London';

--For every customer witha 'Main Office' in Dallas show AddressLine1 of the 'Main Office' and AddressLine1 of the 'Shipping' address - if there is no shipping address leave it blank. Use one row per customer.
WITH mainOffice AS 
		(SELECT SalesOrderHeader.SalesOrderID , [Address].AddressLine1
		FROM Sales.SalesOrderHeader
		INNER JOIN Person.[Address]
		ON [Address].AddressID = SalesOrderHeader.BillToAddressID
		INNER JOIN Person.BusinessEntityAddress
		ON [Address].AddressID = BusinessEntityAddress.AddressID
		INNER JOIN Person.AddressType 
		ON AddressType.AddressTypeID = BusinessEntityAddress.AddressTypeID
		WHERE[Address].City = 'Dallas' AND  AddressType.[Name] = 'Main Office')

SELECT  MainOffice.AddressLine1 AS[Main Office Address Line 1], [Address].AddressLine1 AS [ShippingAddress's Address Line 1]
FROM mainOffice
INNER JOIN Sales.SalesOrderHeader
ON mainOffice.SalesOrderID = SalesOrderHeader.SalesOrderID
INNER JOIN Person.[Address]
ON [Address].AddressID = SalesOrderHeader.ShipToAddressID
INNER JOIN Sales.Customer
ON SalesOrderHeader.CustomerID = Customer.CustomerID
GROUP BY Customer.CustomerID, [Address].AddressLine1, MainOffice.AddressLine1;

--For each order show the SalesOrderID and SubTotal calculated From the SalesOrderHeader
SELECT SalesOrderHeader.SalesOrderID, SalesOrderHeader.SubTotal AS SubTotal
FROM Sales.SalesOrderHeader;


--For each order show the SalesOrderID and SubTotal calculated From Sum of OrderQty*UnitPrice
SELECT SalesOrderDetail.SalesOrderID ,SUM(SalesOrderDetail.OrderQty * SalesOrderDetail.UnitPrice) AS SubTotal
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderDetail.SalesOrderID;



--For each order show the SalesOrderID and SubTotal calculated From Sum of OrderQty*ListPrice

SELECT SalesOrderDetail.SalesOrderID, SUM(SalesOrderDetail.OrderQty * Product.ListPrice *(1 -SalesOrderDetail.UnitPriceDiscount)) AS SubTotal
FROM Sales.SalesOrderDetail
INNER JOIN Production.Product
ON SalesOrderDetail.ProductID = Product.ProductID
GROUP BY SalesOrderDetail.SalesOrderID;


--SELECT SpecialOffer.
--FROM Sales.SpecialOffer

----WHERE SalesOrderDetail.SalesOrderID = 43663

--Show the best selling item by value
SELECT TOP(1) Product.[Name] AS [Product Name], CONCAT(SUM(SalesOrderDetail.LineTotal), '$') AS [Total Orders]
FROM Sales.SalesOrderDetail
INNER JOIN Production.Product
ON SalesOrderDetail.ProductID = Product.ProductID
GROUP BY Product.[Name]
ORDER BY SUM(SalesOrderDetail.LineTotal) DESC;


--Show how many orders are in the following ranges (in $): (0-99)(100-999)(1000-9999)(1000-)
--WITH FilteredRanges AS (
--					SELECT CASE
--								WHEN SalesOrderHeader.TotalDue BETWEEN 0 AND 99 then SUM(SalesOrderHeader.TotalDue) END
								
--					FROM Sales.SalesOrderHeader
					
--					)



--Identify the three most important cities. Show the break down of top level product category against city.
	WITH BestCategoryPerCity AS (
									SELECT [Address].City, ProductCategory.[Name] AS CategoryName,COUNT(ProductCategory.[Name]) AS ProductCategoryCount
									FROM Production.ProductCategory
									INNER JOIN Production.ProductSubcategory
									ON ProductCategory.ProductCategoryID = ProductSubcategory.ProductSubcategoryID
									INNER JOIN Production.Product
									ON Product.ProductSubcategoryID = ProductSubcategory.ProductSubcategoryID
									INNER JOIN Sales.SalesOrderDetail
									ON SalesOrderDetail.ProductID = Product.ProductID
									INNER JOIN Sales.SalesOrderHeader
									ON SalesOrderDetail.SalesOrderID = SalesOrderHeader.SalesOrderID
									INNER JOIN Person.[Address]
									ON [Address].AddressID = SalesOrderHeader.ShipToAddressID
									GROUP BY [Address].City, ProductCategory.[Name]
								
								)


	SELECT TOP(3)  [Address].City, CONCAT(SUM(SalesOrderHeader.TotalDue),'$'), BestCategoryPerCity.ProductCategoryCount
	FROM Sales.SalesOrderHeader
	INNER JOIN Person.[Address]
	ON [Address].AddressID = SalesOrderHeader.ShipToAddressID
	INNER JOIN BestCategoryPerCity
	ON BestCategoryPerCity.City = [Address].City
	GROUP BY [Address].City, BestCategoryPerCity.ProductCategoryCount
	ORDER BY SUM(SalesOrderHeader.TotalDue) DESC, BestCategoryPerCity.ProductCategoryCount DESC





SELECT TOP(3) WITH TIES  [Address].City, CONCAT(SUM(SalesOrderHeader.TotalDue),'$')
FROM Sales.SalesOrderHeader
INNER JOIN Person.[Address]
ON [Address].AddressID = SalesOrderHeader.ShipToAddressID

GROUP BY [Address].City
ORDER BY SUM(SalesOrderHeader.TotalDue) DESC

--List the SalesOrderNumber for the customer 'Good Toys' 'Bike World'
SELECT SalesOrderHeader.SalesOrderID, Store.[Name]
FROM Sales.SalesOrderHeader
INNER JOIN Sales.Customer
ON Customer.CustomerID = SalesOrderHeader.CustomerID
INNER JOIN Sales.Store
ON Store.BusinessEntityID = Customer.StoreID
WHERE Store.[Name] = 'Good Toys' OR Store.[Name] = 'Bike World'

--List the ProductName and the quantity of what was ordered by 'Futuristic Bikes'
SELECT Product.[Name], SUM(SalesOrderDetail.OrderQty) AS [Order quantity]
FROM Sales.Store
INNER JOIN Sales.Customer
ON Store.BusinessEntityID = Customer.StoreID
INNER JOIN Sales.SalesOrderHeader
ON SalesOrderHeader.CustomerID = Customer.CustomerID
INNER JOIN Sales.SalesOrderDetail
ON SalesOrderDetail.SalesOrderID = SalesOrderHeader.SalesOrderID
INNER JOIN Production.Product
ON Product.ProductID = SalesOrderDetail.ProductID
WHERE Store.[Name] =  'Futuristic Bikes'
GROUP BY Product.[Name]

--Show the total order value for each CountryRegion. List by value with the highest first.
SELECT CountryRegion.[Name], COUNT(SalesOrderHeader.SalesOrderID) as [Total Orders]
FROM Sales.SalesOrderHeader
INNER JOIN Person.[Address] 
ON SalesOrderHeader.ShipToAddressID = [Address].AddressID
INNER JOIN Person.StateProvince
ON StateProvince.StateProvinceID = [Address].StateProvinceID
INNER JOIN Person.CountryRegion
ON CountryRegion.CountryRegionCode = StateProvince.CountryRegionCode
GROUP BY CountryRegion.[Name]

--Find the best customer in each region.
SELECT CountryRegion.[Name],Customer.CustomerID, SUM(SalesOrderHeader.TotalDue)AS [Total Ordered Value]
FROM  Sales.SalesOrderHeader
INNER JOIN Sales.Customer
ON Customer.CustomerID = SalesOrderHeader.CustomerID
INNER JOIN Person.[Address]
ON [Address].AddressID = SalesOrderHeader.BillToAddressID
INNER JOIN Person.StateProvince
ON StateProvince.StateProvinceID = [Address].StateProvinceID
INNER JOIN Person.CountryRegion
ON StateProvince.CountryRegionCode = CountryRegion.CountryRegionCode
GROUP BY CountryRegion.[Name], Customer.CustomerID
ORDER BY [Total Ordered Value] DESC
