#!/bin/zsh
# Mesures post-v4 (plan du 02.10.2026, § 3). La v4 reste figée : rien ne change dans la génération,
# sauf pour la mesure M-d qui est explicitement marquée (--refus-systeme).
#   M-a  v1 (base de référence propre) sur Q25–Q34, 2 modèles                  ≈ 10 min
#   M-c  v4 sur Q25–Q34, 3 passages (variance ; passage 1 = comparaison au 01.10) ≈ 30 min
#   M-d  v4 Apertus sur Q23–Q27, phrase de refus dans le prompt système         ≈ 3 min
#   M-b  v4 recherche seule sur Q25–Q34 (extraits à juger par Nasser, sans modèle) ≈ 1 min
#   M-f  recall@5 / MRR au niveau de l'article, v1 à v4 (sans modèle)           ≈ 2 min
#   M-g  durée d'Aegis chronométrée dans les passages v4 (colonne duree_aegis_s)
cd "$(dirname "$0")"
mkdir -p resultats
LOG="resultats/log_mesures_2026-10.txt"
exec > >(tee -a "$LOG") 2>&1
echo "=== Mesures post-v4 — démarrage $(date '+%d.%m.%Y %H:%M')"
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
SOMMATIF="Q25,Q26,Q27,Q28,Q29,Q30,Q31,Q32,Q33,Q34"

echo "M-a : v1 sur Q25–Q34"
"$PY" rag_test.py --pipeline v1 --ids "$SOMMATIF" --tag Ma-base-v1

for k in 1 2 3; do
  echo "M-c : v4 sur Q25–Q34, passage $k/3"
  "$PY" rag_test.py --pipeline v4 --ids "$SOMMATIF" --tag "Mc-passage$k"
done

echo "M-d : v4 Apertus, phrase de refus dans le prompt système, Q23–Q27"
"$PY" rag_test.py --pipeline v4 --modeles apertus --ids Q23,Q24,Q25,Q26,Q27 --refus-systeme --tag Md

echo "M-b : v4 recherche seule sur Q25–Q34"
"$PY" rag_test.py --pipeline v4 --recherche-seule --ids "$SOMMATIF" --tag Mb

echo "M-f : métriques de recherche v1–v4"
"$PY" metriques_recherche.py --pipelines v1,v2,v3,v4

echo "=== TERMINÉ $(date '+%H:%M') — fichiers dans resultats/ (suffixes Ma, Mc-passage1..3, Md, Mb, metriques_recherche_*)"
