# Tasks — Adicionar ou tirar servico no link publico

## Ordem macro

1. `T-01` grava a selecao e o total no use case.
2. `T-02` publica o contrato HTTP. Depende de `T-01`.
3. `T-03` coloca o botao e o modal. Depende de `T-02`.

## Tasks

### T-01 - Gravar a selecao publica no use case

- objetivo: o use case aplica o conjunto, recoloca o obrigatorio, conserva o snapshot e move so a soma dos servicos.
- cobre requisitos: `R-04`, `R-05`, `R-08`, `R-09`, `R-12`, `R-13`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: `quoteServiceLines`, `sumServiceQuote`, `getByVenueId`, `proposalRepository.update` com `serviceLines`, `historyRepository.create`
- prompt recomendado: `normal`
- estrategia de teste: unitario do use case com repositorios falsos
- cenarios obrigatorios: tira opcional e o total cai o `amount` dessa linha; obrigatorio omitido volta e entra na soma; id de outro espaco nao chama `update`; selecao igual nao chama `update` nem historico; servico novo de hora usa a duracao ja gravada; linha antiga sem `amount` nao deixa resto no total; `approved` nao grava
- definition of done: os cenarios acima passam em `npm test -- --run` no arquivo do use case; dia, locacao e horas extras nao vao no `update`; nenhuma frase de produto ainda

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — a regra que impede tirar obrigatorio e reescrever a locacao
- risco principal: somar errado e deslocar um total negociado, ou gravar servico de outro espaco
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: rota HTTP, tela, foto e descricao, desconto, recalculo de locacao
- prova minima desta task: o unitario mostra total novo igual ao total antigo menos a linha removida, e `update` sem `basePrice`
- criterio de escalada: se a soma antiga nao puder ser lida das linhas gravadas, parar e voltar ao design
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Decisoes arquiteturais importantes`
  - `.cursor/framework_global/framework-libs/security/index.md#Quando esta lib e obrigatoria`
  - `.cursor/framework_core/project/project-decisions.md#D-02 Monolito modular Express`
- caminhos candidatos: `art56_server_v3/src/use-cases/proposal/recalculate-public-proposal/use-case-recalculate-public-proposal.ts`, `art56_server_v3/src/functions/quote-service-lines.ts`
- palavras-chave ou simbolos de busca: `quoteServiceLines`, `getByVenueId`, `serviceLines`, `rpaMinPeople`, `HISTORY_ACTION`
- testes provaveis: `npm test -- --run src/use-cases/proposal/update-public-proposal-services/use-case-update-public-proposal-services.spec.ts`
- nao ler por padrao: `01-spec.md` inteiro, `04-tasks.md` inteiro, tela, cadastro de servico

### T-02 - Publicar as rotas de leitura e gravacao

- objetivo: `GET` e `PUT` em `/proposal/presentation/:proposalId/services` seguem o contrato e nao devolvem preco unitario.
- cobre requisitos: `R-03`, `R-06`, `R-10`
- depende de: `T-01`
- pode rodar em paralelo com: nenhuma
- reusa: o controller e o Zod de `recalculate-public-proposal`; o use case de `T-01`
- prompt recomendado: `normal`
- estrategia de teste: unitario do controller e da presenca da rota
- cenarios obrigatorios: `PUT` sem `ensureAuthenticate`; corpo com `price` ou `totalAmount` nao chega ao use case; `serviceIds` vazio e aceito; mais de 100 ids nao chama o use case; resposta de sucesso nao tem `price`, `unitPrice` nem `pricingType`; aprovado devolve a mensagem de confirmado
- definition of done: os cenarios passam no teste do controller; as rotas estao em `proposal.ts` junto do recalculo

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — rota publica que grava valor
- risco principal: aceitar preco vindo do cliente ou devolver o cadastro do servico
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: regra de soma, tela, rate limit novo
- prova minima desta task: o teste da rota mostra `PUT` publico e a resposta sem `unitPrice`
- criterio de escalada: se o controller precisar de outro formato alem do contrato, parar e ajustar o design antes
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Passada transversal`
  - `.cursor/framework_global/framework-libs/security/skills/reviewing-security-sensitive-changes.md#2. Revisar autenticacao e autorizacao`
  - `.cursor/framework_core/project/project-decisions.md#D-05 Autorizacao parcialmente client-side`
- caminhos candidatos: `art56_server_v3/src/router/proposal.ts`, `art56_server_v3/src/use-cases/proposal/recalculate-public-proposal/controller-recalculate-public-proposal.ts`
- palavras-chave ou simbolos de busca: `presentation/:proposalId/recalculate`, `ensureAuthenticate`, `recalculatePublicProposalBodySchema`
- testes provaveis: `npm test -- --run src/use-cases/proposal/update-public-proposal-services/controller-update-public-proposal-services.spec.ts`
- nao ler por padrao: `01-spec.md` inteiro, tela, `topics/`

### T-03 - Botao e modal na experiencia

- objetivo: o cliente marca ou desmarca no card e ve a lista e o total gravados, ou o motivo da falha.
- cobre requisitos: `R-01`, `R-02`, `R-07`, `R-11`
- depende de: `T-02`
- pode rodar em paralelo com: nenhuma
- reusa: botao pill e `Dialog` de `RecalculateProposalDialog`; texto de obrigatorio ja escrito em `ProposalView`; `setCurrentProposal`
- prompt recomendado: `normal`
- estrategia de teste: browser em `/proposal/:id/view`; `npm run lint` no frontend
- cenarios obrigatorios: botao abre o modal com os servicos do espaco; obrigatorio vem marcado e nao desmarca; confirmar tira um opcional e o investimento baixa; orcamento aprovado mostra a mensagem e nao grava; falha de rede mantem o total da pagina e as caixas do modal; o segundo clique em Confirmar nao parte enquanto o primeiro nao volta; card some quando o espaco nao tem servico
- definition of done: os cenarios de browser foram exercitados; a linha do investimento usa `amount` quando vier numero; uma frase em `product/02-business-rules.md#Proposal` e outra em `product/03-user-profiles.md#Cliente proponente`; lint do frontend sem erro novo nestes arquivos

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — a tela chama a gravacao publica e nao pode enviar preco
- risco principal: esconder o obrigatorio, ou atualizar o total da pagina antes da resposta
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: foto, descricao, skeleton novo, botao de "Alterar orcamento"
- prova minima desta task: no browser, tirar um opcional atualiza a experiencia e o total; o obrigatorio continua marcado
- criterio de escalada: se a pagina precisar de `GET /service/list/:venueId`, parar; o catalogo vem de `GET .../services`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Reuso previsto`
- libs obrigatorias: `react`, `design`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Reuso previsto`
  - `01-spec.md#Criterios de aceite`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/ProposalView.tsx`, `eventhub-vista-dashboard/src/components/proposal/RecalculateProposalDialog.tsx`, `eventhub-vista-dashboard/src/services/proposal.service.ts`
- palavras-chave ou simbolos de busca: `Sua experiência inclui`, `setRecalculateOpen`, `recalculatePublicProposal`, `rpaMinPeople`
- testes provaveis: `npm run lint` no frontend; fluxo do modal no browser
- nao ler por padrao: `04-tasks.md` inteiro, use case, cadastro de servico no painel
