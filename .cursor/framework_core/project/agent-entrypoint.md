# Agent Entrypoint — EventHub

## Resumo

- produto: plataforma web para gestao comercial e operacional de organizacoes e espacos de eventos;
- fluxo central: captar proposta e operar datas, valores, pessoas, contratos, pagamentos e comunicacoes;
- estado: sistema multi-repo com dividas relevantes de seguranca, contratos e testes.

## Ordem curta de leitura

1. este arquivo;
2. `project/active-libs.md`;
3. `BOARD.md` e o artefato indicado;
4. `project/project-decisions.md` se houver estrutura ou excecao;
5. topic da area;
6. somente as libs exigidas;
7. docs detalhados citados pelo topic, se necessario.

## Regras de ouro

- nunca ler ou imprimir `.env`; usar apenas nomes de `.env.example`;
- contrato FE/BE considera ambos os repositorios e atualiza docs;
- rota publica ou autenticada deve ser intencional e testada negativamente;
- permissao no frontend nao substitui autorizacao no backend;
- preservar wall-clock na agenda;
- migration de producao e aditiva e usa `prisma migrate deploy`;
- nao criar terceira abordagem de estado no frontend;
- usar topics para memoria antiga e specs para mudanca futura.

## Leitura por frente

- frontend: `project/frontend-map.md`, journeys, flows, design direction, `topics/frontend-application.md`, `react` e `design`;
- backend: regras, domain model, `topics/backend-api.md`, `node` e `patterns`;
- banco: data model, `topics/data-and-migrations.md`, `database` e `node`;
- auth/PII/pagamento/upload/OAuth: `topics/auth-and-security.md` e `security`;
- integracao: `product/09-integrations.md` e `topics/integrations.md`;
- infra: `project/infra-map.md`;
- estrutural: decisions, ADRs e `architecture`.

## Provas

- backend: `npm test -- --run` e `npx prisma validate`;
- frontend: `npm run build`, `npm run lint`, `npm test`;
- framework no Windows: `py -3 framework_global/framework-base/tools/validate-framework.py --core .cursor/framework_core --global-root framework_global --strict`.

## Escalada

Escalar mudanca multi-repo, schema destrutivo, auth/PII/pagamento/segredo, escolha de estados/moeda/timezone, falta de owner/ambiente, acesso a producao ou deploy.

## Gatilhos

- ideia vaga: `fw:discover`;
- demanda pequena: `fw:intake`;
- sensivel, multi-repo ou maior: `fw:spec`;
- dividir: `fw:split`;
- validar: `fw:doctor`.
