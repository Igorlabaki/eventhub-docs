# Review da spec — 2026-11-20

Entrada: `specs/2026-11-20-url-orcamento-nome-e-codigo/` mais o pedido de um so padrao para todo link publico enviado ao cliente.

Padrao cobrado nesta review, fechado no chat e ainda fora da spec:

- `/espaco/AR756/apresentacao`
- `/espaco/AR756/formulario`
- `/espaco/AR756/regras`
- `/espaco/AR756/parceiro`
- `/espaco/AR756/colaborador`
- `/espaco/AR756/orcamento/maria-silva-{codigo}`
- o mesmo orcamento com `/evento`, `/convidados`, `/colaboradores`, `/programacao`, `/indicacoes`, `/contrato`
- link antigo com `venue`, `proposal` e id continua abrindo
- painel e API continuam em `/proposal/`

## Achados

- severidade: `alta`
- tipo: `lacuna de requisito`
- onde: `01-spec.md#Fora de escopo`, `02-clarify.md#Premissas assumidas`, `03-design.md#Decisoes arquiteturais importantes`, `04-tasks.md#T-02`
- evidencia: a spec manda manter formulario e apresentacao em `/venue/{nome}`, regras e cadastros fora, e os sufixos `links`, `guest-list`, `staff-list`, `schedule-list`, `indications`, `person-contract` e `b2b-contract`. O chat seguinte pediu o mesmo padrao em todos esses links.
- impacto: `T-02` entrega so a familia do orcamento, com sufixo em ingles. Apresentacao, formulario, regras, parceiro e colaborador seguem em `/venue/`.
- reforco: tirar esse conjunto do fora de escopo; um `R-xx` por familia (casa pelo nome, orcamento pelo codigo); `T-02` ou uma `T-03` cobre apresentacao, formulario, regras, parceiro, colaborador e os sufixos em portugues. Links velhos continuam.

- severidade: `alta`
- tipo: `lacuna de design`
- onde: `03-design.md#Componentes e modulos impactados`, `04-tasks.md#T-02`
- evidencia: o link do orcamento tambem e copiado em `ProposalDetails.tsx`, `EmailTab.tsx`, `SendProposalPage.tsx`, `person-list.tsx`, `schedule-list.tsx` e `ProposalContractForm.tsx`. A spec cita `event-link.ts` e o redirect do formulario. Regras usam o id em `public-venue-rules.ts`; apresentacao e formulario usam o nome em `public-venue-presentation.ts`; parceiro e colaborador usam o id em `VenueContacts.tsx`.
- impacto: mesmo o `R-01` atual fica pela metade. Com o padrao novo, esses arquivos nem entram na task.
- reforco: listar cada copia no design e no MRS da task que troca a URL.

- severidade: `media`
- tipo: `lacuna de clarify`
- onde: tabela do chat, um unico `/contrato`
- evidencia: hoje existem `/person-contract` e `/b2b-contract`, duas paginas.
- impacto: um caminho `/contrato` precisa escolher PF ou PJ pelo tipo gravado. Sem isso a task inventa dois sufixos ou uma tela.
- reforco: premissa — `/contrato` abre a pagina do tipo ja gravado. Nao bloqueia o resto do padrao.

- severidade: `baixa`
- tipo: `desalinhamento interno`
- onde: `00-overview.md#Observacoes`
- evidencia: a restricao diz que a URL publica usa `espaco` e `orcamento`, e o fora de escopo guarda `/venue/` no formulario e na apresentacao.
- impacto: o overview promete o padrao que o resto da spec recusa.
- reforco: alinhar a frase ao escopo depois de aplicar o achado alto.

## Parecer

- spec: precisa reforcar antes de executar `T-02`
- `T-01`: pronta. A coluna e a leitura por codigo nao dependem do nome dos caminhos.
- `T-02`: nao pronta. O escopo e a lista de arquivos ficaram atras do chat.
- outro agente executaria `T-01` com seguranca e deixaria a maior parte dos links do cliente no modelo velho se seguisse `T-02` como esta.

## Veredito

- veredito: CHANGES_REQUESTED
- bloqueantes: 2
- achados:
  - alta: fora de escopo deixa formulario, apresentacao, regras, cadastros e os sufixos em ingles fora do padrao `/espaco/...`
  - alta: design e MRS de `T-02` nao listam todos os pontos que copiam o link
  - media: `/contrato` precisa escolher PF ou PJ pelo tipo gravado
  - baixa: overview promete `espaco` em toda URL publica e o fora de escopo guarda `/venue/`
