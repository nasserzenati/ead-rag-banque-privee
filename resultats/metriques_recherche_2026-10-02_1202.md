# Métriques de recherche (top-5), 2026-10-02_1202

| Pipeline | cibles | recall@5 article | MRR article | recall@5 document | MRR document |
|---|---|---|---|---|---|
| v1 | 30 | 0.93 | 0.82 | 1.00 | 0.93 |
| v2 | 30 | 0.93 | 0.83 | 1.00 | 0.93 |
| v3 | 30 | 0.93 | 0.83 | 1.00 | 0.93 |
| v4 | 30 | 1.00 | 0.90 | 1.00 | 0.96 |

Lecture : « article » = le bon document ET le bon article dans les 5 extraits transmis au modèle ; « document » = le bon document, n'importe quel passage (mesure plus indulgente, celle du 01.10). Sans génération ; filtre d'accès appliqué selon le rôle de la question.
