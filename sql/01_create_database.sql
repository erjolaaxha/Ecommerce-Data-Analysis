CREATE DATABASE ECommerceDB
USE ECommerceDB

CREATE TABLE Customers (
CustomerID NVARCHAR(20) NOT NULL PRIMARY KEY,
CustomerAge TINYINT NOT NULL,
CustomerGender NVARCHAR(20) NOT NULL,
CustomerSegment NVARCHAR(50) NOT NULL,  
MembershipStatus NVARCHAR(50) NOT NULL,
CustomerLifetimeValue DECIMAL(12,2) NOT NULL
)

CREATE TABLE Products (
ProductID NVARCHAR(20) NOT NULL PRIMARY KEY,
ProductCategory NVARCHAR(100) NOT NULL,
ProductSubcategory NVARCHAR(100) NOT NULL,
Brand NVARCHAR(100) NOT NULL,
UnitPrice DECIMAL(10,2) NOT NULL
)

CREATE TABLE Locations (
LocationID INT IDENTITY(1,1) PRIMARY KEY,
Country NVARCHAR(100) NOT NULL,
City NVARCHAR(100) NOT NULL,
WarehouseRegion NVARCHAR(50) NOT NULL,
CONSTRAINT UQ_Location UNIQUE (Country, City)
)

CREATE TABLE Shipments (
ShipmentID INT IDENTITY(1,1) PRIMARY KEY,
ShippingMethod NVARCHAR(50) NOT NULL,  
ShippingCost DECIMAL(10,2) NOT NULL,
DeliveryDays TINYINT NOT NULL,
OrderStatus NVARCHAR(30) NOT NULL,  
Returned BIT NOT NULL DEFAULT 0
)

CREATE TABLE OrderFinancials (
OrderID INT NOT NULL PRIMARY KEY,
Quantity SMALLINT NOT NULL,
DiscountPercent TINYINT NOT NULL,
DiscountAmount DECIMAL(10,2) NOT NULL,
CouponUsed BIT NOT NULL DEFAULT 0,
TaxAmount DECIMAL(10,2) NOT NULL,
OrderAmount DECIMAL(12,2) NOT NULL,
ProfitMarginPercent DECIMAL(6,2) NOT NULL,
ProfitAmount DECIMAL(12,2) NOT NULL
)

CREATE TABLE Orders (
OrderID INT NOT NULL PRIMARY KEY,
CustomerID NVARCHAR(20) NOT NULL,
ProductID  NVARCHAR(20) NOT NULL,
LocationID INT NOT NULL,
ShipmentID INT NOT NULL,
OrderDate DATE NOT NULL,
DayOfWeek NVARCHAR(15) NOT NULL,
Quarter TINYINT NOT NULL,
Season NVARCHAR(20) NOT NULL,
HolidaySeason BIT NOT NULL DEFAULT 0,
HighValueOrder BIT NOT NULL DEFAULT 0,
PaymentMethod NVARCHAR(50) NOT NULL,
DeviceType NVARCHAR(30) NOT NULL,
TrafficSource NVARCHAR(50) NOT NULL,
ReviewRating DECIMAL(3,1) NULL,
CONSTRAINT FK_Orders_Customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
CONSTRAINT FK_Orders_Product FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
CONSTRAINT FK_Orders_Location FOREIGN KEY (LocationID) REFERENCES Locations(LocationID),
CONSTRAINT FK_Orders_Shipment FOREIGN KEY (ShipmentID) REFERENCES Shipments(ShipmentID),
CONSTRAINT FK_Orders_Financials FOREIGN KEY (OrderID) REFERENCES OrderFinancials(OrderID)
)

CREATE INDEX IX_Orders_CustomerID ON Orders (CustomerID);
CREATE INDEX IX_Orders_ProductID ON Orders (ProductID);
CREATE INDEX IX_Orders_OrderDate ON Orders (OrderDate);
CREATE INDEX IX_Orders_Status ON Shipments (OrderStatus);

INSERT INTO Customers
    (CustomerID, CustomerAge, CustomerGender, CustomerSegment,
     MembershipStatus, CustomerLifetimeValue)
SELECT
    Customer_ID, Customer_Age, Customer_Gender, Customer_Segment,
    Membership_Status, Customer_Lifetime_Value
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Customer_ID ORDER BY Order_ID) AS rn
    FROM ecommerce_orders_dataset
) x
WHERE x.rn = 1;



INSERT INTO Products
    (ProductID, ProductCategory, ProductSubcategory, Brand, UnitPrice)
SELECT
    Product_ID, Product_Category, Product_Subcategory, Brand, Unit_Price
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Product_ID ORDER BY Order_ID) AS rn
    FROM ecommerce_orders_dataset
) x
WHERE x.rn = 1;



INSERT INTO Locations (Country, City, WarehouseRegion)
SELECT Country, City, Warehouse_Region
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Country, City ORDER BY Order_ID) AS rn
    FROM ecommerce_orders_dataset
) x
WHERE x.rn = 1;


INSERT INTO Shipments
    (ShippingMethod, ShippingCost, DeliveryDays, OrderStatus, Returned)
SELECT
    Shipping_Method, Shipping_Cost, Delivery_Days, Order_Status, Returned
FROM ecommerce_orders_dataset
ORDER BY Order_ID;


INSERT INTO OrderFinancials
    (OrderID, Quantity, DiscountPercent, DiscountAmount, CouponUsed,
     TaxAmount, OrderAmount, ProfitMarginPercent, ProfitAmount)
SELECT
    Order_ID, Quantity, Discount_Percent, Discount_Amount, Coupon_Used,
    Tax_Amount, Order_Amount, Profit_Margin_Percent, Profit_Amount
FROM ecommerce_orders_dataset
ORDER BY Order_ID;


;WITH Ships AS (
    SELECT ShipmentID, ROW_NUMBER() OVER (ORDER BY ShipmentID) AS rn
    FROM Shipments
),
Numbered AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY Order_ID) AS rn
    FROM ecommerce_orders_dataset
)
INSERT INTO Orders (
    OrderID, CustomerID, ProductID, LocationID, ShipmentID,
    OrderDate, DayOfWeek, Quarter, Season,
    HolidaySeason, HighValueOrder,
    PaymentMethod, DeviceType, TrafficSource, ReviewRating
)
SELECT
    r.Order_ID, r.Customer_ID, r.Product_ID,
    l.LocationID, s.ShipmentID,
    CONVERT(DATE, r.Order_Date),
    r.Day_Of_Week, r.Quarter, r.Season,
    r.Holiday_Season, r.High_Value_Order,
    r.Payment_Method, r.Device_Type, r.Traffic_Source,
    r.Review_Rating
FROM Numbered      r
JOIN Ships         s ON s.rn      = r.rn
JOIN dbo.Locations l ON l.Country = r.Country AND l.City = r.City;

