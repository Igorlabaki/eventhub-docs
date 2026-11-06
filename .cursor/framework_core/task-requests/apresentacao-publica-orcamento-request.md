# Solicitacao da Tarefa

## Nome sugerido da tarefa

Apresentar a casa na proposta publica e deixar o valor no fim

## Resumo da solicitacao

A pagina publica do orcamento deixa de ser so a lista de valores. Ela apresenta a casa com o logo do espaco, as fotos marcadas para o site, as caracteristicas, os dados gerais que vendem o espaco e os servicos deste orcamento, nas cores escolhidas para aquele espaco, e so depois mostra o valor.

## Context Pack

- frente principal: produto (frontend e backend)
- superficie sensivel: sim — a pagina `/proposal/:id/view` e publica; o pacote da casa nao pode levar dono, contrato, pagamento ou preco de tabela
- risco principal: a apresentacao publicar dado interno do venue, ou mostrar o catalogo de precos em vez do valor fechado deste orcamento
- repos tocados: `frontend` (`eventhub-vista-dashboard/`), `backend` (`art56_server_v3/`)
- fora de escopo operacional: regras do espaco; textos antigos com `area: "amenities"`; endereco completo, CEP e proprietarios; modelo de preco, preco por pessoa/dia e preco minimo do cadastro; e-mail e mensagem interna da proposta; mudar o calculo do total; repintar o painel inteiro ou o site da organizacao
- prova minima desta execucao: abrir `/proposal/:id/view` de um orcamento com logo, fotos marcadas, caracteristicas e servicos e ver a casa, com o logo do espaco, antes do total; em Configurações do espaço trocar cor primaria, secundaria e de texto, reabrir essa tela e ver as cores gravadas, e ver as mesmas cores na pagina publica; orcamento sem foto, sem caracteristica ou sem servico omite essa secao e ainda mostra o valor; casa sem logo nao inventa uma marca; casa sem cor usa as cores atuais da pagina; a resposta publica nao inclui dono, contrato nem pagamento
- criterio de escalada: a spec e o caminho; voltar para `normal` somente se o pedido for reduzido a reordenar blocos que a pagina publica ja recebe, sem pacote novo da casa
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `design`, `node`, `patterns`, `security`, `database`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_global/framework-libs/security/index.md`
  - `.cursor/framework_global/framework-libs/database/index.md`
- caminhos candidatos: pagina publica da proposta; Configurações do espaço em `/venue/:id/settings`; fotos com exibicao no site da organizacao; cadastro de caracteristicas do venue; servicos ligados a proposta
- palavras-chave ou simbolos de busca: `ProposalView`, `VenueSettings`, `logoUrl`, `isShowOnOrganization`, `VenueAmenity`, `proposalServices`, `instagramUrl`, `facebookUrl`, `tiktokUrl`
- testes provaveis: `npm run build` e `npm run lint` no frontend; a pagina publica no browser, com e sem foto, caracteristica e servico; a resposta da casa nao devolve dono, contrato nem pagamento
- nao ler por padrao: `topics/`; specs de caracteristicas e regras alem do que precisar para saber que esses cadastros ja existem e hoje nao entram na proposta

## Contexto informado na entrada

Pedido em chat: a tela de orcamento so mostra numero e nao vende a casa. A apresentacao usa o que a casa ja tem e o valor fica no fim. Fechado na conversa: logo do espaco; caracteristicas do espaco; fotos que a pessoa marca para aparecer no site; dados estrategicos das informacoes gerais; servicos inclusos neste orcamento; icones para site, Instagram, Facebook e TikTok; o usuario escolhe cor primaria, secundaria e cor do texto em Configurações do espaço.

## Problema atual

Quem abre o link publico do orcamento ve logo, data, convidados e a lista de valores. A casa, as fotos escolhidas para o site e as caracteristicas nao entram nessa pagina. Os servicos deste orcamento so aparecem como linha de preco.

## Objetivo da mudanca

Na pagina publica de um orcamento, a pessoa ve a casa e o que esta incluso naquele orcamento antes do valor, nas cores escolhidas para aquele espaco, e o total continua no fim.

## Escopo inicial percebido

Redesenho da jornada publica da proposta, mais tres cores escolhidas em Configurações do espaço. A tela publica muda, as cores precisam persistir nessa configuracao e a pagina precisa receber fotos marcadas, caracteristicas, dados gerais e essas cores sem abrir o cadastro interno. Toca `frontend` e `backend`, com migration aditiva.

## Itens incluidos neste request

- logo do espaco na capa, o que esta em Logo do Espaco nas informacoes gerais
- cor primaria, cor secundaria e cor do texto em Configurações do espaço (`/venue/:id/settings`), aplicadas nesta pagina publica
- capa com a primeira foto marcada para o site, nome, cidade e descricao
- icones de site, Instagram, Facebook e TikTok, so quando o link existir
- bloco deste evento com data, horario e convidados
- capacidade maxima ao lado dos convidados
- pernoite com check-in, check-out e minimo de noites, quando a casa tiver pernoite
- horario de abertura e fechamento, quando a casa nao tiver pernoite
- galeria com as demais fotos marcadas para o site, na ordem ja gravada
- caracteristicas do espaco, na ordem do cadastro
- secao com o nome dos servicos ligados a este orcamento, antes do total
- card de valor no fim, com base, horas extras, cada servico com preco e o total
- WhatsApp no fim

## Requisitos implicitos ja visiveis

- a pagina continua publica, no mesmo link que o cliente ja recebe
- horario do evento permanece em wall-clock
- a marca da pagina e o logo do espaco quando ele existe; a marca EventHub nao substitui um logo cadastrado
- as tres cores pertencem ao espaco e permanecem ao reabrir Configurações do espaço
- quem ja edita essa tela escolhe as cores; esta entrega nao cria permissao nova
- a gravacao das cores passa pelo backend; a tela nao substitui essa autorizacao
- a migration de producao e aditiva
- sem cor escolhida, a pagina publica mantem as cores que ja usa hoje
- foto desmarcada para o site nao entra na proposta
- servico exibido e o deste orcamento, nao o catalogo do venue
- secao sem dado some; o valor no fim nao depende dela
- o pacote publico da casa nao inclui dono, contrato, pagamento nem tabela de preco do cadastro
- o frontend nao cria uma terceira forma de estado alem das que o projeto ja usa
- mudanca multi-repo: o request pode ser derivado depois com `tasking/task-request-repo-split-prompt.md`, de preferencia depois da spec

## Casos de erro e borda ja percebidos

- nenhuma foto marcada: a capa segue com o logo do espaco e a descricao, sem galeria
- casa sem logo: a capa nao inventa uma marca do espaco; vale o fallback que a pagina ja usa hoje
- casa sem cor, ou cor invalida: a pagina publica mantem as cores atuais; a cor invalida nao e gravada
- nenhuma caracteristica: a secao da casa nao lista itens
- nenhum servico neste orcamento: a secao "incluso" nao aparece; o total continua
- link de rede vazio: aquele icone nao aparece
- casa com pernoite: mostra check-in, check-out e minimo de noites, e nao o horario de funcionamento
- casa sem pernoite: mostra abertura e fechamento, e nao os campos de pernoite
- resposta da casa pedida sem autenticacao nao devolve dado de dono, contrato ou pagamento

## Dependencias

- caracteristicas do espaco ja cadastraveis no painel
- fotos do venue ja tem a marca de aparecer no site da organizacao
- informacoes gerais, logo e links do venue ja existem
- servicos ja sao ligados a proposta
- cor primaria, secundaria e de texto ainda nao existem em Configurações do espaço; a gravacao pede migration aditiva
- a tela de Configurações do espaço ja existe e ja exige permissao para editar o venue

## Restricoes e cuidados

- nao publicar regras do espaco nesta entrega
- nao usar os textos antigos de `area: "amenities"` nesta pagina
- nao mostrar rua, numero, CEP nem proprietarios
- nao mostrar modelo de preco, preco por pessoa, preco por dia nem preco minimo do cadastro
- nao alterar o calculo do total
- nao ler nem versionar valores de `.env`
- a rota publica continua intencional; o que ela devolve precisa ser o recorte de apresentacao, testado para nao incluir dado interno
- as tres cores valem para a pagina publica deste orcamento; nao repintam o painel nem o site da organizacao nesta entrega

## Perguntas em aberto

- Os icones da capa substituem os do rodape? Premissa: a fileira sobe para a capa e o rodape atual permanece.
- Cidade sozinha ou cidade e bairro? Premissa: cidade e bairro, sem o endereco completo.
- O preco de cada servico aparece na secao "incluso"? Premissa: na secao "incluso" so o nome; o preco fica no card final.
- Caracteristica e foto de outro venue podem vazar no link? Premissa: nao; a pagina so le a casa daquele orcamento.
- Casa sem logo mostra a marca EventHub? Premissa: sim, so nesse caso; com logo cadastrado, a pagina usa o logo do espaco.
- As cores mudam o painel e o site tambem? Premissa: nao nesta entrega; a escolha fica em Configurações do espaço e o uso fica na pagina publica do orcamento.

## Prioridade sugerida

Media. Melhora a peca que o cliente recebe, sem corrigir um calculo quebrado.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: o pedido redesenha a jornada publica do orcamento, grava tres cores novas do espaco, toca `frontend` e `backend` e separa um pacote publico da casa do cadastro interno. Nao e seguro executar como uma task isolada.

## Sugestao de slug da spec

- `framework_core/specs/apresentacao-publica-orcamento/`

## Sugestao de nome do arquivo

- `apresentacao-publica-orcamento-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-04-apresentacao-publica-orcamento/`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `opcional`
