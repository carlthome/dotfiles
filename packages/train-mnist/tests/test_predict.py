from mnist.predict import load_model, predict


def test_load_model(mock_onnx):
    session = load_model(mock_onnx)
    assert session is not None


def test_predict(mock_session):
    image = "example.png"
    predict(image, mock_session, invert=True)
