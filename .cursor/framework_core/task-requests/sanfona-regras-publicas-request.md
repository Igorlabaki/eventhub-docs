# Solicitacao da Tarefa

## Nome sugerido da tarefa

Mostrar as regras publicas em sanfona, sem etiqueta

## Resumo da solicitacao

A pagina publica das regras do espaco passa a abrir cada regra numa sanfona, com titulo, aviso fixo e texto ao expandir. As etiquetas de tipo (Proibido, Orientacao, Permitido) nao entram.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao — a rota publica ja existe; esta mudanca nao altera o que a leitura devolve
- risco principal: a sanfona esconder o texto de uma regra sem titulo, ou a pagina perder a marca do espaco (logo, cores, fonte, rodape)
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: cadastro de tipo ou etiqueta na regra; painel de regras; Link do evento; contrato, schema e API; outras paginas publicas
- prova minima desta execucao: em `/venue/:id/rules/view`, um espaco com regras mostra o titulo, o texto de orientacao, o aviso de a quem se aplica e uma linha por regra, com seta e sem etiqueta; abrir a linha mostra o texto; regra sem titulo ainda mostra o texto; espaco sem regras continua dizendo que ainda nao ha regras; logo, cores, fonte e rodape do espaco permanecem
- criterio de escalada: promover para `normal` se a sanfona precisar virar componente compartilhado por outras paginas publicas; `spec` somente se o aviso ou a etiqueta passarem a ser campo gravado
- nivel de autonomia: `L2`
- camadas transversais: `design`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/PublicVenueRules.tsx`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_core/task-requests/link-publico-regras-do-espaco-request.md#Objetivo da mudanca`
- caminhos candidatos: casca publica das listas; card e tipografia ja usados na pagina de regras
- palavras-chave ou simbolos de busca: `PublicVenueRulesPage`, `PublicVenueListShell`, `publicRuleCards`, `publicCardClass`
- testes provaveis: abrir a pagina com regras, com regra sem titulo e sem regras; conferir que nenhuma linha mostra Proibido, Orientacao ou Permitido
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, com uma referencia visual da pagina publica de regras do AR756. A referencia tem titulo, texto de orientacao, um aviso de a quem as regras se aplicam e cada regra numa sanfona. Ao lado do titulo de cada regra a referencia mostra uma etiqueta (Orientacao, Permitido ou Proibido). O pedido e tirar essas etiquetas e manter o resto parecido com essa pagina.

## Problema atual

A pagina publica lista cada regra num card aberto, so com titulo e texto. Nao ha sanfona, texto de orientacao nem aviso de a quem as regras se aplicam. O cadastro nao tem tipo de regra.

## Objetivo da mudanca

Quem abre o endereco publico das regras ve a lista no formato da referencia, sem etiqueta de tipo, e continua lendo titulo e texto na ordem ja cadastrada.

## Escopo inicial percebido

Ajuste visual da pagina que ja existe. Uma frente, so no frontend. O que a API devolve permanece titulo, texto e ordem.

## Itens incluidos neste request

- titulo "Regras do espaco" com o texto fixo de orientacao
- aviso fixo de que as regras se aplicam a organizadores, convidados e fornecedores
- cada regra como linha que abre e fecha, com o titulo e uma seta, e o texto ao abrir
- nenhuma etiqueta de Proibido, Orientacao ou Permitido

## Requisitos implicitos ja visiveis

- a pagina continua na casca publica do espaco: cor primaria no fundo, secundaria nos cards, cor do texto na fonte, Manrope, logo, descricao, aba e rodape
- a ordem continua a do cadastro
- regra sem titulo nao esconde o texto
- a pagina nao grava nada e nao cria campo novo

## Casos de erro e borda ja percebidos

- espaco sem regras: a pagina abre na marca do espaco e diz que ainda nao ha regras; a sanfona nao aparece vazia no lugar dessa frase
- regra sem titulo: a linha abre e o texto aparece
- falha ao carregar: a mensagem e o tentar de novo continuam, sem lista quebrada
- varias regras: abrir uma nao depende de etiqueta; cada linha abre e fecha por conta propria

## Dependencias

- a pagina publica `/venue/:id/rules/view` ja existe e ja lista titulo, texto e ordem
- a casca publica das listas ja aplica a marca do espaco

## Restricoes e cuidados

- nao criar coluna, tipo ou etiqueta na regra
- nao mudar o cadastro do painel nem o Link do evento
- nao mudar o que a leitura publica devolve
- nao ler nem versionar valores de `.env`

## Perguntas em aberto

- O texto de orientacao e o aviso sao frase fixa da pagina? Premissa: sim, as duas frases da referencia, sem campo novo no espaco.
- Qual regra comeca aberta? Premissa: nenhuma; a pessoa abre a linha que quiser.
- A etiqueta some so da pagina publica? Premissa: sim, e ela tambem nao entra no cadastro.

## Prioridade sugerida

Baixa. A pagina publica ja mostra as regras; o pedido e so a apresentacao.

## Faixa sugerida para task workflow

- `A` = executar com `tasking/task-workflow-prompt-smart.md`

## Candidato a spec

- `nao`
- motivo: e um ajuste de apresentacao numa pagina que ja existe, numa frente so, sem contrato, schema ou campo novo

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `sanfona-regras-publicas-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `nao se aplica`
