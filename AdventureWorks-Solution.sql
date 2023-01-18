USE AdventureWorks2019;
-- Q1 : Show the first name and the email address of customer with CompanyName 'Bike World' 

SELECT Person.FirstName, EmailAddress.EmailAddress
FROM Person.Person 
INNER JOIN Person.EmailAddress
ON Person.BusinessEntityID = EmailAddress.BusinessEntityID
INNER JOIN Sales.Customer
ON Customer.PersonID = Person.BusinessEntityID
INNER JOIN Sales.Store store
ON  Customer.StoreID = store.BusinessEntityID
WHERE store.[Name] = 'Bike World';

-- Q2  : Show the CompanyName for all customers with an address in City 'Dallas'.
SELECT DISTINCT store.[Name]
FROM Sales.Store
INNER JOIN Sales.Customer
ON Customer.StoreID = Store.BusinessEntityID
INNER JOIN Sales.SalesOrderHeader
on SalesOrderHeader.CustomerID = Customer.CustomerID
INNER JOIN Person.[Address] [address]
ON [address].AddressID = SalesOrderHeader.BillToAddressID
WHERE [address].City = 'Dallas';


--Q3 : How many items with ListPrice more than $1000 have been sold?
SELECT COUNT(DISTINCT product.ProductID)
FROM Production.Product product
JOIN Sales.SalesOrderDetail
ON product.ProductID = SalesOrderDetail.ProductID
WHERE product.ListPrice > 1000;
-- second interpretation of the question
SELECT SUM(SalesOrderDetail.OrderQty)
FROM Production.Product
INNER JOIN Sales.SalesOrderDetail
ON Product.ProductID = SalesOrderDetail.ProductID
WHERE Product.ListPrice > 1000



--Q4 : Give the CompanyName of those customers with orders over $100000. Include the subtotal plus tax plus freight.

SELECT store.[Name] as CompanyName
FROM Sales.SalesOrderHeader 
INNER JOIN Sales.Customer
ON Customer.CustomerID = SalesOrderHeader.CustomerID
INNER JOIN Sales.Store store
ON store.BusinessEntityID = Customer.StoreID
WHERE SalesOrderHeader.TotalDue > 100000
GROUP BY  store.Name;



-- Q5 : Find the number of left racing socks ('Racing Socks, L') ordered by CompanyName 'Riding Cycles'
SELECT SUM(SalesOrderDetail.OrderQty)
FROM Production.Product
INNER JOIN Sales.SalesOrderDetail
ON Product.ProductID = SalesOrderDetail.ProductID
INNER JOIN Sales.SalesOrderHeader
ON SalesOrderHeader.SalesOrderID = SalesOrderDetail.SalesOrderID
INNER JOIN Sales.Customer
ON SalesOrderHeader.CustomerID = Customer.CustomerID
INNER JOIN Sales.Store store
ON Customer.StoreID = store.BusinessEntityID
WHERE Product.[Name] = 'Racing Socks, L' and store.[Name] = 'Riding Cycles';


-- Q6 :A "Single Item Order" is a customer order where only one item is ordered. Show the SalesOrderID and the UnitPrice for every Single Item Order.

SELECT Sales.SalesOrderDetail.SalesOrderID, CONCAT(Sales.SalesOrderDetail.UnitPrice,'$')
FROM Sales.SalesOrderDetail
INNER JOIN Sales.SalesOrderHeader
ON Sales.SalesOrderDetail.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID
WHERE Sales.SalesOrderDetail.LineTotal = Sales.SalesOrderHeader.SubTotal;
/*the reason the above line is that salesOrderHeader.Subtotal = SUM(salesOrderDetail.LineTotal)
	 and the LineTotal = UnitPrice * (1 - UnitPerDiscount)* OrderQty*/

-- Q7 : Where did the racing socks go? List the product name and the CompanyName for all Customers who ordered ProductModel 'Racing Socks'.
SELECT Production.Product.[Name] AS [Product Name] ,Sales.Store.[Name] AS [Company Name]
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


