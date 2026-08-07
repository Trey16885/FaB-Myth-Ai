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

### Updating

Once installed, update in place with:

```bash
fabmyth update
```

It fetches the latest `fabmyth`, keeps a backup at `~/.fabmyth/fabmyth.bak`, and
replaces itself atomically. To pull from a specific branch (e.g. before a change
is merged to `main`): `fabmyth update --branch <name>`.

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
| `fabmyth image [model] "prompt"` | Generate images with Ollama's image models (see below) |
| `fabmyth collab "m1 m2 …"` | 2–10 models **collaborate** on a task (see below) |
| `fabmyth remember <model> [msg]` | Chat with **persistent per-model memory** (see below) |
| `fabmyth memory <list\|show\|clear>` | Manage saved memories |
| `fabmyth agent <model> [task]` | **Termux AgenticOS** — let the model act on your device (see below) |
| `fabmyth web <model> [opts]` | **Web API** — serve a model + embeddable chat widget for your site (see below) |
| `fabmyth site [model] [opts]` | Generate a ready-to-host chat **website** (no coding) |
| `fabmyth API <name>` | **Forever API** — reusable API key for any device/site (see below) |
| `fabmyth update [--branch B]` | Self-update to the latest version |
| `fabmyth logs [-f\|N]` | Show server logs |

Run `fabmyth help` for the full list.

## Image generation

`fabmyth image` wraps Ollama's (experimental) text-to-image support, so you can
generate pictures from a prompt with models like **`x/z-image-turbo`**:

```bash
fabmyth pull x/z-image-turbo:fp8          # 13GB (fp8); :bf16 is 33GB, higher quality
fabmyth image "a red fox asleep in the snow, golden hour"
# or name the model explicitly:
fabmyth image x/z-image-turbo:fp8 "a neon city street in the rain"
```

Images are saved to `$FABMYTH_IMAGE_DIR` (defaults to the current directory),
and `fabmyth image` reports exactly which files were created.

