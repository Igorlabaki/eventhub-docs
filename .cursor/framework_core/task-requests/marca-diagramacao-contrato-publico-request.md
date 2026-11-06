# Solicitacao da Tarefa

## Nome sugerido da tarefa

Levar a marca e a diagramacao da proposta as paginas publicas de contrato

## Resumo da solicitacao

`/proposal/:id/person-contract` e `/proposal/:id/b2b-contract` passam a usar a marca do espaco e a diagramacao das listas publicas: cores, fonte, logo, descricao, aba, skeleton, rodape, coluna central, cartao, hierarquia do titulo, grade dos campos e botao em pilula.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao. As rotas ja sao publicas e ja gravam dados pessoais; este request nao muda campos, mascaras, gravacao nem o que a API devolve
- risco principal: o contrato continuar com a casca do painel, ou a troca do `FormLayout` alterar formularios internos que ainda devem parecer painel
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: formularios de parceiro e equipe; painel; fotos, mapa e tour de ver o orcamento; campos, mascaras e gravacao do contrato; schema e API
- prova minima desta execucao: abrir `/proposal/:id/person-contract` e `/proposal/:id/b2b-contract` de um espaco com cor primaria, secundaria, cor de texto, logo, nome, descricao e ao menos uma rede e ver, nas duas, fundo na primaria, cartao na secundaria, texto na cor do texto, fonte Manrope, logo e descricao no topo, aba com nome e descricao, coluna central, cartao com rotulo, titulo, frase, divisor, campos em duas colunas a partir de `sm`, campo claro para digitar e botao em pilula a direita; durante o carregamento, a tela usa as cores do espaco e nao mostra a marca EventHub; sair da pagina devolve a aba ao titulo EventHub; salvar continua gravando os mesmos dados
- criterio de escalada: promover para `normal` se o `FormLayout` compartilhado tiver de mudar para o contrato acompanhar e isso atingir o painel; `spec` nao se aplica
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/components/proposal/public-list-pattern.ts` e o uso em `eventhub-vista-dashboard/src/pages/GuestList.tsx`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/task-requests/marca-espaco-listas-publicas-request.md#Objetivo da mudanca`
- caminhos candidatos: paginas publicas de contrato de pessoa fisica e de pessoa juridica; casca das listas publicas; formulario publico de criar orcamento
- palavras-chave ou simbolos de busca: `person-contract`, `b2b-contract`, `ContarctPFForm`, `ContarctPjForm`, `PFContractPersonalInfoForm`, `PJContractPersonalInfoForm`, `FormLayout`, `PublicVenueListShell`, `publicCardClass`, `publicActionClass`
- testes provaveis: abrir as duas rotas com e sem logo, descricao, cores e redes; comparar topo, cartao, campos, botao, fonte, skeleton e rodape com `/proposal/:id/guest-list`; salvar um dado em cada formulario; sair da pagina e conferir a aba
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, depois da marca e da diagramacao das listas publicas. Os links `/proposal/:id/person-contract` e `/proposal/:id/b2b-contract` ainda abrem fora do padrao. O usuario confirmou que a diferenca inclui a diagramacao e o estilo, alem da marca do espaco.

## Problema atual

As duas paginas publicas de contrato usam a casca antiga do EventHub e o `FormLayout` do painel. O topo e o calendario com o texto EventHub, o fundo e a cor do produto, o carregamento e o `AppLoadingScreen` e o rodape e o roxo "Seu hub para gestao de eventos". O cartao e branco, com borda, sombra fraca e largura da pagina. O titulo fica sozinho, sem rotulo, frase nem divisor. Cada campo ocupa a linha inteira. O botao "Salvar Alteracoes" e retangular, no tema do painel. Criar orcamento, ver o orcamento e as listas publicas do mesmo espaco ja usam a marca e a diagramacao da proposta.

## Objetivo da mudanca

Nas duas paginas publicas de contrato, marca, fonte, carregamento, rodape e diagramacao do cartao seguem as listas publicas da proposta.

## Escopo inicial percebido

Ajuste visual de duas paginas publicas que ja existem e ja carregam a proposta e o espaco. Sem campo novo, sem gravacao nova e sem tela nova. A referencia visual ja esta nas listas publicas e em criar orcamento.

## Itens incluidos neste request

