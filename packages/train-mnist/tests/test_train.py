from unittest.mock import patch

from mnist.train import LitModel, MNISTDataModule


def test_lightningmodule(random_dataset, random_model, tmp_path):
    dims = [1, 28, 28]
    num_classes = 10
    module = LitModel(dims, num_classes)

    module.configure_optimizers()
    module.training_step(random_dataset[0:3], 0)
    module.predict_step(random_dataset[0:3], 0)
    module.to_onnx(tmp_path / "model.onnx")


def test_lightningdatamodule(random_dataset):
    datamodule = MNISTDataModule()
    with patch("mnist.train.MNIST", return_value=random_dataset):
        datamodule.prepare_data()
        datamodule.setup()
