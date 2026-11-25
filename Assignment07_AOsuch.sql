--*************************************************************************--
-- Title: Assignment07
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2017-01-01,RRoot,Created File
-- 2026-11-18,AOsuch,Drafted code
-- 2026-11-24,AOsuch,Completed code
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_AOsuch')
	 Begin 
	  Alter Database [Assignment07DB_AOsuch] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_AOsuch;
	 End
	Create Database Assignment07DB_AOsuch;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_AOsuch;

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
,[UnitPrice] [money] NOT NULL
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
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
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
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product  name.

-- <Put Your Code Here> --

-- first select the product name and unformatted price from the base view.
/*
SELECT
  ProductName,
  UnitPrice
  FROM dbo.vProducts
;
GO
*/

-- finally format the price as US dollars and sort by product.
SELECT 
  ProductName, 
  FORMAT(UnitPrice, 'C', 'en-US') AS UnitPrice
  FROM dbo.vProducts
ORDER BY ProductName
;
GO

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.

-- <Put Your Code Here> --

-- first check the columns from each base view, including CategoryID for the join.
/*
SELECT
  CategoryID,
  CategoryName
  FROM dbo.vCategories
;
GO

SELECT
  CategoryID,
  ProductName,
  UnitPrice
  FROM dbo.vProducts
;
GO
*/

-- then join the base views by CategoryID to get a category for each price.
-- use the currency format from Question 1
/*
SELECT
  c.CategoryName, -- add prefix to match ORDER BY, same below
  p.ProductName,
  p.UnitPrice
  FROM dbo.vProducts p
  JOIN dbo.vCategories c
    ON p.CategoryID = c.CategoryID
;
GO
*/

-- finally apply the Q1 currency format and sort by category and product.
SELECT
  c.CategoryName,
  p.ProductName,
  FORMAT(p.UnitPrice, 'C', 'en-US') AS UnitPrice
  FROM dbo.vProducts p
  JOIN dbo.vCategories c 
    ON p.CategoryID = c.CategoryID
ORDER BY 
  c.CategoryName, 
  p.ProductName
;
GO

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --

-- first check the inventory and product columns, including ProductID for the join.
/*
SELECT
  ProductID,
  InventoryDate,
  [Count]
  FROM dbo.vInventories
;
GO

SELECT
  ProductID,
  ProductName
  FROM dbo.vProducts
;
GO
*/

-- then join by ProductID and inspect the raw dates and counts in order.
/*
SELECT
  p.ProductName,
  i.InventoryDate,
  i.[Count] AS InventoryCount
  FROM dbo.vInventories i
  JOIN dbo.vProducts p
    ON i.ProductID = p.ProductID
ORDER BY
  p.ProductName,
  i.InventoryDate -- keep original i column to avoid the text sorting from FORMAT output
;
GO
*/

-- finally format the displayed date and keep the raw date for sorting.
SELECT 
  p.ProductName,
  FORMAT(i.InventoryDate, 'MMMM, yyyy', 'en-US') AS InventoryDate,
  i.[Count] AS InventoryCount
  FROM dbo.vInventories i
  JOIN dbo.vProducts p
    ON i.ProductID = p.ProductID
ORDER BY 
  p.ProductName,
  i.InventoryDate
;
GO

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --

-- first reuse the Q3 query with the product and inventory base views.
-- then save the query as vProductInventories for the later reports.
-- basically the above as a view
-- TOP allows ORDER BY inside this view
CREATE VIEW dbo.vProductInventories
WITH SCHEMABINDING
AS
  SELECT TOP (1000000)
    p.ProductName,
    FORMAT(i.InventoryDate, 'MMMM, yyyy', 'en-US') AS InventoryDate,
    i.[Count] AS InventoryCount
    FROM dbo.vInventories i
    JOIN dbo.vProducts p
      ON i.ProductID = p.ProductID
  ORDER BY
    p.ProductName,
    i.InventoryDate
;
GO

