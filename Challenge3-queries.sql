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
WHERE store.[Name] = 'Bike World'

--Show the CompanyName for all customers with an address in City 'Dallas'.
SELECT DISTINCT store.[Name]
FROM Sales.Store store
INNER JOIN Sales.Customer c
ON c.StoreID = store.BusinessEntityID
INNER JOIN Sales.SalesOrderHeader soh
on soh.CustomerID = c.CustomerID
INNER JOIN Person.[Address] [address]
ON [address].AddressID = soh.BillToAddressID
WHERE [address].City = 'Dallas'


--How many items with ListPrice more than $1000 have been sold?
SELECT COUNT(DISTINCT product.ProductID)
FROM Production.Product product
JOIN Sales.SalesOrderDetail sod
ON product.ProductID = sod.ProductID
WHERE product.ListPrice > 1000


--Give the CompanyName of those customers with orders over $100000. Include the subtotal plus tax plus freight.

SELECT store.[Name] as CompanyName
FROM Sales.SalesOrderHeader salesHeader
INNER JOIN Sales.Customer c
ON c.CustomerID = salesHeader.CustomerID
INNER JOIN Sales.Store store
ON store.BusinessEntityID = c.StoreID
WHERE salesHeader.TotalDue > 100000
GROUP BY  store.Name



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
WHERE pr.[Name] = 'Racing Socks, L' and store.[Name] = 'Riding Cycles'


--A "Single Item Order" is a customer order where only one item is ordered. Show the SalesOrderID and the UnitPrice for every Single Item Order.

SELECT Sales.SalesOrderDetail.SalesOrderID, Sales.SalesOrderDetail.UnitPrice
FROM Sales.SalesOrderDetail
INNER JOIN Sales.SalesOrderHeader
ON Sales.SalesOrderDetail.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID
WHERE Sales.SalesOrderDetail.LineTotal = Sales.SalesOrderHeader.SubTotal;

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
GROUP BY Product.[Name], Store.[Name]


--Show the product description for culture 'fr' for product with ProductID 736.
SELECT Production.ProductDescription.[Description]
FROM Production.ProductModelProductDescriptionCulture
INNER JOIN Production.ProductDescription
ON ProductDescription.ProductDescriptionID = ProductModelProductDescriptionCulture.ProductDescriptionID
INNER JOIN Production.Product
ON Product.ProductModelID = ProductModelProductDescriptionCulture.ProductModelID

WHERE ProductModelProductDescriptionCulture.CultureID = 'fr'  AND Product.ProductID = 736

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
ORDER BY SalesOrderHeader.SubTotal DESC


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
WHERE ProductSubcategory.[Name] = 'Cranksets' ANd [Address].City = 'London'