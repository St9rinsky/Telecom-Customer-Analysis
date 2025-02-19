CREATE TABLE TelecomCustomerChurn
(
    CustomerID VARCHAR(50) PRIMARY KEY,
    Gender VARCHAR(10),
    Age INT,
    Married VARCHAR(5),
    NumberOfDependents INT,
    City VARCHAR(100),
    ZipCode INT,
    Latitude FLOAT,
    Longitude FLOAT,
    NumberOfReferrals INT,
    TenureInMonths INT,
    Offer VARCHAR(50),
    PhoneService VARCHAR(10),
    AvgMonthlyLongDistanceCharges FLOAT,
    MultipleLines VARCHAR(50),
    InternetService VARCHAR(50),
    InternetType VARCHAR(50),
    AvgMonthlyGBDownload FLOAT,
    OnlineSecurity VARCHAR(50),
    OnlineBackup VARCHAR(50),
    DeviceProtectionPlan VARCHAR(50),
    PremiumTechSupport VARCHAR(50),
    StreamingTV VARCHAR(50),
    StreamingMovies VARCHAR(50),
    StreamingMusic VARCHAR(50),
    UnlimitedData VARCHAR(50),
    Contract VARCHAR(50),
    PaperlessBilling VARCHAR(5),
    PaymentMethod VARCHAR(50),
    MonthlyCharge FLOAT,
    TotalCharges FLOAT,
    TotalRefunds FLOAT,
    TotalExtraDataCharges INT,
    TotalLongDistanceCharges FLOAT,
    TotalRevenue FLOAT,
    CustomerStatus VARCHAR(20),
    ChurnCategory VARCHAR(50),
    ChurnReason VARCHAR(255)
);

SELECT * FROM TelecomCustomerChurn;

--TO REMOVE ALL THE IMPOSSIBLE NEGATIVE CHARGES

DELETE FROM TelecomCustomerChurn
WHERE MonthlyCharge < 0;

--UPDATING ALL THE NULL AND MISSING VALUES

SELECT DISTINCT(InternetType)
FROM TelecomCustomerChurn
ORDER BY 1;

UPDATE TelecomCustomerChurn
SET InternetType ='unknown'
WHERE InternetType IS NULL or InternetType = '';

SELECT DISTINCT(OnlineSecurity)
FROM TelecomCustomerChurn;

UPDATE TelecomCustomerChurn
SET OnlineSecurity = 'No'
WHERE OnlineSecurity IS NULL or OnlineSecurity = '';

SELECT DISTINCT(OnlineBackup)
FROM TelecomCustomerChurn;

UPDATE TelecomCustomerChurn
SET OnlineBackup = 'No'
WHERE OnlineBackup IS NULL or OnlineBackup = '';

SELECT DISTINCT(ChurnReason)
FROM TelecomCustomerChurn;

UPDATE TelecomCustomerChurn
SET ChurnCategory = 'Not Churned',
    ChurnReason = 'Not Churned'
WHERE CustomerStatus = 'Stayed' AND ChurnCategory IS NULL or ChurnCategory = '';

--DELETES ALL THE DUPLICATE RECORDS
WITH CTE AS (
    SELECT CustomerID, ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY CustomerID) AS rn
    FROM TelecomCustomerChurn
)
DELETE FROM CTE WHERE rn > 1;

--------------------------------------------------------------------------------------------------------
----Split the data into tables for normalisation

CREATE TABLE Customers 
(
    CustomerID VARCHAR(50) PRIMARY KEY,
    Gender VARCHAR(10),
    Age INT,
    Married VARCHAR(5),
    NumberOfDependents INT,
    City VARCHAR(100),
    ZipCode INT,
    Latitude FLOAT,
    Longitude FLOAT,
    NumberOfReferrals INT,
    TenureInMonths INT
);

INSERT INTO Customers 
SELECT CustomerID, Gender, Age, Married, NumberOfDependents, City, ZipCode, Latitude, Longitude, NumberOfReferrals, TenureInMonths
FROM TelecomCustomerChurn;

CREATE TABLE CustomerServices 
(
    CustomerID VARCHAR(50),
    PhoneService VARCHAR(10),
    MultipleLines VARCHAR(50),
    InternetService VARCHAR(50),
    InternetType VARCHAR(50),
    OnlineSecurity VARCHAR(50),
    OnlineBackup VARCHAR(50),
    DeviceProtectionPlan VARCHAR(50),
    PremiumTechSupport VARCHAR(50),
    StreamingTV VARCHAR(50),
    StreamingMovies VARCHAR(50),
    StreamingMusic VARCHAR(50),
    UnlimitedData VARCHAR(50),
    Contract VARCHAR(50),
    Offer VARCHAR(50),
    PRIMARY KEY (CustomerID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

INSERT INTO CustomerServices 
SELECT CustomerID, PhoneService, MultipleLines, InternetService, InternetType, OnlineSecurity, OnlineBackup, DeviceProtectionPlan, 
PremiumTechSupport, StreamingTV, StreamingMovies, StreamingMusic, UnlimitedData, Contract, Offer
FROM TelecomCustomerChurn;

CREATE TABLE Billing 
(
    CustomerID VARCHAR(50),
    PaperlessBilling VARCHAR(5),
    PaymentMethod VARCHAR(50),
    MonthlyCharge FLOAT,
    TotalCharges FLOAT,
    TotalRefunds FLOAT,
    TotalExtraDataCharges INT,
    TotalLongDistanceCharges FLOAT,
    TotalRevenue FLOAT,
    PRIMARY KEY (CustomerID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

INSERT INTO Billing 
SELECT CustomerID, PaperlessBilling, PaymentMethod, MonthlyCharge, TotalCharges, TotalRefunds, TotalExtraDataCharges, 
TotalLongDistanceCharges, TotalRevenue
FROM TelecomCustomerChurn;

CREATE TABLE Churn 
(
    CustomerID VARCHAR(50),
    CustomerStatus VARCHAR(20),
    ChurnCategory VARCHAR(50),
    ChurnReason VARCHAR(255),
    PRIMARY KEY (CustomerID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

INSERT INTO Churn 
SELECT CustomerID, CustomerStatus, ChurnCategory, ChurnReason
FROM TelecomCustomerChurn;

