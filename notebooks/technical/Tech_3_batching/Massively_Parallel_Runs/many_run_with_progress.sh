#!/usr/bin/env bash

# Trap Ctrl-C and kill all background jobs
trap 'echo .; echo "Keyboard interrupt detected. Exiting..."; kill 0; exit 1;' SIGINT

NCPUS=$(nproc)  # Get the number of available CPU cores

# We want to control the number of jobs that we run in parallel so that we 
# don't overwhelm our system.
# I will limit the number of jobs to a maximum of 10, but you can change this
# to whatever you would prefer. I also try to leave a couple of cores free so
# that I don't accidentally lock up the system.
if [ "$NCPUS" -le 2 ]; then
    MAX_JOBS=1
elif [ "$NCPUS" -gt 11 ]; then
    MAX_JOBS=10
else
    MAX_JOBS=$((NCPUS - 2))
fi

MAX_JOBS=10

num_voters=1000
num_seats=3
num_iterations=10

# Prepare the list of jobs first
jobs_list=()

for ballot_generator in "slate_pl" "slate_bt" "cambridge"; do
for election_type in "stv" "borda" "plurality"; do
for settings_file in $(find ./vk_run_settings/ -type f -name "*.json"); do
    jobs_list+=("$ballot_generator|$election_type|$settings_file")
done
done
done

total_jobs=${#jobs_list[@]}
current_job=0

# Function to run a single job
run_job() {
    # Split the input string into components using the '|' character as a delimieter
    IFS='|' read -r ballot_generator election_type settings_file <<< "$1"

    settings_base=$(basename "$settings_file" .json)
    outputs_base_string="${election_type}_${ballot_generator}_voters_${num_voters}_seats_${num_seats}_iterations_${num_iterations}_${settings_base}"

    log_file="./logs/${outputs_base_string}.log"
    output_file="./outputs/${outputs_base_string}.jsonl"
    results_file="./results/${outputs_base_string}.jsonl"

    python votekit_cli_many.py \
        --ballot-generator "$ballot_generator" \
        --num-voters "$num_voters" \
        --num-seats "$num_seats" \
        --election-type "$election_type" \
        --ballot-generator-kwargs-settings-file "$settings_file" \
        --num-iterations "$num_iterations" \
        --output-file "$results_file" \
        > "$output_file" 2> "$log_file"
}

for job in "${jobs_list[@]}"; do
    ((current_job++))
    printf "\rCurrent job count: %d/%d" "$current_job" "$total_jobs"

    run_job "$job" &

    # Wait if the number of background jobs reaches the limit
    while [ "$(jobs -rp | wc -l)" -ge "$MAX_JOBS" ]; do
        sleep 0.5
    done
done

wait
echo
echo "All ${total_jobs} jobs completed."
