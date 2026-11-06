# TODO Master — EventHub

## 1. Objetivo do Documento

Este é o **backlog oficial consolidado** do projeto EventHub. Reúne todas as tarefas identificadas nos documentos de análise e planejamento em `/docs`, com priorização única, rastreabilidade por documento de origem e critérios de aceite. Nenhuma tarefa foi inventada: todas têm base em pelo menos um documento existente. O sistema está em produção; mudanças devem preservar banco e compatibilidade (ver [MIGRATION_STRATEGY.md](../../processo/MIGRATION_STRATEGY.md) e [INDEX.md](../../INDEX.md)).

---

## 2. Regras de Priorização

Ordem obrigatória ao priorizar trabalho:

1. **Segurança & Autorização** — Rotas sem auth, req.userId, refresh token, CORS, vazamento em 500.
2. **Integridade de Dados** — Transações em fluxos multi-escrita, rotas 404 (GET document/payment por ID).
3. **Consistência de API** — Envelope de resposta, contratos FE↔BE.
4. **Estabilidade em Produção** — Middleware global de erro, express-async-errors, typo/hook que quebram fluxos.
5. **Performance** — Paginação, body/upload limits, índices (apenas após medir).
6. **Refactors** — ProtectedRoute, Zustand vs React Query, lazy load, TypeScript strict.
7. **Melhorias de UX** — Placeholders, Prettier, testes, documentação de API.

---

## 3. Now (Alta Prioridade)

Apenas tarefas de alto risco, impacto direto em produção, segurança ou inconsistência estrutural.

