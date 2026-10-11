#!/bin/zsh
# Itération 4 (protocole pré-enregistré PROTOCOLE_v4.md) :
#   1. v3 (référence) sur les nouvelles questions Q25–Q34
#   2. v4 sur les 34 questions
#   3. v4 sans contrôle d'accès (test de fuite) sur Q11, Q12, Q32
cd "$(dirname "$0")"
mkdir -p resultats
LOG="resultats/log_v4.txt"
exec > >(tee -a "$LOG") 2>&1
echo "=== Itération 4 — démarrage $(date '+%d.%m.%Y %H:%M')"
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
echo "ÉTAPE 1/3 : v3 (référence) sur Q25–Q34"
"$PY" rag_test.py --pipeline v3 --ids Q25,Q26,Q27,Q28,Q29,Q30,Q31,Q32,Q33,Q34
echo "ÉTAPE 2/3 : v4 sur les 34 questions"
"$PY" rag_test.py --pipeline v4
echo "ÉTAPE 3/3 : v4 sans contrôle d'accès (Q11, Q12, Q32)"
"$PY" rag_test.py --pipeline v4 --sans-acl --ids Q11,Q12,Q32
echo "=== TERMINÉ $(date '+%H:%M')"
