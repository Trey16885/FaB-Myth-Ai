#!/usr/bin/env python3
"""FaB-Myth Forever API — Python example using the `requests` library.

    pip install requests
    python python_requests.py "your question here"
"""
import sys
import requests

# ---- configure these two ----
API_URL = "http://YOUR_HOST:8899/v1/chat"   # your `fabmyth API serve` address
API_KEY = "fmk_REPLACE_WITH_YOUR_KEY"        # from `fabmyth API <name>`
# -----------------------------


def ask(message, model="default", history=None):
    """Send a message to the Forever API and return the model's reply."""
    resp = requests.post(
        API_URL,
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {API_KEY}",  # or pass "key" in the body below
        },
        json={
            "key": API_KEY,
            "model": model,          # "default" -> llama3.2:1b, or any model you've pulled
            "message": message,
            "history": history or [],
        },
        timeout=600,
    )
    data = resp.json()
    if resp.status_code != 200 or "error" in data:
        raise RuntimeError(data.get("error", f"HTTP {resp.status_code}"))
    return data["reply"]


if __name__ == "__main__":
    prompt = " ".join(sys.argv[1:]) or "Say hello in one sentence."
    try:
        print(ask(prompt))
    except Exception as exc:  # noqa: BLE001
        print("Error:", exc, file=sys.stderr)
        sys.exit(1)
