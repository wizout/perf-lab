#!/usr/bin/env python3
# python3 scripts/energy_from_hwinfo.py windows/power.csv windows/phases.csv [out_dir]
import csv
import os
import sys
from collections import defaultdict
from datetime import datetime

power_csv = sys.argv[1]
phases_csv = sys.argv[2]
out_dir = sys.argv[3] if len(sys.argv) > 3 else os.path.dirname(power_csv)

TS_FMT = "%Y-%m-%d %H:%M:%S.%f"
PKG = "CPU Package Power"
SOC = "CPU SoC Power (SVI2 TFN)"
GPU = "GPU Power"
CORES = "ΣCore"


def ts(s):
    return datetime.strptime(s, TS_FMT).timestamp()


series = defaultdict(list)
with open(power_csv, encoding="utf-8-sig") as f:
    for r in csv.DictReader(f):
        series[r["label"]].append((ts(r["ts"]), float(r["value_w"])))

# сума потужності по всіх ядрах
core_labels = sorted(l for l in series if l.startswith("Core ") and l.endswith(" Power") and "SVI2" not in l)
core_sum = defaultdict(float)
for l in core_labels:
    for t, v in series[l]:
        core_sum[t] += v
series[CORES] = sorted(core_sum.items())


def integrate(label, a, b):
    # трапеції, повертає енергію за [a,b], середню потужність і к-сть точок
    pts = [(t, v) for t, v in series[label] if a <= t <= b]
    if len(pts) < 2:
        return float("nan"), float("nan"), len(pts)
    e = 0.0
    for (t1, v1), (t2, v2) in zip(pts, pts[1:]):
        e += (t2 - t1) * (v1 + v2) / 2
    p_avg = e / (pts[-1][0] - pts[0][0])
    return p_avg * (b - a), p_avg, len(pts)


with open(phases_csv, encoding="utf-8-sig") as f:
    phases = list(csv.DictReader(f))

rows = []
for p in phases:
    a, b = ts(p["start"]), ts(p["end"])
    e_pkg, p_pkg, n = integrate(PKG, a, b)
    e_core, p_core, _ = integrate(CORES, a, b)
    _, p_soc, _ = integrate(SOC, a, b)
    e_gpu, p_gpu, _ = integrate(GPU, a, b)
    rows.append({
        "phase": p["phase"],
        "T": b - a,
        "n": n,
        "runs": int(p["runs"]),
        "cpu_prog": float(p["prog_cpu_s"]),
        "cpu_other": float(p["sys_cpu_s"]),
        "wall": float(p["prog_wall_s"]),
        "P_pkg": p_pkg, "E_pkg": e_pkg,
        "P_core": p_core, "E_core": e_core,
        "P_soc": p_soc,
        "P_gpu": p_gpu, "E_gpu": e_gpu,
    })

idle = next(r for r in rows if r["phase"] == "IDLE")
lines = []

lines.append("Джерело: HWiNFO64 Shared Memory, AMD Ryzen 3 2200G (SMU), опитування 1 Гц")
lines.append("")
lines.append("3.1 Енергія системи за вікно (CPU package; GPU окремо)")
lines.append(f"{'phase':<10}{'T,s':>7}{'runs':>5}{'P_pkg,W':>9}{'E_pkg,J':>9}{'P_cores,W':>10}{'P_SoC,W':>9}{'P_GPU,W':>9}{'E_pkg+GPU,J':>12}")
for r in rows:
    lines.append(f"{r['phase']:<10}{r['T']:>7.1f}{r['runs']:>5}{r['P_pkg']:>9.2f}{r['E_pkg']:>9.1f}"
                 f"{r['P_core']:>10.2f}{r['P_soc']:>9.2f}{r['P_gpu']:>9.2f}{r['E_pkg'] + r['E_gpu']:>12.1f}")

lines.append("")
lines.append("3.2 Енергія ОДНОГО запуску програми")
lines.append(f"{'phase':<10}{'t_run,s':>8}{'A marg,J':>10}{'B share,J':>10}{'share':>7}{'C cores,J':>10}{'ΔP_pkg,W':>9}")

# a - маржинальна, b - за часткою cpu (фон міряю в idle), c - тільки ядра
bg_rate = idle["cpu_other"] / idle["T"]
res = {}
for r in rows:
    if r["phase"] == "IDLE":
        continue
    k = max(r["runs"], 1)
    e_a = (r["E_pkg"] - idle["P_pkg"] * r["T"]) / k
    share = r["cpu_prog"] / (r["cpu_prog"] + bg_rate * r["T"])
    e_b = r["E_pkg"] * share / k
    e_c = (r["E_core"] - idle["P_core"] * r["T"]) / k
    dp = r["P_pkg"] - idle["P_pkg"]
    res[r["phase"]] = {"t": r["wall"] / k, "A": e_a, "C": e_c}
    lines.append(f"{r['phase']:<10}{r['wall'] / k:>8.2f}{e_a:>10.1f}{e_b:>10.1f}{share:>7.0%}{e_c:>10.1f}{dp:>9.2f}")

lines.append("")
lines.append("4.4 Порівняння (O0 = 1.00)")
base = res.get("prog_O0")
for ph, v in res.items():
    lines.append(f"{ph:<10} час ×{base['t'] / v['t']:.1f} швидше, "
                 f"енергія/запуск (A) ×{base['A'] / v['A']:.1f} менше, (C) ×{base['C'] / v['C']:.1f} менше")
lines.append(f"idle: P_pkg={idle['P_pkg']:.2f} W, ΣP_cores={idle['P_core']:.2f} W, P_GPU={idle['P_gpu']:.2f} W")

report = "\n".join(lines)
print(report)
with open(os.path.join(out_dir, "energy_report.txt"), "w", encoding="utf-8") as f:
    f.write(report + "\n")

try:
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    t0 = series[PKG][0][0]
    fig, ax = plt.subplots(figsize=(11, 4))
    for label, name in [(PKG, "CPU package"), (CORES, "Σ cores"), (SOC, "SoC")]:
        ax.plot([t - t0 for t, _ in series[label]], [v for _, v in series[label]], label=name, lw=1.4)

    colors = {"IDLE": "#999999", "prog_O0": "#d62728", "prog_O3": "#2ca02c", "prog_avx2": "#1f77b4"}
    for p in phases:
        a, b = ts(p["start"]) - t0, ts(p["end"]) - t0
        ax.axvspan(a, b, color=colors.get(p["phase"], "#ccc"), alpha=0.12)
        ax.text((a + b) / 2, ax.get_ylim()[1] * 0.95, p["phase"], ha="center", va="top", fontsize=9)

    ax.set_xlabel("час, с")
    ax.set_ylabel("потужність, W")
    ax.legend(loc="upper center", bbox_to_anchor=(0.5, -0.2), ncol=3, frameon=False)
    ax.set_title("Ryzen 3 2200G: потужність CPU по фазах (HWiNFO, 1 Гц)")
    fig.tight_layout()
    fig.savefig(os.path.join(out_dir, "power_timeline.png"), dpi=130)
except Exception as e:
    print("plot skipped:", e)
