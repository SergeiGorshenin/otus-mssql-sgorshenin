-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE Sales.SendNewInvoice_HW
	@invoiceId INT
AS
BEGIN
	SET NOCOUNT ON;

    --Sending a Request Message to the Target	
	DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RequestMessage NVARCHAR(4000);
	
	BEGIN TRAN --�� ������ ������ � ����������, �.�. ��� ��� �� ��������� � ���������� �������� ���������

	--��������� XML � ������ RequestMessage ��� ��������� ����� �������(� �������� ��������� ����� ���� �����)
	SELECT @RequestMessage = (SELECT InvoiceID
							  FROM Sales.Invoices AS Inv
							  WHERE InvoiceID = @invoiceId
							  FOR XML AUTO, root('RequestMessage')); 
	
	
	--������� ������
	BEGIN DIALOG @InitDlgHandle
	FROM SERVICE
	[//WWI/SB/InitiatorService] --�� ����� �������(��� ������ ������� ��, ������� �� �� ������)
	TO SERVICE
	'//WWI/SB/TargetService'    --� ����� �������(��� ������ ������� ����� ���� ���-��, ������� ������)
	ON CONTRACT
	[//WWI/SB/Contract]         --� ������ ����� ���������
	WITH ENCRYPTION=OFF;        --�� �����������

	--���������� ���� ���� �������������� ���������, �� ����� ��������� � ����� ���������, ������� ����� �������������� ������ ���������������)
	SEND ON CONVERSATION @InitDlgHandle 
	MESSAGE TYPE
	[//WWI/SB/RequestMessage]
	(@RequestMessage);
	
	--��� ��� ������������ - �� ����� ��� �� �����
	SELECT @RequestMessage AS SentRequestMessage;
	
	COMMIT TRAN 
END
GO