-- Q8 : Show the product description for culture 'fr' for product with ProductID 736.
SELECT Production.ProductDescription.[Description]
FROM Production.ProductModelProductDescriptionCulture
INNER JOIN Production.ProductDescription
ON ProductDescription.ProductDescriptionID = ProductModelProductDescriptionCulture.ProductDescriptionID
INNER JOIN Production.Product
ON Product.ProductModelID = ProductModelProductDescriptionCulture.ProductModelID

WHERE ProductModelProductDescriptionCulture.CultureID = 'fr'  AND Product.ProductID = 736;

-- Q9 :Use the SubTotal value in SaleOrderHeader to list orders from the largest to the smallest. For each order show the CompanyName and the SubTotal and the total weight of the order.


SELECT Sales.SalesOrderHeader.SubTotal, Store.[Name], SUM(Product.[Weight]*SalesOrderDetail.OrderQty) AS TotalWeight
FROM Sales.SalesOrderHeader
INNER JOIN Sales.Customer
ON SalesOrderHeader.CustomerID = Customer.CustomerID
INNER JOIN Sales.Store
ON Store.BusinessEntityID = Customer.StoreID
INNER JOIN Sales.SalesOrderDetail
ON SalesOrderDetail.SalesOrderID = SalesOrderHeader.SalesOrderID
INNER JOIN Production.Product
ON Product.ProductID = SalesOrderDetail.ProductID
GROUP BY SalesOrderDetail.SalesOrderID, SalesOrderHeader.SubTotal, Store.[Name]
ORDER BY SalesOrderHeader.SubTotal DESC;


-- Q10 : How many products in ProductCategory 'Cranksets' have been sold to an address in 'London'?
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

-- Q11 : For every customer witha 'Main Office' in Dallas show AddressLine1 of the 'Main Office' and AddressLine1 of the 'Shipping' address - if there is no shipping address leave it blank. Use one row per customer.
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

-- Q12 : For each order show the SalesOrderID and SubTotal calculated From the SalesOrderHeader
SELECT SalesOrderHeader.SalesOrderID, SalesOrderHeader.SubTotal AS SubTotal
FROM Sales.SalesOrderHeader;


-- Q13 : For each order show the SalesOrderID and SubTotal calculated From Sum of OrderQty*UnitPrice
SELECT SalesOrderDetail.SalesOrderID ,SUM(SalesOrderDetail.OrderQty * SalesOrderDetail.UnitPrice) AS SubTotal
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderDetail.SalesOrderID;



-- Q14 : For each order show the SalesOrderID and SubTotal calculated From Sum of OrderQty*ListPrice

SELECT SalesOrderDetail.SalesOrderID, SUM(SalesOrderDetail.OrderQty * Product.ListPrice *(1 -SalesOrderDetail.UnitPriceDiscount)) AS SubTotal
FROM Sales.SalesOrderDetail
INNER JOIN Production.Product
ON SalesOrderDetail.ProductID = Product.ProductID
GROUP BY SalesOrderDetail.SalesOrderID;


-- Q15 : Show the best selling item by value
SELECT TOP(1) Product.[Name] AS [Product Name], CONCAT(SUM(SalesOrderDetail.LineTotal), '$') AS [Total Orders]
FROM Sales.SalesOrderDetail
INNER JOIN Production.Product
ON SalesOrderDetail.ProductID = Product.ProductID
GROUP BY Product.[Name]
ORDER BY SUM(SalesOrderDetail.LineTotal) DESC;


-- Q16: Show how many orders are in the following ranges (in $): (0-99)(100-999)(1000-9999)(1000-)

WITH SingleOrdersInRange AS
			(SELECT	CASE 
						WHEN SalesOrderHeader.SubTotal BETWEEN 0 AND 99.9999 THEN '0 - 99' 
						WHEN SalesOrderHeader.SubTotal BETWEEN 100 AND 999.9999 THEN '100 - 999' 
						WHEN SalesOrderHeader.SubTotal BETWEEN 1000 AND 9999.9999 THEN '1000 - 9999' 
						WHEN SalesOrderHeader.SubTotal >= 10000  THEN '10000 - ' 
					END AS [RANGE],			  
					CASE 					  
						WHEN SalesOrderHeader.SubTotal BETWEEN 0 AND 99.9999 THEN 1
						WHEN SalesOrderHeader.SubTotal BETWEEN 100 AND 999.9999 THEN 2
						WHEN SalesOrderHeader.SubTotal BETWEEN 1000 AND 9999.9999 THEN 3
						WHEN SalesOrderHeader.SubTotal >= 10000  THEN 4
					END AS [RANK],
			SalesOrderHeader.SubTotal
			FROM Sales.SalesOrderHeader)
