#!/usr/bin/env python3
"""Mesure M-f (02.10.2026) : qualité de la recherche seule, au niveau de l'article, pour chaque pipeline.

Pour chaque question qui a une source attendue, on reconstitue les extraits tels que le pipeline les aurait
transmis au modèle (top-5 après filtre d'accès ; Aegis pour v3/v4), puis on calcule :
  - recall@5 (article) : part des cibles attendues (document + article si précisé) présentes dans le top-5 ;
  - MRR (article)      : moyenne de 1/rang de la première occurrence (0 si absente) ;
  - recall@5 (document) : même chose en ignorant le numéro d'article (le chiffre « 30/30 » du 01.10 était de ce type).
Aucun appel au modèle de génération. Sortie : resultats/metriques_recherche_<horodatage>.json et .md.
Usage : python3 metriques_recherche.py [--pipelines v1,v2,v3,v4]
"""
import argparse
import csv
import json
import re
from datetime import datetime

import rag_test as rt


def cibles(source_attendue):
    out = []
    if not source_attendue or source_attendue.startswith("(aucune"):
        return out
    for part in re.split(r"\s*(?:\+|;| et )\s*", source_attendue):
        cible = next((f for pat, f in rt.CIBLES if re.search(pat, part, re.I)), None)
        if not cible:
            continue
        m = re.search(r"art\.?\s*(\d+[a-z]?)", part, re.I)
        out.append((cible, m.group(1) if m else None))
    return out


def rang(cible, art, extraits):
    for i, (c, _) in enumerate(extraits, 1):
        if cible not in c["fichier"]:
            continue
        if art and not (c.get("article") == art or re.search(rf"\bArt\.\s*{art}(?![\da-z])", c["texte"])):
            continue
        return i
    return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--pipelines", default="v1,v2,v3,v4")
    a = ap.parse_args()
    pipelines = [p.strip() for p in a.pipelines.split(",")]
    with open(rt.BASE / "questions.csv", encoding="utf-8-sig") as fh:
        questions = [q for q in csv.DictReader(fh, delimiter=";") if cibles(q.get("source_attendue", ""))]
    print(f"{len(questions)} questions avec source attendue")
    horodatage = datetime.now().strftime("%Y-%m-%d_%H%M")
    resume, detail = {}, []
    RagGuard = politique = None
    for p in pipelines:
        v3 = p in ("v3", "v4")
        v4 = p == "v4"
        chunks, E = rt.construire_index("v4" if v4 else ("v1" if v3 else p))
        if v3 and RagGuard is None:
            RagGuard, _, politique = rt.charger_aegis("metriques")
        r_art, r_doc, rr_art, rr_doc = [], [], [], []
        for q in questions:
            if v3:
                garde = RagGuard(politique, q["role"], session_id=f"metriques-{horodatage}-{p}-{q['id']}")
                extraits = garde.filter(rt.rechercher(q["question"], q["role"], chunks, E, acl=False, k=20, hybride=v4)).kept
            else:
                extraits = rt.rechercher(q["question"], q["role"], chunks, E, acl=True)
            extraits = extraits[:rt.TOP_K]
            for cible, art in cibles(q["source_attendue"]):
                ra = rang(cible, art, extraits)
                rd = rang(cible, None, extraits)
                r_art.append(1 if ra else 0)
                r_doc.append(1 if rd else 0)
                rr_art.append(1 / ra if ra else 0.0)
                rr_doc.append(1 / rd if rd else 0.0)
                detail.append({"pipeline": p, "id": q["id"], "jeu": q.get("jeu", ""), "cible": cible,
                               "article": art or "", "rang_article": ra or "absent", "rang_document": rd or "absent"})
        n = len(r_art)
        resume[p] = {"n_cibles": n, "recall@5_article": round(sum(r_art) / n, 3), "MRR_article": round(sum(rr_art) / n, 3),
                     "recall@5_document": round(sum(r_doc) / n, 3), "MRR_document": round(sum(rr_doc) / n, 3)}
        print(p, resume[p], flush=True)
    rt.RESULTATS.mkdir(exist_ok=True)
    out = rt.RESULTATS / f"metriques_recherche_{horodatage}"
    json.dump({"date": horodatage, "top_k": rt.TOP_K, "resume": resume, "detail": detail},
              open(out.with_suffix(".json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    with open(out.with_suffix(".md"), "w", encoding="utf-8") as fh:
        fh.write(f"# Métriques de recherche (top-{rt.TOP_K}), {horodatage}\n\n")
        fh.write("| Pipeline | cibles | recall@5 article | MRR article | recall@5 document | MRR document |\n|---|---|---|---|---|---|\n")
        for p, r in resume.items():
            fh.write(f"| {p} | {r['n_cibles']} | {r['recall@5_article']:.2f} | {r['MRR_article']:.2f} | "
                     f"{r['recall@5_document']:.2f} | {r['MRR_document']:.2f} |\n")
        fh.write("\nLecture : « article » = le bon document ET le bon article dans les 5 extraits transmis au modèle ; "
                 "« document » = le bon document, n'importe quel passage (mesure plus indulgente, celle du 01.10). "
                 "Sans génération ; filtre d'accès appliqué selon le rôle de la question.\n")
    print(f"\nÉcrit : {out}.json / .md")


if __name__ == "__main__":
    main()