| ID | Título | Contexto | Documento(s) de origem | Impacto | Risco | Esforço | Dependências | Pronto quando… |
|----|--------|----------|-------------------------|---------|-------|---------|--------------|----------------|
| T001 | Aplicar ensureAuthenticate em rotas sensíveis | Rotas de image, document, payment, text, clause, contract, contact, notification, emailConfig, dateEvent, schedule, question, seasonalFee, proposal (create, byId, updatePersonalInfo), service list estão sem auth. | BACKEND_ANALISE_ATUAL, SECURITY_HARDENING, KNOWN_LIMITATIONS, AUTHORIZATION_MODEL, INTEGRACAO_FRONT_BACK_ANALISE_ATUAL | Alto | Alto | G | Definir lista de rotas públicas por design | Todas as rotas que alteram dados ou retornam dados restritos exijam token; exceção documentada só para rotas realmente públicas. |
| T002 | Setar req.userId no ensureAuthenticate | Middleware só valida JWT; trecho que setava req.userId está comentado. Impossível autorizar por recurso no servidor. | BACKEND_ANALISE_ATUAL, AUTHORIZATION_MODEL, SECURITY_HARDENING, INTEGRACAO_FRONT_BACK_ANALISE_ATUAL | Alto | Alto | P | Nenhuma | JWT decodificado e req.userId atribuído; Request tipado com userId. |
| T003 | Corrigir fluxo de refresh token (FE↔BE) | FE chama GET /auth/refresh sem body; BE espera body.accessToken. Refresh em 401 falha e usuário é deslogado. | INTEGRACAO_FRONT_BACK_ANALISE_ATUAL, SECURITY_HARDENING, KNOWN_LIMITATIONS | Alto | Alto | M | Alinhamento FE+BE | FE usa POST /token/refresh com body { accessToken }; ou BE implementa GET /auth/refresh lendo token do header; fluxo de 401 renova token e reenvia request. |
| T004 | Restringir CORS a origens conhecidas | server.ts usa origin: "*". Inadequado para produção com credenciais. | BACKEND_ANALISE_ATUAL, SECURITY_HARDENING, INTEGRACAO_FRONT_BACK_ANALISE_ATUAL | Alto | Médio | P | Lista de origens (env) | CORS configurado com process.env.CORS_ORIGIN (ex.: split por vírgula); .env.example documenta CORS_ORIGIN. |
| T005 | Não vazar detalhes em 500 em produção | error-handler retorna body.message = error.toString(); pode expor stack ou dados internos. | BACKEND_ANALISE_ATUAL, SECURITY_HARDENING | Alto | Médio | P | Nenhuma | Em NODE_ENV=production retornar mensagem genérica; logar erro completo apenas no servidor. |
| T006 | Tratamento global de erros async no BE | express-async-errors não importado; sem middleware de erro (4 params). Rejeições async podem não virar resposta JSON. | BACKEND_ANALISE_ATUAL, SECURITY_HARDENING, KNOWN_LIMITATIONS, INTEGRACAO_FRONT_BACK_ANALISE_ATUAL | Alto | Alto | P | Nenhuma | express-async-errors importado no topo de server.ts; middleware (err, req, res, next) chama handleErrors e responde JSON. |
| T007 | Expor GET document por ID e GET payment por ID no BE | FE chama GET /document/:id e GET /payment/byId/:id; rotas não existem no BE → 404 em produção. | INTEGRACAO_FRONT_BACK_ANALISE_ATUAL, KNOWN_LIMITATIONS | Alto | Médio | M | ensureAuthenticate onde fizer sentido | Rotas implementadas no router e use cases; FE pode buscar documento e pagamento por ID sem 404. |
| T008 | Corrigir typo organizattionId no FE | userOrganizationPermissionStore e ProtectedRoute usam organizattionId; service espera organizationId. Risco ao corrigir só em um lugar. | FRONTEND_TODO_PRIORIDADE, FRONTEND_ANALISE_ATUAL, KNOWN_LIMITATIONS, INTEGRACAO_FRONT_BACK_ANALISE_ATUAL | Alto | Médio | P | Nenhuma | Renomeado para organizationId em store e ProtectedRoute; service continua recebendo organizationId. |
| T009 | Corrigir assinatura do hook useGetVenuesList | Hook chama getAllVenues(organizationId) com 1 arg; service espera { organizationId, userId }. Lista pode falhar ou usar userId indefinido. | FRONTEND_TODO_PRIORIDADE, FRONTEND_ANALISE_ATUAL, KNOWN_LIMITATIONS, INTEGRACAO_FRONT_BACK_ANALISE_ATUAL | Alto | Médio | P | Nenhuma | Hook recebe organizationId e userId e chama venueService.getAllVenues({ organizationId, userId }). |
| T010 | Centralizar rotas públicas no FE | Lista duplicada em lib/axios.ts e useBootstrapUser.ts; alteração em uma gera inconsistência (redirect vs token). | FRONTEND_TODO_PRIORIDADE, FRONTEND_ANALISE_ATUAL, KNOWN_LIMITATIONS, INTEGRACAO_FRONT_BACK_ANALISE_ATUAL | Alto | Médio | P | Nenhuma | Constante única em src/constants/publicRoutes.ts; importada em axios e useBootstrapUser. |

---

## 4. Next (Médio Prazo)

Melhorias estruturais importantes mas não críticas.

