import os
import time

import requests
from fastapi import FastAPI
from fastapi.responses import JSONResponse
from prometheus_client import Counter, Gauge, make_asgi_app

app = FastAPI()
app.mount("/metrics", make_asgi_app())

home_lan_up = Gauge("home_lan_up", "1 if home LAN is reachable, 0 otherwise")
checks_total = Counter("home_lan_checks_total", "Total home LAN checks", ["result"])


@app.get("/")
def check_home_lan():
    home_endpoint = os.environ["HOME_LAN_ENDPOINT"]
    socks5 = os.environ["TS_SOCKS5_SERVER"]
    proxies = {"http": f"socks5h://{socks5}", "https": f"socks5h://{socks5}"}
    last_error = None
    for attempt in range(3):
        try:
            resp = requests.get(home_endpoint, proxies=proxies, timeout=8)
            resp.raise_for_status()
            home_lan_up.set(1)
            checks_total.labels(result="up").inc()
            return {"status": "up"}
        except Exception as e:
            last_error = e
            print(f"Attempt {attempt + 1} failed: {e}")
            time.sleep(2)
    print(f"ERROR: Home LAN check failed: {last_error}")
    home_lan_up.set(0)
    checks_total.labels(result="down").inc()
    return JSONResponse({"status": "down", "error": str(last_error)}, status_code=500)
