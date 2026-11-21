# Solicitacao da Tarefa

## Nome sugerido da tarefa

Abrir o link publico com a apresentacao do espaco

## Resumo da solicitacao

O espaco ganha um link publico, no mesmo desenho do orcamento, que apresenta a casa sem um evento fechado. Na sidebar, secao A casa, o item Apresentação abre esse link em outra aba.

## Context Pack

- frente principal: produto (frontend e backend)
- superficie sensivel: sim — a pagina `/venue/:id/apresentacao` e publica; o pacote nao pode levar dono, contrato, pagamento nem o total de um orcamento
- risco principal: a pagina publicar dado interno do venue, ou misturar o catalogo de precos com o total fechado de um orcamento
- repos tocados: `frontend` (`eventhub-vista-dashboard/`), `backend` (`art56_server_v3/`)
- fora de escopo operacional: mudar `/proposal/:id/view`; calcular total, horas extras ou desconto; botao Alterar orcamento ou Alterar servicos; preco na lista de servicos; regras do espaco; endereco por escrito (rua, numero, CEP, proprietarios)
- prova minima desta execucao: na sidebar do espaco, secao A casa, Apresentação abre `https://event-hub-dashboard.vercel.app/venue/:id/apresentacao` em outra aba e o painel fica na tela atual; sem login, a pagina mostra logo, descricao, video ou foto, uma foto, Conheça nosso espaço, Serviços disponíveis, grid, Seu investimento com WhatsApp e o mapa; orcamento publico continua com a proposta e o total
- criterio de escalada: a spec e o caminho; voltar para `normal` somente se a pagina so reutilizar o pacote publico que o orcamento ja recebe, sem leitura nova de servicos e precos do espaco
- nivel de autonomia: `L2`
- camadas transversais: `design`, `security`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `design`, `node`, `patterns`, `security`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_global/framework-libs/security/index.md`
- caminhos candidatos: `ProposalView`; sidebar `A casa` em `sidebar-nav-model.ts` e `VenueNav.tsx`; `public-venue-presentation.ts`; apresentacao publica da proposta; catalogo de servicos do venue; precos em Configurações do espaço
- palavras-chave ou simbolos de busca: `Apresentação`, `publicVenuePresentationShareUrl`, `VIEW_VENUE_SITES`, `ProposalView`, `pricingModel`, `opensExternalUrl`
- testes provaveis: item externo na sidebar; abrir `/venue/:id/apresentacao` sem sessao; conferir a ordem dos blocos com e sem video; a resposta publica nao inclui dono, contrato, pagamento nem total de orcamento
- nao ler por padrao: `topics/`; specs do orcamento alem do que precisar para reutilizar a casca publica

## Contexto informado na entrada

Pedido em chat. O link do espaco segue a pagina publica do orcamento, sem ser um orcamento. Decisoes fechadas na conversa: a ordem dos blocos; Serviços disponíveis no lugar de Sua experiência inclui; Seu investimento explica o preco do espaco e termina no WhatsApp; o mapa fica por ultimo; na sidebar, secao A casa, o item Apresentação abre o link em outra aba.

O item da sidebar ja esta no codigo. Quem ve Site ve Apresentação (`VIEW_VENUE_SITES`). O clique usa `target="_blank"` e o endereco `https://event-hub-dashboard.vercel.app/venue/{id}/apresentacao`. A pagina desse endereco ainda nao existe.

## Problema atual

So o orcamento tem link publico de apresentacao. Esse link exige data, convidados e total. Nao ha uma pagina da casa para enviar antes de fechar um evento. A sidebar ja aponta para o endereco, e esse endereco ainda nao abre a apresentacao.

## Objetivo da mudanca

Quem recebe o link do espaco ve a casa, os servicos disponiveis e como o espaco cobra, e consegue chamar no WhatsApp. Quem esta no painel abre esse link pela sidebar, em outra aba.

## Escopo inicial percebido

Pagina publica nova do venue, leitura publica da casa, dos servicos e do preco de tabela, e o item de sidebar que ja abre o endereco. Toca `frontend` e `backend`. O orcamento publico nao muda.

## Itens incluidos neste request

