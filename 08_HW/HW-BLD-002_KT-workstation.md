# HW-BLD-002 — KT Workstation

**Saga:** KTS-0000001
**Author:** AI-Architect (Claude, 2026-05-01)
**Status:** options surveyed, top pick identified, **not yet ordered**
**Distinct from:** `HW-BLD-001` (ODIN workstation, EPYC 7543 + dual RTX PRO 4500)

## Constraints

- Budget: ~$6,000 system (excludes monitor/peripherals).
- Workload: local AI RAG today, 70B-class inference tomorrow, Java/Spring + Angular dev throughout.
- Stated preferences: 4 memory channels acceptable; top-end Threadripper PRO out (cost); Mac Mini considered but skeptical.
- CUDA path strongly preferred (PyTorch / HuggingFace / Ollama all happy paths).

## Options surveyed (one line each, per your request)

- **Mac Mini M4 Pro 64GB** (~$2.4K) — MLX inference works, but no CUDA cuts you off from PyTorch/HF; leaves $3.6K stranded.
- **Mac Studio M4 Max 128GB unified** (~$4.7K) — best inference-per-dollar for 70B via MLX, but locks out CUDA tooling; **anti-recommend given your toolchain**.
- **AM5 Ryzen 9950X + RTX PRO 4500 Blackwell 32GB + 2×32GB DDR5 + 2TB NVMe** (~$4.5K) — your published Path D from the RDIMM Tax paper, only 2 memory channels (contradicts your 4-channel intuition).
- **Threadripper 7960X (24c) + ASUS Pro WS TRX50-SAGE WIFI + 4×32GB DDR5 ECC + RTX 5090 32GB GDDR7 + Samsung 990 Pro 4TB** (~$5.9K) — **TOP PICK**: 4 memory channels match your intuition, full CUDA, 128GB ECC, 70B-class inference today, comfortably hosts Java/Angular dev.
- **Threadripper PRO 7965WX (24c) + WRX90** ($8K+ before GPU) — 8 channels but blows budget; **anti-recommend per your stated constraint**.
- **Xeon W7-2495X (24c) + ASUS Pro WS W790-ACE + 8×16GB DDR5 ECC + RTX 5090** (~$6.5K) — 8-channel ECC, but Xeon-W premium pushes ~8% over budget for marginal real-world gain on inference workloads.
- **Used EPYC 7543 + H12SSL-CT + dual RTX PRO 4500 Blackwell** (~$5K, your existing ODIN spec) — earmarked for ODIN; **anti-recommend mixing tracks**.

## Top pick rationale (one paragraph)

Threadripper 7960X on TRX50 with 4-channel DDR5 ECC and a single RTX 5090 (32GB GDDR7) lands inside budget while honoring your "4 channels is right" instinct. The 5090's 32GB VRAM is enough for Llama 3.3 70B at Q4_K_M with KV cache headroom — the headline inference target. PCIe Gen5 ×16 keeps GPU-attach bandwidth uncompromised. 128GB ECC system RAM gives you Java IDE + Angular dev + Docker comfortably alongside model serving. The TRX50 platform is current (HEDT, not server), so motherboards and BIOS support are good and parts are available — unlike WRX90 (PRO) which doubles board cost for memory channels you don't need at this workload size.

## Parts list (illustrative — verify pricing at order time)

| Part | Item | Approx |
|---|---|---|
| CPU | AMD Threadripper 7960X (24c/48t, 4.2/5.3 GHz, sTR5) | $1,500 |
| Motherboard | ASUS Pro WS TRX50-SAGE WIFI | $900 |
| RAM | 4×32GB DDR5-5600 ECC RDIMM | $700 |
| GPU | NVIDIA RTX 5090 32GB GDDR7 | $2,000 |
| Storage (boot+models) | Samsung 990 Pro 4TB NVMe | $300 |
| Storage (corpus+code) | Samsung 990 Pro 2TB NVMe | $180 |
| Cooler | Noctua NH-U14S TR5-SP6 | $130 |
| PSU | Corsair RM1200x SHIFT 1200W 80+ Gold | $230 |
| Case | Fractal Design Define 7 XL | $260 |
| **Subtotal** | | **$6,200** |

Slight overage; tune by dropping the second NVMe at order time or accepting a 5%-over-budget premium for headroom.

## Open questions before order

- Does Newegg / Micro Center / B&H currently have RTX 5090 available without scalper markup? (Verify week-of.)
- Is the ECC RDIMM premium (vs UDIMM) worth ~$200 for your use case? Yes for sustained 24/7 inference; arguably no for nights/weekends KT work — but you've consistently chosen ECC across builds.
- Confirm TRX50 board has at least 2× M.2 Gen5 slots for the dual-NVMe plan.

## Migration plan

When this box arrives:
1. Pull `C:\RAW\KT\` from laptop via robocopy.
2. Install Ollama, pull `nomic-embed-text` and `llama3.3:70b-instruct-q4_K_M`.
3. Update `07_RAG/pipeline/config.yml` to point at the new generator model; keep embedding model identical so no re-embedding required.
4. Smoke-test query latency; expect dramatic improvement on 70B vs 8B.
5. Append entry to `06_Status/HISTORY.md` with the model swap and a benchmark.
