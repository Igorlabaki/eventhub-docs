# PlanetScale — EventHub

Contexto do banco para agentes e pessoas. Fatos observados em 2026-11-08 por `pscale` somente leitura; o guia oficial e `https://planetscale.com/docs/agent-setup/prompt.md`.

## Alvo

- organizacao: `igorlabakig`;
- banco: `ar756`;
- engine: Vitess/MySQL (`kind: mysql`), sem sharding mapeado;
- branch de producao: `main` (`production: true`, `safe_migrations: true`);
- regiao: AWS `us-east-2` (Ohio);
- FKs fisicas: desligadas (`foreign_keys_enabled: false`), coerente com `relationMode = "prisma"`;
- schema: as 42 tabelas da `main` correspondem aos 42 models de `art56_server_v3/prisma/schema.prisma`;
- conexao da aplicacao: `DATABASE_URL`; nunca ler, imprimir ou copiar o valor.

## Fluxo real de schema

- a `main` rejeita DDL direto por causa de safe migrations;
- cada mudanca cria uma branch de desenvolvimento a partir da `main` (ex.: `add-partner-category`);
- a DDL e aplicada na branch e entra na `main` por deploy request (`#19` a `#43`, todos `complete`); `#45` (branch `add-proposal-service-courtesy`, coluna `proposalService.courtesyQuantity`) aplicado em 2026-11-10 com aprovacao nomeada, `complete_pending_revert`; `#46` (branch `add-proposal-discount`, colunas `proposal.discountPercent` e `proposal.discountAmount`) aplicado em 2026-11-10 com aprovacao nomeada, `complete_pending_revert`; `#47` (branch `add-owner-person-type`, colunas `owner.personType`, `companyName`, `cnpj` e `companySize`) aplicado em 2026-11-12 com aprovacao nomeada, `complete_pending_revert`; `#48` (branch `add-venue-amenity-image`, tabela `venue_amenity_image`) aplicado em 2026-11-13 com aprovacao nomeada, `complete_pending_revert`, seguido da copia aprovada de 1 foto de `venue_amenity.imageUrl` para a tabela nova; `#49` (branch `add-expense-traffic-source`, coluna `expense.trafficSource` e indice `expense_venueId_category_idx`) aplicado em 2026-11-14 a pedido do usuario, `complete_pending_revert`; `#50` (branch `add-venue-photo`, tabela `venue_photo` e colunas `photoId`/`backgroundPhotoId`, sem FK) aplicado em 2026-11-14 a pedido do usuario, `complete_pending_revert`, seguido do backfill de 46 fotos e das permissoes `VIEW/EDIT_VENUE_PHOTOS` (9 linhas cada); `#51` (branch `add-venue-slogan`, coluna `venue.slogan`) aplicado em 2026-11-19 a pedido do usuario, `complete_pending_revert`, seguido da copia de `description` para `slogan` em 2 espacos;
- apos o deploy existe janela de revert (`complete_pending_revert`); rollback de coluna aditiva e o revert do deploy request enquanto a janela existir;
- `prisma migrate deploy` nao grava historico neste banco: nao existe `_prisma_migrations` na `main`; o diretorio `prisma/migrations/` continua sendo a fonte versionada da DDL;
- `require_approval_for_deploy: false`: quem abre o deploy request tambem pode aplica-lo.

## Postura observada

- backups automaticos da `main`: a cada ~12h, retencao de 2 dias;
- webhooks: nenhum;
- Insights: ligado; coleta de query bruta desligada;
- schema recommendations: 25 abertas em 2026-11-08, nao triadas;
- branches: `main`, `nova-branch` e uma branch por feature ja deployada; nenhuma staging;
- console web na branch de producao: desligado.

## Setup do agente

1. CLI `pscale` 0.292.0 ou superior; no Windows: `winget install --id PlanetScale.CLI -e`;
2. login interativo: `pscale auth login --format json` e aprovacao no navegador; credencial fica no keychain do SO;
3. verificacao: `pscale agent-guide --format json`, `pscale auth check --format json` e `pscale org list --format json`;
4. skills: copiar os `SKILL.md` de `https://github.com/planetscale/skills` para `~/.cursor/skills/` (o `script/setup` do repo faz so isso; no Windows sem bash, copiar manualmente);
5. MCP: em `~/.cursor/mcp.json` ou `.cursor/mcp.json`, `"planetscale": { "url": "https://mcp.pscale.dev/mcp/planetscale" }`; OAuth dispara no primeiro uso; reiniciar o Cursor para carregar;
6. skills de entrada: `planetscale-pscale-cli-automation` para a CLI e `planetscale-safe-orchestrator` para avaliacao completa.

