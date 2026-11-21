# Solicitacao da Tarefa

## Nome sugerido da tarefa

Barra de rolagem moderna, nas cores da casa, no modal de detalhe do servico

## Resumo da solicitacao

O modal publico de detalhe do servico (titulo, foto e descricao, aberto pelo `?` ao lado do servico no formulario de orcamento e na proposta) rola com a barra nativa do Windows: cinza, com setas e trilho claro. A barra passa a ser fina, sem setas, com trilho transparente e polegar arredondado na cor escolhida pela casa.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- camadas transversais: `design`
- risco principal: barra sem contraste com o fundo do card da casa (some ou fica berrante), ou o Chrome 121+ ignorar o `::-webkit-scrollbar` porque `scrollbar-color` foi declarado fora do `@supports`
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: mudar a `.scrollbar-eventhub` do painel (sidebar), outros modais e paginas, layout, tamanho e conteudo do modal, os campos de cor da casa
- prova minima desta execucao: em `/proposal-form/:id` (ou na proposta publica), abrir o `?` de um servico com foto alta; a barra aparece fina, sem setas, sem trilho claro, sem encostar nos cantos arredondados, na cor da casa e legivel contra o fundo do card; em casa com cores escuras e em casa com cores claras; no Firefox a barra fina segue a mesma cor
- criterio de escalada: permanece `smart`; sobe para `normal` se a casa precisar de um campo novo de cor (backend e cadastro)
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/components/proposal/forms/PublicServiceDetail.tsx` em `PublicServiceDetailDialog`; `eventhub-vista-dashboard/src/index.css` em `@layer utilities` (`.scrollbar-eventhub`)
- libs obrigatorias: `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/ProposalForm.tsx` (`cardStyle`, `primary`); `eventhub-vista-dashboard/src/pages/ProposalView.tsx` (`cardStyle` perto da linha 772 e o uso de `PublicServiceDetailDialog`); `eventhub-vista-dashboard/src/components/proposal/forms/ClientPerDayProposalForm.tsx` e `ClientPerPersonProposalForm.tsx` (passam `surfaceStyle={cardStyle}`); `eventhub-vista-dashboard/src/components/ui/dialog.tsx`
- palavras-chave ou simbolos de busca: `PublicServiceDetailDialog`, `surfaceStyle`, `cardStyle`, `scrollbar-eventhub`, `proposalSecondaryColor`, `proposalTextColor`
- testes provaveis: o `DialogContent` do detalhe do servico recebe a classe nova; o padrao de teste por classe ja existe em `components/sidebar/SectionedNav.test.tsx`
- nao ler por padrao: `security`, `database`, backend, `topics/`

## Contexto informado na entrada

Pedido em chat com print do modal `Painel de Led` aberto sobre o formulario publico de orcamento (fundo escuro, foto vertical do salao) e a barra cinza nativa do Windows na lateral direita. Texto: "o scroll deve ser mais moderno e usando as cores que a casa escolheu".

## Problema atual

O `DialogContent` do detalhe tem `max-h-[85vh] overflow-y-auto` sem estilo de barra, entao aparece a barra padrao do sistema, que destoa da pagina personalizada da casa. A unica barra estilizada do projeto, `.scrollbar-eventhub`, usa `--primary` (cor do EventHub, nao da casa) e so aparece no hover.

## Objetivo da mudanca

Ao rolar o modal de detalhe do servico, a barra e fina, sem setas, com trilho transparente, e o polegar usa a cor da casa com contraste legivel sobre o fundo do card.

## Escopo inicial percebido

Uma utility CSS nova para superficies publicas da casa e a classe aplicada no `PublicServiceDetailDialog`. A cor sai do `surfaceStyle` que o modal ja recebe (`color` = cor de texto da casa). Sem prop nova obrigatoria, sem backend.

## Itens incluidos neste request

- utility nova em `index.css` (ex.: `.scrollbar-house`): largura fina, sem botoes, trilho transparente com `margin-block`, polegar arredondado com `color-mix` sobre a cor da casa, hover mais forte
- variavel opcional (ex.: `--house-scroll`) com fallback em `currentColor`, para permitir a cor primaria da casa no futuro sem trocar a classe
- bloco `@supports not selector(::-webkit-scrollbar)` com `scrollbar-width: thin` e `scrollbar-color` para Firefox
- classe aplicada no `DialogContent` de `PublicServiceDetailDialog`, que cobre o formulario por dia, o por pessoa e a proposta publica

## Requisitos implicitos ja visiveis

- a barra nao encosta nos cantos arredondados do modal (`sm:rounded-lg`)
- sem cor da casa definida, cair no `currentColor` do modal, sem barra invisivel
- respeitar `prefers-reduced-motion` se houver transicao
- a `.scrollbar-eventhub` do painel continua igual

## Casos de erro e borda ja percebidos

- conteudo curto, sem rolagem: nenhuma barra aparece
- casa com fundo do card e cor de texto proximos: a barra herda o mesmo contraste do texto, sem piorar
- Chrome 121+: `scrollbar-color` fora do `@supports` desliga o `::-webkit-scrollbar`
- touch/mobile: barra overlay do sistema, sem regressao

## Dependencias

- `cardStyle` de `ProposalForm.tsx` e `ProposalView.tsx` chegando como `surfaceStyle` no modal (ja existe)

## Restricoes e cuidados

- nao alterar `.scrollbar-eventhub` nem o teste da sidebar
- nao usar a cor primaria da casa como default (pode coincidir com o fundo do card)
- seguir o comentario existente em `index.css` sobre `scrollbar-width`/`scrollbar-color`

## Perguntas em aberto

- Qual cor da casa no polegar: texto ou primaria? Premissa: cor de texto (`currentColor`), que ja contrasta com o card; primaria fica possivel via variavel opcional.
- A barra fica sempre visivel ou so no hover? Premissa: sempre visivel e discreta, com hover mais forte, porque o usuario precisa saber que ha conteudo abaixo da foto.
- Aplicar em outros modais publicos? Premissa: nao nesta task; so o detalhe do servico.

## Prioridade sugerida

Baixa a media. Acabamento visual da pagina publica da casa; nada quebrado.

## Faixa sugerida para task workflow

- `A` — um repo, CSS e uma classe, sem contrato
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: ajuste visual isolado em um componente

## Sugestao de slug da spec

- `framework_core/specs/scroll-modal-servico-cores-da-casa/`, apenas se a escalada para spec acontecer

## Sugestao de nome do arquivo

- `scroll-modal-servico-cores-da-casa-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- status: codigo escrito em 2026-11-09 (`.scrollbar-house` em `index.css`, classe no `PublicServiceDetailDialog`, `PublicServiceDetail.test.tsx`); vitest, eslint e build verdes; prova no browser feita no Chromium em `/venue/:id/form` da AR756 (barra fina, sem setas, trilho transparente, cor de texto da casa) e com cores claras simuladas; Firefox nao verificado
- proximo passo: `review` (L2)
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `nao se aplica` (um repo)
