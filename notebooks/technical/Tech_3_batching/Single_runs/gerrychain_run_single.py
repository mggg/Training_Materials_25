from gerrychain_cli import run_chain
from pathlib import Path


def run_single_chain():
    graph_file = Path("../../../../data/gerrymandria.json").resolve()

    output_dir = Path("../chain_out").resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    run_chain(
        graph_file=str(graph_file),
        n_districts=4,
        n_iterations=100,
        population_attr="TOTPOP",
        epsilon=0.00001,
        rng_seed=42,
        output_file=str(output_dir / "test_single.json"),
    )


if __name__ == "__main__":
    run_single_chain()
