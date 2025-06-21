#!/bin/bash

# Shell script to analyze the local corebanking repository
# with specific abstraction hints and feedback from previous analysis

echo "Starting corebanking tutorial generation..."

python main.py \
    --dir "/Users/louis-davidcoulombe/github/corebanking" \
    --name "corebanking" \
    --output "nesto/corebanking/analysis_output" \
    --abstractions-hints \
        "Event" \
        "Command" \
        "Aggregate" \
        "Repository" \
        "API Handler" \
        "Core Facade" \
        "Service" \
        "Consumer" \
        "Product Engine" \
        "Simulation Services and Repositories" \
        "products" \
        "parameters" \
        "customers" \
    --feedback "nesto/corebanking/review.md" \
    --language "english" \
    --max-size 150000

echo "Corebanking analysis completed!" 