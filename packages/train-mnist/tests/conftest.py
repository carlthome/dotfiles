from pathlib import Path

import pytest
import torch


class RandomDataset(torch.utils.data.Dataset):
    def __init__(self, size: int = 60000, num_classes: int = 10):
        self.size = size
        self.num_classes = num_classes

    def __len__(self):
        return self.size

    def __getitem__(self, idx: int) -> tuple[torch.Tensor, torch.Tensor]:
        image = torch.randn(1, 28, 28)
        label = torch.randint(0, self.num_classes, (1,))
        return image, label


class RandomModel(torch.nn.Module):
    def __init__(self, input_size: int = 784, num_classes: int = 10):
        super().__init__()
        self.fc = torch.nn.Linear(input_size, num_classes)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        logits = self.fc(x.flatten(start_dim=1))
        return logits


@pytest.fixture
def random_dataset() -> RandomDataset:
    return RandomDataset()


@pytest.fixture
def random_model() -> RandomModel:
    return RandomModel()


@pytest.fixture
def onnx_model(
    random_model: RandomModel, random_dataset: RandomDataset, tmp_path: Path
) -> Path:
    image, _label = next(iter(random_dataset))
    dummy_input = image.unsqueeze(0)
    onnx_path = tmp_path / "model.onnx"
    torch.onnx.export(random_model, dummy_input, onnx_path)
    return onnx_path
