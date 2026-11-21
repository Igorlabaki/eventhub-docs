# Agent Entrypoint — EventHub

## Resumo

- produto: plataforma web para gestao comercial e operacional de organizacoes e espacos de eventos;
- fluxo central: captar orcamento por link publico, calcular preco, fechar com contrato e agenda, receber pagamentos e operar o dia do evento;
- estado: sistema multi-repo em producao com dividas relevantes de seguranca (88 endpoints publicos), contratos e testes de integracao.

## Ordem curta de leitura

1. este arquivo;
2. `project/active-libs.md`;
3. `BOARD.md` e o artefato indicado;
4. `project/project-decisions.md` se houver estrutura ou excecao;
5. map da frente (`project/backend-map.md`, `project/frontend-map.md`, `project/api-endpoints.md`);
6. topic da area;
7. somente as libs exigidas (`topics/framework-global-map.md` diz o que ler);
8. docs detalhados citados pelo topic, se necessario.

## Regras de ouro

- nunca ler ou imprimir `.env`; usar apenas nomes de `.env.example` e dos maps;
- caminhos `.cursor/framework_global/` citados em artefatos ficam em `eventhub-docs/framework_global/`;
- contrato FE/BE considera ambos os repositorios e atualiza `project/api-endpoints.md` e docs;
- rota publica ou autenticada deve ser intencional, entrar na allowlist (backend e `PUBLIC_ROUTES`) e ser testada negativamente;
- permissao nova existe no backend, no enum, na rota e na sidebar, com backfill;
- permissao no frontend nao substitui autorizacao no backend;
- preservar wall-clock na agenda (`lib/wall-clock-datetime` nos dois repos);
- dinheiro e preco passam por `topics/pricing-and-proposal-calculation.md` e testes de `functions/`;
- migration de producao e aditiva e entra na `main` do PlanetScale por deploy request, nunca por DDL direto;
- no banco real o padrao e somente leitura; escrita, deploy request na `main` e `--force` exigem aprovacao nomeada;
- nao criar terceira abordagem de estado no frontend;
- antes de retomar spec, conferir se o codigo descrito existe (`topics/delivery-and-known-gaps.md`);
- usar topics para memoria atual e specs para mudanca futura.

## Leitura por frente

- frontend: `project/frontend-map.md`, `topics/frontend-application.md`, flows, design direction, `react` e `design`;
- paginas publicas e marca do espaco: `topics/public-pages-and-branding.md`;
- backend: `project/backend-map.md`, `project/api-endpoints.md`, regras, `topics/backend-api.md`, `node` e `patterns`;
- preco, orcamento e servicos: `topics/pricing-and-proposal-calculation.md`;
- relatorios, KPIs e graficos: `topics/reports-and-kpis.md`;
- banco: `product/08-data-model.md`, `topics/data-and-migrations.md`, `project/planetscale.md`, `database` e `node`;
- auth/PII/pagamento/upload/OAuth: `topics/auth-and-security.md`, `topics/permissions-catalog.md` e `security`;
- integracao: `product/09-integrations.md` e `topics/integrations.md`;
- infra e workspace: `project/infra-map.md` e `project/workspace-map.md`;
- docs antigos: `topics/legacy-docs-map.md`;
- estrutural: decisions, ADRs e `architecture`.

## Provas

- backend: `npm test -- --run` e `npx prisma validate`;
- banco: `pscale auth check --format json` antes de tudo; schema lido de volta com `pscale sql ar756 main --org igorlabakig --format json --query "..."`;
- frontend: `npm run build`, `npm run lint`, `npm test`;
- framework no Windows (a partir de `eventhub-docs/`): `py -3 framework_global/framework-base/tools/validate-framework.py --core .cursor/framework_core --global-root framework_global --strict`.

## Escalada

Escalar mudanca multi-repo, schema destrutivo, auth/PII/pagamento/segredo, fechamento de endpoint publico usado por pagina publica, escolha de estados/moeda/timezone, falta de owner/ambiente, acesso a producao ou deploy.

## Gatilhos

- ideia vaga: `fw:discover`;
- demanda pequena: `fw:intake`;
- sensivel, multi-repo ou maior: `fw:spec`;
- dividir: `fw:split`;
- validar: `fw:doctor`.
