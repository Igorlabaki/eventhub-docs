# Tasks — De onde vem os eventos

## Ordem macro

1. `T-01`: funcao pura e spec. Backend.
2. `T-02`: `select`, use case, rota e linha em `api-endpoints.md`. Depende de `T-01`.
3. `T-03`: card na aba EVENTO e paragrafo no topic. Pode comecar pelo contrato de `03-design.md#Contratos e dados` em paralelo com `T-02`. A prova no browser espera a rota.

## Tasks

### T-01 - Agrupar cidade, estado e bairro

- objetivo: `buildEventOrigin` devolve `events` e tres rankings que somam `events`, com a chave de `03-design.md#Contratos e dados`
- cobre requisitos: `R-01`, `R-02`, `R-03`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: o estilo de `functions/report-event-profile.ts` e do spec ao lado
- prompt recomendado: `smart`
- estrategia de teste: unitario da funcao pura, sem Prisma
- cenarios obrigatorios:
  - duas linhas "Sao Paulo" / "SP" / "Centro" e "sao paulo" / "sp" / "centro" viram um item em cada lista, `events` 2, somas 2
  - "São Paulo" fica em outro item que "Sao Paulo"
  - "São  Paulo" (dois espacos no meio) fica em outro item que "São Paulo"
  - linha com cidade, estado ou bairro `null` ou `"  "` nao entra; as tres somas continuam iguais a `events`
  - empate de `count` ordena por `localeCompare` `pt-BR`; o maior `count` vem primeiro
  - o rotulo e o `trim` da primeira linha, nao a chave em minusculas
- definition of done:
  - `npm test -- --run src/functions/report-event-origin.spec.ts` verde
  - o retorno nao tem outro campo alem de `year`, `events` e as tres listas

#### Context Pack

- frente principal: backend, funcao pura
- superficie sensivel: sim — a entrada e pedaco de endereco; a saida e so rotulo e quantidade
- risco principal: somar linha incompleta e quebrar a igualdade das tres listas
- repos tocados: `backend`
- fora de escopo desta task: rota, Prisma, tela, docs
- prova minima desta task: o spec cobre os seis cenarios acima e fica verde
- criterio de escalada: parar se a regra de acento ou de espaco interno precisar mudar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `01-spec.md#Criterios de aceite`
- caminhos candidatos: `art56_server_v3/src/functions/report-event-profile.ts`; `art56_server_v3/src/functions/report-event-profile.spec.ts`
- palavras-chave ou simbolos de busca: `buildEventProfile`, `toLocaleLowerCase`, `localeCompare`
- testes provaveis: `src/functions/report-event-origin.spec.ts`
- nao ler por padrao: `security`, frontend, `04-tasks.md` inteiro

### T-02 - Endpoint agregado da origem

- objetivo: `GET /venue/reports/event-origin` autoriza, le so as tres colunas e devolve o envelope `EventOriginReport`
- cobre requisitos: `R-04`, `R-05`, `R-06`
- depende de: `T-01`
- pode rodar em paralelo com: `T-03` (o card usa o contrato, nao esta rota)
- reusa: `approvedInYearWhere`, `reportEnvelope`, `ReportController`, `ReportAuthorizer`, factory de `event-profile`
- prompt recomendado: `normal`
- estrategia de teste: `reports.spec.ts` com repositorio e authorizer fakes
- cenarios obrigatorios:
  - sem permissao, o use case rejeita `HttpForbiddenError` e nao chama `eventOriginRows`
  - com permissao, o `where` e o de `approvedInYearWhere` sem `eventCategory`, e o `data` e o retorno de `buildEventOrigin`
  - `eventOriginRows` no Prisma usa `select` exatamente `{ city: true, state: true, neighborhood: true }`
  - a rota passa por `ensureAuthenticate` e pelo `ReportController`
  - `api-endpoints.md` ganha a linha do `GET`, com auth + `VIEW_VENUE_ANALYSIS` e `type: "EventOriginReport"`
- definition of done:
  - `npm test -- --run src/use-cases/venue/reports/reports.spec.ts` verde
  - a rota nao esta em allowlist publica

#### Context Pack

