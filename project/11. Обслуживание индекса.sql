USE bazaar
GO

-- �������� ��������� ��������:
SELECT OBJECT_NAME(ind.OBJECT_ID) AS TableName,
    ind.name AS IndexName, indexstats.index_type_desc AS IndexType,
    indexstats.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
INNER JOIN sys.indexes AS ind ON ind.object_id = indexstats.object_id
    AND ind.index_id = indexstats.index_id
WHERE indexstats.avg_fragmentation_in_percent > 5
ORDER BY indexstats.avg_fragmentation_in_percent DESC;

--������������ �������� + ��������� ���������� ��������� 1:00
exec master.dbo.IndexOptimize
	@Databases = N'bazaar',
	--�������� ��� ������������
	@FragmentationLow = NULL, --������ 
	@FragmentationMedium = 'INDEX_REORGANIZE',
	@FragmentationHigh = 'INDEX_REBUILD_ONLINE, INDEX_REORGANIZE', --����������� ����������� ������, ���� �� ��������� - �������������� (��������� �������� ����� ���������� � ������ ��)

	--����� ����������� ����������� �������
	@FragmentationLevel1 = 30,  --5, ������������ MS
	@FragmentationLevel2 = 70, --30, ������������ MS
	@SortInTempdb = 'N', --'Y' - ���� tempdb �� ������� �����
	@MaxDOP = 2, --NULL,
	@Resumable = 'N', 
	--@FillFactor = NULL,
	--@PadIndex = NULL,

	@TimeLimit = NULL, --, ����������� �� ������� (���)
	@Delay = 10, --NULL, �������� ����� ���������
	@LogToTable = 'Y', --����������� � ������� CommandLog
	@Execute = 'Y' -- 'N' - ���� 'Y' - ������

go
select * from master.dbo.CommandLog order by StartTime desc