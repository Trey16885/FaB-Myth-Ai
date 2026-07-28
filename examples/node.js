// FaB-Myth Forever API — Node.js example (Node 18+ has fetch built in)
//
//   node node.js "your question here"
//
// Configure these two:
const API_URL = "http://YOUR_HOST:8899/v1/chat"; // your `fabmyth API serve` address
const API_KEY = "fmk_REPLACE_WITH_YOUR_KEY";      // from `fabmyth API <name>`

async function ask(message, model = "default", history = []) {
  const res = await fetch(API_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + API_KEY,
    },
    body: JSON.stringify({ key: API_KEY, model, message, history }),
  });
  const data = await res.json();
  if (!res.ok || data.error) {
    throw new Error(data.error || `HTTP ${res.status}`);
  }
  return data.reply;
}

(async () => {
  const message = process.argv.slice(2).join(" ") || "Say hello in one sentence.";
  try {
    const reply = await ask(message);
    console.log(reply);
  } catch (e) {
    console.error("Error:", e.message);
    process.exit(1);
  }
})();
