# FaB-Myth Forever API — examples

These examples call the **Forever API**: a reusable key that works from any
website or device. The same key works everywhere until you delete it.

## 1. Create a key and start the server (on the host machine)

```bash
fabmyth API mykey          # prints a key like: fmk_XXXXXXXXXXXXXXXXXXXXXXXX
fabmyth API serve          # starts the API on port 8899 (all interfaces)
```

Find the host's address (e.g. `http://192.168.1.50:8899`). For other devices to
reach it, they must be on the same network — or front the server with an HTTPS
tunnel (`cloudflared`, `ngrok`) and use that URL.

## 2. Call it

Every example sends a JSON body:

```json
{ "key": "fmk_...", "model": "default", "message": "Hello!" }
```

- **`model`** — set to `"default"` to use `llama3.2:1b`, or the name of any model
  you've pulled on the host (e.g. `"qwen2.5:3b"`), which lets you host multiple
  models behind one key.
- **`history`** *(optional)* — array of `{ "role": "user"|"assistant", "content": "..." }`
  for multi-turn context.
- The key may be sent in the body as `"key"`, or as a header
  `Authorization: Bearer fmk_...`, or `X-API-Key: fmk_...`.

The response is:

```json
{ "reply": "Hi there!", "model": "llama3.2:1b" }
```

## Files

- `browser.html` — a minimal web page (plain HTML + fetch)
- `node.js` — Node.js using the built-in fetch
- `python_requests.py` — Python using the `requests` library

In each file, replace `API_URL` and `API_KEY` with your own. On error the JSON
has an `error` field instead of `reply` (e.g. a bad key returns HTTP 401).
