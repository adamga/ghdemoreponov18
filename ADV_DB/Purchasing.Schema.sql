USE [AdventureWorks2014]
GO
/****** Object:  Schema [Purchasing]    Script Date: 2024-12-13 10:07:47 AM ******/
CREATE SCHEMA [Purchasing]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains objects related to vendors and purchase orders.' , @level0type=N'SCHEMA',@level0name=N'Purchasing'
GO
