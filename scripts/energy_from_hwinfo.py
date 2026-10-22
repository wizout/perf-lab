#!/usr/bin/env python3
"""Енергія по фазах із HWiNFO Shared Memory (power.csv) + межі фаз (phases.csv).

Usage: python3 scripts/energy_from_hwinfo.py windows/power.csv windows/phases.csv [out_dir]

3.1 Енергія системи (CPU-пакет, + GPU як «решта ПК, що ми бачимо»):  E = ∫P dt (трапеції).
3.2 Енергія лише програми, трьома способами:
    A) маржинальна:   (E_pkg - P_idle * T) / runs
    B) за часткою CPU: E_pkg * cpu_prog / (cpu_prog + cpu_bg*T) / runs,
       cpu_bg — фоновий CPU-час ОС за секунду, виміряний у фазі IDLE
       (знімки Get-Process у фазах навантаження ненадійні: процеси, що завершились між знімками, «зникають»)
    C) по ядрах:      (∫ΣP_core dt - ΣP_core_idle * T) / runs   (лише ядра, без SoC/uncore)
"""
import csv, sys, os
from datetime import datetime
from collections import defaultdict

power_csv, phases_csv = sys.argv[1], sys.argv[2]
out_dir = sys.argv[3] if len(sys.argv) > 3 else os.path.dirname(power_csv)
F = "%Y-%m-%d %H:%M:%S.%f"
t = lambda s: datetime.strptime(s, F).timestamp()

# label -> [(ts, W)]
series = defaultdict(list)
for r in csv.DictReader(open(power_csv, encoding="utf-8-sig")):
    series[r["label"]].append((t(r["ts"]), float(r["value_w"])))
core_labels = sorted(l for l in series if l.startswith("Core ") and l.endswith(" Power") and "SVI2" not in l)
core_sum = defaultdict(float)
for l in core_labels:
    for ts, v in series[l]:
        core_sum[ts] += v
series["ΣCore"] = sorted(core_sum.items())

def integ(label, a, b):
    """∫P dt на [a,b] (трапеції) і середня P."""
    pts = [(ts, v) for ts, v in series[label] if a <= ts <= b]
    if len(pts) < 2:
        return float("nan"), float("nan"), len(pts)
    e = sum((t2 - t1) * (v1 + v2) / 2 for (t1, v1), (t2, v2) in zip(pts, pts[1:]))
    return e / (pts[-1][0] - pts[0][0]) * (b - a), e / (pts[-1][0] - pts[0][0]), len(pts)

phases = list(csv.DictReader(open(phases_csv, encoding="utf-8-sig")))
rows = []
for p in phases:
    a, b = t(p["start"]), t(p["end"])
    T = b - a
    E_pkg, P_pkg, n = integ("CPU Package Power", a, b)
    E_core, P_core, _ = integ("ΣCore", a, b)
    E_soc, P_soc, _ = integ("CPU SoC Power (SVI2 TFN)", a, b)
    E_gpu, P_gpu, _ = integ("GPU Power", a, b)
    rows.append(dict(phase=p["phase"], T=T, n=n, runs=int(p["runs"]),
                     cpu_prog=float(p["prog_cpu_s"]), cpu_other=float(p["sys_cpu_s"]),
                     wall=float(p["prog_wall_s"]),
                     P_pkg=P_pkg, E_pkg=E_pkg, P_core=P_core, E_core=E_core,
                     P_soc=P_soc, P_gpu=P_gpu, E_gpu=E_gpu))

