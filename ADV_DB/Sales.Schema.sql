USE [AdventureWorks2014]
GO
/****** Object:  Schema [Sales]    Script Date: 2024-12-13 10:07:47 AM ******/
CREATE SCHEMA [Sales]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains objects related to customers, sales orders, and sales territories.' , @level0type=N'SCHEMA',@level0name=N'Sales'
GO
