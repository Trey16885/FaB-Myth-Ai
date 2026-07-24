# Running FaB-Myth-Ai on Termux (Android)

Termux lets you run a real Linux userland on your phone, which means you can run
Ollama models locally — no cloud, no account, fully offline once downloaded.
This guide covers the two supported paths and the gotchas unique to Android.

> **TL;DR**
> ```bash
> pkg install -y curl
> curl -fsSL https://raw.githubusercontent.com/Trey16885/FaB-Myth-Ai/main/install.sh | bash
> fabmyth setup
> fabmyth start
> fabmyth pull llama3.2:1b
> fabmyth chat
> ```

---

## 0. Install Termux the right way

Install Termux from **F-Droid** or **GitHub**, *not* the Play Store version
(that one is outdated and won't update its packages).

Then bootstrap the basics:

```bash
pkg update -y && pkg upgrade -y
pkg install -y curl
```

## 1. Install the helper

```bash
curl -fsSL https://raw.githubusercontent.com/Trey16885/FaB-Myth-Ai/main/install.sh | bash
```

On Termux this drops `fabmyth` into `$PREFIX/bin`, which is already on your PATH.

## 2. Install Ollama

```bash
fabmyth setup
```

`fabmyth setup` first tries `pkg install ollama` (available in current Termux
repos). If your repo doesn't carry it, the command prints the **proot-distro**
fallback (see below).

### Fallback: proot-distro

Some Termux setups don't have an Ollama package. In that case run a tiny Debian
inside Termux and install Ollama there:

```bash
pkg install -y proot-distro
proot-distro install debian
proot-distro login debian
# --- now you're inside Debian ---
apt update && apt install -y curl
curl -fsSL https://ollama.com/install.sh | sh
```

Install the helper inside Debian too, then use it normally:

```bash
curl -fsSL https://raw.githubusercontent.com/Trey16885/FaB-Myth-Ai/main/install.sh | bash
fabmyth start
```

Remember: when you use proot, you must be **inside** the Debian shell
(`proot-distro login debian`) every time you want to run models.

## 3. Start the server and pull a model

```bash
fabmyth start
fabmyth search          # pick a ★ phone-friendly model
fabmyth pull llama3.2:1b
fabmyth chat            # choose it and start chatting
```

---

## Picking a model your phone can handle

Phones are RAM-constrained. `fabmyth doctor` reads your available RAM and tells
you what's safe. Rough guide:

| Phone RAM | Comfortable models                  |
|-----------|-------------------------------------|
| 3 GB      | `qwen2.5:0.5b`, `tinyllama`         |
| 4 GB      | `llama3.2:1b`, `qwen2.5:1.5b`       |
| 6 GB      | `llama3.2:3b`, `gemma2:2b`, `phi3:mini` |
| 8 GB+     | `qwen2.5:3b`, small 7B models (slow) |

Models download over your network — grab them on Wi-Fi, not mobile data.

## Termux AgenticOS — let the model do things on your phone

`fabmyth agent` lets a local model run shell/Python/JS and save files on your
device, approving each action yourself:

```bash
pkg install -y python        # required for the agent loop
pkg install -y nodejs        # optional, only for JavaScript actions
fabmyth agent llama3.2:3b "save a shopping list to list.txt"
```

- Every command or file is shown to you first — answer `y`/`N`/`a`/`q`.
- Files land in **`/sdcard/FabMyth/<model>/`**, so you can open them in any
  Android app (Files, a text editor, etc.). You may need to run
  `termux-setup-storage` once and grant the storage permission so `/sdcard` is
  writable.
- Use `/bye` to leave, `/ws` to see the folder, `/reset` to clear history.

Small models (1–3B) are hit-or-miss at following the action format — if the
agent isn't emitting `fabmyth-` blocks, a 3B+ model (e.g. `llama3.2:3b`,
`qwen2.5:3b`) tends to behave better.

## Web API — embed your model on a website

`fabmyth web` gives you a `<script>` tag (no key) that adds a chat widget backed
by your model to any site:

```bash
pkg install -y python
fabmyth web llama3.2:3b
```

Open the printed preview URL to see the widget and copy the tag. This is
**chat-only** — it never runs commands.

To reach it from a real website (a phone isn't publicly addressable on its own),
run it behind a tunnel and point the tag at that URL:

```bash
pkg install -y cloudflared        # or use ngrok / an SSH tunnel
cloudflared tunnel --url http://localhost:8777    # gives you an https URL
# then, in another Termux session:
fabmyth web llama3.2:3b --url https://your-tunnel-url.trycloudflare.com
```

The `--url` value is what gets baked into the embed tag, so visitors' browsers
hit the tunnel instead of your phone's local address.

## Keeping it running

- **Prevent Android from killing Termux:** acquire a wakelock with
  `termux-wake-lock` (from the Termux notification, tap "Acquire wakelock"), and
  disable battery optimization for Termux in Android settings.
- **Free storage:** models live under `~/.ollama/models`. Remove ones you don't
  use with `fabmyth rm <model>`.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Ollama isn't installed` | Run `fabmyth setup`. If it fails, use the proot-distro path. |
| Server won't come up | `fabmyth logs -f` to see why; often it's low memory. |
| `killed` mid-chat | Model is too big for your RAM — pick a smaller ★ model. |
| Very slow responses | Normal on phones; smaller models respond faster. |
| Command not found after install | Add the printed `export PATH=...` line to `~/.bashrc`. |

Run `fabmyth doctor` any time to get a health check tailored to your device.
