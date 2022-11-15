USE [DataWarehouse]
GO
/****** Object:  StoredProcedure [dbo].[spCreateTableDynamically]  Script Date: 11/7/2022 10:33:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[spCreateTableDynamically] 
AS
BEGIN
SET NOCOUNT ON;

DECLARE      @TableName VARCHAR(100),
			 @ColumnName VARCHAR(100),
			 @CreateStatements VARCHAR(max) =  '',
			 @ColumnList VARCHAR(max)=''

DECLARE GetTableName CURSOR READ_ONLY
      FOR
      SELECT DISTINCT [tableName]
      FROM [dbo].[dbTableMaster]

OPEN GetTableName
 
      --FETCH THE RECORD INTO THE VARIABLES.
      FETCH NEXT FROM GetTableName INTO
      @TableName
 
      --LOOP UNTIL RECORDS ARE AVAILABLE.
      WHILE @@FETCH_STATUS = 0
      BEGIN
			SET @ColumnList=''
            PRINT   CAST(@TableName AS VARCHAR(10)) 
			DECLARE GetTableStructure CURSOR READ_ONLY
			FOR	SELECT DISTINCT [columnName] FROM [dbo].[dbTableMaster] WHERE [tableName]=@TableName	
			OPEN GetTableStructure
				FETCH NEXT FROM GetTableStructure INTO
				@ColumnName
			WHILE @@FETCH_STATUS = 0
			BEGIN
            	SET @ColumnList = @ColumnList + @ColumnName + ' VARCHAR(300) ,'
				PRINT LEFT(@ColumnList, LEN(@ColumnList) - 1)   
				--FETCH THE NEXT RECORD INTO THE VARIABLES.
				FETCH NEXT FROM GetTableStructure INTO
				@ColumnName
				--Create Column List

			END 
			IF  NOT EXISTS (SELECT * FROM sys.objects 
					WHERE object_id = OBJECT_ID(N'[dbo].'+REPLACE(@TableName,'-','_')))
			BEGIN
			SET  @ColumnList = LEFT(@ColumnList, LEN(@ColumnList) - 1)
			SET @CreateStatements = 'CREATE TABLE '+@TableName+'('+ @ColumnList+')'
			SET @CreateStatements = REPLACE(@CreateStatements,'-','_')
			PRINT 'CREATE TABLE STATEMENT : '+ REPLACE(@CreateStatements,'-','_')
			--IF  NOT EXISTS (SELECT * FROM sys.objects 
			--WHERE object_id = OBJECT_ID('[dbo].'+@TableName) AND type in (N'U'))
			--Begin
				EXEC(@CreateStatements)
			--END
			END
			SET @CreateStatements=''
			CLOSE GetTableStructure
	        DEALLOCATE GetTableStructure
	  --Create Create Command
      --FETCH THE NEXT RECORD INTO THE VARIABLES.
      FETCH NEXT FROM GetTableName INTO
      @TableName
      END
      --CLOSE THE CURSOR.
      CLOSE GetTableName
      DEALLOCATE GetTableName

END



