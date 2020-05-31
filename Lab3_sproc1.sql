USE GreenHouse
GO
--create a stored procedure that inserts data in tables that are in a m:n relationship; 
--if one insert fails, all the operations performed by the procedure must be rolled back
--m:n realtionship tables
SELECT * FROM isWorking
SELECT * FROM Gardener
SELECT * FROM Plant
--try to insert into table Plant

DBCC LOG('GreenHouse',4)

--function to validate plant type
CREATE FUNCTION validatePlantType (@type varchar(30)) 
RETURNS INT 
AS
BEGIN
	DECLARE @return INT
	SET @return=0
	IF (@type IN ('Feng Shui Plants','Indoor Plants','Autumn Flower','Garden Plants'))
		SET @return=1
	RETURN @return
END

CREATE OR ALTER PROCEDURE ADDPLANT @price INT,@type varchar(30),@name varchar(30) AS
BEGIN
BEGIN TRY
	BEGIN TRAN 
	IF(dbo.validatePlantType(@type) <> 1)
	BEGIN 
		RAISERROR('Incorrect plant type!',14,1)
	END
	DECLARE @id INT
	SET @id=(SELECT MAX(pid) FROM Plant)+1
	INSERT INTO Plant VALUES(@id,@price,@type,@name)
	INSERT INTO isWorking(date,time,pid) VALUES (DATEADD(DAY, 1, GETDATE()),CURRENT_TIMESTAMP,@id)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN
	PRINT 'The transaction was rolled back!'
END CATCH
END

--the plant won't be added
SELECT * FROM Plant
SELECT * FROM isWorking
EXEC ADDPLANT 50,'Swamp Plants','DuckWeed'
SELECT * FROM Plant
SELECT * FROM isWorking

--the plant is added
SELECT * FROM Plant
SELECT * FROM isWorking
EXEC ADDPLANT 50,'Feng Shui Plants','BEGONIA'
SELECT * FROM Plant
SELECT * FROM isWorking
