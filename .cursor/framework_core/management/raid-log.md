# RAID Log

## Riscos

- R-01 alto: rotas sensiveis sem auth/autorizacao consistente;
- R-02 alto: valor com aparencia de credencial em arquivo de exemplo;
- R-03 alto: cobertura automatizada insuficiente;
- R-04 medio: escritas multi-entidade sem transacao;
- R-05 medio: falta de observabilidade e rollback documentado;
- R-06 medio: contratos FE/BE e refresh divergentes;
- R-07 medio: deploy request no PlanetScale sem aprovacao obrigatoria e com um admin; agente com essa credencial pode se autoaprovar em producao;
- R-08 medio: backup de 2 dias, sem restore ensaiado e sem webhook de erro de deploy ou anomalia.

## Premissas

- A-01: Vercel e plataforma atual porque ambos repositorios contem configuracao;
- A-02: confirmada em 2026-11-08: banco atual e MySQL no PlanetScale (`ar756`), pelas 42 tabelas da `main` iguais aos models do Prisma;
- A-03: `docs/` pode conter informacao desatualizada e deve ser conferido contra codigo.

## Issues

- I-01: owners e ambientes nao identificados;
- I-02: env examples incompletos;
- I-03: nao existe CI/CD de produto mapeado;
- I-04: backlog legado pode misturar resolvidos e pendentes;
- I-05: `prisma migrate deploy` nao grava historico em `ar756` (sem `_prisma_migrations`); `migrate status` nao reflete o banco;
- I-06: 25 schema recommendations do PlanetScale abertas e nao triadas;
- I-07: backend nao sobe em Node 25+ (`buffer-equal-constant-time` usa `SlowBuffer`, removido); versao de Node do projeto nao esta fixada (sem `.nvmrc` nem `engines`); contorno local: nvm-windows com Node 22.

## Dependencias

- prioridade e owners humanos;
- acesso autorizado a ambientes externos para provas de integracao/deploy;
- baseline de volume e performance para decidir paginacao/indices.

## Operacao

- tipo: raid;
- status: ativo;
- proximo passo: transformar risco selecionado em spec, sem executar o log inteiro como lote.
