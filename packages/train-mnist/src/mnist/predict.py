import numpy as np

import onnxruntime


def main():
    session = onnxruntime.InferenceSession("model.onnx")
    input_name = session.get_inputs()[0].name
    inputs = {input_name: np.random.randn(1, 1, 28, 28).astype(np.float32)}
    outputs = session.run(None, inputs)
    print(outputs)


if __name__ == "__main__":
    main()
