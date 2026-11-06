# Solicitacao da Tarefa

## Nome sugerido da tarefa

Preco por hora ou por pessoa, foto e descricao no servico do espaco

## Resumo da solicitacao

O servico do espaco deixa de ter so preco fixo. O cadastro passa a aceitar preco por hora ou por pessoa, uma foto ilustrativa e uma descricao. O orcamento e a pagina publica usam o valor calculado da linha.

## Context Pack

- frente principal: produto (backend e frontend)
- superficie sensivel: sim — valor do orcamento, upload de imagem e pagina publica do orcamento
- risco principal: somar o preco unitario cru no total, ou alterar o valor de um orcamento ja enviado ao editar o cadastro
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: novo tipo de preco da locacao do espaco; preco por diaria do servico; mudar a regra de obrigatoriedade a partir de N pessoas; galeria, contrato, e-mail ou site
- prova minima desta execucao: no painel, criar um servico fixo, um por hora e um por pessoa, com descricao e foto; marcar os tres num orcamento e ver a linha fixa, a linha vezes as horas do evento e a linha vezes os convidados; na pagina publica, ver foto, nome e descricao na experiencia e o valor calculado no investimento; editar o preco no cadastro e o orcamento ja salvo permanecer igual ate recalcular; servico sem foto e sem descricao continua valendo; usuario sem permissao de edicao nao grava
- criterio de escalada: a spec e o caminho; voltar para `normal` somente se o pedido for reduzido a descricao e foto no cadastro, sem mudar o calculo do orcamento
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `database`, `node`, `patterns`, `react`, `design`, `aws`, `security`, `architecture`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_core/project/project-decisions.md#D-06` e `#D-07`
  - `.cursor/framework_global/framework-libs/security/index.md`
  - `.cursor/framework_global/framework-libs/aws/index.md`
- caminhos candidatos: cadastro de servico do venue; soma do servico na criacao, edicao e recalculo do orcamento; bloco "Sua experiencia inclui" e o investimento na pagina publica
- palavras-chave ou simbolos de busca: `Service`, `ProposalService`, `getByProposalServiceListTotalAmount`, `calcEventDuration`, `rpaRequired`, `EDIT_VENUE_SERVICES`
- testes provaveis: `npx prisma validate` e `npm test -- --run` no backend; criar os tres tipos no painel e conferir a linha no orcamento e na pagina publica
- nao ler por padrao: `topics/`, `specs/` de outras frentes, locacao do espaco, contrato e e-mail

## Contexto informado na entrada

Pedido em chat: o servico do espaco so tem preco fixo. Deve passar a ter preco por hora ou por pessoa, uma foto ilustrativa e uma descricao.

## Problema atual

O cadastro do servico guarda um unico preco. Criar, editar e recalcular o orcamento somam esse preco inteiro. A pagina publica e o resumo do painel mostram o mesmo numero, sem quantidade, sem texto e sem imagem.

## Objetivo da mudanca

Um usuario autorizado cadastra servico com preco fixo, por hora ou por pessoa, mais descricao e foto opcionais, e o orcamento mostra o valor da linha calculado sem alterar orcamentos ja salvos.

## Escopo inicial percebido

Mudanca do cadastro de servico e do jeito como o valor entra no orcamento e na pagina publica. Toca `backend` e `frontend`, pede migration aditiva e mexe em upload e em rota publica.

## Itens incluidos neste request

- tipo de preco no cadastro: fixo, por hora ou por pessoa
- descricao opcional e uma foto ilustrativa opcional
- valor da linha no orcamento: o preco, o preco vezes as horas do evento, ou o preco vezes os convidados
- exibicao na pagina publica e no resumo do painel
- servicos ja cadastrados continuam como preco fixo, sem descricao e sem foto

## Requisitos implicitos ja visiveis

- a gravacao passa pelo backend autenticado; a permissao da tela nao substitui a autorizacao da API
- a migration de producao e aditiva
- dinheiro continua no tipo ja usado no legado; trocar Float nao faz parte deste pedido
- horario do evento permanece wall-clock
- a foto nao entra na galeria da casa
- a pagina publica nao recebe tabela de preco alem da linha deste orcamento
- o frontend nao cria uma terceira forma de estado alem das que o projeto ja usa

## Casos de erro e borda ja percebidos

- servico sem foto ou sem descricao: o cadastro e a proposta seguem, so sem esse complemento
- inicio e fim na mesma hora: a linha por hora fica zerada e isso aparece para quem monta o orcamento
- locacao de varios dias ou com pernoite: a hora do servico usa o intervalo entre inicio e fim, nao o numero de diarias
- preco minimo da casa: continua valendo so para a locacao; o servico entra por cima
- editar o cadastro depois: o orcamento ja salvo mantem a linha ate o proximo save ou o recalculo publico
- usuario sem permissao de edicao: nao grava servico nem foto
- arquivo que nao e imagem: a foto nao e salva

## Dependencias

- cadastro de servico, orcamento e pagina publica ja existem
- upload de imagem do produto ja existe e deve ser reaproveitado
- mudanca multi-repo: o request pode ser derivado depois com `tasking/task-request-repo-split-prompt.md`, de preferencia depois da spec

## Restricoes e cuidados

- nao criar preco por diaria do servico
- nao alterar o modelo de preco da locacao do espaco
- nao mudar a obrigatoriedade do servico a partir de um numero de pessoas
- nao ler nem versionar valores de `.env`
- upload e rota publica sao intencionais; autorizacao no backend para gravar; a pagina publica so expoe o que o orcamento ja mostra

## Perguntas em aberto

- Quais tipos de preco entram? Premissa: fixo, por hora e por pessoa. Por diaria fica de fora.
- A hora conta o que? Premissa: as horas inteiras entre o inicio e o fim do evento, inclusive pernoite e estadia de varios dias.
- Quantas fotos? Premissa: uma, opcional, so deste servico.
- A descricao e obrigatoria? Premissa: nao.
- Onde a pessoa ve isso na proposta? Premissa: foto, nome e descricao no bloco da experiencia; no investimento, o nome e o valor calculado, com a conta (unitario vezes horas ou pessoas).
- Um orcamento ja enviado muda se o cadastro mudar? Premissa: nao. So muda ao salvar de novo ou ao recalcular.

## Prioridade sugerida

Media. E evolucao do cadastro comercial, sem correcao de um fluxo que ja esteja quebrado.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: o pedido muda o cadastro, o calculo de todo orcamento, o upload e a pagina publica. Toca `backend` e `frontend`, pede schema e se quebra em varias tasks. Nao e seguro executar como uma task isolada.

## Sugestao de slug da spec

- `framework_core/specs/preco-foto-descricao-servico/`

## Sugestao de nome do arquivo

- `preco-foto-descricao-servico-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `revisar entrega (fw:review)`
- promovida para: `specs/2026-11-04-preco-foto-descricao-servico/`
- entrada publica recomendada: `fw:spec`
- derivacao repo-local: `necessaria`
