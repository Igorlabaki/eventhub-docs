# Data and Migrations

## Mapa

- banco: PlanetScale Vitess/MySQL, banco `ar756`, producao em `main`; ver `project/planetscale.md`;
- ORM: Prisma 5;
- schema: `art56_server_v3/prisma/schema.prisma`;
- migrations: `art56_server_v3/prisma/migrations/`;
- modelo explicado: `docs/referencias/DATA_MODEL_EXPLAINED.md`;
- diagrama: `docs/referencias/database.dbml`.

## Regras

- `relationMode = "prisma"`: validar integridade na aplicacao; o banco tem FKs desligadas;
- a `main` tem safe migrations: DDL vai para uma branch de desenvolvimento e entra por deploy request;
- `prisma migrate deploy` nao grava historico em `ar756`; nao usar `migrate status` como prova e nunca usar `migrate dev` contra o PlanetScale;
- deploy request na `main`, SQL de escrita e `--force` exigem aprovacao nomeada;
- evolucao destrutiva exige fases aditivas, backfill, compatibilidade e rollback;
- nao alterar dinheiro Float, IDs UUID/CUID ou datetime como limpeza lateral;
- fluxos com varias escritas precisam avaliar `prisma.$transaction`;
- medir antes de criar indice ou cache; Insights e schema recommendations do PlanetScale sao a fonte de medida.

## Prova minima

`npx prisma format`, `npx prisma validate`, migration revisada, `pscale deploy-request diff` conferido, schema lido de volta na `main` por `pscale sql ... --role reader`, teste de fluxo e verificacao de compatibilidade FE/BE. Acesso a banco real requer alvo e autorizacao explicitos.
