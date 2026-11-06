# Solicitacao da Tarefa

## Nome sugerido da tarefa

Esvaziar o formulario ao criar outra regra ou caracteristica

## Resumo da solicitacao

Depois de cadastrar uma regra, abrir Nova regra de novo mostra o que acabou de ser salvo. O mesmo acontece em Nova caracteristica. Os dois formularios de criacao devem abrir vazios. Editar um item que ja existe continua mostrando esse item.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: a correcao limpar tambem a edicao, ou passar a esvaziar outros formularios do painel que a pessoa nao pediu
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: link das regras; Link do evento; campos novos; validacao nova; formularios de servico, contato, orcamento e demais cadastros
- prova minima desta execucao: cadastrar uma regra, abrir Nova regra de novo e ver titulo e texto vazios; repetir em Caracteristicas com o nome vazio; abrir a edicao de um item ja salvo e ver os dados daquele item
- criterio de escalada: `normal` se o mesmo estado preso aparecer em outros cadastros e a correcao precisar ser compartilhada de proposito; `spec` nao se aplica
- nivel de autonomia: `L2`
- camadas transversais: `design`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: formulario e secao de regras do espaco; formulario e secao de caracteristicas do espaco
- palavras-chave ou simbolos de busca: `VenueRuleForm`, `VenueAmenityForm`, `Nova regra`, `Nova caracteristica`
- testes provaveis: abrir o formulario de criacao duas vezes seguidas, com um cadastro no meio, e conferir campos vazios; abrir edicao e conferir o item selecionado
- nao ler por padrao: `security`, `database`, `topics/`, schema e os demais formularios do painel

## Contexto informado na entrada

Pedido em chat. Ao criar uma regra, o formulario nao esvazia: ao entrar nele de novo, esta preenchido com o que acabou de ser feito. O formulario de caracteristica faz o mesmo.

## Problema atual

Nova regra reabre com titulo e texto do cadastro anterior. Nova caracteristica reabre com o nome do cadastro anterior. A pessoa precisa apagar o conteudo antigo para lancar outro item.

## Objetivo da mudanca

Cada abertura de Nova regra ou Nova caracteristica comeca com os campos de criacao vazios, e a edicao de um item existente continua mostrando esse item.

## Escopo inicial percebido

Os dois formularios de criacao, regra e caracteristica, passam a nascer vazios sempre que a pessoa abre um cadastro novo. A edicao segue carregando o registro escolhido.

## Itens incluidos neste request

- Nova regra abre com titulo e texto vazios, inclusive logo depois de um cadastro bem-sucedido
- Nova caracteristica abre com o nome vazio, inclusive logo depois de um cadastro bem-sucedido
- editar uma regra mostra titulo, texto e posicao da regra escolhida
- editar uma caracteristica mostra nome e posicao da caracteristica escolhida
- cancelar e abrir de novo tambem comeca vazio

## Requisitos implicitos ja visiveis

- o defeito foi visto nos dois cadastros; a correcao cobre os dois
- a lista continua na tela depois que o formulario fecha
- nao entra campo novo nem muda o que o cadastro grava

## Casos de erro e borda ja percebidos

- cadastro que falha: o formulario permanece aberto com o que a pessoa digitou, para ela corrigir
- sair de uma edicao e abrir Nova regra: o formulario de criacao nao herda os dados do item editado
- sair de uma criacao e abrir a edicao de outro item: a edicao mostra o item clicado, nao o rascunho anterior
- posicao so aparece na edicao, como hoje

## Dependencias

- as telas Regras e Caracteristicas ja cadastram e editam esses itens

## Restricoes e cuidados

- nao alterar o formulario de servico, contato, orcamento nem os outros cadastros do painel
- nao mudar validacao, permissao nem o texto dos botoes
- nao ler nem versionar valores de `.env`

## Perguntas em aberto

- Cancelar sem salvar tambem deve esvaziar a proxima abertura? Premissa: sim.
- Um erro de gravacao deve limpar o que foi digitado? Premissa: nao; so a abertura seguinte de um cadastro novo comeca vazia.
- Outros formularios do painel com o mesmo sintoma entram agora? Premissa: nao.

## Prioridade sugerida

Alta. O cadastro repetido fica errado ou exige apagar o item anterior na mao.

## Faixa sugerida para task workflow

- `A` — o mesmo defeito em dois formularios irmaos, sem dado novo
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: correcao local de estado de dois formularios que ja existem

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `tr-02-reset-formulario-regra-caracteristica.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-05-links-painel-e-formularios/`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `nao se aplica`