-- Check that it works: Select * From vProductInventories;
-- sort by product and chronological date.
SELECT * 
  FROM dbo.vProductInventories
ORDER BY
  ProductName,
  CAST(InventoryDate AS date)
;
GO

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --

-- first add the category to each product's inventory count before grouping.
/*
SELECT
  c.CategoryName,
  p.ProductName,
  i.InventoryDate,
  i.[Count] AS InventoryCount
  FROM dbo.vInventories i
  JOIN dbo.vProducts p
    ON i.ProductID = p.ProductID
  JOIN dbo.vCategories c
    ON p.CategoryID = c.CategoryID
ORDER BY
  c.CategoryName,
  i.InventoryDate,
  p.ProductName
;
GO
*/

-- then group by category and raw date to get one total per category and date.
/*
SELECT
  c.CategoryName,
  i.InventoryDate,
  SUM(i.[Count]) AS InventoryCountByCategory -- SUM function for adding the counts together
  FROM dbo.vInventories i
  JOIN dbo.vProducts p
    ON i.ProductID = p.ProductID
  JOIN dbo.vCategories c
    ON p.CategoryID = c.CategoryID
GROUP BY
  c.CategoryName, -- map to category
  i.InventoryDate -- group to match the SUM
ORDER BY
  c.CategoryName, -- the instruction says Product, but Figure 5 is ordered by category, matching to the figure here
  i.InventoryDate
;
GO
*/

-- then format the displayed date and save the category totals as a view.
CREATE VIEW dbo.vCategoryInventories
WITH SCHEMABINDING
AS
  SELECT TOP (1000000)
    c.CategoryName,
    FORMAT(i.InventoryDate, 'MMMM, yyyy', 'en-US') AS InventoryDate,
    SUM(i.[Count]) AS InventoryCountByCategory
    FROM dbo.vInventories i
    JOIN dbo.vProducts p
      ON i.ProductID = p.ProductID
    JOIN dbo.vCategories c
      ON p.CategoryID = c.CategoryID
  GROUP BY
    c.CategoryName,
    i.InventoryDate
  ORDER BY
    c.CategoryName,
    i.InventoryDate
;
GO

-- Check that it works: Select * From vCategoryInventories;
SELECT * 
  FROM dbo.vCategoryInventories
ORDER BY
  CategoryName,
  CAST(InventoryDate AS date)
;
GO

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

-- <Put Your Code Here> --

-- first use the Q4 result check to inspect each product's dates and counts.
-- ran SELECT * on the view to remind myself of what's in it
-- then add LAG in date order to see the NULL previous count for each product's first row.
/*
SELECT
  ProductName,
  InventoryDate,
  InventoryCount,
  LAG(InventoryCount)
    OVER (PARTITION BY ProductName
      ORDER BY CAST(InventoryDate AS date)
    )
  AS PreviousMonthCount
  FROM dbo.vProductInventories -- dropped AS i since there's only one view being referenced here
ORDER BY
  ProductName,
  CAST(InventoryDate AS date)
;
GO
*/

-- then use ISNULL to show zero for the first month and save the report as a view.
-- avoids LAG generating NULL since there's no month before Jan
CREATE VIEW dbo.vProductInventoriesWithPreviousMonthCounts
WITH SCHEMABINDING
AS
  SELECT TOP (1000000)
    ProductName,
    InventoryDate,
    InventoryCount,
    ISNULL(
      LAG(InventoryCount)
        OVER (PARTITION BY ProductName
          ORDER BY CAST(InventoryDate AS date)
        ),
      0)
      AS PreviousMonthCount
    FROM dbo.vProductInventories
  ORDER BY
    ProductName,
    CAST(InventoryDate AS date)
;
GO

-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;
SELECT * 
  FROM dbo.vProductInventoriesWithPreviousMonthCounts
ORDER BY
  ProductName,
  CAST(InventoryDate AS date)
;
GO

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.
-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!