| ID | Título | Contexto | Documento(s) de origem | Impacto | Risco | Esforço | Dependências | Pronto quando… |
|----|--------|----------|-------------------------|---------|-------|---------|--------------|----------------|
| T011 | Padronizar envelope de resposta no BE | BE retorna às vezes { data }, às vezes { success, message, data, count, type }, às vezes payload direto; FE usa fallbacks frágeis. | INTEGRACAO_FRONT_BACK_ANALISE_ATUAL, KNOWN_LIMITATIONS, MIGRATION_STRATEGY | Médio | Médio | G | Não quebrar clientes atuais | Formato único definido (ex.: sempre { data } para sucesso); documentado; FE ajustado onde padronizado; compatibilidade mantida (header/query se necessário). |
| T012 | Um único express.json e urlencoded com limit | Duplicação em server.ts (linhas 42–44); body limit 50mb. Comportamento confuso e risco DoS. | BACKEND_ANALISE_ATUAL, SECURITY_HARDENING | Médio | Baixo | P | Nenhuma | Um único express.json({ limit }) e um único urlencoded({ limit }); valor adequado (ex.: 10mb). |
| T013 | Criar .env.example no FE e no BE | Variáveis só em PRODUCTION_SETUP.md; ausência no repo dificulta onboarding e deploy. | INDEX, FRONTEND_TODO_PRIORIDADE, BACKEND_ANALISE_ATUAL, PRODUCTION_SETUP, INTEGRACAO_FRONT_BACK_ANALISE_ATUAL | Médio | Baixo | P | Nenhuma | Arquivos .env.example na raiz de eventhub-vista-dashboard e art56_server_v3 com nomes das variáveis (sem valores sensíveis). |
| T014 | Documentar rotas públicas por design | Evitar que ensureAuthenticate quebre formulários ou sites públicos; exceção explícita e única. | SECURITY_HARDENING, AUTHORIZATION_MODEL | Médio | Baixo | P | T001 (lista de exceções) | Lista em README ou doc (ex.: proposal create, byId, venue getWebData, organization getHubData/getOrganizationWebData) atualizada e referenciada. |
| T015 | Transação em criação de proposta e fluxos multi-escrita | proposal, payment, dateEvent fazem múltiplas escritas sem $transaction; risco de inconsistência em falha parcial. | BACKEND_ANALISE_ATUAL, PERFORMANCE_PLAN, KNOWN_LIMITATIONS | Médio | Médio | M | Backup/rollback planejado | Fluxos de create proposal (e relacionados) envolvidos em prisma.$transaction. |
| T016 | Paginação em listas principais (venue, proposal, organization) | findMany sem take/skip; performance e memória com muitos registros. | BACKEND_ANALISE_ATUAL, PERFORMANCE_PLAN, ROADMAP_TECHNICAL | Médio | Baixo | M | Compatibilidade | Parâmetros opcionais page/limit (ou take/skip); sem paginação = comportamento atual; resposta com total ou hasMore quando solicitado. |
| T017 | Unificar fonte de verdade Zustand vs React Query (FE) | Stores e hooks para os mesmos recursos; dados dessincronizados e refetch redundante. | FRONTEND_TODO_PRIORIDADE, FRONTEND_ANALISE_ATUAL, KNOWN_LIMITATIONS | Médio | Médio | G | Convenção documentada | Convenção definida (ex.: React Query como fonte por recurso; store só selectedVenue); um fluxo piloto migrado (ex.: lista de venues). |
| T018 | Simplificar ProtectedRoute (extrair usePreloadRouteContext) | Muitos useEffects e getState() em async; difícil testar e manter. | FRONTEND_TODO_PRIORIDADE, FRONTEND_ANALISE_ATUAL, KNOWN_LIMITATIONS | Médio | Baixo | M | Nenhuma | Lógica de preload em hook (ex.: usePreloadRouteContext); ProtectedRoute só auth + permissão + loading/erro/children. |
| T019 | Lazy load de rotas no App.tsx | Todas as páginas importadas estáticas; bundle grande e difícil leitura. | FRONTEND_TODO_PRIORIDADE, FRONTEND_ANALISE_ATUAL, KNOWN_LIMITATIONS | Médio | Baixo | M | Nenhuma | React.lazy + Suspense para páginas (ex.: 2–3 mais pesadas); opcionalmente rotas em arquivos separados. |
| T020 | Reforçar TypeScript no FE (strict gradual) | strict: false, noImplicitAny: false; erros de tipo passam despercebidos. | FRONTEND_TODO_PRIORIDADE, FRONTEND_ANALISE_ATUAL, KNOWN_LIMITATIONS | Médio | Baixo | G | Corrigir lib, store, services primeiro | strictNullChecks e/ou noImplicitAny habilitados em etapas; módulo piloto (ex.: lib/) sem erros. |
| T021 | Rate limit em /auth e /token | Sem rate limit; risco de abuso e DoS em login/refresh. | SECURITY_HARDENING, BACKEND_ANALISE_ATUAL, ROADMAP_TECHNICAL | Médio | Baixo | P | Nenhuma | express-rate-limit (ou equivalente) aplicado em rotas de auth e token; configurável (ex.: 5 req/min por IP). |

