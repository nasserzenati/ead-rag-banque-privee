#!/usr/bin/env python3
"""Télécharge les 4 documents publics du corpus (FINMA, LBA, LPD) dans corpus/."""
import json, re, sys, urllib.parse, urllib.request
from datetime import date
from pathlib import Path

CORPUS = Path(__file__).resolve().parent / "corpus"
UA = {"User-Agent": "Mozilla/5.0 (prototype academique HES-SO)"}

FINMA = {
    "FINMA_circ_2023-01_risques_operationnels.pdf":
        "https://www.finma.ch/fr/~/media/finma/dokumente/dokumentencenter/myfinma/rundschreiben/finma-rs-2023-01-20221207.pdf",
    "FINMA_communication_08-2024_IA.pdf":
        "https://www.finma.ch/fr/~/media/finma/dokumente/dokumentencenter/myfinma/4dokumentation/finma-aufsichtsmitteilungen/20241218-finma-aufsichtsmitteilung-08-2024.pdf",
}
FEDLEX = {  # fichier : identifiant ELI du texte consolidé
    "LBA_RS_955.0.pdf": "eli/cc/1998/892_892_892",
    "LPD_RS_235.1.pdf": "eli/cc/2022/491",
}


def get(url, data=None, headers=None, timeout=60):
    req = urllib.request.Request(url, data=data, headers={**UA, **(headers or {})})
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return r.read()


def enregistrer(nom, contenu):
    if not contenu.startswith(b"%PDF"):
        raise ValueError("le contenu reçu n'est pas un PDF")
    (CORPUS / nom).write_bytes(contenu)
    print(f"  OK  {nom} ({len(contenu) // 1024} Ko)")


def url_fedlex_sparql(eli):
    q = f"""PREFIX jolux: <http://data.legilux.public.lu/resource/ontology/jolux#>
SELECT ?url ?date WHERE {{
 ?cons jolux:isMemberOf <https://fedlex.data.admin.ch/{eli}> ;
       jolux:dateApplicability ?date ;
       jolux:isRealizedBy ?expr .
 ?expr jolux:language <http://publications.europa.eu/resource/authority/language/FRA> ;
       jolux:isEmbodiedBy ?manif .
 ?manif jolux:userFormat <https://fedlex.data.admin.ch/vocabulary/user-format/pdf-a> ;
        jolux:isExemplifiedBy ?url .
 FILTER(?date <= NOW())
}} ORDER BY DESC(?date) LIMIT 1"""
    rep = get("https://fedlex.data.admin.ch/sparqlendpoint",
              data=urllib.parse.urlencode({"query": q}).encode(),
              headers={"Accept": "application/sparql-results+json",
                       "Content-Type": "application/x-www-form-urlencoded"})
    b = json.loads(rep)["results"]["bindings"]
    return b[0]["url"]["value"] if b else None


def url_fedlex_repertoire(eli):
    base = f"https://fedlex.data.admin.ch/filestore/fedlex.data.admin.ch/{eli}/"
    html = get(base).decode("utf-8", "ignore")
    aujourdhui = date.today().strftime("%Y%m%d")
    dates = sorted({d for d in re.findall(r"(\d{8})/", html) if d <= aujourdhui}, reverse=True)
    slug = eli.replace("/", "-")
    for d in dates:
        url = f"{base}{d}/fr/pdf-a/fedlex-data-admin-ch-{slug}-{d}-fr-pdf-a.pdf"
        try:
            urllib.request.urlopen(urllib.request.Request(url, method="HEAD", headers=UA), timeout=30)
            return url
        except Exception:
            continue
    return None


def main():
    CORPUS.mkdir(exist_ok=True)
    erreurs = []
    for nom, url in FINMA.items():
        if (CORPUS / nom).exists():
            print(f"  déjà là  {nom}"); continue
        try:
            enregistrer(nom, get(url))
        except Exception as e:
            erreurs.append(nom); print(f"  ÉCHEC  {nom} : {e}")
    for nom, eli in FEDLEX.items():
        if (CORPUS / nom).exists():
            print(f"  déjà là  {nom}"); continue
        url = None
        for methode in (url_fedlex_sparql, url_fedlex_repertoire):
            try:
                url = methode(eli)
                if url:
                    break
            except Exception as e:
                print(f"  ({methode.__name__} : {e})")
        try:
            if not url:
                raise ValueError("URL du PDF introuvable")
            enregistrer(nom, get(url))
        except Exception as e:
            erreurs.append(nom); print(f"  ÉCHEC  {nom} : {e}")
    if erreurs:
        print("\nÀ télécharger à la main (voir README) : " + ", ".join(erreurs))
    return 0


if __name__ == "__main__":
    sys.exit(main())
