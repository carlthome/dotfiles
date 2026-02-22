from unittest.mock import MagicMock, patch

import pytest
from fastapi.testclient import TestClient

from main import app


@pytest.fixture
def client(monkeypatch):
    monkeypatch.setenv("HOME_LAN_ENDPOINT", "http://192.168.1.1")
    monkeypatch.setenv("TS_SOCKS5_SERVER", "localhost:1055")
    return TestClient(app)


def test_home_lan_up(client):
    with patch("main.requests.get") as mock_get:
        mock_get.return_value = MagicMock(status_code=200)
        mock_get.return_value.raise_for_status.return_value = None
        response = client.get("/")
    assert response.status_code == 200
    assert response.json()["status"] == "up"


def test_home_lan_down(client):
    with patch("main.requests.get") as mock_get:
        mock_get.side_effect = Exception("Connection refused")
        response = client.get("/")
    assert response.status_code == 500
    assert response.json()["status"] == "down"


def test_metrics_endpoint(client):
    response = client.get("/metrics")
    assert response.status_code == 200
    assert b"home_lan_up" in response.content
    assert b"home_lan_checks_total" in response.content
