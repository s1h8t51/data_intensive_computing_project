#!/bin/bash
set -euo pipefail

DATANODE_DIR="/opt/hadoop/data/dataNode"
echo "======================================="
echo "DataNode init script"
echo "======================================="

# Create the data dir if missing, preserve contents if present
if [ ! -d "$DATANODE_DIR" ]; then
    echo "📁 Creating DataNode directory: $DATANODE_DIR"
    mkdir -p "$DATANODE_DIR"
else
    echo "ℹ️ DataNode directory exists. Not removing data. ($DATANODE_DIR)"
fi

# Set ownership and permissions (adjust user:group to match your container)
chown -R hadoop:hadoop "$DATANODE_DIR" || true
chmod 755 "$DATANODE_DIR" || true

echo "======================================="
echo "🚀 Starting HDFS DataNode..."
echo "======================================="
exec hdfs datanode
