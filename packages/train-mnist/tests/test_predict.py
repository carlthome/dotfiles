from mnist.predict import load_model, predict


def test_predict(onnx_model):
    image = "example.png"
    session = load_model(onnx_model)
    predict(image, session, invert=True)
