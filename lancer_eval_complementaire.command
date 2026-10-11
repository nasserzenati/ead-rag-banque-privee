#!/bin/zsh
# Évaluation complémentaire préenregistrée (PROTOCOLE_EVAL_COMPLEMENTAIRE_2026-10-08.md)
#   1. E2 : ablation — v2 puis v3 sur le jeu sommatif Q25–Q34 (v1 et v4 existent déjà)
#   2. E1 : injections inconnues (BIPIA), bout en bout, v4, deux modèles
# Durée estimée : 40 à 60 minutes. Laisser le Mac allumé et branché.
cd "$(dirname "$0")"
mkdir -p resultats
LOG="resultats/log_eval_complementaire.txt"
exec > >(tee -a "$LOG") 2>&1
echo "=== Évaluation complémentaire — démarrage $(date '+%d.%m.%Y %H:%M')"
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
IDS="Q25,Q26,Q27,Q28,Q29,Q30,Q31,Q32,Q33,Q34"
echo "ÉTAPE 1/3 : E2 — v2 sur le jeu sommatif"
"$PY" rag_test.py --pipeline v2 --ids $IDS --tag E2-ablation
echo "ÉTAPE 2/3 : E2 — v3 sur le jeu sommatif"
"$PY" rag_test.py --pipeline v3 --ids $IDS --tag E2-ablation
echo "ÉTAPE 3/3 : E1 — injections inconnues (BIPIA), bout en bout"
"$PY" test_E1_bout_en_bout.py
echo "=== TERMINÉ $(date '+%H:%M') — prévenir Claude"
