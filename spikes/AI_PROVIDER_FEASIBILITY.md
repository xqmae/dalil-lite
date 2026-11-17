# AI Provider Feasibility Study (Task D3)

**Author:** Hossam Tarek Elessawi (Member D - AI & Backend)  
**Project:** Dalil Lite  
**Phase:** Phase 1 — Week 2  

---

## 1. Objective
Evaluate and shortlist 2–3 external AI providers for document summarization and Q&A capabilities based on Arabic/English quality, context window size, pricing, rate limits, and strict compliance with Phase 1 privacy rules (zero training on user data).

---

## 2. Candidate Providers Comparison

| Evaluation Criteria | Google Gemini (gemini-1.5-flash / pro) | OpenAI (gpt-4o-mini / gpt-4o) | Anthropic (claude-3-5-sonnet) |
| :--- | :--- | :--- | :--- |
| **Arabic & English Quality** | Excellent contextual understanding and summarization in both Arabic and English. | Industry-leading Arabic phrasing and instruction following. | Very strong comprehension of complex, long-form documents. |
| **Context Window** | **Up to 1M – 2M tokens** (handles full large PDFs in a single pass without heavy chunking). | Up to 128k tokens. | Up to 200k tokens. |
| **Pricing (Cost Efficiency)** | **Highly economical** (especially Flash tier, lowest cost per request). | Moderate to low (GPT-4o-mini is cost-effective; GPT-4o is higher). | Higher cost per 1M input/output tokens compared to Flash/Mini tiers. |
| **Data Privacy & Retention** | **Compliant:** Paid API data is not used to train Google models by default. | **Compliant:** API inputs/outputs are not used for model training; short retention window. | **Compliant:** Zero data retention/training by default on commercial API calls. |
| **Latency & Rate Limits** | Ultra-low latency (Flash) with generous rate limits and easy billing setup. | High reliability and mature SDK ecosystem. | High quality, though stricter initial rate limits on lower tiers. |

---

## 3. Shortlist & Final Recommendation

1. **Primary Provider: Google Gemini (gemini-1.5-flash)**
   * **Rationale:** Massive context window (1M+ tokens) allows processing entire multi-page Arabic/English PDFs cleanly, combined with ultra-low cost per session and fast response times.
2. **Fallback / Secondary Provider: OpenAI (gpt-4o-mini)**
   * **Rationale:** Reliable backup option with strong Arabic fluency and predictable JSON structured outputs if primary limits or outages occur.

---

## 4. Privacy & Cost Guardrails
* **Phase 1 Rule:** Only mock/synthetic payloads are used during development; no real user PDF content is transmitted.
* **Estimated Session Cost:** Less than $0.005 per standard document Q&A session using gemini-1.5-flash.
