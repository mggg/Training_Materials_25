#!/usr/bin/env bash


# Here we assign the parameters that we would like to use to variables.
# Note that in bash, there can be no space between the variable name and the
# assignment operator. Also, the variable name cannot contain any special
# characters, such as hyphens or spaces.
num_voters=1000
num_seats=3
num_iterations=10

ballot_generator="slate_pl"
election_type="stv"
ballot_generator_kwargs_settings_file="./vk_run_settings/wc_(0p1_0p9)_cohesion_(0p7_0p3_0p7_0p3).json"

# A helpful way to split the string so that we can get the settings out to make well-named
# results files
settings_base=$(basename "$ballot_generator_kwargs_settings_file" .json)


outputs_base_string="${election_type}_${ballot_generator}_voters_${num_voters}_seats_${num_seats}_iterations_${num_iterations}_${settings_base}"

log_file="./logs/${outputs_base_string}.log"
output_file="./outputs/${outputs_base_string}.jsonl"
results_file="./results/${outputs_base_string}.jsonl"

# Here we are invoking the cli that we set up in our python
# file. Fortunately, since we designed it as a wrapper around the base
# function, the syntax will feel very familiar.
python votekit_cli_many.py \
    --ballot-generator $ballot_generator \
    --num-voters $num_voters \
    --num-seats $num_seats \
    --election-type $election_type \
    --ballot-generator-kwargs-settings-file $ballot_generator_kwargs_settings_file \
    --num-iterations $num_iterations \
    --output-file $results_file \
    > $output_file 2> $log_file