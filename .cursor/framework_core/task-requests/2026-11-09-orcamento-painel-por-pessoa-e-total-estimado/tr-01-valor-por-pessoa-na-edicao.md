# Solicitacao da Tarefa

## Nome sugerido da tarefa

Valor por pessoa ao lado do Total na edicao do orcamento

## Resumo da solicitacao

Na tela de editar orcamento do painel, o campo Total passa a mostrar ao lado `R$ X / pessoa`, como ja acontece na criacao, recalculado ao mudar Total ou Convidados.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- camadas transversais: `design`
- risco principal: o texto ao lado do input quebrar a ligacao do `FormControl` com o input (label, `aria-*`, mensagem de erro) ou espremer o campo no grid de duas colunas
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: backend e contrato de `updatePerPerson`; total estimado (vai em `tr-02`); edicao por diaria; formularios publicos; mudar `perPersonLabel`
- prova minima desta execucao: em `/proposal/:id/edit` de um orcamento com 100 convidados e total R$ 5.000,00, aparece `R$ 50,00 / pessoa` ao abrir a tela; trocar para 80 convidados mostra `R$ 62,50 / pessoa` sem salvar; apagar o Total mostra `— / pessoa`; o payload do `Atualizar` continua igual
- criterio de escalada: permanece `smart`
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/ProposalEdit.tsx` no `form.watch("data.guestNumber")` e no `FormField` de `data.totalAmountInput`; `eventhub-vista-dashboard/src/components/proposal/forms/PerPersonProposalForm.tsx` no `FormField` de `totalAmountInput` como modelo
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/lib/per-person-amount.ts` (so leitura)
- palavras-chave ou simbolos de busca: `perPersonLabel`, `totalAmountInput`, `guestNumberValue`, `NumericFormat`, `aria-live`
- testes provaveis: nenhum novo de logica (`per-person-amount.test.ts` ja cobre o calculo); conferir no browser a abertura com valor salvo
- nao ler por padrao: `security`, `database`, `topics/`, backend

## Contexto informado na entrada

Pedido em chat: "no editar o orcamento nao tem aquele lance do preco por pessoa aparecendo igual no criar". O request da criacao deixou a edicao fora de escopo de proposito.

## Problema atual

`ProposalEdit.tsx` renderiza o Total so com o `NumericFormat`, sem o texto `/ pessoa`. Quem ajusta convidados ou total na edicao precisa fazer a conta de cabeca.

## Objetivo da mudanca

Na edicao, com Total e Convidados preenchidos, o valor por pessoa aparece ao lado do Total ja na abertura da tela e atualiza a cada mudanca, igual a criacao.

## Escopo inicial percebido

Importar `perPersonLabel`, observar `data.totalAmountInput` e repetir o bloco visual da criacao (`div` flex com o input e o `span` auxiliar). Um arquivo.

## Itens incluidos neste request

- `span` `<valor> / pessoa` ao lado do Total em `ProposalEdit.tsx`, fora do `FormControl`, com `aria-live="polite"`
- mesmo layout e classes da criacao (quebra de linha em largura curta)

## Requisitos implicitos ja visiveis

- o valor vem do `form.reset` com `currentProposal.totalAmount`, entao aparece na abertura sem interacao
- o calculo parte do valor sem mascara entregue pelo `NumericFormat`
- nada muda no payload de `updateProposalPerPerson`

## Casos de erro e borda ja percebidos

- orcamento de permuta com total 0: `— / pessoa`
- Total apagado: `— / pessoa` (o campo continua obrigatorio pela validacao existente)
- convidados vazio ou zero: `— / pessoa`, sem `NaN`/`Infinity`
- skeleton enquanto `currentProposal` carrega: o texto so aparece com o form

## Dependencias

- `perPersonLabel` em `src/lib/per-person-amount.ts`, ja entregue pelo request da criacao

## Restricoes e cuidados

- nao alterar `perPersonLabel` nem o formulario de criacao
- se a duplicacao do bloco incomodar, extrair um componente pequeno so se os dois usos ficarem identicos; caso contrario, repetir

## Perguntas em aberto

- Extrair um componente `TotalWithPerPerson` para criar e editar? Premissa: nao nesta task; repetir o bloco.

## Prioridade sugerida

Media. Paridade entre criar e editar; nada quebra hoje.

## Faixa sugerida para task workflow

- `A` — um valor derivado ja existente aplicado em mais um arquivo
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: um arquivo do frontend, logica ja pronta e testada

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `tr-01-valor-por-pessoa-na-edicao.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `executar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `nao se aplica`
