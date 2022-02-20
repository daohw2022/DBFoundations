--*************************************************************************--
-- Title: Assignment06
-- Author: Sam Dao
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2022-02-17,Sam Dao,Created File
-- Create Basic and customized Views from tables, and retrieve data using View.
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_SamDao')
	 Begin 
	  Alter Database [Assignment06DB_SamDao] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_SamDao;
	 End
	Create Database Assignment06DB_SamDao;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_SamDao;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'
GO
-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
--345678901234567890123456789012345678901234567890123456789012345678901234567890

--SELECT * FROM Categories;
--GO
CREATE VIEW vCategories
WITH SCHEMABINDING
AS
SELECT CategoryID, CategoryName FROM dbo.Categories;
GO

--SELECT * FROM Products;
--GO
CREATE VIEW vProducts
WITH SCHEMABINDING
AS
SELECT ProductID, ProductName, CategoryID, UnitPrice FROM dbo.Products;
GO

--SELECT * FROM Employees;
--GO
CREATE VIEW vEmployees
WITH SCHEMABINDING
AS
SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID FROM dbo.Employees;
GO

--SELECT * FROM Inventories;
--GO
CREATE VIEW vInventories
WITH SCHEMABINDING
AS
SELECT InventoryID, InventoryDate, EmployeeID, ProductID, Count FROM dbo.Inventories;
GO

SELECT * FROM dbo.vCategories;
SELECT * FROM dbo.vProducts;
SELECT * FROM dbo.vEmployees;
SELECT * FROM dbo.vInventories;
GO


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

DENY SELECT ON dbo.Categories TO PUBLIC;
DENY SELECT ON dbo.Products TO PUBLIC;
DENY SELECT ON dbo.Employees TO PUBLIC;
DENY SELECT ON dbo.Inventories TO PUBLIC;

GRANT SELECT ON dbo.vCategories TO PUBLIC;
GRANT SELECT ON dbo.vProducts TO PUBLIC;
GRANT SELECT ON dbo.vEmployees TO PUBLIC;
GRANT SELECT ON dbo.vInventories TO PUBLIC;
GO


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

CREATE VIEW vProductsByCategories
AS
SELECT TOP 10000 CategoryName, ProductName, UnitPrice
FROM dbo.vCategories as c 
	INNER JOIN dbo.vProducts as p
	ON c.CategoryID = p.CategoryID
ORDER BY CategoryName, ProductName;
GO

SELECT * FROM dbo.vProductsByCategories;
GO

-- Here is an example of some rows selected from the view:
-- CategoryName ProductName       UnitPrice
-- Beverages    Chai              18.00
-- Beverages    Chang             19.00
-- Beverages    Chartreuse verte  18.00


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

--SELECT ProductID, InventoryDate, Count FROM Inventories
--GROUP BY ProductID, InventoryDate, Count;
--GO

CREATE VIEW vInventoriesByProductsByDates
AS
SELECT TOP 10000 ProductName, InventoryDate, Count 
FROM dbo.vProducts AS p
	INNER JOIN dbo.vInventories as i 
	ON p.ProductID = i.ProductID
GROUP BY ProductName, InventoryDate, Count
ORDER BY ProductName, InventoryDate, count;
GO

SELECT * FROM dbo.vInventoriesByProductsByDates;
GO

-- Here is an example of some rows selected from the view:
-- ProductName	  InventoryDate	Count
-- Alice Mutton	  2017-01-01	  0
-- Alice Mutton	  2017-02-01	  10
-- Alice Mutton	  2017-03-01	  20
-- Aniseed Syrup	2017-01-01	  13
-- Aniseed Syrup	2017-02-01	  23
-- Aniseed Syrup	2017-03-01	  33


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

--SELECT * FROM Employees;
--SELECT InventoryDate, Count, EmployeeID FROM Inventories;
--GO

/****** SELECT DISTINCT can be used instead of GROUP BY clause ******/
CREATE VIEW vInventoriesByEmployeesByDates
AS
SELECT TOP 10000 InventoryDate, Employee = EmployeeFirstName + ' ' + EmployeeLastName
FROM dbo.vInventories AS i 
	INNER JOIN dbo.vEmployees AS e 
	ON i.EmployeeID = e.EmployeeID
