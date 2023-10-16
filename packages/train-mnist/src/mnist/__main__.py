import fire

import mnist.train
import mnist.predict


def main():
    commands = {
        "train": mnist.train.main,
        "predict": mnist.predict.main,
    }
    fire.Fire(commands)


if __name__ == "__main__":
    main()
