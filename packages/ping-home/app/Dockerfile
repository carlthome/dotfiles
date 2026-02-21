FROM python:3.10-slim
RUN apt-get update && apt-get install -y curl
RUN curl -fsSL https://tailscale.com/install.sh | sh
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
RUN chmod +x start.sh
CMD ["./start.sh"]
