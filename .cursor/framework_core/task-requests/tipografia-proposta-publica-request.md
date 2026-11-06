# Solicitacao da Tarefa

## Nome sugerido da tarefa

Dar cara de proposta comercial a pagina publica do orcamento

## Resumo da solicitacao

A pagina publica do orcamento troca a tipografia generica do painel por Manrope, na escala pedida, e o valor final, o espacamento e o WhatsApp passam a parecer uma proposta comercial.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: a fonte nova pintar o painel inteiro, ou o grafite e o texto fixos apagarem a cor primaria, a secundaria e a cor do texto ja escolhidas pelo espaco
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: painel administrativo, site da organizacao, calculo do total, gravacao de cores, schema, API e o conteudo das secoes (fotos, caracteristicas, servicos, mapa, rodape)
- prova minima desta execucao: abrir `/proposal/:id/view` e ver Manrope nos titulos, itens, total e botao; o total maior e separado dos valores por pessoa e da hora extra; o WhatsApp como botao visivel; com as tres cores do espaco preenchidas, fundo, cards e fonte continuam nos papeis ja gravados; sem cor escolhida, o fundo padrao deixa o preto absoluto
- criterio de escalada: promover para `normal` se a fonte precisar virar token do painel inteiro ou se o ajuste exigir coluna ou contrato novo; `spec` nao se aplica
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/ProposalView.tsx` no card de valor e no link de WhatsApp
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_core/task-requests/papeis-cores-proposta-request.md#Objetivo da mudanca`
- caminhos candidatos: pagina publica da proposta; carregamento da fonte Inter no HTML do dashboard
- palavras-chave ou simbolos de busca: `ProposalView`, `Falar no WhatsApp`, `totalAmount`, `proposalPrimaryColor`, `proposalTextColor`, `font-['Inter'`
- testes provaveis: abrir a pagina publica com as tres cores preenchidas e com as tres vazias; conferir titulo, item, total, observacao e botao no celular
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, com a proposta AR756 como exemplo do link que o cliente recebe. A fonte atual parece formulario administrativo. A escolha fechada na conversa e Manrope sozinha, moderna e legivel em titulo, texto e preco. A combinacao Plus Jakarta Sans nos titulos e DM Sans nos textos ficou como alternativa mais sofisticada, nao como a escolha. Alem da fonte, o pedido pede mais destaque ao valor final, menos destaque aos valores secundarios, menos area vazia, fundo grafite no lugar do preto absoluto, WhatsApp como botao visivel e o total separado do resto.

Escala pedida, toda em Manrope:

- titulo das secoes: peso 700, 20px
- descricao dos itens: peso 400, 15px
- valores individuais: peso 500, 16px
- valor total: peso 800, 30px
- observacoes: peso 400, 12px
- botao WhatsApp: peso 700, 15px

O texto corrido pedido usa 15px, entrelinha 1.6 e cor `#181818`. Titulos com tracking negativo. O total usa tracking mais fechado e numeros tabulares. O grafite pedido para o fundo e `#111315`.

## Problema atual

Quem abre o link publico ve a mesma familia tipografica do painel. Titulo da secao de valor e o numero do total competem no mesmo tamanho. Valores por pessoa e da hora extra aparecem com o mesmo peso do total. O contato de WhatsApp e um link de texto. O fundo, quando cai no preto absoluto, nao parece a peca comercial de um espaco de eventos.

## Objetivo da mudanca

Na pagina publica de qualquer orcamento, a tipografia e Manrope na escala pedida, o total se destaca dos demais valores e o WhatsApp e um botao visivel.

## Escopo inicial percebido

Ajuste visual de uma pagina que ja existe. A fonte nova vale para essa pagina. As cores ja gravadas do espaco continuam com o papel atual: primaria no fundo, secundaria nos cards, cor do texto na fonte.

## Itens incluidos neste request