-- start with the current and previous counts from the Q6 view.
-- then use CASE to turn each comparison into a KPI.
/*
SELECT
  ProductName,
  InventoryDate,
  InventoryCount,
  PreviousMonthCount, -- at first glance this seemed to be the only column needed for the KPI calculation per question
  CASE
    WHEN InventoryCount > PreviousMonthCount
      THEN 1
    WHEN InventoryCount = PreviousMonthCount
      THEN 0
    ELSE -1 -- decided on this order although logic could have been rearranged differently.
  END AS CountVsPreviousCountKPI -- KPI column name add matches Figure 7
  FROM dbo.vProductInventoriesWithPreviousMonthCounts
ORDER BY
  ProductName,
  CAST(InventoryDate AS date)
;
GO
*/

CREATE VIEW dbo.vProductInventoriesWithPreviousMonthCountsWithKPIs
WITH SCHEMABINDING
AS
  SELECT TOP (1000000)
    ProductName,
    InventoryDate,
    InventoryCount,
    PreviousMonthCount,
    CASE
      WHEN InventoryCount > PreviousMonthCount
        THEN 1
      WHEN InventoryCount = PreviousMonthCount
        THEN 0
      ELSE -1
    END AS CountVsPreviousCountKPI
  FROM dbo.vProductInventoriesWithPreviousMonthCounts
ORDER BY
  ProductName,
  CAST(InventoryDate AS date)
;
GO

-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;

SELECT * 
  FROM dbo.vProductInventoriesWithPreviousMonthCountsWithKPIs
ORDER BY
  ProductName,
  CAST(InventoryDate AS date)
;
GO

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --

-- first preview the Q7 rows for a KPI of 1 using a local variable.
/*
DECLARE @KPIValue int = 1; -- ran here to end of select to test without creating the function

SELECT
  ProductName,
  InventoryDate,
  InventoryCount,
  PreviousMonthCount,
  CountVsPreviousCountKPI
  FROM dbo.vProductInventoriesWithPreviousMonthCountsWithKPIs
  WHERE CountVsPreviousCountKPI = @KPIValue
ORDER BY
  ProductName,
  CAST(InventoryDate AS date)
;
GO
*/

-- then make @KPIValue a parameter of the inline table-valued function.
-- TOP allows ORDER BY inside this inline function
CREATE FUNCTION dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs
(
  @KPIValue int
)
RETURNS TABLE
AS
RETURN
  SELECT TOP (1000000)
    ProductName,
    InventoryDate,
    InventoryCount,
    PreviousMonthCount,
    CountVsPreviousCountKPI
    FROM dbo.vProductInventoriesWithPreviousMonthCountsWithKPIs
    WHERE CountVsPreviousCountKPI = @KPIValue
  ORDER BY
    ProductName,
    CAST(InventoryDate AS date)
;
GO

Print 'Note: You will get an error until the views and functions are created!'
/* Check that it works:
Select * From vProductInventories;
Select * From vCategoryInventories;
Select * From vProductInventoriesWithPreviousMonthCounts;
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;

Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/

SELECT *
  FROM dbo.vProductInventories
ORDER BY
  ProductName,
  CAST(InventoryDate AS date)
;
GO

SELECT *
  FROM dbo.vCategoryInventories
ORDER BY
  CategoryName,
  CAST(InventoryDate AS date)
;
GO

SELECT *
  FROM dbo.vProductInventoriesWithPreviousMonthCounts
ORDER BY
  ProductName,
  CAST(InventoryDate AS date)
;
GO

SELECT *
  FROM dbo.vProductInventoriesWithPreviousMonthCountsWithKPIs
ORDER BY
  ProductName,
  CAST(InventoryDate AS date)
;
GO

SELECT *
  FROM dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(1)
ORDER BY
  ProductName,
  CAST(InventoryDate AS date)
;
GO

SELECT *
  FROM dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(0)
ORDER BY
  ProductName,
  CAST(InventoryDate AS date)
;
GO

SELECT *
  FROM dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(-1)
ORDER BY
  ProductName,
  CAST(InventoryDate AS date)
;
GO

/***************************************************************************************/
