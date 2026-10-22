#!/usr/bin/env bash
# запуск з кореня репо: ./scripts/run_linux.sh
set -eu
cd "$(dirname "$0")/.."

FREQ=${FREQ:-999}
VARIANTS=${VARIANTS:-"O0 O3 avx2"}
FG=tools/FlameGraph

command -v perf >/dev/null || { echo "perf not found (sudo apt install linux-tools-generic)"; exit 1; }
[ -d "$FG" ] || git clone --depth 1 https://github.com/brendangregg/FlameGraph "$FG"

make -s all
mkdir -p results

has_rapl=0
if perf list 2>/dev/null | grep -q 'power/energy-pkg/'; then has_rapl=1; fi

for v in $VARIANTS; do
  prog=./build/prog_$v
  out=results/$v
  mkdir -p "$out"
  echo "== $v =="

  /usr/bin/time --verbose "$prog" > "$out/program_output.txt" 2> "$out/time_verbose.txt"
  perf stat -d -r 5 -o "$out/perf_stat.txt" "$prog" > /dev/null

  perf record -F "$FREQ" --call-graph dwarf -o "$out/perf.data" "$prog" > /dev/null 2> "$out/perf_record.log"
  perf report -i "$out/perf.data" --stdio --no-children --sort symbol 2>/dev/null | grep -v '^$' | head -60 > "$out/perf_report.txt"
  perf report -i "$out/perf.data" --stdio --children --sort symbol 2>/dev/null | grep -v '^$' | head -80 > "$out/perf_report_children.txt"
  perf script -i "$out/perf.data" 2>/dev/null > "$out/out.perf"
  "$FG/stackcollapse-perf.pl" "$out/out.perf" > "$out/out.folded"
  "$FG/flamegraph.pl" --title "prog_$v CPU FlameGraph" "$out/out.folded" > "$out/flamegraph.svg"
  perf annotate -i "$out/perf.data" --stdio -M intel -s matmul 2>/dev/null > "$out/perf_annotate_matmul.txt" || true
  rm -f "$out/out.perf"

  # енергія тільки якщо є rapl
  if [ "$has_rapl" = 1 ]; then
    perf stat -a -e power/energy-pkg/,power/energy-ram/ -r 3 -o "$out/energy_system.txt" "$prog" > /dev/null || true
    t=$(grep -oP 'total\s+\K[0-9.]+' "$out/program_output.txt")
    perf stat -a -e power/energy-pkg/ -o "$out/energy_idle.txt" sleep "$t" || true
  fi
done

# diff flamegraph O0 -> avx2, ім'я процесу прибираю щоб стеки збігались
for v in O0 avx2; do
  sed 's/^prog_[^;]*;/prog;/' results/$v/out.folded > results/$v/out.norm.folded
done
"$FG/difffolded.pl" results/avx2/out.norm.folded results/O0/out.norm.folded \
  | "$FG/flamegraph.pl" --title "Differential FlameGraph: O0 -> avx2 (blue = fewer samples after optimization)" --negate \
  > results/flamegraph_diff_O0_avx2.svg

echo "done, see results/"
