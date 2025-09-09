# model_convergence.py

```python title="Setup the experiment"
# Compared to just using print(...), we can automatically report the timestamp
# when we output !
def setup_logging(args):
    logging.basicConfig(
        filename=log_file,
        level=logging.INFO,
        format="(%(asctime)s)[%(levelname)s]: %(message)s",
    )

def parse_args():
    import argparse

    parser = argparse.ArgumentParser(description="Experimental Pipeline")
    parser.add_argument(
        "-i", "--input", type=Path, required=True, help="Path to training data"
    )
    parser.add_argument(
        "-o", "--output", type=Path, required=True, help="Output folder"
    )
    parser.add_argument("--force", action="store_true", help="Prevent reloading existing data")
    args = parser.parse_args()

    if not args.input.exists():
        parser.error(f"Input path {args.input} does not exist.")
    
    if not args.output.exists():
        args.output.mkdir(parents=True, exist_ok=True)

    return parser.parse_args()

if __name__ == "__main__":
    args = parse_args()
    setup_logging(args)
    main(args)
```


```python title="Main with optional reloading"
def main(args):
    # Try to reload the data first
    logging.info("Starting experimental pipeline")
    if not args.force and not args.output / "raw/results.csv".exists():
        logging.info("Running experiment")
        results = run_experiment(args)
        logging.info("Experiment completed and results saved")
    else:
        logging.info("Loading existing results")
        results = pd.read_csv(args.output / "raw/results.csv")

    plot(results)
```


```python title="Data collection"
def run_experiment(args):
    data = pd.read_csv(args.input)

    train_x, test_x, train_y, test_y = train_test_split(
        data.drop(columns=["target"]), data["target"], test_size=0.2, random_state=42
    )
    results = []
    output_path = args.output / "raw/results.csv"

    for perc in np.linspace(0.1, 1.0, 10):
        sample_size = int(len(train_x) * perc)
        sample_indices = np.random.choice(len(train_x), size=sample_size, replace=False)

        X = train_x.iloc[sample_indices].copy()
        y = train_y.iloc[sample_indices]

        model = LGBMRegressor()
        model.fit(X, y)

        preds = model.predict(test_x)
        mse = mean_squared_error(test_y, preds)

        results.append((int(perc * len(data)), mse))
        # We dump to file regularly so that we won't lose data if the script crashes
        res = pd.DataFrame(results, columns=["nsamples", "mse"])
        res.to_csv(output_path)
    return res
```

```python title="Plotting"
def plot(args, results):

    fig, ax = plt.subplots(figsize=(10, 6))
    sns.lineplot(data=results, x="nsamples", y="mse", marker="o", ax=ax)
    ax.set_title("Evolution of MSE with the number of training samples")

    ax.set_xlabel("Number of Training Samples Used")
    ax.set_xticks(
        np.linspace(results["nsamples"].min()),
            results["nsamples"].max()
            10
    )

    ax.set_ylabel("Mean Squared Error (MSE)")
    ax.set_yticks(
        np.linspace(results["mse"].min()),
            results["mse"].max()
            10
    )
    ax.grid("y")

    ax.margins(0)
    output_dir = args.output / "results"
    output_dir.mkdir(parents=True, exist_ok=True)
    fig.savefig(output_dir / "results_plot.png")
    plt.close()
```