- as duas paginas usam as cores do espaco no mesmo papel das listas: primaria no fundo, secundaria no cartao e no rodape, cor do texto na fonte
- o topo mostra o logo do espaco e, abaixo, a descricao
- a fonte e Manrope
- a entrada da pagina usa a animacao discreta ja usada nas listas publicas
- a aba mostra o nome e a descricao do espaco
- o rodape fica igual ao das listas publicas
- o skeleton usa as cores do espaco e espera a marca antes de mostrar a pagina
- o conteudo fica numa coluna central, no mesmo limite das listas
- o cartao segue o cartao das listas: cantos, sombra, rotulo curto, titulo, frase de apoio, divisor e campos em duas colunas a partir de `sm`
- os campos continuam claros para digitar dentro do cartao
- a acao fica a direita, separada por uma linha, no botao em pilula das listas
- ao sair da pagina, a aba volta ao titulo generico do EventHub
- salvar continua gravando os mesmos dados, com as mesmas mascaras

## Requisitos implicitos ja visiveis

- vale para qualquer proposta aberta nessas duas rotas, nao para um registro so
- a referencia de casca e de cartao e a lista publica; criar orcamento confirma o mesmo papel de cores, fonte, logo e rodape
- o titulo de cada formulario permanece o que a pagina ja mostra
- sem descricao, a aba mostra so o nome e o topo nao reserva bloco de descricao
- sem logo, o topo usa o mesmo fallback das listas publicas
- o rodape so aparece quando a lista publica tambem mostraria rodape
- os rotulos dos campos permanecem os atuais
- a frase de apoio cabe numa linha e nao cria campanha comercial nova
- no celular os campos descem um embaixo do outro
- o `FormLayout` do painel continua como esta para as telas internas
- parceiro e equipe continuam na casca antiga

## Casos de erro e borda ja percebidos

- espaco sem alguma cor: a tela usa o mesmo fallback das listas publicas para aquele papel
- espaco sem logo, sem descricao ou sem redes: topo, aba e rodape degradam como nas listas
- descricao longa: entra no titulo; o navegador corta a exibicao
- espaco ou formulario ainda carregando: a tela nao mostra a marca EventHub nem cores de outro espaco
- logo que falha ao baixar: a espera do skeleton nao prende a pagina para sempre
- navegacao para fora do contrato: a aba volta ao titulo EventHub
- formulario sem alteracao: o botao de salvar continua desabilitado, dentro da marca do espaco
- pessoa juridica tem mais campos que pessoa fisica: os dois usam a mesma diagramacao, cada um com os campos que ja tem

## Dependencias

- `/proposal/:id/guest-list` ja aplica cores, Manrope, logo, descricao, aba, skeleton, animacao, rodape e a diagramacao do cartao
- `/venue/:id/form` e `/proposal/:id/view` ja aplicam a mesma marca
- `venueTabTitle` ja monta o texto da aba
- as duas paginas de contrato ja carregam a proposta e o espaco

## Restricoes e cuidados

- nao alterar o que os formularios gravam nem os rotulos e as mascaras dos campos
- nao alterar o `FormLayout` compartilhado nem o carregamento das outras telas
- nao trazer fotos, mapa ou tour da pagina de ver o orcamento
- nao incluir formularios de parceiro e equipe
- nao criar endpoint nem mudar schema
- nao recolocar a primaria no cartao

## Perguntas em aberto

- Parceiro e equipe entram junto? Premissa: nao; neste request so os dois links de contrato.
- A frase de apoio muda o titulo atual? Premissa: nao; o titulo permanece e a frase so completa a hierarquia do cartao.
- O rodape compartilhado do EventHub muda para todo mundo? Premissa: nao; estas duas paginas deixam de usa-lo e as demais telas continuam com a marca do produto.
- Os campos ficam brancos dentro do cartao? Premissa: sim; o cartao usa a secundaria e os campos continuam claros para digitar.

## Prioridade sugerida

Alta. Ver o orcamento e as listas publicas ja apresentam o espaco, e os dois links de contrato da mesma proposta ainda abrem na casca do painel.

## Faixa sugerida para task workflow

- `A` — duas telas do mesmo tipo, um repo, sem schema; a referencia visual ja existe
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: aplica em duas paginas publicas que ja existem a marca e a diagramacao que as listas publicas ja implementam; nao abre jornada, contrato nem migration

## Sugestao de slug da spec

- nao se aplica; a referencia visual continua em `framework_core/task-requests/marca-espaco-listas-publicas-request.md`

## Sugestao de nome do arquivo

- `marca-diagramacao-contrato-publico-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar` a entrega (`fw:review`)
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- status: executado em 2026-11-04; as duas paginas usam a casca e o cartao das listas publicas; review de entrega ainda nao rodou
- derivacao repo-local: `nao se aplica`
