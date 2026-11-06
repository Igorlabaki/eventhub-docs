# Solicitacao da Tarefa

## Nome sugerido da tarefa

Foto ou video do YouTube e descricao em cada caracteristica do espaco

## Resumo da solicitacao

Cada caracteristica do espaco passa a aceitar uma descricao e uma midia: uma foto ou um link de video do YouTube. O painel grava isso no item, e a proposta publica mostra o complemento junto do nome.

## Context Pack

- frente principal: produto (backend e frontend)
- superficie sensivel: sim — upload de imagem e exposicao na pagina publica do orcamento
- risco principal: gravar foto e video no mesmo item, ou aceitar um link que nao e do YouTube e expor isso na pagina publica
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: tour do espaco, galeria da casa, foto e descricao de servico, regras do espaco, e upload de arquivo de video
- prova minima desta execucao: no painel, criar uma caracteristica so com nome, uma com descricao e foto, e uma com descricao e link do YouTube; a terceira recusa foto e video juntos e recusa link que nao seja do YouTube; na pagina publica, o item com midia mostra descricao e foto ou video, e o item so com nome continua na lista; caracteristicas ja cadastradas seguem validas; usuario sem permissao de edicao nao grava
- criterio de escalada: a spec e o caminho; voltar para `normal` somente se o pedido for reduzido a descricao no cadastro, sem foto, sem video e sem a pagina publica
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `database`, `node`, `patterns`, `react`, `design`, `aws`, `security`, `architecture`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_core/project/project-decisions.md#D-01`, `#D-03` e `#D-05`
  - `.cursor/framework_global/framework-libs/security/index.md`
  - `.cursor/framework_global/framework-libs/aws/index.md`
- caminhos candidatos: cadastro de caracteristicas do venue; bloco "Conheça nosso espaço" na pagina publica do orcamento
- palavras-chave ou simbolos de busca: `VenueAmenity`, `Nova caracteristica`, `Conheça nosso espaço`
- testes provaveis: `npx prisma validate` e `npm test -- --run` no backend; no painel, criar os tres casos e abrir a pagina publica
- nao ler por padrao: `topics/`, `specs/` de outras frentes, tour do espaco, galeria e servicos

## Contexto informado na entrada

Pedido em chat, na lista de caracteristicas do painel. Cada item deve aceitar uma foto ou um link de video do YouTube, e uma descricao.

## Problema atual

A caracteristica guarda nome e posicao. O formulario de criar e editar nao tem descricao nem midia. Na proposta publica, o bloco "Conheça nosso espaço" lista so o nome.

## Objetivo da mudanca

Um usuario autorizado grava, em cada caracteristica, uma descricao opcional e no maximo uma midia — foto ou link do YouTube — e a proposta publica mostra esse complemento.

## Escopo inicial percebido

Cadastro da caracteristica no painel e leitura desse complemento na pagina publica. Toca `backend` e `frontend`, pede migration aditiva, upload de imagem e validacao de link.

## Itens incluidos neste request

- descricao opcional no criar e no editar
- uma foto opcional ou um link de video do YouTube, nunca os dois no mesmo item
- o mesmo conteudo visivel na proposta publica
- caracteristicas ja cadastradas continuam validas, sem descricao e sem midia

## Requisitos implicitos ja visiveis

- a gravacao passa pelo backend autenticado; a permissao da tela nao substitui a autorizacao da API
- a migration de producao e aditiva
- a foto reaproveita o upload de imagem que o produto ja tem
- o link aceito e so do YouTube, em `https`
- a pagina publica nao recebe dado interno do painel
- o frontend nao cria uma terceira forma de estado alem das que o projeto ja usa

## Casos de erro e borda ja percebidos

- item sem descricao e sem midia: o cadastro e a lista publica seguem como hoje
- foto e link preenchidos juntos: a gravacao recusa
- link que nao e do YouTube, ou que nao e `https`: a gravacao recusa
- arquivo que nao e imagem: a foto nao e salva
- usuario sem permissao de edicao: nao grava
- apagar ou trocar a midia de um item que ja tem foto: a foto antiga nao permanece acessivel como se ainda fosse deste item

## Dependencias

- o cadastro de caracteristicas e o bloco publico ja existem
- upload de imagem do produto ja existe e deve ser reaproveitado
- mudanca multi-repo: o request pode ser derivado depois com `tasking/task-request-repo-split-prompt.md`, de preferencia depois da spec

## Restricoes e cuidados

- nao aceitar arquivo de video; o video entra so como link do YouTube
- nao alterar o tour do espaco, a galeria da casa nem a foto do servico
- nao ler nem versionar valores de `.env`
- upload e pagina publica sao intencionais; autorizacao no backend para gravar; a pagina publica so expoe descricao e midia da caracteristica

## Perguntas em aberto

- A descricao e obrigatoria? Premissa: nao.
- Foto e video podem coexistir no mesmo item? Premissa: nao. No maximo um dos dois, e os dois sao opcionais.
- Onde o convidado ve isso? Premissa: no bloco "Conheça nosso espaço" da proposta publica, junto do nome. Item sem complemento continua so com o nome.
- Quantas fotos? Premissa: uma, opcional, so desta caracteristica.
- Qual link vale? Premissa: URL `https` do YouTube, inclusive Shorts e `youtu.be`. Arquivo de video fica de fora.

## Prioridade sugerida

Media. E complemento do cadastro da caracteristica, sem correcao de um fluxo que ja esteja quebrado.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: o pedido cria capacidade nova no cadastro, no schema, no upload e na pagina publica. Toca `backend` e `frontend` e se quebra em varias tasks. Nao e seguro executar como uma task isolada.

## Sugestao de slug da spec

- `framework_core/specs/foto-video-descricao-caracteristica/`

## Sugestao de nome do arquivo

- `foto-video-descricao-caracteristica-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-05-foto-video-descricao-caracteristica/`
- entrada publica recomendada: `fw:spec`
- derivacao repo-local: `necessaria`