## Convencoes da CLI

- sempre `--format json` em automacao;
- `--org igorlabakig` vai no subcomando (`database`, `branch`, `sql`, `api`), nunca na raiz `pscale`;
- positionals antes das flags: `pscale sql ar756 <branch> --org igorlabakig --format json --query "SELECT 1"`;
- `pscale sql` usa `--role reader` por padrao; `DELETE`, `DROP` e `TRUNCATE` exigem `--force`;
- `--force` so com aprovacao explicita da query exata;
- erro com `status: action_required` traz `next_steps`; seguir em vez de repetir o comando.

## Comandos de leitura

```bash
pscale auth check --format json
pscale branch list ar756 --org igorlabakig --format json
pscale deploy-request list ar756 --org igorlabakig --format json
pscale deploy-request diff ar756 <numero> --org igorlabakig --format json
pscale sql ar756 main --org igorlabakig --format json --query "SHOW TABLES"
pscale insights queries ar756 main --org igorlabakig --format json --sort totalTime
pscale insights recommendations ar756 --org igorlabakig --format json
pscale backup list ar756 main --org igorlabakig --format json
```

## Permissoes do agente

Padrao provisorio ate decisao do owner (`DR-07`):

- livre: listar e ler metadados, branches, deploy requests, backups, Insights, recomendacoes e `SELECT` limitado com `--role reader`;
- livre como proposta: criar branch de desenvolvimento, aplicar DDL aditiva nela e abrir deploy request para `main`;
- exige aprovacao nomeada (org, banco, branch, acao exata): aplicar deploy request na `main`, SQL de escrita em qualquer branch, criar ou apagar branch alem da propria proposta, revert, webhook, senha, role, safe migrations, backup manual e restore;
- nunca autonomo: `DROP` de tabela ou coluna em producao, apagar banco, desligar safe migrations, expor segredo em log, issue, PR ou doc, aplicar DDL gerada por LLM sem revisao.

Aprovacao valida cita alvo e acao exata; "pode seguir" generico nao vale. Antes de acao em producao: comando exato, efeito esperado, risco de dados, rollback e prova.

## Localhost com o banco de producao

- skill pessoal `eventhub-prod-db-tunnel` em `~/.cursor/skills/`; o agente a usa quando o usuario pede tunel ou localhost com dados de prod;
- tunel: `pscale connect ar756 main --org igorlabakig --port 3309 --no-random --role readwriter`, dentro de um loop de reconexao, porque a senha efemera expira em ~80 min sem renovacao;
- backend na mesma sessao: `DATABASE_URL=mysql://root@127.0.0.1:3309/ar756`, sem editar `.env` (dotenv nao sobrescreve variavel existente);
- frontend: `VITE_API_URL=http://localhost:3000`;
- dados sao reais e os servicos do `.env` local (e-mail, Web Push, S3, Google Calendar) disparam de verdade;
- nunca rodar `prisma migrate`, `db push` ou seed pelo tunel;
- backend exige Node 22: em Node 25+ `buffer-equal-constant-time` (via `jsonwebtoken` e `web-push`) quebra por falta de `SlowBuffer`; na maquina local, `nvm use 22.23.4` (nvm-windows).

## Headless e CI

- usar service token: `--service-token-id` e `--service-token` vindos de variaveis de ambiente, nunca do repositorio;
- com service token, `pscale org show` e `pscale service-token list` falham por desenho; usar `pscale org list --format json` e `pscale api`.

## Lacunas

- sem staging: deploy request vai direto da branch de feature para producao;
- aprovacao de deploy desligada e organizacao com um admin: um agente com a credencial do admin pode se autoaprovar;
- branches de features ja deployadas seguem abertas; limpeza exige aprovacao;
- sem webhooks para `deploy_request.errored`, `branch.anomaly` ou storage;
- retencao de backup curta e restore nunca ensaiado;
- historico do Prisma divergente do banco: `migrate status` nao serve como prova.

## Fontes

`pscale database list`, `branch list`, `deploy-request list`, `backup list`, `webhook list`, `insights recommendations` e `sql "SHOW TABLES"` em 2026-11-08; `05-state.md` das specs de 2026-11-04 e 2026-11-05.
