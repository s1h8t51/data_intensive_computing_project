$HadoopContainerName = "namenode"
$KaggleDatasetSlug = "asaniczka/1-3m-linkedin-jobs-and-skills-2024"
$HdfsTargetPath = "/user/data/linkedin-jobs-and-skills-2024"

$TempDownloadDir = "$PSScriptRoot\dataset"

Write-Host "Starting data ingestion process..."

Write-Host "Checking for existing dataset..."
$CsvFiles = Get-ChildItem -Path $TempDownloadDir -Filter "*.csv"

if ($CsvFiles.Count -gt 0) {
    Write-Host "Dataset already exists at $($TempDownloadDir). Skipping download."
} else {
    Write-Host "Dataset not found. Downloading from Kaggle to local machine..."
    if (-not (Test-Path $TempDownloadDir)) {
        New-Item -ItemType Directory -Path $TempDownloadDir -Force
    }

    kaggle datasets download -d $KaggleDatasetSlug --unzip -p $TempDownloadDir

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Kaggle download failed. Check dataset slug or credentials."
        exit
    }
    Write-Host "Dataset downloaded and unzipped successfully."

    $CsvFiles = Get-ChildItem -Path $TempDownloadDir -Filter "*.csv"
}

if ($CsvFiles.Count -eq 0) {
    Write-Host "Error: No CSV files found in the downloaded directory."
    exit
}

Write-Host "Ingesting all CSV files into HDFS..."
Write-Host "Checking for and creating HDFS directory..."
$HdfsDirCheckCommand = "hdfs dfs -test -d $HdfsTargetPath || hdfs dfs -mkdir -p $HdfsTargetPath"
docker exec $HadoopContainerName bash -c "$HdfsDirCheckCommand"

foreach ($file in $CsvFiles) {
    $DockerTempPath = "/tmp/$($file.Name)"

    Write-Host "Copying $($file.Name) to Docker container: $($HadoopContainerName)"
    docker cp "$($file.FullName)" "$($HadoopContainerName):$($DockerTempPath)"

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to copy $($file.Name) to Docker container."
        continue
    }
    
    Write-Host "Uploading $($file.Name) to HDFS..."
    $HadoopPutCommand = "hdfs dfs -put -f $($DockerTempPath) $($HdfsTargetPath)"
    docker exec $HadoopContainerName bash -c "$HadoopPutCommand"

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to upload $($file.Name) to HDFS."
    }
    
    Write-Host "Cleaning up temporary file inside the container..."
    docker exec $HadoopContainerName bash -c "rm -f $($DockerTempPath)"
}

Write-Host "Listing files in HDFS to verify upload:"
$HdfsLsCommand = "hdfs dfs -ls $HdfsTargetPath"
docker exec $HadoopContainerName bash -c "$HdfsLsCommand"

Write-Host "Cleaning up temporary local files..."
Remove-Item -Path $TempDownloadDir -Recurse -Force

Write-Host "Data ingestion complete. All files are now available in HDFS at $HdfsTargetPath."