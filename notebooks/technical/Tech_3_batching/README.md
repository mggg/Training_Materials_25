# Running Elections with Votekit

In this tutorial, we will be going through a few different ways of running elections using
VoteKit. We will start with the very basics of loading a preference profile and feeding it to
an election constructor in something like a jupyter notebook. We will then move on to scaling
the runner into a python script that allows for a parameter sweep over the variables of
interest. In more detail, we will cover the following


Time to get every one set up: 10 min

## Single Election runs

- Running a single election in VoteKit (3 min)
- Running a simple instance of GerryChain and writing to a file (5 min -- script provided)
- Collecting demographic data with GerryChian (5 min -- script provided)
- Incorporating GerryChain runs into election runs (10 min)


## Parallel Runs with Joblib (Getting around the GIL)

- Making a lot of sample plans with GerryChain and Joblib (5 min)
    - Requires multiple seed plans and multiple random seeds
    - Don't forget PYTHONHASHSEED
- Running several elections at once using Joblib (5 min)
    - Making good output files

<!-- OUR GOAL IS TO GET TO HERE -->

## Creating a robust job suite with CLIs

- Making a CLI with click (5 min)
- Using python subprocess or bash scripts (10 min)
    - Log and Err files
    - Auditing with grep or VSCode Search
- Project structure: How do you keep 10s of thousands of files straight? (5 min)

