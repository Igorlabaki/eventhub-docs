# Solicitacao da Tarefa

## Nome sugerido da tarefa

Categorizar o parceiro no cadastro e agrupar os indicados na pagina publica

## Resumo da solicitacao

O parceiro passa a ter uma categoria fixa, escolhida no cadastro. Quem ja existe fica em Outros. A pagina publica das indicacoes separa os parceiros por essa categoria.

## Context Pack

- frente principal: produto (frontend e backend)
- superficie sensivel: nao — a categoria nao e pagamento, segredo nem documento; o cadastro publico de parceiro ja existe e so ganha o campo
- risco principal: a migration marcar membro de equipe como Outros, ou a pagina publica misturar indicado de outra categoria ou de outro orcamento
- repos tocados: `frontend` (`eventhub-vista-dashboard/`), `backend` (`art56_server_v3/`)
- fora de escopo operacional: filtro ou busca por categoria; trocar a funcao livre do contato; foto, descricao ou preco do parceiro; redesenhar a casca da pagina publica; colaborador; mudar a rota do link
- prova minima desta execucao: cadastro de parceiro no painel e no formulario publico so grava com uma categoria da lista; parceiro que ja existia abre como Outros; colaborador continua sem categoria; em `/proposal/:id/indications`, os indicados aparecem separados pela categoria, e categoria sem ninguem nao aparece
- criterio de escalada: a spec e o caminho; voltar para `normal` somente se a coluna e o fallback ja existirem e a mudanca ficar so no rotulo de uma tela
- nivel de autonomia: `L2`
- camadas transversais: `database`, `design`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `node`, `database`, `patterns`, `react`, `design`, `architecture`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Regras de ouro`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_core/project/project-decisions.md#D-01`
  - `.cursor/framework_core/project/project-decisions.md#D-03`
  - `.cursor/framework_core/topics/data-and-migrations.md#Regras`
- caminhos candidatos: cadastro de contato do tipo fornecedor; formulario publico de parceiro; pagina publica `/proposal/:id/indications`
- palavras-chave ou simbolos de busca: `SUPPLIER`, `ContactType`, `PartnerForm`, `ProposalIndications`, `indications`
- testes provaveis: criar parceiro com categoria valida no painel e no formulario publico; recusar categoria fora da lista; reler parceiro antigo e ver Outros; abrir a pagina publica e ver os indicados separados por categoria
- nao ler por padrao: `security`, `topics/` alem de dados e migracoes, specs de outras frentes, pagamento e listas de convidados

## Contexto informado na entrada

Pedido em chat, em dois momentos. A categoria do parceiro deve ser um enum com estes valores: `BUFFET`, `CHURRASCO`, `BAR`, `DJ`, `MUSICA_AO_VIVO`, `FOTOGRAFIA`, `FILMAGEM`, `DECORACAO`, `CENOGRAFIA`, `BOLOS_DOCES`, `RECREACAO`, `ENTRETENIMENTO`, `CERIMONIAL`, `AUDIOVISUAL`, `MOBILIARIO`, `BRINDES` e `OUTROS`. Os parceiros que ja existem recebem `OUTROS`. No mesmo pedido, o cadastro do parceiro passa a pedir essa categoria, e o link publico dos parceiros indicados os separa por categoria.

## Problema atual

O parceiro e um contato do tipo fornecedor. O cadastro, no painel e no formulario publico, guarda uma funcao em texto livre e nao pede categoria. A pagina publica `/proposal/:id/indications` lista os indicados numa fila so, sem grupo. Nao da para classificar buffet, DJ, fotografia e os demais, nem para a pessoa ver os indicados separados por tipo de servico.

## Objetivo da mudanca

Todo parceiro tem uma categoria da lista fechada, escolhida no cadastro; quem ja existia fica em Outros; a pagina publica dos indicados mostra cada um dentro da sua categoria.

## Escopo inicial percebido

A categoria entra no cadastro do parceiro, no painel e no formulario publico, e passa a ser gravada e lida junto com o contato. A mudanca de dados coloca Outros nos fornecedores que ja existem. A pagina publica das indicacoes usa essa categoria para separar os parceiros daquele orcamento. Colaborador fica de fora.

## Itens incluidos neste request

