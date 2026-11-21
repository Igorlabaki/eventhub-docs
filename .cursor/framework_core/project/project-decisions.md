# Project Decisions — EventHub

Fatos e excecoes locais; desejos futuros nao sao decisao.

## Decisoes ativas

### D-01 Workspace multi-repo

- estado: ativo;
- fato: backend e frontend sao repositorios independentes;
- efeito: contrato compartilhado usa artefato canonico e `fw:split` para `backend` e `frontend`.

### D-02 Monolito modular Express

- estado: ativo;
- fato: router -> controller/factory -> use case -> repository Prisma;
- efeito: nova capacidade segue o dominio existente; extracao de servico exige ADR e spec.

### D-03 MySQL com integridade gerida pelo Prisma

- estado: ativo;
- fato: `relationMode = "prisma"`;
- efeito: nao assumir FKs fisicas ou cascata do banco.

### D-04 Deploy orientado a Vercel

- estado: ativo, confirmado pelos dois `vercel.json`;
- efeito: API e serverless; frontend e SPA com rewrite;
- lacuna: ambientes, dominios, owners e promocao nao estao documentados.

### D-05 Autorizacao parcialmente client-side

- estado: legado ativo, nao alvo desejado;
- fato: `ProtectedRoute` protege UI, enquanto o backend protege apenas parte das rotas;
- efeito: auth/permissao e superficie sensivel com testes negativos obrigatorios.

### D-06 Datas de evento com semantica wall-clock

- estado: convencao documentada;
- fonte: `docs/planos/horario-wall-clock/`;
- efeito: nao converter agenda como instante UTC sem revisar o fluxo.

### D-07 Dinheiro em Float no legado

- estado: legado ativo;
- efeito: migrar para Decimal ou centavos inteiros exige spec e migracao de dados.

### D-08 Docs detalhados permanecem em docs

- estado: ativo;
- efeito: o core roteia e resume; mudancas atualizam tambem os docs detalhados impactados.

### D-09 Banco no PlanetScale com deploy requests

- estado: ativo, observado por `pscale` em 2026-11-08;
- fato: banco `ar756` da org `igorlabakig`, Vitess/MySQL; `main` e producao com safe migrations; deploy requests `#19` a `#43` aplicados;
- efeito: DDL nasce em branch de desenvolvimento e entra por deploy request; `prisma migrate deploy` nao registra historico neste banco;
- lacuna: sem staging, sem aprovacao obrigatoria de deploy e sem webhooks;
- detalhe: `project/planetscale.md`.

## Decisoes pendentes

- owners e canal oficial;
- ambientes e promocao;
- React Query versus Zustand;
- politica monetaria e arredondamento;
- estados oficiais de Proposal;
- SLO, RPO e RTO;
- CI/CD e gates obrigatorios;
- permissoes de agentes no PlanetScale e branch de staging (`DR-07`).

## Atualizacao

Escolha nova entre alternativas vai para `management/decision-register.md` e, se estrutural, para `project/adrs/`. Divida fica em topic, plan, roadmap, task-request ou spec.
