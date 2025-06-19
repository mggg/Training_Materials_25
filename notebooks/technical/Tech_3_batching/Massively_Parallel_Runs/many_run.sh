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


# Here we assign the parameters that we would like to use to variables.
# Note that in bash, there can be no space between the variable name and the
# assignment operator. Also, the variable name cannot contain any special
# characters, such as hyphens or spaces.
num_voters=1000
num_seats=3
num_iterations=10

# A nice little counter to keep track of how many jobs we have kicked off.
current_job=0

for ballot_generator in "slate_pl" "slate_bt" "cambridge"
do
for election_type in "stv" "borda" "plurality"
do
for settings_file in $(find ./vk_run_settings/ -type f -name "*.json")
do
    # Small bash quirk: arithmetic operations are a bit weird.
    # This just increments the current job counter by 1.
    ((current_job++))

    # A helpful way to split the string so that we can get the settings out to make well-named
    # results files
    settings_base=$(basename "$settings_file" .json)

    outputs_base_string="${election_type}_${ballot_generator}_voters_${num_voters}_seats_${num_seats}_iterations_${num_iterations}_${settings_base}"

    log_file="./logs/${outputs_base_string}.log"
    output_file="./outputs/${outputs_base_string}.jsonl"
    results_file="./results/${outputs_base_string}.jsonl"

    # This is like print in bash
    echo "Running job no. ${current_job}: ${outputs_base_string}"

    # Here we are invoking the cli that we set up in our python
    # file. Fortunately, since we designed it as a wrapper around the base
    # function, the syntax will feel very familiar.
    python votekit_cli_many.py \
        --ballot-generator $ballot_generator \
        --num-voters $num_voters \
        --num-seats $num_seats \
        --election-type $election_type \
        --ballot-generator-kwargs-settings-file $settings_file \
        --num-iterations $num_iterations \
        --output-file $results_file \
        > $output_file 2> $log_file &


    # Check if the number of background jobs is less than MAX_JOBS
    while [ $(jobs -r | wc -l) -ge $MAX_JOBS ]; do
        sleep 1  # Wait for a second before checking again
    done
done
done
done


wait  # Wait for all background jobs to finish
echo "All jobs completed."