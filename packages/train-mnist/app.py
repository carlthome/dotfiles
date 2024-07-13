import logging
from dataclasses import dataclass

import gradio as gr
from fastapi import FastAPI, UploadFile

from mnist.predict import load_model
from mnist.predict import predict as run_model

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

logger.info("Loading model...")
session = load_model("model.onnx")
logger.info("Loaded model.")

app = FastAPI()


@dataclass
class Request:
    image: UploadFile
    invert: bool


@dataclass
class Response:
    predictions: dict[str, float]


@app.post("/predict/", response_model=Response)
async def predict(request: Request):
    logger.debug(f"Received {request=}...")
    labels, scores = run_model(request.image.file, session, invert=request.invert)
    response = Response(dict(zip(labels.tolist(), scores.tolist())))
    logger.debug(f"Sending {response=}")
    return response


async def handle_image(images: dict[str, str], invert: bool):
    with open(images["composite"], "rb") as f:
        image = UploadFile(file=f, filename=images["composite"])
        request = Request(image=image, invert=invert)
        response = await predict(request)
    return response.predictions


def create_gradio_app() -> gr.Interface:
    with gr.Blocks() as demo:
        image = gr.Paint(type="filepath")
        invert = gr.Checkbox(label="Invert colors")
        output = gr.Label()
        for f in [image.change, invert.change]:
            f(handle_image, inputs=[image, invert], outputs=[output])
    return demo


demo = create_gradio_app()
app = gr.mount_gradio_app(app, demo, path="/gradio")
