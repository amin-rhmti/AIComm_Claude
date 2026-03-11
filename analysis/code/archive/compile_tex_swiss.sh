#!/bin/bash

# Resolve absolute path to the directory containing this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Navigate to swiss_insta_experiment relative to script location
cd "$SCRIPT_DIR/../../analysis/output/swiss_insta_experiment" || {
    echo "Target directory not found. Exiting."
    exit 1
}

for folder in "sample2_standardized"  "sample3_standardized"  "sample4_standardized" ; do

    for subfolder in "post" ; do

        cd ${folder}/${subfolder}
    
        # Process all .tex files in the current directory
        for j in *.tex; do

            pdflatex "$j"

        done

        for j in *.aux *.log *.tex; do
            rm ${j}
        done

        cd ../..

    done
done 