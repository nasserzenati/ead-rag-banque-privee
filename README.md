# Assistant réglementaire souverain : maquette RAG locale (HES-SO Master, module EAD)

Maquette et données d'évaluation de l'article « Assistant réglementaire souverain pour une banque privée suisse : ce que garantit une architecture RAG locale, et ce qu'elle ne garantit pas » (N. Zenati, HES-SO Master, 2026).

Le dépôt permet de vérifier chaque chiffre de l'article et de rejouer les mesures.

## Contenu
| Dossier / fichier | Rôle |
|---|---|
| `rag_test.py` | maquette : ingestion, recherche (sémantique, hybride), génération, contrôles ; versions v1 à v4 |
| `metriques_recherche.py` | rappel à 5 et rang moyen inverse, par version et par jeu de questions |
| `telecharger_corpus.py` | téléchargement des textes publics (Fedlex, FINMA) |
| `corpus/` | 4 textes publics (LPD, LBA, circulaire FINMA 2023/1, communication FINMA 08/2024) et 7 documents internes **fictifs**, dont des pièges (versions, instruction cachée, note confidentielle, FAQ brouillon erronée) |
| `questions.csv` | 34 questions en trois jeux : développement, diagnostic (`test`), sommatif (`test2`) |
| `resultats/` | réponses brutes, mesures et synthèse des mesures |
| `codage_humain/` | grille de notation, clés de l'aveugle (avec empreintes), codages IA à l'aveugle, dont un codeur tiers isolé (aucun codage humain) |
| `PROTOCOLE_EVAL_COMPLEMENTAIRE_2026-10-08.md`, `test_E1_bout_en_bout.py`, `lancer_eval_complementaire.command` | évaluation complémentaire préenregistrée (empreinte SHA-256) : ablation v2/v3 et attaques inconnues |
| `E1_bipia_text_attack_test.json`, `E1_bipia_LICENSE_MIT.txt` | 75 consignes d'attaque du jeu public BIPIA (Yi et al., 2025 ; microsoft/BIPIA, licence MIT), reproduites sans modification |
| `aegis_banque_suisse.patch` | adaptation du plan de contrôle Aegis utilisée pour l'orchestration (v3, v4) |
| `lancer_*.command`, `verifier_environnement.command`, `requirements.txt` | exécution sur macOS |

## Exécution (macOS, Apple Silicon)
1. Installer Ollama, puis les modèles : `qwen3:8b`, `MichelRosselli/apertus:8b-instruct-2509-q4_k_m`, `bge-m3`.
2. `pip install -r requirements.txt`, puis `python telecharger_corpus.py`.
3. `python rag_test.py --pipeline v4` (voir `--help` pour les options), puis `python metriques_recherche.py`.

Environnement de référence : Ollama 0.30.8, Python 3.13.5, MacBook M1 16 Go ; décodage à température nulle.

## Limites
Corpus de onze documents, dont sept fictifs ; dix questions sommatives ; aucune donnée réelle de banque. Les documents internes sont inventés : toute ressemblance avec une banque existante est fortuite.

## Démarche
Le code, le corpus fictif, les questions et l'article ont été produits avec une IA générative (Claude, Anthropic), sous la direction et le contrôle de l'auteur ; voir la section 9 de l'article.

## Licence
Code, corpus fictif, questions et résultats : licence MIT (fichier `LICENSE`). Ne sont pas couverts : les textes publics du dossier `corpus/` (Fedlex, FINMA), reproduits tels quels, et les consignes BIPIA, sous leur propre licence MIT (`E1_bipia_LICENSE_MIT.txt`).
