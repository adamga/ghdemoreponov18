USE [AdventureWorks2014]
GO
/****** Object:  Schema [Person]    Script Date: 2024-12-13 10:07:47 AM ******/
CREATE SCHEMA [Person]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains objects related to names and addresses of customers, vendors, and employees' , @level0type=N'SCHEMA',@level0name=N'Person'
GO
