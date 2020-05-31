--create a stored procedure that inserts data in tables that are in a m:n relationship; 
--if an insert fails, try to recover as much as possible from the entire operation: 
--for example, if the user wants to add a book and its authors, succeeds creating the authors,
--but fails with the book, the authors should remain in the database
USE GreenHouse
GO

DBCC LOG('GreenHouse',4)

--m:n relationship tables
SELECT * FROM isWorking
SELECT * FROM Gardener
SELECT * FROM Plant

--stored procedure
CREATE OR ALTER PROCEDURE ADDVALIDATED @price INT,@type varchar(30),@name varchar(30),@gardenerName varchar(30) AS
BEGIN
DECLARE @id INT
DECLARE @tranName varchar(10)
BEGIN TRY
	SET @tranName = 'plant'
	BEGIN TRAN @tranName
		IF(dbo.validatePlantType(@type) <> 1 OR @price<=0)
		BEGIN 
			RAISERROR('Incorrect plant type!',14,1)
		END
		SET @id=(SELECT MAX(pid) FROM Plant)+1
		INSERT INTO Plant VALUES(@id,@price,@type,@name)
	COMMIT TRAN @tranName
END TRY
BEGIN CATCH
	ROLLBACK TRAN @tranName
	PRINT 'The transaction for adding the plant was rolled back!'
END CATCH
SET @tranName='gardener'
BEGIN TRY
	BEGIN TRAN @tranName
		IF((SELECT COUNT(*) FROM Gardener WHERE name=@gardenerName) <> 0)
		BEGIN
			RAISERROR('Gardener already exist!',14,1)
		END
		SET @id=(SELECT MAX(gid) FROM Gardener)+1
		INSERT INTO Gardener(gid,name) VALUES (@id,@gardenerName)
	COMMIT TRAN @tranName
END TRY
BEGIN CATCH
	ROLLBACK TRAN @tranName
	PRINT 'The transaction for adding the gardener was rolled back!'
END CATCH
END

--neither are added
SELECT * FROM Plant
SELECT * FROM Gardener
EXEC ADDVALIDATED 50,'Swamp Plants','DuckWeed','Anabia Seymour'
SELECT * FROM Plant
SELECT * FROM Gardener

--adds only the plant
SELECT * FROM Plant
SELECT * FROM Gardener
EXEC ADDVALIDATED 35,'Garden Plants','CLEMATIS','Anabia Seymour'
SELECT * FROM Plant
SELECT * FROM Gardener

--adds only the gardener
SELECT * FROM Plant
SELECT * FROM Gardener
EXEC ADDVALIDATED 50,'Swamp Plants','DuckWeed','Cristina Bac'
SELECT * FROM Plant
SELECT * FROM Gardener

--adds both
SELECT * FROM Plant
SELECT * FROM Gardener
EXEC ADDVALIDATED 40,'Garden Plants','LANTANA CAMARA','Tudor Arde'
SELECT * FROM Plant
SELECT * FROM Gardener