---

## 5. Later (Baixa Prioridade)

Refactors incrementais, otimizações e qualidade.

| ID | Título | Contexto | Documento(s) de origem | Impacto | Risco | Esforço | Dependências | Pronto quando… |
|----|--------|----------|-------------------------|---------|-------|---------|--------------|----------------|
| T022 | Extrair serviço de upload (S3/Sharp) dos controllers | Lógica de S3 e Sharp nos controllers; acoplamento e difícil teste. | BACKEND_ANALISE_ATUAL | Baixo | Baixo | M | Nenhuma | ImageStorageService (ou equivalente) extraído e injetado nos controllers. |
| T023 | Logger estruturado (pino) no BE | console.log/console.error em vários pontos; sem formato padrão nem correlation id. | BACKEND_ANALISE_ATUAL, OBSERVABILITY_PLAN | Médio | Baixo | M | Nenhuma | Pino (ou similar) em middleware de request e em error-handler; logs em JSON. |
| T024 | Health check com checagem de DB | GET / retorna "API online!"; sem verificação de dependências. | OBSERVABILITY_PLAN | Baixo | Baixo | P | Nenhuma | GET /health opcional com prisma.$queryRaw (ex.: SELECT 1); 503 e db: "error" em falha. |
| T025 | Corrigir nomes com typo no FE | OrganizationPermissionsv2, ContarctPjForm, ContarctPFForm; legibilidade e consistência. | FRONTEND_TODO_PRIORIDADE, FRONTEND_ANALISE_ATUAL, KNOWN_LIMITATIONS | Baixo | Baixo | P | Nenhuma | Renomeados para convenção correta (ex.: ContractPjForm, ContractPFForm); imports ajustados. |
| T026 | Resolver placeholders ProposalContact e ProposalSend | Rotas retornam apenas div simples; sem função real. | FRONTEND_TODO_PRIORIDADE, FRONTEND_ANALISE_ATUAL, KNOWN_LIMITATIONS | Baixo | Baixo | M | Definir escopo | Telas reais implementadas ou rotas removidas até existir implementação. |
| T027 | Revisar dependências de useEffect no FE | Vários eslint-disable-next-line react-hooks/exhaustive-deps; risco de stale closure ou deps incorretas. | FRONTEND_TODO_PRIORIDADE, FRONTEND_ANALISE_ATUAL | Baixo | Baixo | M | Nenhuma | Deps corretas nos useEffects citados; disable removido onde possível. |
| T028 | Adicionar Prettier no FE | Sem script de formatação; formatação inconsistente. | FRONTEND_TODO_PRIORIDADE, FRONTEND_ANALISE_ATUAL | Baixo | Baixo | P | Nenhuma | Prettier instalado e configurado; script format no package.json; opcionalmente format on save. |
| T029 | Unificar tratamento de erro da API no FE | Services e componentes tratam erro ad hoc; mensagens e comportamento diferentes por tela. | FRONTEND_TODO_PRIORIDADE, INTEGRACAO_FRONT_BACK_ANALISE_ATUAL | Médio | Baixo | M | Nenhuma | Interceptor de response que normaliza erro; opcionalmente toast/estado global; serviços com erro tipado único. |
| T030 | Configurar testes no FE (Vitest ou Jest) | Nenhum arquivo *.test.* ou script test no package.json. | FRONTEND_TODO_PRIORIDADE, FRONTEND_ANALISE_ATUAL | Médio | Baixo | P | Nenhuma | Vitest ou Jest configurado; script test no package.json. |
| T031 | Testes unitários mínimos no FE | ProtectedRoute, useBootstrapUser, lib/utils, lib/error-handler sem testes. | FRONTEND_TODO_PRIORIDADE, FRONTEND_ANALISE_ATUAL | Médio | Baixo | M | T030 | Redirect sem auth, AccessDenied sem permissão; bootstrap com/sem token; handleBackendError, cn() cobertos. |
| T032 | E2E com Playwright (fluxos críticos) | Nenhum E2E; regressão manual. | FRONTEND_TODO_PRIORIDADE, ROADMAP_TECHNICAL | Baixo | Baixo | G | T030 | Playwright configurado; fluxo login → dashboard → venue → proposal coberto. |
| T033 | Remover arquivo Zod duplicado no BE | list-service-by-venue-param-schema copy.ts em zod/services; poluição. | BACKEND_ANALISE_ATUAL | Baixo | Baixo | P | Nenhuma | Cópia removida; um único schema em uso. |
| T034 | Reduzir body limit e definir Multer fileSize | Body 50mb facilita DoS; sem limite por arquivo no Multer. | SECURITY_HARDENING, PERFORMANCE_PLAN | Médio | Baixo | P | T012 (evitar conflito) | Limit global adequado (ex.: 10mb); Multer limits.fileSize para uploads. |
| T035 | Paginação em payment, user e outros list | Estender padrão de paginação às demais listagens conforme uso. | PERFORMANCE_PLAN, ROADMAP_TECHNICAL | Baixo | Baixo | M | T016 | Parâmetros opcionais page/limit aplicados; compatibilidade mantida. |
| T036 | Documentação de API (OpenAPI ou README) | Contratos implícitos; integração manual. | INTEGRACAO_FRONT_BACK_ANALISE_ATUAL, ROADMAP_TECHNICAL | Médio | Baixo | M | T011 (envelope estável) | Endpoints críticos documentados (método, auth, body, response); ou OpenAPI gerado. |
| T037 | Revisar status dos docs no INDEX | Coluna Status do Mapa por Área deve refletir realidade. | INDEX | Baixo | Baixo | P | Nenhuma | Coluna "Status" (✅ Atual / ⚠️ Revisar / ❌ Desatualizado) revisada e atualizada. |
| T038 | Alinhar README.md com INDEX.md | README é índice resumido; INDEX é o mapa oficial. | INDEX | Baixo | Baixo | P | Nenhuma | README aponta para INDEX.md como referência completa da documentação. |
| T039 | Índices no banco (apenas se gargalo medido) | Sugestões para proposal/dateEvent por período; não alterar sem medição. | PERFORMANCE_PLAN, DATA_MODEL_EXPLAINED | Baixo | Baixo | P | Métricas/slow query | Índices compostos (ex.: venueId + startDate) só após evidência de lentidão em produção. |