- rota publica `/venue/:id/apresentacao`, no mesmo host dos outros links publicos
- casca visual do orcamento: logo, descricao, cores do espaco e rodape com logo e redes
- hero com o video do tour; sem video, a primeira foto marcada para o site
- uma foto no lugar do card Proposta personalizada; com video, essa foto e a capa; sem video, e a foto seguinte a capa
- Conheça nosso espaço igual ao orcamento, com caracteristicas e Agendar uma visita
- Serviços disponíveis: catalogo do espaco, nome e detalhe, sem preco e sem Alterar servicos
- grid com as fotos restantes marcadas para o site
- Seu investimento entre o grid e o mapa: modelo de preco ja gravado (por pessoa, por dia, por pessoa/dia ou por pessoa/hora) com o valor correspondente, preco minimo quando existir, e o botao Conversar com nossa equipe
- mapa igual ao do orcamento: bairro, cidade e mapa incorporado
- item Apresentação na secao A casa, abrindo o link em outra aba, visivel para quem ja abre Site

## Requisitos implicitos ja visiveis

- `/proposal/:id/view` permanece a pagina do evento, com proposta, total e Alterar orcamento
- a marca da pagina e o logo do espaco quando ele existe
- as cores do espaco valem nesta pagina, como ja valem no orcamento
- foto desmarcada para o site nao entra
- secao sem dado some
- o item da sidebar nao fica marcado como pagina atual
- no menu recolhido, Apresentação segue oculta, como o restante de A casa
- quem nao tem `VIEW_VENUE_SITES` nao ve o item
- a gravacao de preco, servico, foto e caracteristica continua nas telas que ja existem
- a resposta publica nao inclui dono, contrato, pagamento nem total de um orcamento

## Casos de erro e borda ja percebidos

- casa sem video: a capa sobe para o topo e a foto seguinte ocupa o lugar da proposta; o restante vai para o grid
- uma foto so: hero com essa foto; o lugar da proposta e o grid ficam vazios
- nenhuma foto marcada: a pagina segue com logo e descricao, sem hero, sem foto solta e sem grid
- casa sem logo: vale o fallback que a pagina do orcamento ja usa
- nenhum servico: Serviços disponíveis nao aparece
- preco minimo vazio: a linha de minimo nao aparece
- WhatsApp vazio: o botao Conversar com nossa equipe nao aparece; Agendar uma visita tambem nao
- espaco inexistente: a pagina publica nao mostra dado de outra casa

## Dependencias

- apresentacao publica do orcamento ja existe e e o modelo visual
- logo, descricao, cores, video, fotos marcadas, caracteristicas, WhatsApp e mapa ja existem no pacote da casa
- servicos do espaco ja existem no cadastro; esta pagina passa a le-los sem um orcamento
- modelo de preco, valor do modelo e preco minimo ja existem em Configurações do espaço
- o item Apresentação ja esta em `sidebar-nav-model.ts` e `VenueNav.tsx`, com `publicVenuePresentationShareUrl`

## Restricoes e cuidados

- nao mostrar total fechado, locacao calculada, horas extras, desconto, referencia por convidado nem Alterar orcamento; a hora extra so existe dentro de um orcamento
- nao mostrar o preco de cada servico em Serviços disponíveis
- nao mostrar rua, numero, CEP nem proprietarios por escrito; o mapa usa o mesmo recorte do orcamento
- nao ler nem versionar valores de `.env`
- a rota publica e intencional; o que ela devolve precisa ser o recorte de apresentacao
- nao criar permissao nova; o item reutiliza `VIEW_VENUE_SITES`

## Perguntas em aberto

- Nenhuma. O preco do servico fica de fora de Serviços disponíveis. Quem ve o item e quem ja abre Site.

## Prioridade sugerida

Media. Cria a peca publica da casa; o orcamento de um evento continua valendo.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: a pagina publica nova le servicos e preco de tabela do espaco, separa esse pacote do orcamento e toca `frontend` e `backend`. Nao e seguro executar como uma task isolada.

## Sugestao de slug da spec

- `framework_core/specs/apresentacao-publica-do-espaco/`

## Sugestao de nome do arquivo

- `apresentacao-publica-do-espaco-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-18-apresentacao-publica-do-espaco/`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `opcional`
