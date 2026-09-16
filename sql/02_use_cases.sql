--Use Case 1: Analiza e Shitjeve sipas Kategorive të Produkteve
--Qëllimi: Të identifikohen kategoritë që gjenerojnë më shumë të ardhura.
SELECT p.ProductCategory,
SUM(f.OrderAmount) AS TotalSales,
SUM(f.ProfitAmount) AS TotalProfit,
COUNT(o.OrderID) AS TotalOrders
FROM Orders o
INNER JOIN Products p
ON o.ProductID = p.ProductID
INNER JOIN OrderFinancials f
ON o.OrderID = f.OrderID
GROUP BY p.ProductCategory
ORDER BY TotalSales DESC

--Use Case 2: Trendi Mujor i Shitjeve
--Qëllimi: Të analizohen ndryshimet e shitjeve gjatë viteve.
SELECT YEAR(OrderDate) AS SalesYear,
MONTH(OrderDate) AS SalesMonth,
SUM(f.OrderAmount) AS MonthlySales
FROM Orders o
INNER JOIN OrderFinancials f
ON o.OrderID = f.OrderID
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY SalesYear, SalesMonth


--Use Case 3: Analiza e Profitit sipas Shteteve
--Qëllimi: Të identifikohen tregjet më fitimprurëse.
SELECT l.Country,
SUM(f.OrderAmount) AS Revenue,
SUM(f.ProfitAmount) AS Profit
FROM Orders o
INNER JOIN Locations l
ON o.LocationID = l.LocationID
INNER JOIN OrderFinancials f
ON o.OrderID = f.OrderID
GROUP BY l.Country
ORDER BY Profit DESC


--Use Case 4: Analiza e Segmentimit të Klientëve
--Qëllimi: Të kuptohet kontributi i secilit segment klientësh.
SELECT c.CustomerSegment,
COUNT(DISTINCT c.CustomerID) AS TotalCustomers,
SUM(f.OrderAmount) AS Revenue,
AVG(f.OrderAmount) AS AvgOrderValue
FROM Orders o
INNER JOIN Customers c
ON o.CustomerID = c.CustomerID
INNER JOIN OrderFinancials f
ON o.OrderID = f.OrderID
GROUP BY c.CustomerSegment
ORDER BY Revenue DESC


--Use Case 5: Analiza e Kthimeve (Returns)
--Qëllimi: Të identifikohen kategoritë me normën më të lartë të kthimeve.
SELECT p.ProductCategory,
COUNT(*) AS TotalOrders,
SUM(CASE WHEN s.Returned = 1 THEN 1 ELSE 0 END) AS ReturnedOrders,
ROUND(100.0 * SUM(CASE WHEN s.Returned = 1 THEN 1 ELSE 0 END) / COUNT(*),2) AS ReturnRate
FROM Orders o
INNER JOIN Products p
ON o.ProductID = p.ProductID
INNER JOIN Shipments s
ON o.ShipmentID = s.ShipmentID
GROUP BY p.ProductCategory
ORDER BY ReturnRate DESC