- Manrope so na pagina publica, com os pesos 400, 500, 700 e 800
- titulos de secao em 20px e peso 700, com tracking negativo
- descricoes em 15px e peso 400, com entrelinha 1.6
- valores individuais em 16px e peso 500
- valor total em 30px e peso 800, com tracking mais fechado e numeros tabulares
- observacoes em 12px e peso 400
- total separado visualmente da lista e dos valores secundarios
- valores por pessoa e da hora extra com menos destaque que o total
- espacamento dos itens mais justo, com menos area vazia
- WhatsApp como botao de contato visivel, em 15px e peso 700
- fundo padrao em grafite `#111315` quando o espaco nao escolheu cor primaria
- texto padrao em `#181818` quando o espaco nao escolheu cor de texto

## Requisitos implicitos ja visiveis

- a mudanca vale para toda pagina publica de orcamento; AR756 e o exemplo, nao um estilo so daquele registro
- o painel continua na fonte que ja usa
- primaria, secundaria e cor do texto ja gravadas nao mudam de papel
- o calculo do total nao muda
- a pagina continua publica, no mesmo link
- o botao so aparece quando o espaco tem WhatsApp, como o link aparece hoje
- "AR756 • PROPOSTA" e as frases de exemplo eram amostra de fonte, nao um rotulo novo na pagina

## Casos de erro e borda ja percebidos

- espaco com as tres cores preenchidas: fundo, cards e fonte continuam nessas cores; o grafite e o `#181818` nao substituem a escolha
- espaco sem cor primaria: o fundo padrao e o grafite, nao o preto absoluto nem o lilas claro atual
- espaco sem cor de texto: a fonte padrao e `#181818` onde o card e claro; texto sobre o grafite precisa continuar legivel
- orcamento sem WhatsApp: o botao nao aparece e o card de valor continua
- cor do texto clara sobre card escuro: o rotulo do botao nao herda essa cor se o botao tiver fundo proprio
- tela do painel aberta depois da troca: continua na fonte atual do dashboard

## Dependencias

- a pagina publica da apresentacao ja existe
- o papel das cores (primaria no fundo, secundaria nos cards, texto na fonte) ja esta corrigido nessa pagina
- Manrope vem do Google Fonts; nao ha familia nova no repositorio hoje

## Restricoes e cuidados

- nao aplicar Manrope no `body` do HTML do dashboard
- nao criar coluna, endpoint nem permissao
- nao alterar o calculo do total
- nao repintar o painel nem o site da organizacao
- nao trocar o conteudo das secoes nem o rodape alem do que a fonte da pagina atingir
- nao gravar `#111315` nem `#181818` por cima de uma cor que o espaco ja escolheu

## Perguntas em aberto

- Manrope sozinha ou Plus Jakarta Sans nos titulos e DM Sans no texto? Premissa: Manrope sozinha, como na escolha fechada do pedido.
- O grafite substitui a cor primaria ja escolhida? Premissa: nao; `#111315` so entra quando a primaria esta vazia.
- `#181818` substitui a cor do texto ja escolhida? Premissa: nao; so entra quando a cor do texto esta vazia.
- Qual o preenchimento do botao de WhatsApp? Premissa: botao preenchido, visivel, com rotulo claro; nao e um link sublinhado.
- A amostra "AR756 • PROPOSTA" entra na pagina? Premissa: nao.

## Prioridade sugerida

Media. Melhora a peca que o cliente recebe, sem corrigir um calculo quebrado.

## Faixa sugerida para task workflow

- `A` — uma pagina, um repo, sem contrato nem schema
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: polimento visual da pagina publica que ja existe na spec `apresentacao-publica-orcamento`; nao abre jornada, contrato nem migration

## Sugestao de slug da spec

- nao se aplica; permanece em `framework_core/specs/2026-11-04-apresentacao-publica-orcamento/`

## Sugestao de nome do arquivo

- `tipografia-proposta-publica-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar entrega`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- status: executado em 2026-11-04; review de entrega ainda nao rodou
- derivacao repo-local: `nao se aplica`
