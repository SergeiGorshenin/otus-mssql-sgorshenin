USE bazaar
GO

-- ѕроверка состо€ни€ индексов:
SELECT OBJECT_NAME(ind.OBJECT_ID) AS TableName,
    ind.name AS IndexName, indexstats.index_type_desc AS IndexType,
    indexstats.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
INNER JOIN sys.indexes AS ind ON ind.object_id = indexstats.object_id
    AND ind.index_id = indexstats.index_id
WHERE indexstats.avg_fragmentation_in_percent > 5
ORDER BY indexstats.avg_fragmentation_in_percent DESC;

--обслуживание индексов + настройка параметров процедуры 1:00
exec master.dbo.IndexOptimize
	@Databases = N'bazaar',
	--действи€ при фрагментации
	@FragmentationLow = NULL, --ничего 
	@FragmentationMedium = 'INDEX_REORGANIZE',
	@FragmentationHigh = 'INDEX_REBUILD_ONLINE, INDEX_REORGANIZE', --попробовать перестроить онлайн, если не получитс€ - реорганизовать (возможные значени€ можно посмотреть в тексте хп)

	--менее агрессивна€ перестройка индекса
	@FragmentationLevel1 = 30,  --5, рекомендации MS
	@FragmentationLevel2 = 70, --30, рекомендации MS
	@SortInTempdb = 'N', --'Y' - если tempdb на быстром диске
	@MaxDOP = 2, --NULL,
	@Resumable = 'N', 
	--@FillFactor = NULL,
	--@PadIndex = NULL,

	@TimeLimit = NULL, --, ограничение по времени (сек)
	@Delay = 10, --NULL, задержка между индексами
	@LogToTable = 'Y', --логирование в таблицу CommandLog
	@Execute = 'Y' -- 'N' - тест 'Y' - запуск

go
select * from master.dbo.CommandLog order by StartTime desc