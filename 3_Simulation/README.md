# 🎨 Stage 3 — Simulation

> **The "Vision"** — UI mockups and the target experience for KiloCode CLI on Mac & Windows.

---

## Interactive Carousel

👉 [View the Simulation Carousel](index.html)

The carousel shows 5 terminal mockups representing the target experience:

1. **Successful installation** — version check on macOS
2. **Project indexing** — embedding 47 files into Qdrant
3. **Semantic search** — asking about auth flow
4. **Windows PowerShell** — same experience on Windows
5. **Configuration display** — unified config across platforms

---

## Target User Flow

```
[User opens terminal]
        ↓
[Run: kilocode --version]
        ↓
[All green: Ollama ✓, Qdrant ✓]
        ↓
[cd ~/myproject && kilocode index .]
        ↓
[kilocode ask "how does X work?"]
        ↓
[Get relevant files + AI-generated answer]
```

---

## Images Directory

Add screenshots/mockup images to `3_Simulation/images/` — they will automatically
appear in the carousel when image support is enabled.

Current images: _(none yet — add .png or .jpg files here)_

---

## Design Principles

- **Minimal friction** — 5 commands from install to first query
- **Platform parity** — identical experience on Mac and Windows
- **Graceful degradation** — works without internet (local Ollama)
- **Visible status** — always show connection health on startup

---

*[← Stage 2](../markdown_renderer.html?file=2_Environment/README.md) · [Stage 4 →](../markdown_renderer.html?file=4_Formula/README.md)*
