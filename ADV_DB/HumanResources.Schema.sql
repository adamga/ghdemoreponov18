USE [AdventureWorks2014]
GO
/****** Object:  Schema [HumanResources]    Script Date: 2024-12-13 10:07:47 AM ******/
CREATE SCHEMA [HumanResources]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains objects related to employees and departments.' , @level0type=N'SCHEMA',@level0name=N'HumanResources'
GO
