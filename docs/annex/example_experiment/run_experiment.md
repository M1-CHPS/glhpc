# run_experiment.sh

This Bash script will run an experiment and perform logging:

```bash title="Argument parsing"
#!/bin/bash

# We enable these flags so that
# The script stops on error
set -e
set -o pipefail

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input data> <output_dir>"
    exit 1
fi

INPUT_DATA=$1
OUTPUT_DIR=$2
mkdir -p "$OUTPUT_DIR"
```


```bash title="Main experiment block"
# We run the experiment inside a subshell so that we can log everything through tee
(
    echo "Seeding environment..."
    source ./setup_env.sh

    # We collect information about the system and dump them to the the output folder
    # This acts as a "label" for the run
    echo "Collecting system information..."
    cp /proc/cpuinfo "$OUTPUT_DIR/cpuinfo.txt"
    timestamp >> "$OUTPUT_DIR/timestamp.txt"
    uname -a >> "$OUTPUT_DIR/uname.txt"
    echo $(python3 --version) > "$OUTPUT_DIR/python_version.txt"
    echo $(pip freeze) > "$OUTPUT_DIR/requirements.txt"

    echo "Running experiment..."
    python3 run_experiment.py -i "$INPUT_DATA" -o "$OUTPUT_DIR/results"

) 2>&1 | tee "$OUTPUT_DIR/raw_logs.log"
```