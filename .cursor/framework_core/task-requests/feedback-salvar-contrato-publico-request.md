# Solicitacao da Tarefa

## Nome sugerido da tarefa

Mostrar um obrigado ao salvar os dados do contrato publico

## Resumo da solicitacao

Depois de salvar em `/proposal/:id/person-contract` e `/proposal/:id/b2b-contract`, o cartao confirma no proprio lugar que deu certo, com um obrigado que a pessoa entende. A falha tambem aparece no cartao.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao. As rotas ja sao publicas e ja gravam dados pessoais; este request nao muda campos, mascaras, gravacao nem o que a API devolve
- risco principal: o aviso continuar so no toast do painel, ou a confirmacao substituir o formulario e impedir uma correcao
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: formularios de parceiro, equipe e painel; o toast das outras telas; campos, mascaras e gravacao; schema e API
- prova minima desta execucao: em `/proposal/:id/person-contract` e `/proposal/:id/b2b-contract`, alterar um campo, salvar e ver no cartao o titulo Obrigado e uma frase de que os dados foram recebidos, sem depender do aviso do canto; o formulario continua na pagina; sair e voltar nao deixa o obrigado preso; se a gravacao falhar, o cartao mostra o erro
- criterio de escalada: promover para `normal` se a confirmacao exigir mudar o que a API devolve; `spec` nao se aplica
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/components/proposal/forms/PublicContractFormCard.tsx` e o envio em `eventhub-vista-dashboard/src/components/proposal/forms/PFContractPersonalInfoForm.tsx`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/task-requests/marca-diagramacao-contrato-publico-request.md#Objetivo da mudanca`
- caminhos candidatos: formularios publicos de pessoa fisica e de pessoa juridica; cartao do contrato publico
- palavras-chave ou simbolos de busca: `showSuccessToast`, `Salvar Alterações`, `PublicContractFormCard`, `updateProposalPersonalInfo`, `PFContractPersonalInfoForm`, `PJContractPersonalInfoForm`
- testes provaveis: salvar com sucesso nas duas rotas; ver o obrigado no cartao; editar de novo e salvar outra vez; sair e voltar; provocar uma falha e ler o erro no cartao
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, depois da marca e da diagramacao das duas paginas publicas de contrato. Ao clicar em Salvar Alteracoes, a pessoa nao ve nada acontecer. O usuario quer um obrigado, um retorno que deixe claro que deu certo.

## Problema atual

As duas paginas gravam e disparam o toast do painel, com o titulo Sucesso e o texto de dados atualizados. Esse aviso fica no canto, some em poucos segundos e usa a voz do painel. O cartao nao muda. O botao apenas volta a ficar desabilitado. Quem esta no fim do formulario, sobretudo no celular, olha para o botao e nao entende que a gravacao deu certo. Se falhar, o erro usa o mesmo toast e tambem passa despercebido.

## Objetivo da mudanca

Nas duas paginas publicas de contrato, um salvamento bem-sucedido mostra no cartao um obrigado que a pessoa entende, e uma falha mostra o erro no mesmo cartao.

## Escopo inicial percebido

Ajuste de retorno visual nos dois formularios publicos que ja existem. Sem campo novo, sem gravacao nova e sem tela nova. A diagramacao do cartao ja existe.

## Itens incluidos neste request

- depois de gravar com sucesso, o cartao mostra o titulo Obrigado e uma frase curta de que os dados foram recebidos
- a confirmacao fica no cartao, na mesma hierarquia visual da pagina
- o formulario continua visivel para uma correcao
- a confirmacao nao depende do toast do canto
- se a gravacao falhar, o cartao mostra o erro no mesmo lugar, em linguagem que a pessoa entende
- pessoa fisica e pessoa juridica usam o mesmo retorno
- sair da pagina e voltar nao deixa a confirmacao da visita anterior presa

## Requisitos implicitos ja visiveis

- vale para qualquer proposta aberta nessas duas rotas
- o obrigado so aparece depois que a gravacao de fato deu certo
- enquanto salva, o botao nao aceita um segundo clique
- a frase cabe numa linha e nao cria campanha comercial nova
- os rotulos, as mascaras e o que e gravado permanecem
- o toast do painel das outras telas continua como esta

## Casos de erro e borda ja percebidos

- e-mail invalido: o campo continua mostrando o erro e o obrigado nao aparece
- formulario sem alteracao: o botao continua desabilitado e nao ha obrigado
- gravacao recusada pelo servidor: o cartao mostra o erro e o obrigado nao aparece
- segundo salvamento, depois de corrigir: o obrigado aparece de novo
- sair e entrar de novo: a pagina abre no formulario, sem o obrigado da visita anterior
- pessoa juridica tem mais campos: o retorno e o mesmo

## Dependencias

- as duas paginas ja usam o cartao publico e ja gravam os dados pessoais
- `showSuccessToast` ja existe, mas nao e o retorno que a pessoa ve nesta pagina

## Restricoes e cuidados

- nao alterar o que os formularios gravam nem os rotulos e as mascaras
- nao alterar o toast compartilhado das outras telas
- nao esconder o formulario depois do sucesso
- nao incluir parceiro, equipe nem o painel
- nao criar endpoint nem mudar schema

## Perguntas em aberto

- O formulario some e fica so o obrigado? Premissa: nao; o obrigado entra no cartao e os campos continuam para correcao.
- O obrigado some sozinho? Premissa: nao; fica no cartao ate a pessoa alterar um campo ou sair da pagina.
- A falha tambem sai do toast do canto? Premissa: sim; o erro da gravacao aparece no cartao, porque o toast do canto e o que hoje passa despercebido.

## Prioridade sugerida

Alta. A pessoa preenche dados de contrato e hoje nao tem como saber se o clique gravou.

## Faixa sugerida para task workflow

- `A` — duas telas do mesmo tipo, um repo, sem schema; o cartao ja existe
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: acrescenta o retorno de sucesso e de falha em dois formularios que ja gravam; nao abre jornada, contrato nem migration

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `feedback-salvar-contrato-publico-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar` a entrega (`fw:review`)
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- status: executado em 2026-11-05; o cartao mostra Obrigado depois de gravar e o erro quando a gravacao falha; review de entrega ainda nao rodou
- derivacao repo-local: `nao se aplica`
