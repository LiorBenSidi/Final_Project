CREATE VIEW DiversifiedInvestor
AS
SELECT B.ID
FROM Buying B, Company C
WHERE B.Symbol = C.Symbol
GROUP BY B.ID, B.tDate
HAVING COUNT(DISTINCT C.Sector) >= 6;


CREATE VIEW SumOfBuying
AS
SELECT B.ID, ROUND(SUM(B.BQuantity * S.Price), 3) AS TotalSum
FROM Buying B, Stock S
WHERE B.Symbol = S.Symbol AND B.tDate = S.tDate
GROUP BY B.ID;


CREATE VIEW Condition1
AS
SELECT DISTINCT B.Symbol
FROM Buying B, (SELECT DISTINCT tDate
                FROM Buying) DistinctDay
WHERE B.BQuantity <> 0
GROUP BY B.Symbol
HAVING COUNT(DISTINCT B.tDate) = COUNT(DISTINCT DistinctDay.tDate);


CREATE VIEW PopularCompany
AS
SELECT Condition1.Symbol
FROM Condition1, Company, (SELECT C.Sector
                           FROM Condition1 C1, Company C
                           WHERE C1.Symbol = C.Symbol
                           GROUP BY C.Sector
                           HAVING COUNT(C.Sector) = 1)  Condition2
WHERE Condition1.Symbol = Company.Symbol AND Company.Sector = Condition2.Sector;


CREATE VIEW SumOfBQ
AS
SELECT ID, PC.Symbol, SUM(BQuantity) AS SBQ
FROM Buying B, PopularCompany PC
WHERE B.Symbol = PC.Symbol
GROUP BY ID, PC.Symbol;


CREATE VIEW CompanyMaxBQ
AS
SELECT SOBQ.ID, MBQ.Symbol, MAX(SBQ) AS MaxCompanyBQ
FROM SumOfBQ SOBQ, (
    SELECT Symbol, MAX(SBQ) AS MaxBQ
    FROM SumOfBQ
    GROUP BY Symbol) MBQ
WHERE SOBQ.Symbol = MBQ.Symbol AND SOBQ.SBQ = MBQ.MaxBQ
GROUP BY SOBQ.ID, MBQ.Symbol;


CREATE VIEW ProfitableCompany
AS
SELECT S1.Symbol, S1.tDate
FROM Stock S1, Stock S2, (SELECT MIN(tDate) AS MinDay, MAX(tDate) MaxDay
                          FROM Stock DistinctDay) FirstLastDay
WHERE S1.Symbol = S2.Symbol AND S2.Price > 1.06 * S1.Price
  AND S1.tDate = FirstLastDay.MinDay AND S2.tDate = FirstLastDay.MaxDay
GROUP BY S1.tDate, S1.Symbol;