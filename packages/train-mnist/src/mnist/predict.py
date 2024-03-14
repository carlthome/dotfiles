import numpy as np
import onnxruntime
from PIL import Image, ImageOps


def main(image, model="./model.onnx", invert=False):
    # Load model.
    session = onnxruntime.InferenceSession(model)
    input_name = session.get_inputs()[0].name
    output_name = session.get_outputs()[0].name

    # Load image and preprocess it.
    image = Image.open(image).resize((28, 28)).convert("L")
    image = ImageOps.autocontrast(image)

    # Invert the image (this is useful for photos of paper).
    if invert:
        image = ImageOps.invert(image)

    # Convert image to normalized float array.
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

    # Display results.
    for label, score in zip(labels, scores):
        print(f"The digit was {label}, with a score of {score*100:.0f}%.")


if __name__ == "__main__":
    main()
