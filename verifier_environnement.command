#!/bin/zsh
# Relève l'environnement exact de la maquette (reproductibilité) et vérifie que le README fonctionne tel quel.
# Écrit resultats/environnement_<date>.txt. Ne modifie rien.
cd "$(dirname "$0")"
OUT="resultats/environnement_$(date '+%Y-%m-%d_%H%M').txt"
exec > >(tee "$OUT") 2>&1
echo "=== Environnement de la maquette — $(date '+%d.%m.%Y %H:%M')"
echo "--- Machine"; sw_vers 2>/dev/null; uname -m; sysctl -n machdep.cpu.brand_string 2>/dev/null; echo "RAM : $(( $(sysctl -n hw.memsize) / 1073741824 )) Go"
if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
  open -a Ollama
  for i in {1..45}; do sleep 2; curl -s http://localhost:11434/api/tags >/dev/null 2>&1 && break; done
fi
echo "--- Ollama"; ollama --version 2>/dev/null || curl -s http://localhost:11434/api/version
echo "--- Modèles (nom, empreinte, taille)"
curl -s http://localhost:11434/api/tags | /usr/bin/python3 -c "
import json,sys
for m in json.load(sys.stdin)['models']:
    if any(k in m['name'] for k in ('qwen3:8b','apertus','bge-m3')):
        d=m.get('details',{})
        print(m['name'], '|', m['digest'], '|', round(m['size']/1e9,2),'Go |', d.get('parameter_size',''), d.get('quantization_level',''))"
PY=""
for p in "/opt/anaconda3" "$HOME/anaconda3" "$HOME/miniconda3" "$HOME/opt/anaconda3" "$HOME/opt/miniconda3"; do
  [ -x "$p/bin/python" ] && PY="$p/bin/python" && break
done
[ -z "$PY" ] && PY="$(command -v python3)"
echo "--- Python"; echo "$PY"; "$PY" --version
"$PY" -c "
import importlib
for p in ('numpy','pypdf','yaml'):
    try:
        m=importlib.import_module(p); print(p, getattr(m,'__version__','?'))
    except Exception as e: print(p,'ABSENT',e)"
echo "--- Aegis"; export AEGIS_PATH="$HOME/aegis"
git -C "$AEGIS_PATH" --no-optional-locks log -1 --format='%H %ci %s'
git -C "$AEGIS_PATH" --no-optional-locks rev-parse --abbrev-ref HEAD
echo "--- Empreintes des fichiers figés"
shasum -a 256 questions.csv PROTOCOLE_v4.md rag_test.py metriques_recherche.py corpus/*
echo "--- Test du README : question libre en v4"
"$PY" rag_test.py --pipeline v4 --modeles qwen3 --role gestionnaire --question "Qui doit approuver l'ouverture d'une relation avec un PEP étranger ?"
echo "=== TERMINÉ — fichier : $OUT"
