#!/usr/bin/env bash
# Повний прогін профілювання для Linux (пп. 1, 2, 4.2, 4.3; енергія — п. 3 якщо є RAPL).
# Запуск із кореня репозиторію:  ./scripts/run_linux.sh
# Результати: results/<variant>/...
set -eu
cd "$(dirname "$0")/.."

FREQ=${FREQ:-999}            # частота семплювання perf record, Гц
VARIANTS=${VARIANTS:-"O0 O3 avx2"}
FG=tools/FlameGraph

command -v perf >/dev/null || { echo "perf не знайдено (sudo apt install linux-tools-generic)"; exit 1; }
[ -d "$FG" ] || git clone --depth 1 https://github.com/brendangregg/FlameGraph "$FG"

make -s all
mkdir -p results

# Чи є апаратний лічильник енергії (RAPL)?
HAS_RAPL=0
if perf list 2>/dev/null | grep -q 'power/energy-pkg/'; then HAS_RAPL=1; fi

for v in $VARIANTS; do
  P=./build/prog_$v
  R=results/$v
  mkdir -p "$R"
  echo "===== $v ====="

  # 2.1 /usr/bin/time --verbose
  /usr/bin/time --verbose "$P" > "$R/program_output.txt" 2> "$R/time_verbose.txt"

  # 2.2 perf stat -d (5 повторів → середнє ± розкид)
  perf stat -d -r 5 -o "$R/perf_stat.txt" "$P" > /dev/null

  # 2.3 + 1: perf record з call-graph → perf report → FlameGraph
  perf record -F "$FREQ" --call-graph dwarf -o "$R/perf.data" "$P" > /dev/null 2> "$R/perf_record.log"
  perf report -i "$R/perf.data" --stdio --no-children --sort symbol 2>/dev/null \
      | grep -v '^$' | head -60 > "$R/perf_report.txt"
  perf report -i "$R/perf.data" --stdio --children --sort symbol 2>/dev/null \
      | grep -v '^$' | head -80 > "$R/perf_report_children.txt"
  perf script -i "$R/perf.data" 2>/dev/null > "$R/out.perf"
  "$FG/stackcollapse-perf.pl" "$R/out.perf" > "$R/out.folded"
  "$FG/flamegraph.pl" --title "prog_$v CPU FlameGraph" "$R/out.folded" > "$R/flamegraph.svg"
  # анотація гарячої функції з асемблером
  perf annotate -i "$R/perf.data" --stdio -M intel -s matmul 2>/dev/null > "$R/perf_annotate_matmul.txt" || true
  rm -f "$R/out.perf"

  # 3. Енергія (лише якщо є RAPL на хості)
  if [ "$HAS_RAPL" = 1 ]; then
    # 3.1 система під час виконання програми
    perf stat -a -e power/energy-pkg/,power/energy-ram/ -r 3 -o "$R/energy_system.txt" "$P" > /dev/null || true
    # базлайн простою стільки ж часу
    T=$(grep -oP 'total\s+\K[0-9.]+' "$R/program_output.txt")
    perf stat -a -e power/energy-pkg/ -o "$R/energy_idle.txt" sleep "$T" || true
  fi
done

# Різницевий FlameGraph: червоне — стало повільніше, синє — швидше (O0 → avx2)
# форма графіка — "до" (O0), колір — зміна після оптимізації (синє = стало менше)
# прибираємо ім'я процесу з кореня стека, щоб стеки двох збірок зіставлялись
for v in O0 avx2; do sed 's/^prog_[^;]*;/prog;/' results/$v/out.folded > results/$v/out.norm.folded; done
"$FG/difffolded.pl" results/avx2/out.norm.folded results/O0/out.norm.folded \
  | "$FG/flamegraph.pl" --title "Differential FlameGraph: O0 -> avx2 (blue = fewer samples after optimization)" --negate > results/flamegraph_diff_O0_avx2.svg

echo "Готово. Дивись results/"