GROUP BY InventoryDate, EmployeeFirstName, EmployeeLastName
ORDER BY InventoryDate;
GO

SELECT * FROM dbo.vInventoriesByEmployeesByDates;
GO

-- Here is are the rows selected from the view:
-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

--SELECT CategoryID, ProductName, InventoryDate, Count
--FROM dbo.Products INNER JOIN dbo.Inventories 
--ON Products.ProductID = Inventories.ProductID;
--GO

CREATE VIEW vInventoriesByProductsByCategories
AS
SELECT TOP 10000 CategoryName, ProductName, InventoryDate, Count
FROM dbo.vInventories AS i 
	INNER JOIN dbo.vProducts AS p 
	ON i.ProductID = p.ProductID
	INNER JOIN dbo.vCategories AS c
	ON p.CategoryID = c.CategoryID
ORDER BY CategoryName, ProductName, InventoryDate, Count;
GO

SELECT * FROM dbo.vInventoriesByProductsByCategories;
GO

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- CategoryName	ProductName	InventoryDate	Count
-- Beverages	  Chai	      2017-01-01	  39
-- Beverages	  Chai	      2017-02-01	  49
-- Beverages	  Chai	      2017-03-01	  59
-- Beverages	  Chang	      2017-01-01	  17
-- Beverages	  Chang	      2017-02-01	  27
-- Beverages	  Chang	      2017-03-01	  37


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

--SELECT Products.ProductID, ProductName, InventoryDate, Count, EmployeeID
--FROM Products INNER JOIN Inventories ON Products.ProductID = Inventories.ProductID;
--GO

CREATE VIEW vInventoriesByProductsByEmployees
AS
SELECT TOP 10000 CategoryName, ProductName, InventoryDate,
Count, Employee = EmployeeFirstName + ' ' + EmployeeLastName
FROM dbo.vInventories AS i 
	INNER JOIN dbo.vProducts AS p 
	ON i.ProductID = p.ProductID
	INNER JOIN dbo.vEmployees AS e 
	ON i.EmployeeID = e.EmployeeID
	INNER JOIN dbo.vCategories AS c 
	ON p.CategoryID = c.CategoryID
ORDER BY InventoryDate, CategoryName, ProductName, Employee;
GO

SELECT * FROM dbo.vInventoriesByProductsByEmployees;
GO

-- Here is an example of some rows selected from the view:
-- CategoryName	ProductName	        InventoryDate	Count	EmployeeName
-- Beverages	  Chai	              2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	              2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chartreuse verte	  2017-01-01	  69	  Steven Buchanan
-- Beverages	  C�te de Blaye	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Guaran� Fant�stica	2017-01-01	  20	  Steven Buchanan
-- Beverages	  Ipoh Coffee	        2017-01-01	  17	  Steven Buchanan
-- Beverages	  Lakkalik��ri	      2017-01-01	  57	  Steven Buchanan


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

--SELECT CategoryID, Products.ProductID, ProductName, InventoryDate, Count, EmployeeID
--FROM Products INNER JOIN Inventories ON Products.ProductID = Inventories.ProductID;
--GO

CREATE VIEW vInventoriesForChaiAndChangByEmployees
AS
SELECT CategoryName, ProductName, InventoryDate, Count, 
Employee = EmployeeFirstName + ' ' + EmployeeLastName
FROM dbo.vInventories AS i 
	INNER JOIN dbo.vProducts AS p 
	ON i.ProductID = p.ProductID
	INNER JOIN dbo.vEmployees AS e 
	ON i.EmployeeID = e.EmployeeID
	INNER JOIN dbo.vCategories AS c 
	ON p.CategoryID = c.CategoryID
WHERE ProductName IN ('Chai','Chang');
GO

SELECT * FROM dbo.vInventoriesForChaiAndChangByEmployees;
GO

-- Here are the rows selected from the view:

