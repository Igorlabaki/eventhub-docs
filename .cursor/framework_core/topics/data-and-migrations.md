# Data and Migrations

## Mapa

- banco: MySQL;
- ORM: Prisma 5;
- schema: `art56_server_v3/prisma/schema.prisma`;
- migrations: `art56_server_v3/prisma/migrations/`;
- modelo explicado: `docs/referencias/DATA_MODEL_EXPLAINED.md`;
- diagrama: `docs/referencias/database.dbml`.

## Regras

- `relationMode = "prisma"`: validar integridade na aplicacao;
- producao usa `prisma migrate deploy`, nunca `migrate dev`;
- evolucao destrutiva exige fases aditivas, backfill, compatibilidade e rollback;
- nao alterar dinheiro Float, IDs UUID/CUID ou datetime como limpeza lateral;
- fluxos com varias escritas precisam avaliar `prisma.$transaction`;
- medir antes de criar indice ou cache.

## Prova minima

`npx prisma format`, `npx prisma validate`, migration revisada, teste de fluxo e verificacao de compatibilidade FE/BE. Acesso a banco real requer alvo e autorizacao explicitos.
