import pytest
import torch


class RandomDataset(torch.utils.data.Dataset):
    def __init__(self, *args, **kwargs):
        pass

    def __len__(self):
        return 60000

    def __getitem__(self, idx):
        return torch.randn(1, 28, 28), torch.randint(0, 10, (1,))


class RandomModel(torch.nn.Module):
    def __init__(self, *args, **kwargs):
        super().__init__()
        self.fc = torch.nn.Linear(784, 10)

    def forward(self, x):
        return self.fc(x.view(x.size(0), -1))


@pytest.fixture
def random_dataset() -> RandomDataset:
    return RandomDataset()


@pytest.fixture
def random_model() -> RandomModel:
    return RandomModel()
