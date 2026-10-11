#!/bin/zsh
# Itération 3 : pipeline v3 = v2 + Aegis (control plane), sur les 24 questions.
cd "$(dirname "$0")"
mkdir -p resultats
LOG="resultats/log_v3.txt"
exec > >(tee -a "$LOG") 2>&1
echo "=== Itération 3 (Aegis) — démarrage $(date '+%d.%m.%Y %H:%M')"
if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
  open -a Ollama
  for i in {1..45}; do sleep 2; curl -s http://localhost:11434/api/tags >/dev/null 2>&1 && break; done
fi
PY=""
for p in "/opt/anaconda3" "$HOME/anaconda3" "$HOME/miniconda3" "$HOME/opt/anaconda3" "$HOME/opt/miniconda3"; do
  [ -x "$p/bin/python" ] && PY="$p/bin/python" && break
done
[ -z "$PY" ] && PY="$(command -v python3)"
"$PY" -c "import yaml" 2>/dev/null || "$PY" -m pip install --quiet pyyaml
AEGIS_PATH="$HOME/aegis" "$PY" rag_test.py --pipeline v3
echo "=== TERMINÉ $(date '+%H:%M')"
