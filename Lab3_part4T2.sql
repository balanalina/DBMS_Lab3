--create a scenario that reproduces the update conflict under an optimistic isolation level
USE GreenHouse 
GO

--WE WILL USE TABLE Plant
SELECT * FROM Plant

SET TRANSACTION ISOLATION LEVEL SNAPSHOT
BEGIN TRAN 
SELECT price FROM Plant WHERE name='BEGONIA'
WAITFOR DELAY '00:00:10'
UPDATE Plant SET price=price-10
WHERE name='BEGONIA'
COMMIT TRAN

--Msg 3960, Level 16, State 5, Line 12
--Snapshot isolation transaction aborted due to update conflict. 
--You cannot use snapshot isolation to access table 'dbo.Plant' directly or indirectly in database 'GreenHouse' to update, 
--delete, or insert the row that has been modified or deleted by another transaction. Retry the transaction or change the isolation
--level for the update/delete statement.