-- CategoryName	ProductName	InventoryDate	Count	EmployeeName
-- Beverages	  Chai	      2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chai	      2017-02-01	  49	  Robert King
-- Beverages	  Chang	      2017-02-01	  27	  Robert King
-- Beverages	  Chai	      2017-03-01	  59	  Anne Dodsworth
-- Beverages	  Chang	      2017-03-01	  37	  Anne Dodsworth


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

--SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID FROM Employees;
--GO

CREATE VIEW vEmployeesByManager
AS
SELECT TOP 10000 Manager = m.EmployeeFirstName + ' ' + m.EmployeeLastName, 
Employee = e.EmployeeFirstName + ' ' + e.EmployeeLastName
FROM dbo.vEmployees AS e
	INNER JOIN dbo.vEmployees AS m
	ON e.ManagerID = m.EmployeeID
ORDER BY Manager, Employee;
GO

SELECT * FROM dbo.vEmployeesByManager;
GO

-- Here are teh rows selected from the view:
-- Manager	        Employee
-- Andrew Fuller	  Andrew Fuller
-- Andrew Fuller	  Janet Leverling
-- Andrew Fuller	  Laura Callahan
-- Andrew Fuller	  Margaret Peacock
-- Andrew Fuller	  Nancy Davolio
-- Andrew Fuller	  Steven Buchanan
-- Steven Buchanan	Anne Dodsworth
-- Steven Buchanan	Michael Suyama
-- Steven Buchanan	Robert King


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.
--345678901234567890123456789012345678901234567890123456789012345678901234567890

--SELECT * FROM vCategories;
--SELECT * FROM vProducts;
--SELECT * FROM vEmployees;
--SELECT * FROM vInventories;
--GO

CREATE VIEW vInventoriesByProductsByCategoriesByEmployees
AS
SELECT TOP 100000 c.CategoryID, CategoryName, p.ProductID, ProductName,
UnitPrice, InventoryID, InventoryDate, Count, i.EmployeeID,
Employee = e.EmployeeFirstName + ' ' + e.EmployeeLastName,
Manager = m.EmployeeFirstName + ' ' + m.EmployeeLastName
FROM dbo.vCategories AS c
	FULL JOIN dbo.vProducts AS p 
	ON c.CategoryID = p.CategoryID
	FULL JOIN dbo.vInventories AS i  
	ON p.ProductID = i.ProductID
	LEFT JOIN dbo.vEmployees AS e
	ON i.EmployeeID = e.EmployeeID
	LEFT JOIN dbo.vEmployees AS m 
	ON e.ManagerID = m.EmployeeID
ORDER BY CategoryName, ProductID, InventoryID, Employee;
GO

SELECT * FROM dbo.vInventoriesByProductsByCategoriesByEmployees;
GO

-- Here is an example of some rows selected from the view:
-- CategoryID	  CategoryName	ProductID	ProductName	        UnitPrice	InventoryID	InventoryDate	Count	EmployeeID	Employee
-- 1	          Beverages	    1	        Chai	              18.00	    1	          2017-01-01	  39	  5	          Steven Buchanan
-- 1	          Beverages	    1	        Chai	              18.00	    78	        2017-02-01	  49	  7	          Robert King
-- 1	          Beverages	    1	        Chai	              18.00	    155	        2017-03-01	  59	  9	          Anne Dodsworth
-- 1	          Beverages	    2	        Chang	              19.00	    2	          2017-01-01	  17	  5	          Steven Buchanan
-- 1	          Beverages	    2	        Chang	              19.00	    79	        2017-02-01	  27	  7	          Robert King
-- 1	          Beverages	    2	        Chang	              19.00	    156	        2017-03-01	  37	  9	          Anne Dodsworth
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    24	        2017-01-01	  20	  5	          Steven Buchanan
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    101	        2017-02-01	  30	  7	          Robert King
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    178	        2017-03-01	  40	  9	          Anne Dodsworth
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    34	        2017-01-01	  111	  5	          Steven Buchanan
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    111	        2017-02-01	  121	  7	          Robert King
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    188	        2017-03-01	  131	  9	          Anne Dodsworth


-- Test your Views (NOTE: You must change the names to match yours as needed!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/