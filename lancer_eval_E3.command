#!/bin/zsh
# Évaluation complémentaire E3 (PROTOCOLE_EVAL_E3_2026-10-11.md) : hors corpus puis ablation par composant.
# Durée estimée : 45 à 75 minutes. Laisser le Mac allumé et branché.
cd "$(dirname "$0")"
mkdir -p resultats
LOG="resultats/log_eval_E3.txt"
exec > >(tee -a "$LOG") 2>&1
echo "=== E3 — démarrage $(date '+%d.%m.%Y %H:%M')"
if [ ! -f questions_E3_hors_corpus.csv ]; then echo "STOP : questions_E3_hors_corpus.csv manquant (voir la consigne)."; exit 1; fi
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
export AEGIS_PATH="$HOME/aegis"
shasum -a 256 questions_E3_hors_corpus.csv PROTOCOLE_EVAL_E3_2026-10-11.md
echo "ÉTAPE 1/2 : E3-a — questions hors corpus (v1 et v4)"
"$PY" eval_E3.py hors-corpus
echo "ÉTAPE 2/2 : E3-b — ablation par composant (v3 + un composant)"
"$PY" eval_E3.py ablation
echo "=== TERMINÉ $(date '+%H:%M') — prévenir Claude"
