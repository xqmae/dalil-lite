# ADR-001: Backend Proxy Approach & Guardrails (Task D4)

**Author:** Hossam Tarek Elessawi (Member D - AI & Backend)  
**Project:** Dalil Lite  
**Status:** Proposed (Phase 1 — Week 2)  

---

## 1. Context & Problem
Mobile and desktop client applications cannot securely store secret AI provider API keys. Embedding keys in client binaries exposes them to extraction and quota theft.

## 2. Decision: Lightweight Stateless Proxy
We will route all AI requests through a thin, stateless serverless proxy rather than calling AI providers directly from the Flutter client to ensure zero key exposure and safe privacy filtering.
