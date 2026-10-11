#!/bin/zsh
# Itération 2 : pipeline v1 sur les nouvelles questions, puis pipeline v2 optimisé sur toutes.
cd "$(dirname "$0")"
mkdir -p resultats
LOG="resultats/log_v2.txt"
exec > >(tee -a "$LOG") 2>&1
echo "=== Itération 2 — démarrage $(date '+%d.%m.%Y %H:%M')"
if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
  open -a Ollama
  for i in {1..45}; do sleep 2; curl -s http://localhost:11434/api/tags >/dev/null 2>&1 && break; done
fi
PY=""
for p in "/opt/anaconda3" "$HOME/anaconda3" "$HOME/miniconda3" "$HOME/opt/anaconda3" "$HOME/opt/miniconda3"; do
  [ -x "$p/bin/python" ] && PY="$p/bin/python" && break
done
[ -z "$PY" ] && PY="$(command -v python3)"
echo "ÉTAPE 1/3 : pipeline v1 sur les questions de test Q17-Q24"
"$PY" rag_test.py --pipeline v1 --ids Q17,Q18,Q19,Q20,Q21,Q22,Q23,Q24
echo "ÉTAPE 2/3 : pipeline v2 sur les 24 questions"
"$PY" rag_test.py --pipeline v2
echo "ÉTAPE 3/3 : pipeline v2 sans contrôle d'accès (Q11, Q12)"
"$PY" rag_test.py --pipeline v2 --sans-acl --ids Q11,Q12
echo "=== TERMINÉ $(date '+%H:%M')"