idle = next(r for r in rows if r["phase"] == "IDLE")
lines = []
L = lines.append
L("Джерело: HWiNFO64 Shared Memory, AMD Ryzen 3 2200G (SMU), опитування 1 Гц")
L("")
L("3.1 Енергія системи за вікно (CPU package; GPU окремо)")
L(f"{'phase':<10}{'T,s':>7}{'runs':>5}{'P_pkg,W':>9}{'E_pkg,J':>9}{'P_cores,W':>10}{'P_SoC,W':>9}{'P_GPU,W':>9}{'E_pkg+GPU,J':>12}")
for r in rows:
    L(f"{r['phase']:<10}{r['T']:>7.1f}{r['runs']:>5}{r['P_pkg']:>9.2f}{r['E_pkg']:>9.1f}{r['P_core']:>10.2f}{r['P_soc']:>9.2f}{r['P_gpu']:>9.2f}{r['E_pkg']+r['E_gpu']:>12.1f}")
L("")
L("3.2 Енергія ОДНОГО запуску програми")
L(f"{'phase':<10}{'t_run,s':>8}{'A marg,J':>10}{'B share,J':>10}{'share':>7}{'C cores,J':>10}{'ΔP_pkg,W':>9}")
res = {}
for r in rows:
    if r["phase"] == "IDLE":
        continue
    k = max(r["runs"], 1)
    A = (r["E_pkg"] - idle["P_pkg"] * r["T"]) / k
    bg_rate = idle["cpu_other"] / idle["T"]
    share = r["cpu_prog"] / (r["cpu_prog"] + bg_rate * r["T"])
    B = r["E_pkg"] * share / k
    C = (r["E_core"] - idle["P_core"] * r["T"]) / k
    res[r["phase"]] = dict(t=r["wall"] / k, A=A, B=B, C=C, share=share, dP=r["P_pkg"] - idle["P_pkg"])
    L(f"{r['phase']:<10}{r['wall']/k:>8.2f}{A:>10.1f}{B:>10.1f}{share:>7.0%}{C:>10.1f}{r['P_pkg']-idle['P_pkg']:>9.2f}")
L("")
L("4.4 Порівняння (O0 = 1.00)")
base = res.get("prog_O0")
for ph, v in res.items():
    L(f"{ph:<10} час ×{base['t']/v['t']:.1f} швидше, енергія/запуск (A) ×{base['A']/v['A']:.1f} менше, (C) ×{base['C']/v['C']:.1f} менше")
L(f"idle: P_pkg={idle['P_pkg']:.2f} W, ΣP_cores={idle['P_core']:.2f} W, P_GPU={idle['P_gpu']:.2f} W")
txt = "\n".join(lines)
print(txt)
open(os.path.join(out_dir, "energy_report.txt"), "w", encoding="utf-8").write(txt + "\n")

# графік потужності з межами фаз
try:
    import matplotlib; matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    t0 = series["CPU Package Power"][0][0]
    fig, ax = plt.subplots(figsize=(11, 4))
    for lab, name in [("CPU Package Power", "CPU package"), ("ΣCore", "Σ cores"), ("CPU SoC Power (SVI2 TFN)", "SoC")]:
        ax.plot([ts - t0 for ts, _ in series[lab]], [v for _, v in series[lab]], label=name, lw=1.4)
    colors = {"IDLE": "#999999", "prog_O0": "#d62728", "prog_O3": "#2ca02c", "prog_avx2": "#1f77b4"}
    for p in phases:
        a, b = t(p["start"]) - t0, t(p["end"]) - t0
        ax.axvspan(a, b, color=colors.get(p["phase"], "#ccc"), alpha=0.12)
        ax.text((a + b) / 2, ax.get_ylim()[1] * 0.95, p["phase"], ha="center", va="top", fontsize=9)
    ax.set_xlabel("час, с"); ax.set_ylabel("потужність, W"); ax.legend(loc="upper center", bbox_to_anchor=(0.5, -0.2), ncol=3, frameon=False)
    ax.set_title("Ryzen 3 2200G: потужність CPU по фазах (HWiNFO, 1 Гц)")
    fig.tight_layout(); fig.savefig(os.path.join(out_dir, "power_timeline.png"), dpi=130)
except Exception as e:
    print("plot skipped:", e)
