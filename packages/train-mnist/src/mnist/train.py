import pytorch_lightning as L
import torch
import torch.nn.functional as F
from torch import nn
from torch.utils.data import DataLoader, random_split
from torchmetrics.functional import accuracy
from torchvision import transforms
from torchvision.datasets import MNIST


class MNISTDataModule(L.LightningDataModule):
    def __init__(
        self,
        data_dir: str = "data",
        batch_size: int = 32,
    ):
        super().__init__()
        self.data_dir = data_dir
        self.transform = transforms.Compose(
            transforms=[
                transforms.ToTensor(),
                transforms.Normalize((0.1307,), (0.3081,)),
            ]
        )
        self.augmentation = transforms.Compose(
            transforms=[
                self.transform,
                transforms.RandomInvert(),
                transforms.RandomRotation(10),
                transforms.RandomAffine(0, translate=(0.1, 0.1)),
                transforms.RandomAffine(0, scale=(0.9, 1.1)),
                transforms.RandomAffine(0, shear=10),
            ]
        )
        self.batch_size = batch_size
        self.dims = [1, 28, 28]
        self.num_classes = 10

    def prepare_data(self):
        MNIST(self.data_dir, train=True, download=True)
        MNIST(self.data_dir, train=False, download=True)

    def setup(self, stage=None):
        if stage == "fit" or stage is None:
            mnist_full = MNIST(self.data_dir, train=True, transform=self.augmentation)
            self.mnist_train, self.mnist_val = random_split(mnist_full, [55000, 5000])

        if stage == "test" or stage is None:
            self.mnist_test = MNIST(
                self.data_dir, train=False, transform=self.transform
            )

    def train_dataloader(self):
        return DataLoader(
            self.mnist_train,
            batch_size=self.batch_size,
            num_workers=8,
            persistent_workers=True,
        )

    def val_dataloader(self):
        return DataLoader(
            self.mnist_val,
            batch_size=self.batch_size,
            num_workers=8,
            persistent_workers=True,
        )

    def test_dataloader(self):
        return DataLoader(
            self.mnist_test,
            batch_size=self.batch_size,
            num_workers=8,
            persistent_workers=True,
        )


class LitModel(L.LightningModule):
    def __init__(
        self,
        dims: list[int],
        num_classes: int,
        hidden_size: int = 64,
        learning_rate: float = 2e-4,
    ):
        super().__init__()
        self.save_hyperparameters()
        self.learning_rate = learning_rate
        self.example_input_array = {
            "x": torch.randn(1, *dims),
        }
        self.model = nn.Sequential(
            nn.Conv2d(dims[0], 32, 5, padding=2),
            nn.ReLU(),
            nn.Conv2d(32, 1, 1),
            nn.Flatten(),
            nn.Linear(dims[0] * dims[1] * dims[2], hidden_size),
            nn.ReLU(),
            nn.Dropout(0.1),
            nn.Linear(hidden_size, hidden_size),
            nn.ReLU(),
            nn.Dropout(0.1),
            nn.Linear(hidden_size, num_classes),
        )

    def forward(self, x):
        x = self.model(x)
        return F.log_softmax(x, dim=1)

    def training_step(self, batch, batch_idx):
        x, y = batch
        logits = self(x)
        loss = F.nll_loss(logits, y[:, 0])
        self.log("train_loss", loss)
        return loss

    def validation_step(self, batch, batch_idx):
        x, y = batch
        logits = self(x)
        loss = F.nll_loss(logits, y[:, 0])
        preds = torch.argmax(logits, dim=1)
        acc = accuracy(preds, y[:, 0], task="multiclass", num_classes=10)
        self.log("val_loss", loss, prog_bar=True)
        self.log("val_acc", acc, prog_bar=True)
        return loss

    def test_step(self, batch, batch_idx):
        x, y = batch
        logits = self(x)
        loss = F.nll_loss(logits, y[:, 0])
        preds = torch.argmax(logits, dim=1)
        acc = accuracy(preds, y[:, 0], task="multiclass", num_classes=10)
        self.log("test_loss", loss, prog_bar=True)
        self.log("test_acc", acc, prog_bar=True)
        return loss

    def predict_step(self, batch, batch_idx):
        x, y = batch
        logits = self(x)
        preds = torch.argmax(logits, dim=1)
        return preds

    def configure_optimizers(self):
        optimizer = torch.optim.Adam(self.parameters(), lr=self.learning_rate)
        return optimizer


def main():
    dataset = MNISTDataModule()
    model = LitModel(dataset.dims, dataset.num_classes)
    trainer = L.Trainer(max_epochs=10, default_root_dir="logs")
    trainer.fit(model, dataset)
    trainer.test(model, dataset)
    model.to_onnx("model.onnx", input_sample=torch.randn(1, *dataset.dims))


if __name__ == "__main__":
    main()