SELECT [RANGE], COUNT(*) AS [Num Orders], SUM(SingleOrdersInRange.SubTotal) AS [Total Value]
FROM SingleOrdersInRange
GROUP BY [RANGE], [RANK]
ORDER BY [RANK] ASC;
	

-- Q17: Identify the three most important cities. Show the break down of top level product category against city.
WITH CategoryOrderedPerCity AS 
		(SELECT [Address].City, ProductCategory.[Name] AS CategoryName,
					COUNT(ProductCategory.[Name]) AS ProductCategoryCount, 
					RANK() OVER (PARTITION BY [Address].City ORDER BY COUNT(ProductCategory.[Name]) DESC) AS  [RANK]
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
			GROUP BY [Address].City, ProductCategory.[Name])

SELECT TOP(3)  [Address].City, CONCAT(SUM(SalesOrderHeader.TotalDue),'$') AS [Total Value Of Orders], CategoryOrderedPerCity.CategoryName
FROM Sales.SalesOrderHeader
INNER JOIN Person.[Address]
ON [Address].AddressID = SalesOrderHeader.ShipToAddressID
INNER JOIN CategoryOrderedPerCity
ON CategoryOrderedPerCity.City = [Address].City
WHERE CategoryOrderedPerCity.[RANK] = 1
GROUP BY [Address].City, CategoryOrderedPerCity.ProductCategoryCount, CategoryOrderedPerCity.CategoryName
ORDER BY SUM(SalesOrderHeader.TotalDue) DESC, CategoryOrderedPerCity.ProductCategoryCount DESC;




-- Q18 : List the SalesOrderNumber for the customer 'Good Toys' 'Bike World'
SELECT SalesOrderHeader.SalesOrderID, Store.[Name]
FROM Sales.SalesOrderHeader
INNER JOIN Sales.Customer
ON Customer.CustomerID = SalesOrderHeader.CustomerID
INNER JOIN Sales.Store
ON Store.BusinessEntityID = Customer.StoreID
WHERE Store.[Name] = 'Good Toys' OR Store.[Name] = 'Bike World';

-- Q19 : List the ProductName and the quantity of what was ordered by 'Futuristic Bikes'
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
GROUP BY Product.[Name];

-- Q20 : List the name and addresses of companies containing the word 'Bike' (upper or lower case) and companies containing 'cycle' (upper or lower case). Ensure that the 'bike's are listed before the 'cycles's.

WITH BikesAndCyclesAddresses AS
			(SELECT Store.[Name],
			AddressLine1,
			AddressLine2,
			City,
			StateProvinceName,
			PostalCode, 
			CountryRegionName, 
			CASE 
				WHEN LOWER(Store.Name) LIKE '%bike%' THEN  1
				WHEN LOWER(Store.Name) LIKE '%cycle%' THEN 2
			END AS [Rank]
			FROM Sales.Store
			INNER JOIN Sales.vStoreWithAddresses
			ON Store.[Name] = vStoreWithAddresses.[Name]
			WHERE LOWER(Store.[Name]) LIKE  '%bike%' OR LOWER(Store.[Name]) LIKE '%cycle%')
SELECT [Name] AS [Company Name], AddressLine1, AddressLine2, City, StateProvinceName, PostalCode, CountryRegionName
FROM BikesAndCyclesAddresses
ORDER BY [Rank];


-- Q21: Show the total order value for each CountryRegion. List by value with the highest first.
SELECT CountryRegion.[Name], CONCAT(SUM(SalesOrderHeader.TotalDue),'$') as [Total Orders]
FROM Sales.SalesOrderHeader
INNER JOIN Person.[Address] 
ON SalesOrderHeader.ShipToAddressID = [Address].AddressID
INNER JOIN Person.StateProvince
ON StateProvince.StateProvinceID = [Address].StateProvinceID
INNER JOIN Person.CountryRegion
ON CountryRegion.CountryRegionCode = StateProvince.CountryRegionCode
GROUP BY CountryRegion.[Name];

