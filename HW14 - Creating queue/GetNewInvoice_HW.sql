CREATE PROCEDURE Sales.GetNewInvoice_HW --будет получать сообщение на таргете
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER,
			@Message NVARCHAR(4000),
			@MessageType Sysname,
			@ReplyMessage NVARCHAR(4000),
			@ReplyMessageName Sysname,
			@InvoiceID INT,
			@xml XML; 
	
	BEGIN TRAN; 

	--ѕолучаем сообщение от инициатора которое находитс¤ у таргета
	RECEIVE TOP(1) --обычно одно сообщение, но можно пачкой
		@TargetDlgHandle = Conversation_Handle, --»ƒ диалога
		@Message = Message_Body, --само сообщение
		@MessageType = Message_Type_Name --тип сообщени¤( в зависимости от типа можно по разному обрабатывать) обычно два - запрос и ответ
	FROM dbo.TargetQueueWWI_HW; --им¤ очереди которую мы ранее создавали

	SELECT @Message; --не дл¤ прода

	SET @xml = CAST(@Message AS XML);

	--достали »ƒ
	SELECT @InvoiceID = R.Iv.value('@InvoiceID','INT') --тут используетс¤ ¤зык XPath и он регистрозависимый в отличии от TSQL
	FROM @xml.nodes('/RequestMessage/Inv') as R(Iv);

	IF EXISTS (SELECT * FROM Sales.Invoices WHERE InvoiceID = @InvoiceID)
	BEGIN
		UPDATE Sales.Invoices
		SET InvoiceConfirmedForProcessing_HW = GETUTCDATE() --просто устанавливаем текущую дату в ранее созданном нами поле
		WHERE InvoiceId = @InvoiceID;
	END;
	
	SELECT @Message AS ReceivedRequestMessage, @MessageType; --не дл¤ прода
	
	-- Confirm and Send a reply
	IF @MessageType=N'//WWI/SB/RequestMessage' --если наш тип сообщени¤
	BEGIN
		SET @ReplyMessage =N'<ReplyMessage> Message received</ReplyMessage>'; --ответ
	    --отправл¤ем сообщение нами придуманное, что все прошло хорошо
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[//WWI/SB/ReplyMessage]
		(@ReplyMessage);
		END CONVERSATION @TargetDlgHandle; --ј вот и завершение диалога!!! - оно двухстороннее(пока-пока) Ё“ќ первый ѕќ ј
		                                   --Ќ≈Ћ№«я «ј¬≈–Ўј“№ ƒ»јЋќ√ ƒќ ќ“ѕ–ј¬ » ѕ≈–¬ќ√ќ —ќќЅў≈Ќ»я
	END 
	
	SELECT @ReplyMessage AS SentReplyMessage; --не дл¤ прода - это дл¤ теста

	COMMIT TRAN;
END