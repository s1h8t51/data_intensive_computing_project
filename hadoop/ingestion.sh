#!/bin/bash

# --- User-defined variables ---
# Define the Kaggle dataset slug (found in the dataset URL)
KAGGLE_DATASET_SLUG="asaniczka/1-3m-linkedin-jobs-and-skills-2024"
# A short, simple name for the dataset
DATASET_SHORT="linkedin-jobs-and-skills-2024"
# The target path in HDFS where the data will be stored
HDFS_TARGET_PATH="/user/data/${DATASET_SHORT}"
# A temporary directory on the local machine (inside the Docker container) for the download
TEMP_DOWNLOAD_DIR="/tmp/kaggle_data"

# --- Script starts here ---
echo "Starting data ingestion script..."

## 1. Install necessary packages for a CentOS-based system
echo "Installing Python, pip, and Kaggle API using yum..."
yum install -y python3 python3-pip unzip

# Install Kaggle API using pip3
pip3 install kaggle

# 2. Fix 'kaggle: command not found' error by updating the PATH
# The kaggle executable is often installed in the local user's bin directory.
# This ensures the shell can find and execute the kaggle command.
KAGGLE_BIN_PATH=$(python3 -m site --user-base)/bin
export PATH="$PATH:$KAGGLE_BIN_PATH"

echo "Updated PATH to include Kaggle executable at: ${KAGGLE_BIN_PATH}"

## 3. Check for Kaggle credentials
echo "Checking for Kaggle credentials..."
# Your provided script has the path as /root/.kaggle. 
KAGGLE_CONFIG_DIR_PATH="/root/.kaggle"
if [ ! -f "${KAGGLE_CONFIG_DIR_PATH}/kaggle.json" ]; then
  echo "Error: kaggle.json not found at ${KAGGLE_CONFIG_DIR_PATH}. Please ensure your credentials are mounted correctly."
  exit 1
fi
chmod 600 "${KAGGLE_CONFIG_DIR_PATH}/kaggle.json"

echo "Good so far"
exit 0 
## 4. Download the dataset
echo "Downloading dataset: ${KAGGLE_DATASET_SLUG} to ${TEMP_DOWNLOAD_DIR}..."
mkdir -p "${TEMP_DOWNLOAD_DIR}"
kaggle datasets download -d "${KAGGLE_DATASET_SLUG}" --unzip -p "${TEMP_DOWNLOAD_DIR}"

if [ $? -ne 0 ]; then
  echo "Error: Kaggle download failed. Check dataset slug or credentials."
  exit 1
fi

## 5. Check and create HDFS directory
echo "Checking for and creating HDFS directory..."
if ! hdfs dfs -test -d "${HDFS_TARGET_PATH}"; then
  echo "Creating HDFS directory: ${HDFS_TARGET_PATH}"
  hdfs dfs -mkdir -p "${HDFS_TARGET_PATH}"
else
  echo "HDFS directory '${HDFS_TARGET_PATH}' already exists. Skipping creation."
fi

## 6. Upload data to HDFS
echo "Uploading data from ${TEMP_DOWNLOAD_DIR} to HDFS at ${HDFS_TARGET_PATH}..."
hdfs dfs -put "${TEMP_DOWNLOAD_DIR}/"*.csv "${HDFS_TARGET_PATH}"

## 7. Verify and clean up
echo "Verifying data upload by listing files in HDFS:"
hdfs dfs -ls "${HDFS_TARGET_PATH}"

echo "Cleaning up temporary local files..."
rm -rf "${TEMP_DOWNLOAD_DIR}"

echo "Data ingestion complete. The data is now available in HDFS at ${HDFS_TARGET_PATH}."