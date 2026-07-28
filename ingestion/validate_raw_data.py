import pandas as pd
from pathlib import Path
import json

RAW_DATA_DIR = Path("ingestion/raw_data")

# Grain columns per fact table — used to check for duplicates
GRAIN_COLUMNS = {
    "factinternetsales": ["SalesOrderNumber", "SalesOrderLineNumber"],
    "factresellersales": ["SalesOrderNumber", "SalesOrderLineNumber"],
    "factinternetsalesreason": ["SalesOrderNumber", "SalesOrderLineNumber", "SalesReasonKey"],
}

def validate_table(file_path: Path) -> dict:
    df = pd.read_parquet(file_path)
    table_key = file_path.stem  # e.g. "dimcustomer"

    report = {
        "table": table_key,
        "row_count": len(df),
        "column_count": len(df.columns),
        "null_counts": {
            col: int(df[col].isnull().sum())
            for col in df.columns
            if df[col].isnull().sum() > 0
        },
        "duplicate_grain_rows": None,
    }

    # Only check grain uniqueness for fact tables we've defined a grain for
    if table_key in GRAIN_COLUMNS:
        grain_cols = GRAIN_COLUMNS[table_key]
        dup_count = df.duplicated(subset=grain_cols).sum()
        report["duplicate_grain_rows"] = int(dup_count)
        report["grain_columns_checked"] = grain_cols

    return report

def main():
    parquet_files = sorted(RAW_DATA_DIR.glob("*.parquet"))
    all_reports = []

    print(f"Validating {len(parquet_files)} tables...\n")

    for file_path in parquet_files:
        report = validate_table(file_path)
        all_reports.append(report)

        print(f"  {report['table']}: {report['row_count']:,} rows, {report['column_count']} columns")
        if report["null_counts"]:
            print(f"    Nulls found: {report['null_counts']}")
        else:
            print(f"    No nulls in any column")
        if report["duplicate_grain_rows"] is not None:
            status = "OK" if report["duplicate_grain_rows"] == 0 else "WARNING"
            print(f"    Grain uniqueness ({status}): {report['duplicate_grain_rows']} duplicate rows on {report['grain_columns_checked']}")
        print()

    # Save full report as JSON for later reference (e.g. in docs/)
    output_path = Path("ingestion/validation_report.json")
    with open(output_path, "w") as f:
        json.dump(all_reports, f, indent=2)

    print(f"Full validation report saved to {output_path}")

if __name__ == "__main__":
    main()