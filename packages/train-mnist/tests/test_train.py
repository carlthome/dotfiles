from unittest.mock import patch

import pytest
import torch

from mnist.train import LitModel, MNISTDataModule

from .conftest import RandomDataset


@pytest.fixture
def lightningmodule() -> LitModel:
    dims = [1, 28, 28]
    num_classes = 10
    module = LitModel(dims, num_classes)
    return module


@pytest.fixture
def batch(random_dataset: RandomDataset) -> tuple[torch.Tensor, int]:
    dataloader = torch.utils.data.DataLoader(random_dataset, batch_size=3)
    minibatch = next(iter(dataloader))
    batch_idx = 0
    return minibatch, batch_idx


def test_training_step(lightningmodule: LitModel, batch):
    loss = lightningmodule.training_step(*batch)
    assert torch.isfinite(loss)


def test_validation_step(lightningmodule: LitModel, batch):
    loss = lightningmodule.validation_step(*batch)
    assert torch.isfinite(loss)


def test_test_step(lightningmodule: LitModel, batch):
    lightningmodule.configure_optimizers()
    loss = lightningmodule.test_step(*batch)
    assert torch.isfinite(loss)


def test_predict_step(lightningmodule: LitModel, batch):
    preds = lightningmodule.predict_step(*batch)
    assert len(preds) == 3


def test_datamodule(random_dataset: RandomDataset):
    batch_size = 3
    datamodule = MNISTDataModule(batch_size=batch_size)
    with patch("mnist.train.MNIST", return_value=random_dataset):
        datamodule.prepare_data()
        datamodule.setup()
    for batch in datamodule.train_dataloader():
        assert batch[0].shape == (batch_size, 1, 28, 28)
        assert batch[1].shape == (batch_size, 1)
        break
