# MNIST Image Classifier

## Train

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

## Serve

### Develop

```sh
# Run a local development server with hot reloading.
fastapi dev

# While the app is running, test call it.
curl -L -X POST -F "image=@example.png" http://localhost:8000/predict/
```

### Deploy

```sh
# Deploy the app to Google Cloud Run.
gcloud run deploy --allow-unauthenticated --source='.' mnist

# And test call it.
url=$(gcloud run services describe mnist --format='value(status.url)')
curl -L -X POST -F "image=@example.png" $url/predict/

# And finally, clean up the service.
gcloud run services delete mnist
```
