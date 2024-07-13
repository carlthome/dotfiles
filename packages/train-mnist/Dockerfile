FROM python:3-slim

WORKDIR /build
COPY src src
COPY pyproject.toml .
RUN pip install --no-cache-dir .

WORKDIR /app
COPY app.py .
COPY model.onnx .
ENV PORT 8080
RUN fastapi --help
CMD fastapi run --port $PORT
