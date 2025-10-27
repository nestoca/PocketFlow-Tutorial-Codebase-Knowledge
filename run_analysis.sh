#!/bin/bash

# Shell script to analyze the local corebanking repository
# using YAML configuration file

echo "Starting corebanking tutorial generation..."
source .venv/bin/activate

# Validate configuration before running
echo "Validating configuration..."
python main.py "$1" --validate-only

if [ $? -eq 0 ]; then
    echo "Configuration is valid. Running analysis..."
    python main.py "$1"
else
    echo "Configuration validation failed. Please check the config file."
    exit 1
fi

echo "Done" 