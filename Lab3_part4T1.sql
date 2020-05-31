--create a scenario that reproduces the update conflict under an optimistic isolation level
alter database greenhouse
set allow_snapshot_isolation on


SET DEADLOCK_PRIORITY LOW
BEGIN TRAN
UPDATE Plant SET name='TRAN 2' WHERE type='Swamp Plants'
WAITFOR DELAY '00:00:10'
UPDATE Gardener SET name='TRAN 2' WHERE age=30
COMMIT TRAN