- lista fechada com os dezessete valores da entrada, incluindo `OUTROS`
- o cadastro de parceiro no painel pede a categoria e so grava com um valor da lista
- o formulario publico de parceiro pede a mesma categoria e so grava com um valor da lista
- parceiro ja cadastrado fica em `OUTROS`
- a categoria pode ser alterada depois para outro valor da lista
- a pagina publica dos indicados agrupa os parceiros por categoria
- categoria sem indicado naquele orcamento nao aparece
- a funcao livre do contato continua existindo
- colaborador nao recebe categoria

## Requisitos implicitos ja visiveis

- um parceiro tem uma categoria, nao varias
- valor fora da lista nao grava
- a migration de producao e aditiva e o fallback dos existentes acontece nela
- a permissao da tela nao substitui a validacao no backend
- o formulario publico de parceiro continua publico e passa a enviar a categoria
- a pagina publica continua sem login e continua devolvendo so os indicados daquele orcamento
- rotulos em portugues na tela e nos grupos; o valor gravado permanece o da lista

## Casos de erro e borda ja percebidos

- parceiro antigo sem categoria escolhida: abre como Outros
- colaborador antigo ou novo: sem categoria
- categoria ausente ou desconhecida no parceiro novo: a gravacao nao acontece
- trocar um parceiro para colaborador, ou o contrario: a categoria nao vaza para a equipe e nao some do fornecedor sem uma regra explicita na spec
- formulario publico ou do painel enviado sem categoria: nao grava o parceiro incompleto
- orcamento sem indicacao: a pagina publica abre vazia, como hoje
- todos os indicados em Outros: a pagina mostra um unico grupo, Outros
- duas categorias no mesmo orcamento: cada pessoa aparece so no grupo da categoria atual do cadastro
- categoria alterada depois da indicacao: a pagina mostra o grupo novo, porque le o cadastro atual

## Dependencias

- o contato ja separa fornecedor e membro de equipe
- o painel e o formulario publico ja cadastram parceiro
- a pagina publica `/proposal/:id/indications` ja lista os parceiros indicados naquele orcamento
- a funcao livre ja aparece na lista de contatos e no card da pagina publica

## Restricoes e cuidados

- nao classificar membro de equipe como Outros
- nao apagar nem reaproveitar a funcao livre como se fosse a categoria
- nao criar filtro, busca ou outra rota para a pagina publica
- nao incluir na pagina publica um parceiro que nao foi indicado naquele orcamento
- nao ler nem versionar valores de `.env`
- migration de producao e aditiva e usa `prisma migrate deploy`

## Perguntas em aberto

- A categoria substitui a funcao? Premissa: nao; a funcao livre permanece e a categoria e um campo novo.
- Membro de equipe tambem recebe Outros? Premissa: nao; so o fornecedor que ja existe.
- Parceiro novo pode ficar em Outros de proposito? Premissa: sim; Outros e uma categoria valida, nao so o fallback.
- A lista de contatos do painel tambem mostra a categoria? Premissa: sim, junto da funcao.
- Da para ter mais de uma categoria no mesmo parceiro? Premissa: nao.
- A ordem dos grupos segue a lista da entrada? Premissa: sim, de Buffet ate Outros; grupo vazio nao aparece.
- Dentro do grupo, a ordem e a da indicacao? Premissa: sim, a ordem em que foram salvos naquele orcamento.

## Prioridade sugerida

Media. O cadastro ja existe e a pagina publica ja lista os indicados; falta a categoria nos dois.

## Faixa sugerida para task workflow

- `C` — campo novo, fallback dos registros existentes, cadastro e pagina publica nos dois repositorios
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: o pedido cria a categoria no cadastro, exige migration com fallback, altera o formulario publico e reorganiza a pagina publica das indicacoes. Toca `frontend` e `backend`. Nao e seguro executar como uma task isolada.

## Sugestao de slug da spec

- `framework_core/specs/categoria-parceiro/`

## Sugestao de nome do arquivo

- `categoria-parceiro-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-05-categoria-parceiro/`
- entrada publica recomendada: `fw:spec`
- derivacao repo-local: `necessaria` depois da spec, com `tasking/task-request-repo-split-prompt.md` se a promocao nao dividir o trabalho
