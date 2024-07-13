import numpy as np
import onnxruntime
from PIL import Image, ImageOps


def load_model(model) -> onnxruntime.InferenceSession:
    # Load model.
    session = onnxruntime.InferenceSession(model)
    return session


def predict(image, session: onnxruntime.InferenceSession, invert: bool):
    # Get input and output names.
    input_name = session.get_inputs()[0].name
    output_name = session.get_outputs()[0].name

    # Load image and preprocess it.
    image = Image.open(image).resize((28, 28)).convert("L")
    image = ImageOps.autocontrast(image)

    # Invert the image (this is useful for photos of paper).
    if invert:
        image = ImageOps.invert(image)

    # Save image to file for debugging.
    image.save("tmp.png")

    # Convert image to normalized float array.
    # TODO Use transform from training script.
    x = np.array(image)[None, ...].astype(np.float32) / 255
    x = (x - 0.1307) / 0.3081

    # Run the model.
    inputs = {input_name: [x]}
    outputs = session.run(output_names=[output_name], input_feed=inputs)
    logits = outputs[0]
    activations = np.exp(logits) / np.exp(logits).sum(axis=-1, keepdims=True)

    # Postprocess output.
    labels = np.argmax(activations, axis=-1)
    scores = activations[..., labels][0]

    return labels, scores


def main(image="./example.png", model="./model.onnx", invert=True):
    session = load_model(model)
    labels, scores = predict(image, session, invert)
    for label, score in zip(labels, scores):
        print(f"The digit was {label}, with a score of {score*100:.0f}%.")


if __name__ == "__main__":
    main()
