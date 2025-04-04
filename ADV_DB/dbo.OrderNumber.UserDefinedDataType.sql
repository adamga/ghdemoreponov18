USE [AdventureWorks2014]
GO
/****** Object:  UserDefinedDataType [dbo].[OrderNumber]    Script Date: 2024-12-13 10:07:47 AM ******/
CREATE TYPE [dbo].[OrderNumber] FROM [nvarchar](25) NULL
GO

CREATE TABLE [dbo].[EmployeeSatisfaction] (
    [EmployeeID] INT PRIMARY KEY,
    [SatisfactionScore] INT CHECK (SatisfactionScore BETWEEN 1 AND 10),
    [Comments] NVARCHAR(255) NULL,
    [SurveyDate] DATE NOT NULL,
    [OrderNumber] [dbo].[OrderNumber] NULL,
    [DepartmentID] INT FOREIGN KEY REFERENCES [HumanResources].[Department]([DepartmentID]),
    [ShiftID] TINYINT FOREIGN KEY REFERENCES [HumanResources].[Shift]([ShiftID]),
    [ModifiedDate] DATETIME DEFAULT GETDATE(),
    [CONSTRAINT CK_EmployeeSatisfaction_Score CHECK (SatisfactionScore >= 1)],
    [CONSTRAINT CK_EmployeeSatisfaction_Date CHECK (SurveyDate <= GETDATE())],
    [CONSTRAINT CK_EmployeeSatisfaction_OrderNumber CHECK (LEN(OrderNumber) <= 25)],
    [CONSTRAINT CK_EmployeeSatisfaction_Comments CHECK (Comments NOT LIKE '%foul language%')]
)
GO
