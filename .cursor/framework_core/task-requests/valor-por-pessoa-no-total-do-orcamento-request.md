# Solicitacao da Tarefa

## Nome sugerido da tarefa

Valor por pessoa ao lado do Total na criacao do orcamento

## Resumo da solicitacao

No formulario do painel que cria orcamento por pessoa, ao lado do campo Total aparece quanto a festa sai por pessoa (total dividido pelo numero de convidados), recalculado enquanto o usuario digita o total ou muda os convidados.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- camadas transversais: `design`
- risco principal: o texto ao lado do input quebrar a ligacao do `FormControl` com o input (label, `aria-*` e mensagem de erro) ou espremer o campo no grid de duas colunas
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: backend e calculo automatico do total; formulario por diaria (`PerDayProposalForm`); formularios publicos (`ClientPerPersonProposalForm`, `ClientPerDayProposalForm`); edicao do orcamento; mock `NewBudget.tsx`; contrato e payload enviados na criacao
- prova minima desta execucao: em `/venue/:id/budgets`, novo orcamento por pessoa com 100 convidados e Total R$ 5.000,00 mostra `R$ 50,00 / pessoa` ao lado do campo; trocar para 80 convidados mostra `R$ 62,50 / pessoa` sem salvar; total ou convidados vazios mostram `— / pessoa`; o payload enviado continua igual
- criterio de escalada: permanece `smart`; sobe para `normal` se o valor por pessoa tiver de refletir o total que o backend calcula quando o campo fica em branco
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/components/proposal/forms/PerPersonProposalForm.tsx` no `form.watch("guestNumber")` e no `FormField` de `totalAmountInput`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/VenueBudgets.tsx` so para achar a tela; `eventhub-vista-dashboard/src/components/ui/form.tsx` so para confirmar o `Slot` do `FormControl`
- palavras-chave ou simbolos de busca: `totalAmountInput`, `guestNumberValue`, `NumericFormat`, `FormControl`, `toLocaleString("pt-BR"`
- testes provaveis: 5000 com 100 convidados da 50; 5000 com 80 da 62,50; total vazio; convidados vazio ou zero; total com centavos (`1234.56`); arredondamento em duas casas
- nao ler por padrao: `security`, `database`, `topics/`, backend, schema, formularios publicos

## Contexto informado na entrada

Pedido em chat: ao criar um orcamento, ao lado do input Total deve aparecer quanto sai por pessoa; ao digitar o total na mao (ex.: 5000), o valor por pessoa atualiza em tempo real.

## Problema atual

Quem monta o orcamento digita o Total, mas precisa fazer a conta de cabeca para saber o preco por convidado, que e como o cliente costuma comparar.

## Objetivo da mudanca

Com Total e Convidados preenchidos, o formulario mostra ao lado do Total o valor por pessoa em reais, atualizado a cada tecla, sem salvar e sem mudar o que e enviado ao backend.

## Escopo inicial percebido

Um calculo derivado no componente (`totalAmountInput` / `guestNumber`) e um texto ao lado do input. Os dois campos ja estao no form; `guestNumber` ja e observado com `form.watch`. Sem endpoint, contrato ou schema novo.

## Itens incluidos neste request

- texto `<valor> / pessoa` ao lado do input Total, na mesma linha
- valor em BRL no padrao `pt-BR` (ex.: `R$ 50,00 / pessoa`)
- recalculo ao mudar Total ou Convidados
- placeholder `— / pessoa` quando nao ha como calcular

## Requisitos implicitos ja visiveis

- valor por pessoa = total digitado / numero de convidados, em duas casas
- o `NumericFormat` entrega o valor sem mascara (`5000.00`); o calculo parte dele, nao do texto formatado
- o `FormControl` continua envolvendo so o input; o texto fica fora dele
- o campo Total continua opcional e com a mesma mascara
- nada novo entra em `CreateProposalPerPersonDTO`

## Casos de erro e borda ja percebidos

- Total vazio: `— / pessoa` (o backend calcula o total depois, o form nao sabe o valor)
- Convidados vazio, zero ou invalido: `— / pessoa`, sem divisao por zero nem `NaN`/`Infinity`
- convidados acima de `maxGuest`: o calculo aparece normalmente; a validacao existente continua sendo a do campo
- divisao nao exata (5000 / 3): `R$ 1.666,67 / pessoa`
- tela estreita (uma coluna): o texto nao empurra o input para fora do card
- `form.reset()` apos criar: volta para `— / pessoa`

## Dependencias

- nenhuma; `totalAmountInput` e `guestNumber` ja existem no form

## Restricoes e cuidados

- nao alterar o payload nem o backend
- nao preencher o Total automaticamente
- nao tocar nos formularios publicos nem no de diaria neste request
- seguir o tom de texto auxiliar do form (`text-sm text-gray-500`, como o `Máximo de convidados`)

## Perguntas em aberto

- Vale tambem para o orcamento por diaria? Premissa: nao; la o numero e de hospedes e o pedido fala de festa. Se quiser, vira outro request.
- Texto ao lado ou embaixo do input? Premissa: ao lado, como pedido; em tela estreita pode quebrar para baixo.
- Com Total vazio, mostrar `— / pessoa` ou `calculado ao salvar`? Premissa: `— / pessoa`.

## Prioridade sugerida

Media. Ganho de leitura para quem monta o orcamento; nada quebra hoje.

## Faixa sugerida para task workflow

- `A` — um valor derivado e um texto num unico componente, sem contrato novo
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: um objetivo, um arquivo do frontend, dados que o form ja tem

## Sugestao de slug da spec

- `framework_core/specs/valor-por-pessoa-no-total-do-orcamento/`, apenas se a escalada para spec acontecer

## Sugestao de nome do arquivo

- `valor-por-pessoa-no-total-do-orcamento-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar entrega`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- entrega: `perPersonAmount` e `perPersonLabel` em `src/lib/per-person-amount.ts`; texto `<valor> / pessoa` ao lado do Total em `PerPersonProposalForm.tsx`, fora do `FormControl`, com `aria-live="polite"` e quebra de linha em largura curta; vitest 4 em `per-person-amount.test.ts`; eslint sem erro nos arquivos tocados (aviso `react-refresh` ja existente); `tsc` sem erro nos arquivos tocados (erros antigos em outros arquivos); browser parado no login
- derivacao repo-local: `nao se aplica`
