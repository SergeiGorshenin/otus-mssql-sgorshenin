USE bazaar
GO

--Full Backup
--------------------------------------------

--�������� ������ ��������� �����
BACKUP DATABASE bazaar
TO DISK = 'D:\courses\otus-mssql-sgorshenin\project\Backup\bazaar.bak'
WITH INIT; --� ����������� �����

--�������������� �� ��������� �����
USE master
GO
ALTER DATABASE bazaar
SET SINGLE_USER -- ���� �� �������, �� ����� ��������������, ����� ������� ��� ����������� � ��
--���������� ��� ���������������� ���������� � ���� ������.
WITH ROLLBACK IMMEDIATE
GO
RESTORE DATABASE bazaar
FROM DISK='D:\courses\otus-mssql-sgorshenin\project\Backup\bazaar.bak'
WITH REPLACE  --� ����������� ��(��� �� ��������� ������� ��� ����)
GO