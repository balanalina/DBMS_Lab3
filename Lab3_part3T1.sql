--create 4 scenarios that reproduce the following concurrency issues under pessimistic isolation levels: 
--dirty reads, non-repeatable reads, phantom reads, and a deadlock; you can use stored procedures and / or stand-alone queries; 
--find solutions to solve / workaround the concurrency issues
USE GreenHouse
GO

--WE WILL USE TABLE Plant AND Gardener

SELECT * FROM Plant
SELECT * FROM Gardener

--TRAN1

----------------------DIRTY READS
--UNSOLVED
BEGIN TRAN 
UPDATE Plant SET type='DIRTY READ'
WHERE type='GARDEN PLANTS'
WAITFOR DELAY '00:00:10'
ROLLBACK TRAN

--SOLVED
BEGIN TRAN 
UPDATE Plant SET type='DIRTY READ'
WHERE type='GARDEN PLANTS'
WAITFOR DELAY '00:00:10'
ROLLBACK TRAN


----------------------NON-REPEATABLE READS
--UNSOLVED

DECLARE @id INT
SET @id=(SELECT MAX(pid) FROM Plant) + 1
INSERT INTO Plant VALUES (@id,60,'Swamp Plants','Non-Repeatable Reads')
BEGIN TRAN
WAITFOR DELAY '00:00:10'
UPDATE Plant SET name='DuckWeed'
WHERE type='Swamp Plants'
COMMIT TRAN

DELETE FROM Plant WHERE name='DuckWeed'

--SOLVED
DECLARE @id INT
SET @id=(SELECT MAX(pid) FROM Plant) + 1
INSERT INTO Plant VALUES (@id,60,'Swamp Plants','Non-Repeatable Reads')
BEGIN TRAN
WAITFOR DELAY '00:00:10'
UPDATE Plant SET name='DuckWeed'
WHERE type='Swamp Plants'
COMMIT TRAN


----------------------PHANTOM READS
--UNSOLVED
DECLARE @id INT
SET @id=(SELECT MAX(pid) FROM Plant) + 1
BEGIN TRAN
WAITFOR DELAY '00:00:10'
INSERT INTO Plant VALUES (@id,44,'Indoor Plants','ANTHURIUN ANDRAEANUM(FLAMINGO)')
COMMIT TRAN

DELETE FROM Plant WHERE name='ANTHURIUN ANDRAEANUM(FLAMINGO)'

--SOLVED
DECLARE @id INT
SET @id=(SELECT MAX(pid) FROM Plant) + 1
BEGIN TRAN
WAITFOR DELAY '00:00:10'
INSERT INTO Plant VALUES (@id,44,'Indoor Plants','ANTHURIUN ANDRAEANUM(FLAMINGO)')
COMMIT TRAN


UPDATE Gardener SET age=30 WHERE name LIKE 'TUDOR%'

----------------------DEADLOCK
--UNSOLVED -- WINNER
BEGIN TRAN
UPDATE Plant SET name='TRAN 1' WHERE type='Swamp Plants'
WAITFOR DELAY '00:00:10'
UPDATE Gardener SET name='TRAN 1' WHERE age=30
COMMIT TRAN

--SOLVED -- VICTIM
SET DEADLOCK_PRIORITY LOW
BEGIN TRAN
UPDATE Gardener SET name='TRAN 1' WHERE age=30
WAITFOR DELAY '00:00:10'
UPDATE Plant SET name='TRAN 1' WHERE type='Swamp Plants'
COMMIT TRAN

SELECT * FROM Plant
SELECT * FROM Gardener