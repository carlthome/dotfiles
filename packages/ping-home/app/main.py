import os
import requests
from flask import Flask

app = Flask(__name__)


@app.route("/", methods=["GET", "POST"])
def check_home_lan():
    home_endpoint = os.environ.get("HOME_LAN_ENDPOINT")
    proxies = {"http": "socks5h://localhost:1055", "https": "socks5h://localhost:1055"}
    try:
        response = requests.get(home_endpoint, proxies=proxies, timeout=10)
        response.raise_for_status()
        return "Home LAN is UP", 200
    except Exception as e:
        print(f"ERROR: Home LAN Health check failed: {str(e)}")
        return f"Failed: {str(e)}", 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
