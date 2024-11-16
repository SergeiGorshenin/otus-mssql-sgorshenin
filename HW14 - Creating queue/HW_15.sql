USE [WideWorldImporters];

ALTER TABLE Sales.Invoices
ADD InvoiceConfirmedForProcessing_HW DATETIME;

--Service Broker ������� ��?
select name, is_broker_enabled
from sys.databases;

--�������� ������
USE master
ALTER DATABASE WideWorldImporters
SET ENABLE_BROKER  WITH ROLLBACK IMMEDIATE; --NO WAIT --prod (� �������������������� ������!!! �� ����� ��� �� �����)

--�� ������ ��������������� �� ����� ����������� ������!!!
ALTER AUTHORIZATION    
   ON DATABASE::WideWorldImporters TO [sa];

USE WideWorldImporters
-- For Request
CREATE MESSAGE TYPE
[//WWI/SB/RequestMessage]
VALIDATION=WELL_FORMED_XML; --������ ������������� ��� ��������, ��� ������ ������������� ���� XML(�� ����� ����� ���)
-- For Reply
CREATE MESSAGE TYPE
[//WWI/SB/ReplyMessage]
VALIDATION=WELL_FORMED_XML; 

--������� ��������(���������� ����� ��������� � ������ ����� ��������� ���������)
CREATE CONTRACT [//WWI/SB/Contract]
      ([//WWI/SB/RequestMessage]
         SENT BY INITIATOR,
       [//WWI/SB/ReplyMessage]
         SENT BY TARGET
      );

--������� ������� �������(������� ����� �.�. ����� ALTER ����� �� ������ ���
CREATE QUEUE TargetQueueWWI_HW;
--� ������ �������
CREATE SERVICE [//WWI/SB/TargetService]
       ON QUEUE TargetQueueWWI_HW
       ([//WWI/SB/Contract]);

--�� �� ��� ����������
CREATE QUEUE InitiatorQueueWWI_HW;

CREATE SERVICE [//WWI/SB/InitiatorService]
       ON QUEUE InitiatorQueueWWI_HW
       ([//WWI/SB/Contract]);

--����� �������� ������� ��� ��� ����� ������ ���������� ���������� � ���������
USE [WideWorldImporters]
GO
--���� � MAX_QUEUE_READERS = 0 ����� ������� ������� ��������� � ������� ��� ������ ������� 
ALTER QUEUE [dbo].[InitiatorQueueWWI_HW] WITH STATUS = ON --OFF=������� �� ��������(������ ���� ���������� ��������)
                                          ,RETENTION = OFF --ON=��� ����������� ��������� �������� � ������� �� ��������� �������
										  ,POISON_MESSAGE_HANDLING (STATUS = OFF) --ON=����� 5 ������ ������� ����� ���������
	                                      ,ACTIVATION (STATUS = ON --OFF=������� �� ���������� ��(� PROCEDURE_NAME)(������ �� ����� ����������� ��, �� � ������� ���������)  
										              ,PROCEDURE_NAME = Sales.ConfirmInvoice_HW
													  ,MAX_QUEUE_READERS = 0 --���������� �������(�� ������������ ���������) ��� ��������� ���������(0-32767)
													                         --(0=���� �� ��������� ���������)(������ �� ����� ����������� ��, ��� ������ ���������) 
													  ,EXECUTE AS OWNER --������ �� ����� ������� ���������� ��
													  ) 

GO
ALTER QUEUE [dbo].[TargetQueueWWI_HW] WITH STATUS = ON 
                                       ,RETENTION = OFF 
									   ,POISON_MESSAGE_HANDLING (STATUS = OFF)
									   ,ACTIVATION (STATUS = ON 
									               ,PROCEDURE_NAME = Sales.GetNewInvoice_HW
												   ,MAX_QUEUE_READERS = 0
												   ,EXECUTE AS OWNER 
												   ) 

GO



SELECT InvoiceId, InvoiceConfirmedForProcessing_HW, *
FROM Sales.Invoices
WHERE InvoiceID IN ( 61210,61211,61212,61213) ;

--���������� ���������� �� � ������-������ = �� ������ ��� select ��� ���������
EXEC Sales.SendNewInvoice_HW
	@invoiceId = 61210;

SELECT CAST(message_body AS XML),*
FROM dbo.TargetQueueWWI_HW;

SELECT CAST(message_body AS XML),*
FROM dbo.InitiatorQueueWWI_HW;

--������(�������� ���������)=������� ��������� ������������� ���������
EXEC Sales.GetNewInvoice_HW;

--Initiator(������ ����)
EXEC Sales.ConfirmInvoice_HW;

--������ ��������
SELECT conversation_handle, is_initiator, s.name as 'local service', 
far_service, sc.name 'contract', ce.state_desc
FROM sys.conversation_endpoints ce --������������� ��������(���������� ���������) ����� �� �� ����������� - --������ ��������� ������ �� �������� ������� ���������
LEFT JOIN sys.services s
ON ce.service_id = s.service_id
LEFT JOIN sys.service_contracts sc
ON ce.service_contract_id = sc.service_contract_id
ORDER BY conversation_handle;

--������������ ������� ����
SELECT InvoiceId, InvoiceConfirmedForProcessing_HW, *
FROM Sales.Invoices
WHERE InvoiceID IN ( 61210,61211,61212,61213) ;

--������ �������� 1 ��� �������(������� ������ ������� ��� ��������� ���������)
ALTER QUEUE [dbo].[InitiatorQueueWWI_HW] WITH STATUS = ON --OFF=������� �� ��������(������ ���� ���������� ��������)
                                          ,RETENTION = OFF --ON=��� ����������� ��������� �������� � ������� �� ��������� �������
										  ,POISON_MESSAGE_HANDLING (STATUS = OFF) --ON=����� 5 ������ ������� ����� ���������
	                                      ,ACTIVATION (STATUS = ON --OFF=������� �� ���������� ��(� PROCEDURE_NAME)(������ �� ����� ����������� ��, �� � ������� ���������)  
										              ,PROCEDURE_NAME = Sales.ConfirmInvoice_HW
													  ,MAX_QUEUE_READERS = 1 --���������� �������(�� ������������ ���������) ��� ��������� ���������(0-32767)
													                         --(0=���� �� ��������� ���������)(������ �� ����� ����������� ��, ��� ������ ���������) 
													  ,EXECUTE AS OWNER --������ �� ����� ������� ���������� ��
													  ) 

GO
ALTER QUEUE [dbo].[TargetQueueWWI_HW] WITH STATUS = ON 
                                       ,RETENTION = OFF 
									   ,POISON_MESSAGE_HANDLING (STATUS = OFF)
									   ,ACTIVATION (STATUS = ON 
									               ,PROCEDURE_NAME = Sales.GetNewInvoice_HW
												   ,MAX_QUEUE_READERS = 1
												   ,EXECUTE AS OWNER 
												   ) 

GO

--� ������ ��������� � ������ ��
EXEC Sales.SendNewInvoice_HW
	@invoiceId = 61211;

--���������
SELECT InvoiceId, InvoiceConfirmedForProcessing_HW, *
FROM Sales.Invoices
WHERE InvoiceID IN ( 61210,61211,61212,61213) ;


--������ ���
DROP SERVICE [//WWI/SB/TargetService]
GO

DROP SERVICE [//WWI/SB/InitiatorService]
GO

DROP QUEUE [dbo].[TargetQueueWWI_HW]
GO 

DROP QUEUE [dbo].[InitiatorQueueWWI_HW]
GO

DROP CONTRACT [//WWI/SB/Contract]
GO

DROP MESSAGE TYPE [//WWI/SB/RequestMessage]
GO

DROP MESSAGE TYPE [//WWI/SB/ReplyMessage]
GO

DROP PROCEDURE IF EXISTS  Sales.SendNewInvoice_HW;

DROP PROCEDURE IF EXISTS  Sales.GetNewInvoice_HW;

DROP PROCEDURE IF EXISTS  Sales.ConfirmInvoice_HW;

ALTER TABLE Sales.Invoices 
DROP COLUMN InvoiceConfirmedForProcessing_HW;