import pandas as pd
from sqlalchemy import create_engine
from pathlib import Path
import urllib.parse

# --- Configuration ---
DRIVER = "ODBC Driver 18 for SQL Server"
SERVER = "localhost"
DATABASE = "AdventureWorksDW2025"

# Build the ODBC connection string, then wrap it for SQLAlchemy
odbc_str = (
    f"DRIVER={{{DRIVER}}};"
    f"SERVER={SERVER};"
    f"DATABASE={DATABASE};"
    f"Trusted_Connection=yes;"
    f"TrustServerCertificate=yes;"
)
params = urllib.parse.quote_plus(odbc_str)
engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")

OUTPUT_DIR = Path("ingestion/raw_data")

TABLES = [
    "DimCustomer",
    "DimDate",
    "DimGeography",
    "DimProduct",
    "DimProductCategory",
    "DimProductSubcategory",
    "DimPromotion",
    "DimSalesTerritory",
    "DimReseller",
    "DimSalesReason",
    "FactInternetSales",
    "FactResellerSales",
    "FactInternetSalesReason",
]

def extract_table(engine, table_name: str) -> pd.DataFrame:
    query = f"SELECT * FROM dbo.{table_name}"
    df = pd.read_sql(query, engine)
    return df

def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    print(f"Starting extraction of {len(TABLES)} tables...\n")

    for table_name in TABLES:
        df = extract_table(engine, table_name)
        output_path = OUTPUT_DIR / f"{table_name.lower()}.parquet"
        df.to_parquet(output_path, index=False)
        print(f"  {table_name}: {len(df):,} rows -> {output_path.name}")

    print("\nExtraction complete.")

if __name__ == "__main__":
    main()