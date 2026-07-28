import os
from pathlib import Path
from dotenv import load_dotenv
from databricks.sdk import WorkspaceClient

# Load DATABRICKS_HOST and DATABRICKS_TOKEN from .env into environment variables
load_dotenv()

RAW_DATA_DIR = Path("ingestion/raw_data")
VOLUME_PATH = "/Volumes/adventureworks/bronze/source_files"

def main():
    # WorkspaceClient automatically picks up DATABRICKS_HOST / DATABRICKS_TOKEN
    # from environment variables — no need to pass them manually
    w = WorkspaceClient()

    parquet_files = sorted(RAW_DATA_DIR.glob("*.parquet"))
    print(f"Uploading {len(parquet_files)} files to {VOLUME_PATH}...\n")

    for file_path in parquet_files:
        remote_path = f"{VOLUME_PATH}/{file_path.name}"

        with open(file_path, "rb") as f:
            w.files.upload(remote_path, f, overwrite=True)

        print(f"  Uploaded: {file_path.name} -> {remote_path}")

    print("\nUpload complete.")

if __name__ == "__main__":
    main()