---

## 6. Trilhas Técnicas

Agrupamento das tarefas por categoria (referência aos IDs das seções 3–5).

| Trilha | Tarefas |
|--------|---------|
| **Segurança & Autorização** | T001, T002, T003, T004, T005, T021, T034 |
| **Banco & Migrações** | T015, T039 (e MIGRATION_STRATEGY para qualquer mudança de schema) |
| **API & Contratos** | T007, T011, T036 |
| **Backend** | T001, T002, T004, T005, T006, T012, T015, T016, T022, T023, T024, T033, T034, T035 |
| **Frontend** | T008, T009, T010, T017, T018, T019, T020, T025, T026, T027, T028, T029, T030, T031, T032 |
| **Integração FE↔BE** | T003, T007, T008, T009, T010, T011, T029, T036 |
| **Observabilidade** | T023, T024, T037 (e OBSERVABILITY_PLAN para métricas/alertas) |
| **Performance** | T016, T034, T035, T039 |
| **Produção/Infra** | T013, T014, T037, T038 (e PRODUCTION_SETUP para deploy/smoke test) |

---

## 7. Formato Obrigatório de Cada Tarefa

Toda tarefa do backlog deve conter:

- **Título** — Curto e acionável.
- **Contexto** — Uma linha explicando o problema ou a oportunidade.
- **Documento(s) de origem** — Ao menos um arquivo em `/docs` que fundamenta a tarefa.
- **Impacto** — Alto / Médio / Baixo.
- **Risco** — Alto / Médio / Baixo.
- **Esforço** — P (pequeno) / M (médio) / G (grande).
- **Dependências** — Outras tarefas ou decisões necessárias.
- **Critério de aceite** — "Pronto quando…" observável e verificável.