- frente principal: backend, leitura autenticada
- superficie sensivel: sim — `select` em endereco de cliente
- risco principal: selecionar rua, CEP, nome ou id, ou esquecer o authorizer
- repos tocados: `backend`
- fora de escopo desta task: card, topic, schema
- prova minima desta task: o spec do use case verde e o `select` limitado as tres colunas
- criterio de escalada: parar se a rota precisar ser publica ou se o authorizer compartilhado nao servir
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Reuso previsto`
  - `.cursor/framework_core/topics/auth-and-security.md#Regras de execucao`
  - `.cursor/framework_global/framework-libs/security/skills/reviewing-security-sensitive-changes.md`
  - `.cursor/framework_global/framework-libs/node/skills/building-read-model-endpoints.md`
- caminhos candidatos: `art56_server_v3/src/use-cases/venue/reports/event-profile/`; `report-controller.ts`; `report-authorizer.ts`; `proposal-in-prisma-repository.ts` (`eventProfileRows`); `router/venue.ts`
- palavras-chave ou simbolos de busca: `eventProfileRows`, `REPORT_PERMISSION`, `approvedInYearWhere`, `reports/event-profile`
- testes provaveis: `src/use-cases/venue/reports/reports.spec.ts`
- nao ler por padrao: frontend, formulario de contrato, `04-tasks.md` inteiro

### T-03 - Card De onde vem os eventos

- objetivo: a aba EVENTO mostra o card com as tres listas, na ordem que a API ja devolve
- cobre requisitos: `R-07`, `R-08`
- depende de: contrato em `03-design.md#Contratos e dados`; a prova no browser depende de `T-02`
- pode rodar em paralelo com: `T-02`
- reusa: `ReportBlock`, `useReportEventProfile`, a lista de categorias de `EventProfileCard`
- prompt recomendado: `normal`
- estrategia de teste: vitest do card com fixture; browser na aba EVENTO se a API local responder
- cenarios obrigatorios:
  - titulo "De onde vem os eventos" e tres listas com o `label` e o `count` na ordem do payload
  - `events` 0 mostra o vazio do `ReportBlock` e nao as listas
  - erro mostra "Tentar de novo" e o retry chama `refetch`
  - o card fica em `EventsReport` depois do grid de servicos e porte, largura inteira; em `lg` as tres listas ficam lado a lado
  - `topics/reports-and-kpis.md#Blocos agregados` descreve o `GET`, o card e a regra de linha incompleta
- definition of done:
  - vitest do card verde e `npm run build` do frontend sem erro novo
  - o tipo `EventOriginData` nao tem campo de pessoa
  - se o browser nao abrir a aba, registrar em `05-state.md` o que ficou sem prova

#### Context Pack

- frente principal: frontend, um card na aba EVENTO
- superficie sensivel: nao na tela — ela so mostra rotulo e quantidade; nao inventar coluna de endereco
- risco principal: colocar o card no lugar errado ou tratar lista vazia como erro
- repos tocados: `frontend`
- fora de escopo desta task: mapa, valor, filtro de categoria, mudanca dos outros cards
- prova minima desta task: o teste do card cobre lista, vazio e retry; o build passa
- criterio de escalada: parar se o payload real divergir de `EventOriginData`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Visao geral da solucao`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Reuso previsto`
  - `.cursor/framework_global/framework-libs/react/rules/03_data_fetching_and_server_state.md`
  - `.cursor/framework_global/framework-libs/design/rules/07_data_display_and_dashboards.md`
  - `.cursor/framework_core/topics/reports-and-kpis.md#Blocos agregados`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/reports/EventProfileCard.tsx`; `EventsReport.tsx`; `hooks/venue/queries/venueReportBlocks.ts`; `services/venue.service.ts` (`getReportEventProfile`); `types/venue.ts` (`EventProfileData`)
- palavras-chave ou simbolos de busca: `useReportEventProfile`, `ReportBlock`, `isEmpty`, `De onde vem`
- testes provaveis: spec do card ao lado de `EventProfileCard`, no padrao de `report-blocks.test.ts`
- nao ler por padrao: `security`, Prisma, `04-tasks.md` inteiro
