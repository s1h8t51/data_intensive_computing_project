#!/bin/bash
set -e

# Define the NameNode data directory
NAMENODE_DIR="/opt/hadoop/data/nameNode"

# Check if the NameNode has already been formatted
if [ ! -d "$NAMENODE_DIR/current" ]; then
    echo "==================================================="
    echo "🚀 Formatting NameNode as no existing metadata found."
    echo "==================================================="
    hdfs namenode -format
else
    echo "✅ NameNode already formatted. Skipping format step."
fi

# Start the NameNode service
echo "======================================="
echo "🔧 Starting HDFS NameNode Service..."
echo "======================================="
hdfs namenode