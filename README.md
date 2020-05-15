# kenyaemrMigration

Procedure
1. Configure linked database from MSSQL to MySQL
2. Run MySQL_DDL_Migration_Staging.sql to create tables for staging database
3. Run MSSQL_DML_Migration_Staging.sql to populate the created staging database 
4. Run MySQL_Migration_DDL_DML_Transformed.sql to transform raw data in linked db to coded data for spreadsheet module


Install and COnfigure Pentaho Data Integration tool
1. Download from https://community.hitachivantara.com/s/article/downloads