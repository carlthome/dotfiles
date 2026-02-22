FROM python:3.10-slim
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://tailscale.com/install.sh | sh
WORKDIR /app
COPY pyproject.toml .
RUN uv sync --frozen --no-dev
COPY . .
RUN chmod +x start.sh
CMD ["./start.sh"]
