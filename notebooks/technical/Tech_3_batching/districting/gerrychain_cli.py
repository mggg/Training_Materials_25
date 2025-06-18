import click
from functools import partial
import jsonlines
from gerrychain import Graph, MarkovChain, Partition
from gerrychain.accept import always_accept
from gerrychain.updaters import Tally
from gerrychain.proposals import recom
import networkx as nx
import os
import random
from typing import Optional


def run_chain(
    graph_file: str,
    n_districts: int,
    n_iterations: int,
    population_attr: str,
    epsilon: float,
    rng_seed: int,
    output_file: str,
    target_population: Optional[float] = None,
    initial_assignment_attr: Optional[str] = None,
):

    random.seed(rng_seed)

    # Need this to be set for reproducibility
    assert os.environ["PYTHONHASHSEED"] == "0"

    # Load the graph for GerryChain
    graph = Graph.from_json(graph_file)

    # Quick trick to make sure that if the node labels are not integers, then
    # they are converted to integers starting from 0 so that saving to a JSONL
    # file works correctly every time.
    graph = Graph.from_networkx(
        nx.convert_node_labels_to_integers(graph, first_label=0)
    )

    updaters = {
        "population": Tally(population_attr, alias="population"),
    }

    # Create an initial partition
    if initial_assignment_attr is not None:
        initial_partition = Partition(
            graph=graph,
            assignment=initial_assignment_attr,
            updaters=updaters,
        )
    else:
        initial_partition = Partition.from_random_assignment(
            graph=graph,
            n_parts=n_districts,
            epsilon=epsilon,
            pop_col=population_attr,
            updaters=updaters,
        )

    if target_population is None:
        target_population = sum(initial_partition["population"].values()) / n_districts

    recom_proposal = partial(
        recom,
        pop_col=population_attr,
        pop_target=target_population,
        epsilon=epsilon,
    )

    # Crete the Markov chain
    chain = MarkovChain(
        proposal=recom_proposal,
        constraints=[],
        accept=always_accept,
        initial_state=initial_partition,
        total_steps=n_iterations,
    )

    with jsonlines.open(output_file, "w") as writer:
        for i, step in enumerate(chain):
            if step is None:
                return

            writer.write(
                {
                    "assignment": list(step.assignment.to_series().sort_index()),
                    "sample:": i + 1,
                }
            )


@click.command()
@click.option(
    "--graph-file",
    type=click.Path(exists=True),
    required=True,
    help="Path to the graph file.",
)
@click.option(
    "--n-districts", type=int, required=True, help="Number of districts to create."
)
@click.option(
    "--n-iterations",
    type=int,
    default=1000,
    help="Number of iterations for the Markov chain.",
)
@click.option(
    "--population-attr",
    type=str,
    default="population",
    help="Population attribute for the nodes.",
)
@click.option(
    "--target-population", type=float, help="Target population for each district."
)
@click.option(
    "--epsilon", type=float, default=0.01, help="Epsilon value for the Markov chain."
)
@click.option(
    "--rng-seed", type=int, default=42, help="Random seed for reproducibility."
)
@click.option(
    "--output-file", type=click.Path(), required=True, help="Path to save the output."
)
@click.option(
    "--initial_assignment_attr",
    type=str,
    default=None,
    help="Initial assignment attribute for the nodes.",
)
def run_chain_cli(
    graph_file: str,
    n_districts: int,
    n_iterations: int,
    population_attr: str,
    target_population: float,
    epsilon: float,
    rng_seed: int,
    output_file: str,
    initial_assignment_attr: Optional[str] = None,
):
    run_chain(
        graph_file=graph_file,
        n_districts=n_districts,
        n_iterations=n_iterations,
        population_attr=population_attr,
        target_population=target_population,
        epsilon=epsilon,
        rng_seed=rng_seed,
        output_file=output_file,
        initial_assignment_attr=initial_assignment_attr,
    )


if __name__ == "__main__":
    run_chain_cli()
