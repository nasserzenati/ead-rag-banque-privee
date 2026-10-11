#!/usr/bin/env python3
"""Évaluation complémentaire E3 (protocole PROTOCOLE_EVAL_E3_2026-10-11.md, préenregistré).

La maquette (rag_test.py) n'est PAS modifiée : ce script la réutilise et remplace, le temps d'un passage,
une seule de ses fonctions, pour isoler un composant.

  python eval_E3.py hors-corpus   # E3-a : questions hors corpus écrites par l'auteur, v1 et v4, deux modèles
  python eval_E3.py ablation      # E3-b : v3 + UN seul composant de la v4 (découpage / recherche hybride / consigne)

Les résultats sont écrits dans resultats/ avec les étiquettes E3-… (mêmes colonnes que d'habitude).
"""
import shutil
import sys
import tempfile
from pathlib import Path

import rag_test as R

ICI = Path(__file__).resolve().parent
FICHIER_HC = ICI / "questions_E3_hors_corpus.csv"
SOMMATIF = "Q25,Q26,Q27,Q28,Q29,Q30,Q31,Q32,Q33,Q34"

_orig = {"construire_index": R.construire_index, "rechercher": R.rechercher, "generer": R.generer, "BASE": R.BASE}


def _restaurer():
    for k, v in _orig.items():
        setattr(R, k, v)


def lancer(args):
    print("\n>>> rag_test.py " + " ".join(args), flush=True)
    sys.argv = ["rag_test.py"] + args
    try:
        R.main()
    finally:
        _restaurer()


def hors_corpus():
    if not FICHIER_HC.exists():
        sys.exit(f"Fichier introuvable : {FICHIER_HC.name} (à écrire par l'auteur, voir la consigne).")
    with tempfile.TemporaryDirectory() as d:
        shutil.copy(FICHIER_HC, Path(d) / "questions.csv")
        for pipeline in ("v1", "v4"):
            R.BASE = Path(d)          # seul effet : rag_test lit les questions de ce dossier
            lancer(["--pipeline", pipeline, "--tag", "E3-hors-corpus"])


def ablation():
    # 1) v3 + découpage structurel de la v4 (recherche vectorielle seule, consigne v3)
    R.construire_index = lambda p="v2": _orig["construire_index"]("v4" if p == "v1" else p)
    lancer(["--pipeline", "v3", "--ids", SOMMATIF, "--tag", "E3-v3+decoupage"])
    # 2) v3 + recherche hybride (découpage v3, consigne v3)
    R.rechercher = lambda *a, **k: _orig["rechercher"](*a, **{**k, "hybride": True})
    lancer(["--pipeline", "v3", "--ids", SOMMATIF, "--tag", "E3-v3+hybride"])
    # 3) v3 + consigne de la v4 (langue imposée, phrase de refus ; découpage et recherche v3)
    R.generer = lambda m, q, e, pipeline="v2", **k: _orig["generer"](m, q, e, "v4" if pipeline == "v2" else pipeline, **k)
    lancer(["--pipeline", "v3", "--ids", SOMMATIF, "--tag", "E3-v3+consigne"])


if __name__ == "__main__":
    quoi = sys.argv[1] if len(sys.argv) > 1 else ""
    if quoi == "hors-corpus":
        hors_corpus()
    elif quoi == "ablation":
        ablation()
    else:
        sys.exit(__doc__)
