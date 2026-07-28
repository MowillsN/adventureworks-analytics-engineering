USE CATALOG adventureworks;

CREATE TABLE IF NOT EXISTS bronze.dimcustomer AS
SELECT * FROM parquet.`/Volumes/adventureworks/bronze/source_files/dimcustomer.parquet`;

CREATE TABLE IF NOT EXISTS bronze.dimdate AS
SELECT * FROM parquet.`/Volumes/adventureworks/bronze/source_files/dimdate.parquet`;

CREATE TABLE IF NOT EXISTS bronze.dimgeography AS
SELECT * FROM parquet.`/Volumes/adventureworks/bronze/source_files/dimgeography.parquet`;

CREATE TABLE IF NOT EXISTS bronze.dimproduct AS
SELECT * FROM parquet.`/Volumes/adventureworks/bronze/source_files/dimproduct.parquet`;

CREATE TABLE IF NOT EXISTS bronze.dimproductcategory AS
SELECT * FROM parquet.`/Volumes/adventureworks/bronze/source_files/dimproductcategory.parquet`;

CREATE TABLE IF NOT EXISTS bronze.dimproductsubcategory AS
SELECT * FROM parquet.`/Volumes/adventureworks/bronze/source_files/dimproductsubcategory.parquet`;

CREATE TABLE IF NOT EXISTS bronze.dimpromotion AS
SELECT * FROM parquet.`/Volumes/adventureworks/bronze/source_files/dimpromotion.parquet`;

CREATE TABLE IF NOT EXISTS bronze.dimreseller AS
SELECT * FROM parquet.`/Volumes/adventureworks/bronze/source_files/dimreseller.parquet`;

CREATE TABLE IF NOT EXISTS bronze.dimsalesreason AS
SELECT * FROM parquet.`/Volumes/adventureworks/bronze/source_files/dimsalesreason.parquet`;

CREATE TABLE IF NOT EXISTS bronze.dimsalesterritory AS
SELECT * FROM parquet.`/Volumes/adventureworks/bronze/source_files/dimsalesterritory.parquet`;

CREATE TABLE IF NOT EXISTS bronze.factinternetsales AS
SELECT * FROM parquet.`/Volumes/adventureworks/bronze/source_files/factinternetsales.parquet`;

CREATE TABLE IF NOT EXISTS bronze.factinternetsalesreason AS
SELECT * FROM parquet.`/Volumes/adventureworks/bronze/source_files/factinternetsalesreason.parquet`;

CREATE TABLE IF NOT EXISTS bronze.factresellersales AS
SELECT * FROM parquet.`/Volumes/adventureworks/bronze/source_files/factresellersales.parquet`;