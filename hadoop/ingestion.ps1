# --- User-defined variables ---
# Name of your Hadoop Docker container
$HadoopContainerName = "namenode"
# The Kaggle dataset slug
$KaggleDatasetSlug = "asaniczka/1-3m-linkedin-jobs-and-skills-2024"
# The target path in HDFS
$HdfsTargetPath = "/user/data/linkedin-jobs-and-skills-2024"

# The temporary local directory for the download
$TempDownloadDir = "$PSScriptRoot\dataset"

# --- Script starts here ---
Write-Host "Starting data ingestion process..."

## 1. Check for and Download the Dataset
Write-Host "Checking for existing dataset..."
# Find all unzipped CSV files in the temporary directory
$CsvFiles = Get-ChildItem -Path $TempDownloadDir -Filter "*.csv"

if ($CsvFiles.Count -gt 0) {
    Write-Host "Dataset already exists at $($TempDownloadDir). Skipping download."
} else {
    Write-Host "Dataset not found. Downloading from Kaggle to local machine..."
    # Ensure the temporary directory exists
    if (-not (Test-Path $TempDownloadDir)) {
        New-Item -ItemType Directory -Path $TempDownloadDir -Force
    }

    # The Kaggle CLI download command
    kaggle datasets download -d $KaggleDatasetSlug --unzip -p $TempDownloadDir

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Kaggle download failed. Check dataset slug or credentials."
        exit
    }
    Write-Host "Dataset downloaded and unzipped successfully."

    # Re-find the newly downloaded CSV files
    $CsvFiles = Get-ChildItem -Path $TempDownloadDir -Filter "*.csv"
}

if ($CsvFiles.Count -eq 0) {
    Write-Host "Error: No CSV files found in the downloaded directory."
    exit
}

## 2. Ingest all CSVs into HDFS
Write-Host "Ingesting all CSV files into HDFS..."
# Check and create the HDFS target directory once
Write-Host "Checking for and creating HDFS directory..."
$HdfsDirCheckCommand = "hdfs dfs -test -d $HdfsTargetPath || hdfs dfs -mkdir -p $HdfsTargetPath"
docker exec $HadoopContainerName bash -c "$HdfsDirCheckCommand"

# Loop through each CSV file and upload it to HDFS
foreach ($file in $CsvFiles) {
    # Define the temporary destination path inside the Docker container
    # The filename is preserved inside the container's /tmp directory
    $DockerTempPath = "/tmp/$($file.Name)"

    Write-Host "Copying $($file.Name) to Docker container: $($HadoopContainerName)"
    docker cp "$($file.FullName)" "$($HadoopContainerName):$($DockerTempPath)"

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to copy $($file.Name) to Docker container."
        continue # Skip to the next file
    }
    
    Write-Host "Uploading $($file.Name) to HDFS..."
    # Execute commands inside the Docker container to move data to HDFS
    $HadoopPutCommand = "hdfs dfs -put -f $($DockerTempPath) $($HdfsTargetPath)"
    docker exec $HadoopContainerName bash -c "$HadoopPutCommand"

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to upload $($file.Name) to HDFS."
    }
    
    # Clean up the temporary file inside the container
    Write-Host "Cleaning up temporary file inside the container..."
    docker exec $HadoopContainerName bash -c "rm -f $($DockerTempPath)"
}

## 3. Final Verification and Cleanup
Write-Host "Listing files in HDFS to verify upload:"
$HdfsLsCommand = "hdfs dfs -ls $HdfsTargetPath"
docker exec $HadoopContainerName bash -c "$HdfsLsCommand"

Write-Host "Cleaning up temporary local files..."
Remove-Item -Path $TempDownloadDir -Recurse -Force

Write-Host "Data ingestion complete. All files are now available in HDFS at $HdfsTargetPath."