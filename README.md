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
| `fabmyth logs [-f\|N]` | Show server logs |

Run `fabmyth help` for the full list.

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
