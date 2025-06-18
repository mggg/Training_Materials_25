# Running batches of simulations: Cheat sheet

## Use cases

### I want to hard-code knob values and run a single simple election. 

Open the notebook `simple_run_election.ipynb` in `Single_runs`, modify the values and run all the cells.

### I want to run a single election by passing in the knob values using the console/terminal.

Create a settings file by following the example in `vk_run_settings_example.json`. You can now use the `votekit_cli_single.py` Python file. Run it using `python votekit_cli_single.py <your arguments here>`. If you need to be reminded of what arguments you need, you can run `python votekit_cli_single.py --help`.

### I want to simulate a lot of elections under different knob values.

Edit the Python file `vk_generate_settings_files.py` in `Parallel_runs` and run it to create multiple settings files in the `vk_run_settings` folder.

Then, run `votekit_parallel.py` from the console/terminal, which will pull from the settings files you just created and store the results. The code will use multiple cores at once if your laptop has them.

### I want to run a large number of simulations in a robust way using a bash script.

This is somewhat advanced. Go and check out the `Massively_Parallel_Runs` folder to find the scripts you will need.

## Which knobs go where?

### In settings files:

Voter group proportions, cohesion parameters, alphas, candidate names and their slates.

### In the Python file you are running:

Type of ballot generator model, number of seats (magnitude), number of voters, election method, number of iterations per settings file.

