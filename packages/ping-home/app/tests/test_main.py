from unittest.mock import MagicMock, patch

import pytest

import main


@pytest.fixture
def client(monkeypatch):
    monkeypatch.setenv("HOME_LAN_ENDPOINT", "http://192.168.1.1")
    main.app.config["TESTING"] = True
    return main.app.test_client()


def test_home_lan_up(client):
    with patch("main.requests.get") as mock_get:
        mock_get.return_value = MagicMock(status_code=200)
        mock_get.return_value.raise_for_status.return_value = None
        response = client.get("/")
    assert response.status_code == 200
    assert b"UP" in response.data


def test_home_lan_down(client):
    with patch("main.requests.get") as mock_get:
        mock_get.side_effect = Exception("Connection refused")
        response = client.get("/")
    assert response.status_code == 500
    assert b"Failed" in response.data
