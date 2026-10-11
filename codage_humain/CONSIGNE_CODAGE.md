# Codage humain des 20 réponses sommatives (v4, Q25–Q34 × 2 modèles)

Préparé le 02.10.2026 par l'IA, à la demande des deux relecteurs (condition n° 1 pour un 6). Ordre aléatoire (graine 20261002), modèles anonymisés, aucun commentaire de l'IA. La clé item → (question, modèle) est dans `cle_sommatif_NE_PAS_OUVRIR_avant_codage.json`, empreinte dans `cle_sommatif.sha256`.

## Règles (celles du protocole v4, figées le 01.10)
- **Exactitude 0–2**, jugée **par rapport à la réponse attendue**, pas par rapport aux extraits récupérés : 2 = tous les éléments attendus, rien de faux ; 1 = incomplet (un élément attendu manque) ou imprécision sans erreur de fond ; 0 = faux, inventé, contradictoire, ou refus à tort.
- **Fondement 0–1** : 1 = chaque affirmation citée renvoie à un extrait qui la contient ; 0 = une citation ne soutient pas ce qu'elle est censée soutenir ; n/a = refus.
- Style, langue, longueur, formule de refus ajoutée : **non pénalisés** (règle du 01.10). Si vous voulez quand même pénaliser un cas, notez-le dans le commentaire sans changer la note : on en discutera.
- Un refus justifié (information hors corpus, accès refusé) = 2.

## Procédure
1. Ne pas lire la section A du `RAPPORT_JURY_2_2026-10-02.md` avant d'avoir fini (elle contient des notes et des erreurs de notation déjà repérées ; les lire d'abord ôterait toute valeur au codage).
2. Remplir les trois dernières colonnes de `a_noter_sommatif_v4_2026-10-02.csv` (Numbers, Excel ou un éditeur texte ; garder le `;` comme séparateur). Durée : ~1 h 30.
3. Enregistrer sous `codage_Nasser_sommatif_v4_<date>.csv` dans ce dossier. Ne pas ouvrir la clé.
4. Donner le même fichier vierge à un tiers (camarade, collègue) → `codage_tiers_sommatif_v4_<date>.csv`.
5. Ensuite seulement : l'IA calcule l'accord (brut et kappa) entre vous, le tiers et les notes IA du 01.10, et reconstruit le score sommatif. Les trois jeux de notes sont conservés et déclarés dans l'article.
