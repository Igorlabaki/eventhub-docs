# RAID Log

## Riscos

- R-01 alto: rotas sensiveis sem auth/autorizacao consistente;
- R-02 alto: valor com aparencia de credencial em arquivo de exemplo;
- R-03 alto: cobertura automatizada insuficiente;
- R-04 medio: escritas multi-entidade sem transacao;
- R-05 medio: falta de observabilidade e rollback documentado;
- R-06 medio: contratos FE/BE e refresh divergentes.

## Premissas

- A-01: Vercel e plataforma atual porque ambos repositorios contem configuracao;
- A-02: MySQL e banco atual porque o Prisma o declara;
- A-03: `docs/` pode conter informacao desatualizada e deve ser conferido contra codigo.

## Issues

- I-01: owners e ambientes nao identificados;
- I-02: env examples incompletos;
- I-03: nao existe CI/CD de produto mapeado;
- I-04: backlog legado pode misturar resolvidos e pendentes.

## Dependencias

- prioridade e owners humanos;
- acesso autorizado a ambientes externos para provas de integracao/deploy;
- baseline de volume e performance para decidir paginacao/indices.

## Operacao

- tipo: raid;
- status: ativo;
- proximo passo: transformar risco selecionado em spec, sem executar o log inteiro como lote.