Ao adicionar nova tarefa ao TODO_MASTER, preencher todos os campos e citar documento(s) de origem. Não incluir tarefas sem base documental.

---

## 8. Migração do TODO do Frontend

O conteúdo relevante de [FRONTEND_TODO_PRIORIDADE.md](./FRONTEND_TODO_PRIORIDADE.md) foi migrado para este documento da seguinte forma:

| FRONTEND_TODO (prioridade) | TODO_MASTER |
|----------------------------|-------------|
| P1 #1 — Typo organizattionId | T008 (Now) |
| P1 #2 — Hook useGetVenuesList | T009 (Now) |
| P1 #3 — Centralizar rotas públicas | T010 (Now) |
| P2 #4 — Zustand vs React Query | T017 (Next) |
| P2 #5 — Simplificar ProtectedRoute | T018 (Next) |
| P2 #6 — Lazy load / App.tsx | T019 (Next) |
| P2 #7 — TypeScript strict | T020 (Next) |
| P2 #8 — .env.example | T013 (Next; inclui BE) |
| P3 #9 — Nomes com typo | T025 (Later) |
| P3 #10 — Placeholders ProposalContact/Send | T026 (Later) |
| P3 #11 — Deps useEffect | T027 (Later) |
| P3 #12 — Prettier | T028 (Later) |
| P3 #13 — Tratamento de erro API | T029 (Later) |
| P4 #14 — Configurar testes | T030 (Later) |
| P4 #15 — Testes unitários mínimos | T031 (Later) |
| P4 #16 — E2E Playwright | T032 (Later) |

**Documento original:** [FRONTEND_TODO_PRIORIDADE.md](./FRONTEND_TODO_PRIORIDADE.md). Mantido como referência de detalhes por prioridade P1–P4 e sugestão de ordem de execução (1–2 dias P1; P2 em duas semanas). Evitar redundância longa: FRONTEND_TODO focado em tarefas de FE; KNOWN_LIMITATIONS em dívidas/riscos (ver INDEX §7 Gaps).

---

## 9. Processo de Manutenção

- **Tarefa concluída:** Atualizar os documentos impactados conforme [INDEX.md](./INDEX.md) seção 5 (Política de Atualização Obrigatória). Ex.: alteração em backend → BACKEND_ANALISE_ATUAL.md; se mudar endpoint/payload → API_CONTRACTS.md; se mudar auth → AUTHORIZATION_MODEL.md e SECURITY_HARDENING.md. Nenhuma tarefa é considerada concluída se o código foi alterado e a documentação impactada não foi atualizada (ver [GUIA_DE_IMPLEMENTACAO.md](./GUIA_DE_IMPLEMENTACAO.md) §5).
- **Backlog oficial:** O **TODO_MASTER** é o backlog oficial do projeto. Priorização e decisões de escopo devem usar as seções Now / Next / Later e as Regras de Priorização (§2).
- **TODOs locais:** [FRONTEND_TODO_PRIORIDADE.md](./FRONTEND_TODO_PRIORIDADE.md) e listas pontuais em outros docs são **auxiliares**. Novos itens descobertos no dia a dia devem ser incorporados ao TODO_MASTER (com documento de origem) e, se for o caso, referenciados no doc de análise correspondente.
- **Revisão:** Ajustar Now/Next/Later quando novas limitações forem descobertas (ex.: [KNOWN_LIMITATIONS.md](./KNOWN_LIMITATIONS.md)) ou quando o [ROADMAP_TECHNICAL.md](./ROADMAP_TECHNICAL.md) for revisado (ex.: a cada 30 dias).

---

*Documento gerado a partir exclusivamente dos documentos em `/docs`. Última atualização: fevereiro/2025.*