> **Two honest caveats:**
> 1. **Ollama's image generation is macOS-only right now** (experimental, added
>    Jan 2026). On **Linux/Termux** — FaB-Myth's main target — it won't generate
>    until Ollama ships Linux support. `fabmyth image` warns you and still tries,
>    so it lights up automatically once that lands.
> 2. **There's no way to run a model without its weights.** The host downloads
>    the model once (13GB fp8). "Nobody downloads it" is only achievable by
>    running it on one machine and calling it remotely — not by skipping the
>    weights. Image models are **not auto-pulled** (they're too big); you pull
>    them deliberately.

### Host an image model for everyone (no per-person download)

If you want other people to make images *without each downloading the model*,
run it on **one** machine and let them generate over HTTP:

```bash
fabmyth pull flux2-klein:4b            # 4GB, downloaded once on THIS host
fabmyth image-web flux2-klein:4b       # serves an image generator + embed tag
```

It prints a single `<script>` tag (no key) that drops an image-generator widget
onto any website — visitors type a prompt and get a picture back, generated on
your host. The API is `POST /api/image` with `{"prompt":"..."}` → a
`data:image/png;base64` image. Options: `--port`, `--host`, `--url` (public base
for a tunnel/HTTPS front, same as the chat Web API).

This is the *only* real way to spare people the download: the weights live on
your host (downloaded once), and everyone else just sends prompts. The same two
caveats apply — the host needs the model, and until Ollama's image gen reaches
Linux the host must be a Mac.

## No-code website (`fabmyth site`)

Don't want to write any HTML? Generate a complete chat website in one command:

```bash
fabmyth site --api http://192.168.1.50:8777        # plain Web API
# or point it at the Forever API with a key:
fabmyth site qwen2.5:3b --api http://192.168.1.50:8899 --key fmk_... --title "My Bot"
```

It writes a self-contained `index.html` (a full-page chat UI) to
`./fabmyth-site/` (or `--out DIR`). Host that folder anywhere — GitHub Pages,
Netlify, a USB stick — no build step, no dependencies. Options: `--out`, `--api`,
`--key`, `--title`.

## Forever API — one key, any device or site

The Web API is single-model and keyless. The **Forever API** gives you a
**reusable key** that works from any website or device, and lets callers pick
which model to use.

```bash
fabmyth API mykey        # create a key -> prints fmk_XXXXXXXX... (once)
fabmyth API list         # list your keys (secret masked)
fabmyth API rm mykey     # delete a key
fabmyth API serve        # run the key-authenticated server (port 8899)
```

Call it from anywhere with a JSON body:

```json
{ "key": "fmk_...", "model": "default", "message": "Hello!" }
```

- **`model`** — `"default"` uses `llama3.2:1b`; or name any model you've pulled
  on the host (e.g. `"qwen2.5:3b"`), so **one key can serve several models** you
  host.
- The key can be sent in the body (`"key"`) or as an `Authorization: Bearer ...`
  header. Invalid/missing keys get HTTP 401. Keys are reloaded on every request,
  so new keys work instantly and deleted keys stop working immediately.

Ready-made **examples** (HTML, JavaScript, and Python with `requests`) live in
the [`examples/`](examples/) folder — copy one, drop in your `API_URL` and
`API_KEY`, done.

> Keys are stored on the host in `~/.fabmyth/api_keys.json`. The server binds to
> all interfaces so other devices on your network can reach it; for public use,
> front it with an HTTPS tunnel and pass `--url`. There's no way around the host
> needing to run — the key authenticates callers, it doesn't run the model
> remotely by itself.

## Collab — models working together

`fabmyth collab` puts **2 to 10 models** on the same task. Each one reads the
discussion so far (the task plus every prior model's contribution) and adds its
own — then the first model synthesizes a single final answer.

```bash
fabmyth collab "llama3.2:1b qwen2.5:1.5b gemma2:2b"
# or list them as separate arguments:
fabmyth collab llama3.2:3b qwen2.5:3b
# multiple passes so they iterate on each other, no final merge:
fabmyth collab llama3.2:3b qwen2.5:3b --rounds 3 --no-synth
```

- **2–10 models** (it refuses fewer or more). Any model you've pulled works;
  missing ones are pulled first.
- `--rounds N` (1–5) makes them go around N times, each seeing the latest state.
- `--no-synth` skips the final synthesized answer.
- In-session: `/rounds N`, `/synth on|off`, `/bye`.

Models don't share weights or memory — it's a conversation orchestrated across
each model's API, so a small model can hand off to a stronger one and vice
versa.

## Memory — models that remember you

Plain `chat` forgets everything when you close it. `fabmyth remember` is a chat
that **saves the conversation and reloads it next time**, so the model recalls
what you told it in past sessions.

```bash
fabmyth remember llama3.2:3b
# ... you: "my name is Trey and I like sci-fi"
# ... quit, come back tomorrow ...
fabmyth remember llama3.2:3b
# ... you: "recommend me a book"  -> it already knows you like sci-fi
```

**Each model has its own separate memory.** What you tell `llama3.2:3b` is not
visible to `qwen2.5:3b` — every model gets its own history file under
`~/.fabmyth/memory/<model>.json` (the tag is part of the key, so `:1b` and `:3b`
are distinct too).

Manage it:

```bash
fabmyth memory list                 # which models have memory, size, last used
fabmyth memory show llama3.2:3b     # print the stored conversation
fabmyth memory clear llama3.2:3b    # wipe one model's memory
fabmyth memory clear --all          # wipe every model's memory
```

Inside a `remember` session: `/forget` wipes that model's memory on the spot,
`/memory` shows stats, `/bye` saves and exits. The most recent messages (default
40) are sent back as context each turn — tune with `FABMYTH_MEMORY_WINDOW`, and
set a persona with `FABMYTH_MEMORY_SYSTEM`.

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
