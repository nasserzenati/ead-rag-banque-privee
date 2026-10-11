#!/bin/zsh
# Lance tout le prototype : modèles, corpus, tests. Double-cliquer dans le Finder.
cd "$(dirname "$0")"
mkdir -p resultats
LOG="resultats/log_lancement.txt"
exec > >(tee -a "$LOG") 2>&1
echo "=== Prototype RAG EAD — démarrage $(date '+%d.%m.%Y %H:%M')"

# 1. Ollama
if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
  echo "Démarrage d'Ollama…"
  open -a Ollama
  for i in {1..45}; do sleep 2; curl -s http://localhost:11434/api/tags >/dev/null 2>&1 && break; done
fi
curl -s http://localhost:11434/api/tags >/dev/null 2>&1 || { echo "ERREUR : Ollama ne répond pas."; exit 1; }
echo "ÉTAPE 1/4 : modèles"
ollama pull MichelRosselli/apertus:8b-instruct-2509-q4_k_m || { echo "ERREUR pull Apertus"; exit 1; }
ollama pull bge-m3 || { echo "ERREUR pull bge-m3"; exit 1; }

# 2. Python (conda si présent)
PY=""
for p in "$HOME/miniconda3" "$HOME/anaconda3" "$HOME/opt/miniconda3" "$HOME/opt/anaconda3" \
         "/opt/homebrew/Caskroom/miniconda/base" "/opt/miniconda3" "/opt/anaconda3"; do
  [ -x "$p/bin/python" ] && PY="$p/bin/python" && break
done
[ -z "$PY" ] && PY="$(command -v python3)"
echo "ÉTAPE 2/4 : dépendances ($PY)"
"$PY" -m pip install --quiet pypdf numpy || "$PY" -m pip install --quiet --user pypdf numpy

# 3. Corpus public
echo "ÉTAPE 3/4 : corpus"
"$PY" telecharger_corpus.py

# 4. Tests
echo "ÉTAPE 4/4 : tests (environ 15 à 20 minutes)"
"$PY" rag_test.py
echo "--- Test de fuite sans contrôle d'accès"
"$PY" rag_test.py --sans-acl --ids Q11,Q12
echo "=== TERMINÉ $(date '+%H:%M')"
