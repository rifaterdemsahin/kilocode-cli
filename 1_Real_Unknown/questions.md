# ❓ Core Questions Backlog

> Expanded questions driving the KiloCode CLI setup journey

---

## Installation Questions

1. What is the minimum Node.js version required by KiloCode CLI?
2. Does KiloCode CLI need Rust/Python/Go binaries or is it pure Node?
3. Are there native addons that require Xcode/MSVC build tools?
4. Does the npm package work on both `arm64` and `x64` architectures?

## Configuration Questions

5. Where does KiloCode store its config: `~/.kilocode/`, `~/.config/kilocode/`, or `.env`?
6. Can the same `config.yaml` be shared via dotfiles across platforms?
7. How does KiloCode handle multiple projects — per-project or global config?
8. Can we point to a remote Qdrant instance (not just localhost)?

## Integration Questions

9. Does KiloCode support Claude/GPT in addition to Ollama?
10. Can we switch between embedding models without re-indexing?
11. Is there a watch mode that auto-indexes on file save?
12. Does KiloCode have a VS Code extension that uses the CLI index?

## Platform-Specific Questions

13. On Apple Silicon: does Ollama use GPU (Metal) or CPU?
14. On Windows: does Ollama use CUDA/DirectML for GPU acceleration?
15. WSL2 vs native Windows — which gives better performance?
16. How do we handle Windows line endings (CRLF) in indexed files?

## Reliability Questions

17. What happens if Ollama goes down during indexing?
18. Does Qdrant persist data across Docker restarts?
19. How do we handle index corruption?
20. What's the maximum project size (GB) that works well?

---

*[← Back to Real Unknown](../markdown_renderer.html?file=1_Real_Unknown/README.md)*
