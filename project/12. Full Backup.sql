USE bazaar
GO

--Full Backup
--------------------------------------------

--создание полной резервной копии
BACKUP DATABASE bazaar
TO DISK = 'D:\courses\otus-mssql-sgorshenin\project\Backup\bazaar.bak'
WITH INIT; --с перезаписью файла

--Восстановление из резервной копии
USE master
GO
ALTER DATABASE bazaar
SET SINGLE_USER -- если не сделать, то будет предупреждение, можно закрыть все подключения к бд
--Откатывает все неподтвержденные транзакции в базе данных.
WITH ROLLBACK IMMEDIATE
GO
RESTORE DATABASE bazaar
FROM DISK='D:\courses\otus-mssql-sgorshenin\project\Backup\bazaar.bak'
WITH REPLACE  --с перезаписью БД(или по умолчанию захочет еще логи)
GO