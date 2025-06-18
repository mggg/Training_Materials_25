#!/usr/bin/env bash


MAX_JOBS=10


# Here we assign the parameters that we would like to use to variables.
# Note that in bash, there can be no space between the variable name and the
# assignment operator. Also, the variable name cannot contain any special
# characters, such as hyphens or spaces.
num_voters=1000
num_seats=3
num_iterations=10

current_job=0

for ballot_generator in "slate_pl" "slate_bt" "cambridge"
do
for election_type in "stv" "borda" "plurality"
do
for settings_file in $(find ./vk_run_settings/ -type f -name "*.json")
do
    ((current_job++))

    # A helpful way to split the string so that we can get the settings out to make well-named
    # results files
    settings_base=$(basename "$settings_file" .json)

    outputs_base_string="${election_type}_${ballot_generator}_voters_${num_voters}_seats_${num_seats}_iterations_${num_iterations}_${settings_base}"

    log_file="./logs/${outputs_base_string}.log"
    output_file="./outputs/${outputs_base_string}.jsonl"
    results_file="./results/${outputs_base_string}.jsonl"

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