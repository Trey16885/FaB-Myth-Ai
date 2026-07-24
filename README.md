# FaB-Myth-Ai

**FaB Myth** is an Ollama helper that lets you run *any* downloadable AI model
from the [Ollama library](https://ollama.com/library) on your own device — with
a single, friendly command. It's built to be effortless on **Linux** and, above
all, on **Termux (Android)**, where getting Ollama running is usually the hard
part.

No cloud. No account. Once a model is downloaded it runs fully offline, on your
phone or laptop.

```
$ fabmyth chat
==> Installed models:
   1  llama3.2:1b
   2  qwen2.5:1.5b
Pick a number (or type a model name): 1
==> Starting chat with llama3.2:1b  (type /bye to quit)
>>> hey, what can you do on a phone?
```

## Why

Ollama is fantastic, but on a phone the setup is a maze: which install path,
which build, how to keep the server alive, and — most importantly — *which
models actually fit in your RAM*. `fabmyth` wraps all of that into a handful of
commands and adds Termux-aware install logic, a phone-friendly model picker, and
a `doctor` that tells you what your device can handle.

## Install

**One-liner (Linux or Termux):**

```bash
curl -fsSL https://raw.githubusercontent.com/Trey16885/FaB-Myth-Ai/main/install.sh | bash
```

**From a clone:**

```bash
git clone https://github.com/Trey16885/FaB-Myth-Ai.git
cd FaB-Myth-Ai
./install.sh
```

The installer only requires `bash` and `curl`. It places the `fabmyth` command
on your PATH (`$PREFIX/bin` on Termux, `/usr/local/bin` or `~/.local/bin` on
Linux).

## Quick start

```bash
fabmyth setup            # install Ollama for your platform
fabmyth start            # launch the background server
fabmyth search           # browse phone-friendly models (★)
fabmyth pull llama3.2:1b # download one
fabmyth chat             # pick it and start talking
```

On **Termux**, follow the dedicated walkthrough in
[docs/TERMUX.md](docs/TERMUX.md) — it covers the `pkg` install, the
`proot-distro` fallback, wakelocks, and picking a model that fits your RAM.

## Commands

| Command | What it does |
|---|---|
| `fabmyth setup` | Install Ollama (Termux via `pkg`, Linux via official/userspace install) |
| `fabmyth start` / `stop` / `restart` | Manage the background Ollama server |
| `fabmyth status` | Show platform, install, and server state |
| `fabmyth doctor` | Diagnose your environment and suggest fixes / models |
| `fabmyth search [term]` | Browse a curated catalog; ★ marks phone-friendly models |
| `fabmyth pull <model>` | Download a model |
| `fabmyth run <model> [prompt]` | Chat with a model (auto-pulls if missing) |
| `fabmyth chat` | Pick an installed model and chat |
| `fabmyth list` / `ps` | List installed / running models |
| `fabmyth rm <model>` | Remove a model |
| `fabmyth agent <model> [task]` | **Termux AgenticOS** — let the model act on your device (see below) |
| `fabmyth web <model> [opts]` | **Web API** — serve a model + embeddable chat widget for your site (see below) |
| `fabmyth logs [-f\|N]` | Show server logs |

Run `fabmyth help` for the full list.

## Termux AgenticOS

`fabmyth agent` turns a local model into a hands-on agent that can **run shell,
Python, and JavaScript** and **save files** on your device — with a hard rule:
**you approve every single action before it runs.**

```bash
fabmyth agent llama3.2:3b "make a file called notes.txt with a haiku in it"
```

How it works:

- The model requests actions by emitting tagged fenced blocks — `fabmyth-sh`,
  `fabmyth-py`, `fabmyth-js`, or `fabmyth-save <file>`. **Only these tagged
  blocks ever run**, so ordinary code examples in its replies never execute.
- Before anything runs, fabmyth shows you the exact command or file contents and
  asks: `[y]es / [N]o / [a]ll this session / [q]uit`. The default is **No**.
- The action's output is fed back to the model so it can chain steps toward the
  goal, up to a per-task action limit.
- Files the model creates are saved under **`<storage>/FabMyth/<ModelName>/`** —
  on Termux that's `/sdcard/FabMyth/<model>/`, so you can open them in any
  Android app. Paths are sandboxed to that folder (no `..` escapes, no absolute
  paths). Set `FABMYTH_STORAGE` to change the base location.

Requirements: Python (`pkg install python`) for the agent loop; Node.js
(`pkg install nodejs`) only if you want the model to run JavaScript. Run
`fabmyth doctor` to check.

In-session commands: `/bye` to quit, `/reset` to clear history, `/ws` to print
the workspace path.

> **Heads up:** this executes model-generated code on your device. The approval
> prompt is your safety gate — read each command before you approve it, and use
> `[a]ll` only when you trust the whole task.

## Web API — put your model on a website

`fabmyth web` stands up a small HTTP server for one model and gives you a single
`<script>` tag to drop into any website — **no API key**. It's **chat-only** and
never runs commands (that's AgenticOS's job, and it's deliberately separate).

```bash
fabmyth web llama3.2:3b
```

It prints a tag like this to paste into your HTML (just before `</body>`):

```html
<script src="http://YOUR_HOST:8777/embed.js" data-fabmyth-model="llama3.2:3b"></script>
```

That tag adds a floating chat bubble to your site, wired to your model. You can
customize it with data attributes:

```html
<script src="http://YOUR_HOST:8777/embed.js"
        data-fabmyth-model="llama3.2:3b"
        data-fabmyth-title="Support Bot"
        data-fabmyth-color="#e11d48"></script>
```

**Endpoints** (CORS-open so any site can call them):

| Route | Purpose |
|---|---|
| `GET /` | Preview page with a live widget and the copy-paste tag |
| `GET /embed.js` | The widget script the tag loads |
| `POST /api/chat` | `{ "message": "...", "history": [...] }` → `{ "reply": "..." }` |
| `GET /health` | `{ "ok": true, "model": "..." }` |

**Options:** `--port N` (default 8777), `--host H` (default `0.0.0.0`),
`--url URL` (public base URL used in the printed tag — set this when fronting the
API with a tunnel/HTTPS), `--system TEXT` (a system prompt / persona for the bot).

> **No key by design** means the endpoint is open to anyone who can reach it. For
> local use or your own LAN that's fine. To expose it to the public internet
> (e.g. from a phone on Termux), run it behind a tunnel — `cloudflared`,
> `ngrok`, or an SSH tunnel — and pass that HTTPS address via `--url` so the
> embed tag points at it.

## How it works

`fabmyth` is a single, dependency-light Bash script (`bin/fabmyth`). It:

- **detects your platform** (Termux vs Linux, CPU arch) and installs Ollama the
  right way for it, including a root-free userspace install;
- **manages the server** in the background with a tracked PID and log file, so
  `start`/`stop`/`status` just work without systemd (which Termux lacks);
- **wraps model commands** (`pull`, `run`, `list`, `rm`, `ps`) and auto-starts
  the server when needed;
- **guides model choice** with a curated, size-annotated catalog and a `doctor`
  that reads your RAM and recommends models that will actually run.

State lives under `~/.fabmyth` (PID + logs). Configure with `OLLAMA_HOST` and
`FABMYTH_HOME` environment variables.

## Requirements

- `bash` and `curl` (both present on a normal Termux/Linux setup)
- Enough RAM for your chosen model — `fabmyth doctor` will advise. A 4 GB phone
  comfortably runs 1B models; 6–8 GB handles 3B and small 7B models.

## License

MIT — see [LICENSE](LICENSE). Copyright (c) 2026 Trey16885.
