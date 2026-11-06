# Spec — Links do painel e formularios de cadastro

## Problema

Em Regras, o endereco publico aparece num campo somente leitura e o texto copiado usa `window.location.origin`. No painel local, o que vai para a area de transferencia comeca com localhost. Nova regra e Nova caracteristica reabrem com o cadastro anterior. Link do evento, na sidebar do orcamento, abre outra pagina do painel com o mesmo tipo de campo, em vez da pagina publica daquele orcamento.

## Objetivos

- copiar o link das regras por um botao largo, ja na base `https://event-hub-dashboard.vercel.app`
- abrir Nova regra e Nova caracteristica com os campos de criacao vazios, sem alterar a edicao
- abrir a pagina publica do evento numa aba nova, a partir do item que ja existe na sidebar

## Fora de escopo

- conteudo, rota e leitura de `/venue/:id/rules/view`
- destino "Regras do espaço" em `/proposal/:id/links`
- tela Indicar parceiros
- formularios de servico, contato, orcamento e os demais cadastros
- apagar a rota `/proposal/:id/event-link`
- variavel de ambiente para a base, WhatsApp, e-mail e contrato novo

## User stories ou cenarios principais

- em Regras, a pessoa copia o link publico daquele espaco e envia ao cliente, mesmo com o painel aberto em localhost
- depois de cadastrar uma regra ou uma caracteristica, o proximo cadastro comeca vazio; a edicao continua mostrando o item clicado
- na sidebar do orcamento, Link do evento abre a pagina publica daquele orcamento em outra aba e o painel fica onde estava

## Criterios de aceite

- `R-01`: em Regras nao ha rotulo nem campo somente leitura com o endereco
- `R-02`: o botao largo "Copiar link das regras" copia `https://event-hub-dashboard.vercel.app/venue/{id}/rules/view`, tambem com o painel em localhost
- `R-03`: copia bem-sucedida mostra o toast de sucesso; copia recusada mostra aviso e nao pede para selecionar um campo
- `R-04`: sem id de espaco, o botao nao aparece e nada e copiado
- `R-05`: Nova regra abre com titulo e texto vazios depois de salvar, depois de cancelar e depois de uma edicao
- `R-06`: Nova caracteristica abre com o nome vazio nos mesmos tres casos
- `R-07`: editar uma regra mostra titulo, texto e posicao da regra clicada; editar uma caracteristica mostra nome e posicao da caracteristica clicada
- `R-08`: gravacao que falha deixa o formulario aberto com o que foi digitado
- `R-09`: Link do evento abre `https://event-hub-dashboard.vercel.app/proposal/{id}/links` noutra aba e a aba do painel nao vai para `/proposal/{id}/event-link`
- `R-10`: o item segue visivel so com `SEND_PROPOSAL_INFO`; sem id de orcamento nao abre aba; se o navegador bloquear a aba, o painel permanece
- `R-11`: a pagina publica das regras, o destino "Regras do espaço" e Indicar parceiros permanecem

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: quem nao abre Regras continua sem ver o botao; o item da sidebar nao ganha nem perde permissao; as paginas publicas ja existentes nao mudam de audiencia
- erros e mensagens esperadas: toast de sucesso e de falha na copia; erro de gravacao de regra ou caracteristica continua no toast que a secao ja mostra, com os campos preservados
- observabilidade minima: nenhuma metrica nova; o toast e a aba aberta sao o sinal para quem usa
- concorrencia, idempotencia ou retry: nao se aplica; nao ha fila, retry nem gravacao repetida
- rollout, fallback ou degradacao: deploy do frontend; reverter o commit devolve o campo, o formulario preso e a navegacao interna

## Casos de erro e borda obrigatorios

- caso: area de transferencia recusa a copia
  impacto: a pessoa nao recebe o link e a lista de regras continua na tela
  cobertura esperada: `R-03` em `T-01`
- caso: espaco ou orcamento sem id
  impacto: endereco incompleto nao sai do painel
  cobertura esperada: `R-04` e `R-10`
- caso: painel em localhost
  impacto: o texto copiado e a aba nova nao podem conter localhost
  cobertura esperada: `R-02` e `R-09`
- caso: gravacao de regra ou caracteristica falha
  impacto: o texto digitado nao pode sumir
  cobertura esperada: `R-08` em `T-02`
- caso: sair de uma edicao e abrir um cadastro novo, ou o contrario
  impacto: criacao nao herda o item; edicao nao herda o rascunho
  cobertura esperada: `R-05`, `R-06` e `R-07`

## Impacto esperado

Tres gestos do painel passam a se comportar como as outras telas que ja entregam link de producao, e o cadastro repetido de regra e caracteristica deixa de exigir apagar o item anterior.

## Areas impactadas

- `frontend`: `VenueRules.tsx`, secoes e formularios de regra e caracteristica, `ProposalNav.tsx`, `public-venue-rules.ts`, `event-link.ts`
- `backend`: nenhum

## Restricoes e cuidados

- a base pedida e a mesma ja escrita em Orcamentos e Contatos; nao extrair um modulo unico de origem nesta feature
- nao alterar `AnimatedFormSwitcher`; ele esconde o formulario sem desmontar e e compartilhado
- nao recolocar o campo de endereco em outro ponto do painel
- nao ler nem versionar valores de `.env`

## Dependencias

- `publicVenueRulesPath` ja devolve `/venue/{id}/rules/view`
- `ProposalEventLinkPage` ja responde em `/proposal/:id/links`
- `NavItem` ja distingue link interno de botao sem `href`
- Orcamentos e Contatos ja usam botao `outline` com `w-full` e a base `https://event-hub-dashboard.vercel.app`

## Mapeamento leve requisito -> task -> prova

- `R-01` a `R-04` -> `T-01` -> unitario da URL e browser da tela Regras
- `R-05` a `R-08` -> `T-02` -> unitario da key e browser dos dois cadastros
- `R-09` a `R-11` -> `T-03` -> unitario da URL e dos destinos, e browser da sidebar

## Perguntas em aberto

Nenhuma bloqueante. Premissas em `02-clarify.md`.

## Base documental

- lote `task-requests/2026-11-05-links-painel-e-formularios/`
- `specs/2026-11-05-link-publico-regras-do-espaco/` como dona da pagina publica, nao deste gesto
- `topics/frontend-application.md`: rotas no frontend e formularios publicos; nao muda estes tres gestos
- `framework-libs/react/index.md`, `framework-libs/design/index.md`, `framework-libs/design/rules/06_forms_and_input_ux.md`
- codigo citado em `03-design.md#Componentes e modulos impactados`

## Operacao

- tipo: `spec`
- proxima task: nenhuma; `T-01` a `T-03` escritas
- execucao recomendada: `smart`
- repo-local: `nao se aplica`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