--Q22 : Find the best customer in each region.


WITH RegionOrderedCustomers AS 
		(SELECT	CountryRegion.[Name],
				Customer.CustomerID, 
				CONCAT(SUM(SalesOrderHeader.TotalDue),'$') AS [Total Ordered Value], 
				RANK() OVER (PARTITION BY CountryRegion.[Name] ORDER BY  SUM(SalesOrderHeader.TotalDue) DESC) AS [RANK]
		FROM  Sales.SalesOrderHeader
		INNER JOIN Sales.Customer
		ON Customer.CustomerID = SalesOrderHeader.CustomerID
		INNER JOIN Person.[Address]
		ON [Address].AddressID = SalesOrderHeader.BillToAddressID
		INNER JOIN Person.StateProvince
		ON StateProvince.StateProvinceID = [Address].StateProvinceID
		INNER JOIN Person.CountryRegion
		ON StateProvince.CountryRegionCode = CountryRegion.CountryRegionCode
		GROUP BY CountryRegion.[Name], Customer.CustomerID)

SELECT RegionOrderedCustomers.[Name], RegionOrderedCustomers.CustomerID, RegionOrderedCustomers.[Total Ordered Value]
FROM RegionOrderedCustomers
WHERE RegionOrderedCustomers.[RANK] = 1
ORDER BY RegionOrderedCustomers.[Total Ordered Value] DESC;




-- Q9 other solutions
--CONCAT(SUM(Product.[Weight]*SalesOrderDetail.OrderQty),' ', Product.WeightUnitMeasureCode) AS TotalWeight
--SELECT CONCAT(Sales.SalesOrderHeader.SubTotal,'$'), Store.[Name], 
--	CASE 
--		WHEN Product.WeightUnitMeasureCode = 'G' THEN SUM(Product.[Weight] * SalesOrderDetail.OrderQty)*0.00220462
--		WHEN Product.WeightUnitMeasureCode ='LB' THEN SUM(Product.[Weight] * SalesOrderDetail.OrderQty) END As TotalWeight
--FROM Sales.SalesOrderHeader
--INNER JOIN Sales.Customer
--ON SalesOrderHeader.CustomerID = Customer.CustomerID
--INNER JOIN Sales.Store
--ON Store.BusinessEntityID = Customer.StoreID
--INNER JOIN Sales.SalesOrderDetail
--ON SalesOrderDetail.SalesOrderID = SalesOrderHeader.SalesOrderID
--INNER JOIN Production.Product
--ON Product.ProductID = SalesOrderDetail.ProductID
--GROUP BY SalesOrderDetail.SalesOrderID, SalesOrderHeader.SubTotal, Store.[Name], Product.WeightUnitMeasureCode
--ORDER BY SalesOrderHeader.SubTotal DESC

--	SELECT Sales.SalesOrderHeader.SubTotal, Store.[Name], CONCAT(SUM(Product.[Weight] * SalesOrderDetail.OrderQty),' ',Product.WeightUnitMeasureCode)
--	FROM Sales.SalesOrderHeader
--	INNER JOIN Sales.Customer
--	ON SalesOrderHeader.CustomerID = Customer.CustomerID
--	INNER JOIN Sales.Store
--	ON Store.BusinessEntityID = Customer.StoreID
--	INNER JOIN Sales.SalesOrderDetail
--	ON SalesOrderDetail.SalesOrderID = SalesOrderHeader.SalesOrderID
--	INNER JOIN Production.Product
--	ON Product.ProductID = SalesOrderDetail.ProductID
--	WHERE Product.[Weight] IS NOT NULL
--	GROUP BY SalesOrderDetail.SalesOrderID, SalesOrderHeader.SubTotal, Store.[Name], Product.WeightUnitMeasureCode
--	ORDER BY SalesOrderHeader.SubTotal DESC