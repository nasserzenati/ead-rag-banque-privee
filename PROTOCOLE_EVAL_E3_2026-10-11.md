# Protocole d'évaluation complémentaire E3 (préenregistré le 11.10.2026)

Décidé par Nasser le 11.10.2026 (« je suis chaud »), sur proposition de l'IA, après le jury simulé du 11.10 (critiques communes : notation uniquement par IA, refus hors corpus non testé, régression de la FAQ non attribuée à un composant). **La maquette (rag_test.py) n'est pas modifiée** : eval_E3.py la réutilise. Ce protocole est figé par une empreinte SHA-256 et publié dans le dépôt public AVANT toute mesure ; l'heure de publication sur GitHub sert d'horodatage tiers.

## E3-a. Refus hors corpus
- **Question** : quand l'information n'est pas dans les documents, l'assistant refuse-t-il, ou invente-t-il ?
- **Matériel** : 10 questions écrites par l'AUTEUR (pas par l'IA), dans questions_E3_hors_corpus.csv, avant toute mesure, selon la consigne CONSIGNE_QUESTIONS_HORS_CORPUS.md ; 8 questions dont la réponse n'est dans aucun des 11 documents, 2 questions « proches » (sujet couvert par le corpus, mais pas la réponse demandée). Le fichier est haché et publié avant le premier passage.
- **Passage** : v1 et v4, deux modèles (Qwen3 8B, Apertus 8B), température 0 (eval_E3.py hors-corpus).
- **Mesure** : refus correct = la réponse dit que l'information n'est pas disponible, sans affirmer de fait inventé. Jugé par un codeur IA aveugle (sans connaître version ni modèle) ET relu par l'auteur ; la colonne automatique « refus » de rag_test sert de contrôle. Taux = refus corrects / 10, par version et par modèle.
- **Hypothèse annoncée** : en v4, Qwen3 refuse au moins 8 fois sur 10 et Apertus moins souvent (sur les 3 questions hors corpus des jeux de développement et de diagnostic, v4 : Qwen3 3/3, Apertus 0/3) ; les 2 questions « proches » sont les plus difficiles.
- **Refus abusifs** : rapportés à partir des données existantes (refus sur des questions sommatives dont la réponse est dans le corpus), sans nouveau passage.

## E3-b. Ablation par composant
- **Question** : lequel des trois changements de la v4 (découpage structurel, recherche hybride, consigne de réponse) explique le gain de recherche et la régression sur la FAQ (Q30) ?
- **Passage** : jeu sommatif inchangé (Q25–Q34), deux modèles, trois variantes de la v3 avec UN seul composant de la v4 chacune (eval_E3.py ablation) : v3 + découpage ; v3 + recherche hybride ; v3 + consigne.
- **Mesures** : celles du tableau 4 ; rappel à 5 et MRR recalculés ; rang de l'art. 9 al. 1 LBA et de la FAQ pour Q30 ; exactitude notée par un codeur IA aveugle avec la grille du 03.10, sans connaître la variante ni le modèle.
- **Lecture** : ablation « un facteur à la fois » ajoutée à la v3 ; les interactions entre composants ne sont pas mesurées. À déclarer.
- **Hypothèse annoncée** : la régression sur Q30 vient du découpage (scission de l'art. 9 par alinéas) ; le gain de rappel vient surtout de la recherche hybride (articles cités par leur numéro).

## E3-c. Codage humain à l'aveugle (sous-échantillon)
- **Question** : un humain qui ne connaît pas les notes de l'IA donne-t-il les mêmes notes ?
- **Matériel** : 12 réponses tirées au hasard (graine 20261011) parmi les 40 réponses v1 et v4 du jeu sommatif ; fichier A_NOTER_tiers_humain_12_aveugle.xlsx (items renumérotés T01–T12) ; clé cle_tiers_humain_12.json, hachée (cle_tiers_humain_12.sha256) et non communiquée au codeur.
- **Codeur** : une personne qui n'a vu ni les notes de l'IA, ni la clé, ni les résultats ; idéalement avec une formation en droit, compliance ou banque, à défaut un étudiant de Master. Elle n'utilise aucune IA. Son profil est déclaré dans l'article.
- **Mesures** : accord brut sur l'exactitude (x sur 12), kappa pondéré linéaire, et accord sur le fondement, par rapport au codage de référence du 03.10. Tous les écarts sont listés.
- **Hypothèse annoncée** : au moins 9 notes d'exactitude sur 12 identiques ; kappa pondéré ≥ 0,6.

## Ce qui est déjà calculé (sans nouveau passage, 11.10.2026)
- Questions sommatives sans recoupement avec les jeux de développement et de diagnostic : Q25, Q26, Q32, Q33, Q34 (Q27 et Q30 recoupent Q05 ; Q28 recoupe Q10 ; Q29 recoupe Q19 ; Q31 recoupe Q09, Q10 et Q24). Codage de référence, exactitude sur 10 (5 questions × 0–2) : Qwen3 4 → 9, Apertus 5 → 6 (v1 → v4) ; questions avec recoupement : Qwen3 3 → 6, Apertus 2 → 5. Le gain de la v4 ne s'explique donc pas par le recoupement.

## Ce qui sera rapporté
Tous les résultats, favorables ou non, dans le tableau 4, au § 4 (protocole) et au § 6, en une ou deux phrases chacun ; les données brutes dans le dépôt public. Un écart au protocole est déclaré avant la mesure, comme pour l'amendement n° 1 du 08.10.
