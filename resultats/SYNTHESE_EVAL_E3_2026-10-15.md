# Synthèse de l'évaluation E3 (protocole préenregistré le 11.10.2026, amendement n° 1 ; mesures du 11.10.2026, 20 h 04–20 h 50)

Protocole, amendement et questions publiés sur GitHub avant la mesure (commits 0ef260f, 1a89228, 25d925e). Notation par deux codeurs IA isolés et aveugles (version, variante et modèle inconnus), 15.10.2026.

## E3-a. Refus hors corpus (10 questions écrites par un tiers ; v1 et v4 ; deux modèles)
| Version | Qwen3 : refus corrects / hallucinations | Apertus : refus corrects / hallucinations |
|---|---|---|
| v1 | 9 / 1 (H09 : seuil attribué à l'OPDo) | 10 / 0 |
| v4 | 9 / 0 (H09 noté 1 : 250 collaborateurs cité sans dire que l'OPDo manque) | 1 / 8 |
- Apertus v4 invente notamment : un plafond de CHF 100 000 pour les cadeaux, la garantie esisuisse « à CHF 100 000 » attribuée à un extrait, une date d'entrée en vigueur de Bâle III (1.1.2024, date de la circulaire 2023/1), une durée de conservation des vidéos tirée de la grille tarifaire, une majoration de change attribuée à P-PAY-03.
- Hypothèse annoncée : confirmée pour Qwen3 (≥ 8/10) et pour l'écart entre modèles ; NON annoncé : la régression d'Apertus entre v1 et v4. v1 et v4 diffèrent par plusieurs composants ; la cause n'est pas isolée (la consigne de réponse est la candidate la plus probable, à tester).
- Les 3 questions hors corpus des jeux formatifs donnaient déjà, en v4 : Qwen3 3/3, Apertus 0/3.

## E3-b. Ablation par composant (v3 + un seul composant de la v4 ; jeu sommatif)
| Variante | Rappel à 5 (9 cibles) | Exactitude Qwen3 / Apertus (sur 20) | FAQ (Q30) crue par |
|---|---|---|---|
| v3 (E2, autre codeur IA) | 7/9 | 10 / 10 | 1 modèle sur 2 (Apertus résiste) |
| v3 + découpage par article | 8/9 | 15 / 10 | 2 sur 2 |
| v3 + recherche hybride | 7/9 | 12 / 11 | 2 sur 2 |
| v3 + consigne v4 | 7/9 | 11 / 8 | 2 sur 2 |
| v4 (E2, autre codeur IA) | 9/9 | 15 / 10 | 2 sur 2 |
- Hypothèses annoncées : « la régression sur Q30 vient du découpage » : NON confirmée, chacun des trois composants suffit ; « le gain de rappel vient surtout de la recherche hybride » : NON confirmée, il vient du découpage (8/9 seul ; 9/9 avec les deux).
- Q30 : la FAQ est en tête dans toutes les variantes ; le modèle qui y résiste change d'une version à l'autre (v1 : Qwen3 ; v2, v3 : Apertus) et disparaît avec n'importe quel composant de la v4 → la résistance du modèle n'est pas fiable ; l'erreur est de gouvernance.
- Limites : codeur IA différent de celui de l'ablation par cycles ; n = 10 ; interactions non mesurées.

## Déjà calculé le 11.10 (sans nouveau passage)
Questions sommatives sans recoupement (Q25, Q26, Q32, Q33, Q34), codage de référence, sur 10 : Qwen3 4 → 9, Apertus 5 → 6 ; avec recoupement (Q27–Q31) : Qwen3 3 → 6, Apertus 2 → 5. L'article disait « quatre » questions recoupées : ce sont cinq (corrigé).

## E3-c. Codage humain
Un codage de 12 réponses a été reçu d'un tiers le 11.10.2026. Ses conditions d'aveugle n'ont pas pu être établies ; il n'est pas utilisé dans l'article.
