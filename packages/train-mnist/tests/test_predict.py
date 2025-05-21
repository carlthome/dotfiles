from pathlib import Path

import onnx
import onnxruntime as ort
import pytest
import torch

from mnist.predict import load_model, predict


@pytest.fixture
def onnx_model(random_model, tmp_path: Path) -> Path:
    dummy_input = torch.randn(1, 1, 28, 28)
    onnx_path = tmp_path / "model.onnx"
    torch.onnx.export(random_model, dummy_input, onnx_path)
    return onnx_path


@pytest.fixture
def inference_session(onnx_model: Path) -> ort.InferenceSession:
    onnx_model = onnx.load(onnx_model)
    onnx_model.SerializeToString()
    onnx_session = ort.InferenceSession(onnx_model.SerializeToString())
    return onnx_session


def test_load_model(onnx_model):
    session = load_model(onnx_model)
    assert session is not None


def test_predict(inference_session):
    image = "example.png"
    predict(image, inference_session, invert=True)
