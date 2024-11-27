USE bazaar
GO

-- ������ �� ���������� �������������
DROP FUNCTION IF EXISTS dbo.fn_SayHello
GO
DROP PROCEDURE IF EXISTS dbo.usp_SayHello
GO
DROP ASSEMBLY IF EXISTS SimpleDemoAssembly
GO

-- �������� CLR
exec sp_configure 'show advanced options', 1;
GO
reconfigure;
GO

exec sp_configure 'clr enabled', 1;
exec sp_configure 'clr strict security', 0 
GO

-- clr strict security 
-- 1 (Enabled): ���������� Database Engine ������������ �������� PERMISSION_SET � ������� 
-- � ������ ���������������� �� ��� UNSAFE. �� ���������, ������� � SQL Server 2017.

reconfigure;
GO

-- ��� ����������� �������� ������ � EXTERNAL_ACCESS ��� UNSAFE
ALTER DATABASE bazaar SET TRUSTWORTHY ON; 

-- ���������� dll 
CREATE ASSEMBLY SplitStringAssembly
FROM 'D:\courses\otus-mssql-sgorshenin\HW19 - Create CLR\SplitString\bin\Debug\SplitString.dll'
WITH PERMISSION_SET = SAFE;  

-- ���������� ������������ ������ (SSMS: <DB> -> Programmability -> Assemblies)
SELECT * FROM sys.assemblies

-- ���������� ������� �� dll - AS EXTERNAL NAME
CREATE FUNCTION dbo.fn_SplitString(@text nvarchar(max), @delimiter nchar(1))  
RETURNS TABLE (
	part nvarchar(max),
	ID_ODER int) WITH EXECUTE AS CALLER
AS EXTERNAL NAME [SplitStringAssembly].[UserDefinedFunctions].SplitString;
GO 

-- ��������
SELECT * FROM dbo.fn_SplitString('11,22,33,44,22,33,44,22,33,44,22,33,44,22,33,44', ',')