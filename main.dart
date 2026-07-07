// Minimal Claude API proxy for AI Study Helper.
// Deploy this (Railway, Render, Fly.io, a cheap VPS) and put its URL in the
// app's Settings screen. Your Anthropic API key stays on the server —
// NEVER inside the APK, where it can be extracted within minutes of launch.

const express = require("express");
const app = express();
app.use(express.json({ limit: "15mb" })); // homework photos come through as base64

const ANTHROPIC_KEY = process.env.ANTHROPIC_API_KEY; // set in your host's env vars

app.post("/api/claude", async (req, res) => {
  try {
    const upstream = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": ANTHROPIC_KEY,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify(req.body),
    });
    const data = await upstream.json();
    res.status(upstream.status).json(data);
  } catch (err) {
    res.status(500).json({ error: String(err) });
  }
});

// TODO before public launch: add rate limiting (express-rate-limit) and some
// form of app attestation or auth token, otherwise strangers can burn your
// API budget once they find the endpoint.

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Proxy listening on ${port}`));
