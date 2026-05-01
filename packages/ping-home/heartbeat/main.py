import os
import time

import functions_framework
from google.cloud import monitoring_v3

PROJECT_ID = None  # Auto-detected from environment


@functions_framework.http
def heartbeat(request):
    """Receive heartbeat from home and write metric to Cloud Monitoring."""
    secret = request.headers.get("X-Heartbeat-Secret")
    if not secret or secret != os.environ["HEARTBEAT_SECRET"]:
        return {"error": "unauthorized"}, 401

    client = monitoring_v3.MetricServiceClient()
    project_name = f"projects/{PROJECT_ID or _get_project_id()}"

    series = monitoring_v3.TimeSeries()
    series.metric.type = "custom.googleapis.com/home/heartbeat"
    series.resource.type = "global"

    now = time.time()
    interval = monitoring_v3.TimeInterval(
        {"end_time": {"seconds": int(now), "nanos": int((now % 1) * 1e9)}}
    )
    point = monitoring_v3.Point({"interval": interval, "value": {"int64_value": 1}})
    series.points = [point]

    client.create_time_series(name=project_name, time_series=[series])

    return {"status": "ok", "timestamp": now}, 200


def _get_project_id():
    import google.auth

    _, project = google.auth.default()
    return project
