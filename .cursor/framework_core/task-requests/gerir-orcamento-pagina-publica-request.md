# Solicitacao da Tarefa

## Nome sugerido da tarefa

Botao Gerir orcamento no canto das paginas publicas do orcamento

## Resumo da solicitacao

Quem esta logado com acesso ao espaco ve, no canto superior direito das paginas publicas daquele orcamento, um botao Gerir orcamento. O clique abre o painel nesse orcamento. Quem nao esta logado nesse espaco nao ve o botao.

## Context Pack

- frente principal: frontend
- superficie sensivel: sim — o botao fica em pagina publica e so pode aparecer para quem ja entra no painel daquele espaco
- risco principal: o cliente, ou um usuario de outro espaco, ver o atalho e o id do painel
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: paginas publicas da casa (apresentacao, formulario, regras, parceiro, colaborador); mudar a URL publica; gravar codigo nos orcamentos antigos; novo endpoint
- prova minima desta execucao: logado no espaco da AR756, o botao aparece no canto superior direito do orcamento, do evento, dos convidados, dos colaboradores, da programacao, das indicacoes e do contrato, no endereco novo e no antigo, e o clique abre `/proposal/{id}` daquele orcamento; sem sessao, o mesmo endereco nao mostra o botao
- criterio de escalada: promover para `spec` se a visibilidade exigir permissao ou dado que a pagina publica ainda nao tem
- nivel de autonomia: `L2`
- camadas transversais: `design`, `security`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `design`, `security`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Regras de ouro`
  - `.cursor/framework_core/project/agent-entrypoint.md#Provas`
  - `.cursor/framework_global/framework-libs/security/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/topics/public-pages-and-branding.md`
- caminhos candidatos: paginas publicas do orcamento (capa e listas); rota do painel `/proposal/:id`
- palavras-chave ou simbolos de busca: `PUBLIC_ROUTES`, `proposalPrimaryColor`, `proposalSecondaryColor`, `proposalTextColor`, `/proposal/:id/view`
- testes provaveis: sessao do espaco ve o botao; sem sessao nao ve; clique cai no painel do mesmo orcamento
- nao ler por padrao: spec da URL publica inteira; schema e migration de `publicCode`

## Contexto informado na entrada

Pedido em chat. No link antigo, apagar `view` de `/proposal/{id}/view` abria o painel daquele orcamento quando a pessoa estava logada. O endereco novo nao tem esse pedaco. O atalho pedido e um botao.

## Problema atual

Nas paginas publicas do orcamento novo nao da para ir ao painel editando a URL. O caminho do painel continua `/proposal/{id}`, e o trecho publico e o nome com o codigo.

## Objetivo da mudanca

Em toda pagina publica de um orcamento, quem esta logado com acesso aquele espaco ve Gerir orcamento no canto superior direito e, ao clicar, abre o painel desse orcamento.

## Escopo inicial percebido

Um botao nas paginas publicas do orcamento, no frontend. A capa e as listas. Os dois formatos de URL, porque sao as mesmas paginas.

## Itens incluidos neste request

- botao com o texto Gerir orcamento
- canto superior direito, sem deslocar a logo nem o slogan do centro
- paginas: orcamento, evento, convidados, colaboradores, programacao, indicacoes e contrato
- endereco novo `/espaco/{casa}/orcamento/...` e endereco antigo `/proposal/{id}/...`
- clique abre `/proposal/{id}` daquele orcamento
- so aparece para quem esta logado com acesso ao espaco daquele orcamento

## Requisitos implicitos ja visiveis

- cores da pagina publica: fundo do botao na cor secundaria, texto na cor de texto da proposta, canto `rounded-xl`, fonte Manrope, no mesmo padrao dos cartoes
- a logo e o slogan continuam centralizados
- sem sessao, a pagina publica permanece como o cliente ve
- usuario logado em outro espaco nao ve o botao neste orcamento

## Casos de erro e borda ja percebidos

- cliente abre o link sem estar logado
- usuario logado num espaco diferente do orcamento
- orcamento antigo, sem codigo, aberto pelo id
- orcamento novo, aberto pelo codigo, cujo painel ainda usa o id
- a mesma pagina servida pelos dois formatos de URL

## Dependencias

- as paginas publicas do orcamento ja existem nos dois formatos
- o painel do orcamento continua em `/proposal/{id}`
- a sessao do painel ja e reconhecida nas rotas publicas quando ha token

## Restricoes e cuidados

- nao mostrar o botao a quem nao entra no painel desse espaco
- nao colocar o botao nas paginas da casa
- nao mudar o endereco publico nem o do painel
- nao alargar o que a pagina publica devolve ao cliente
- nao ler nem versionar valores de `.env`

## Perguntas em aberto

- Quem conta como dono do espaco? Premissa: quem ja pode abrir o painel desse orcamento. Nao e qualquer login do EventHub, nem o cadastro juridico de proprietario.

## Prioridade sugerida

Media. O atalho de apagar `view` deixa de existir no link novo.

## Faixa sugerida para task workflow

- `B` = executar com `tasking/task-workflow-prompt-normal.md`

## Candidato a spec

- `nao`
- motivo: um botao, um destino e uma regra de visibilidade. So frontend, sem contrato novo nem schema.

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `gerir-orcamento-pagina-publica-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- proximo passo: `executar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `nao se aplica`
