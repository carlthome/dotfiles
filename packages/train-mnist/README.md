# Train MNIST

## Usage

```sh
# Create a virtual Python environment.
python -m venv .venv
source .venv/bin/activate

# Install the package in development mode.
pip install -e .

# Train the model.
mnist train

# Predict with the trained model in the working directory.
mnist predict --image=example.png --invert
```

and you should see something like this:

> The digit was 7, with a score of 100%.
