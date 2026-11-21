# Solicitacao da Tarefa

## Nome sugerido da tarefa

Abrir apresentacao e formulario de orcamento pelo nome do espaco

## Resumo da solicitacao

Os links publicos da apresentacao e do formulario de orcamento passam a identificar a casa pelo nome do espaco. O id da casa sai desses dois enderecos. O painel e o link de um orcamento ja fechado continuam como estao.

## Context Pack

- frente principal: produto (frontend e backend)
- superficie sensivel: sim — `/venue/:id/apresentacao` e `/venue/:id/form` sao publicas; achar a casa pelo nome nao pode devolver dono, contrato, pagamento nem o pacote interno do `getById`
- risco principal: o formulario gravar o orcamento com o nome no lugar do id, ou um link ja enviado com o UUID deixar de abrir
- repos tocados: `frontend` (`eventhub-vista-dashboard/`), `backend` (`art56_server_v3/`)
- fora de escopo operacional: rotas do painel (`/venue/:id/settings` e as demais); `/proposal/:id/view`; regras, parceiros e colaboradores; criar slug novo ou mudar o nome unico do cadastro
- prova minima desta execucao: o item Apresentação e o botao de copiar o formulario abrem `https://event-hub-dashboard.vercel.app/venue/AR756/apresentacao` e `https://event-hub-dashboard.vercel.app/venue/AR756/form`; sem login, as duas paginas carregam a AR756; enviar o formulario grava o orcamento nessa casa; a resposta publica nao inclui dono, contrato nem pagamento
- criterio de escalada: a spec e o caminho; voltar para `normal` somente se a troca ficar so na montagem do link no frontend e a leitura publica por nome ja existir
- nivel de autonomia: `L2`
- camadas transversais: `security`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `node`, `patterns`, `security`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Regras de ouro`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/security/index.md`
- caminhos candidatos: `public-venue-presentation.ts`; `VenueNav.tsx`; `VenueBudgets.tsx`; `VenuePresentation.tsx`; `ProposalForm.tsx`; `GET /venue/presentation/:venueId`; `getPublicPresentation`; `fetchVenueById`
- palavras-chave ou simbolos de busca: `publicVenuePresentationShareUrl`, `Copiar link do formulário de orçamento`, `/venue/:id/form`, `/venue/:id/apresentacao`, `PUBLIC_ROUTES`, `Venue.name`
- testes provaveis: link da sidebar e link copiado com o nome; abrir as duas rotas sem sessao; nome desconhecido nao mostra outra casa; envio do formulario usa o id real da casa
- nao ler por padrao: `topics/`; specs da apresentacao e do orcamento alem do contrato publico que estes dois links ja usam

## Contexto informado na entrada

Pedido em chat, com a apresentacao aberta em `localhost:8080/venue/8159e209-0057-4df3-ae72-855363c3b84e/apresentacao`. A casa na tela e a AR756. O endereco publico da apresentacao e o do formulario de orcamento devem levar o nome do espaco, nao o id da casa.

O que ja foi conferido no codigo: `publicVenuePresentationShareUrl` monta `/venue/{id}/apresentacao` com `venue.id`. O botao em Orcamentos copia `/venue/{selectedVenue.id}/form`. `Venue.name` e unico. A apresentacao busca `GET /venue/presentation/:venueId` por id. O formulario trata o trecho da URL como id e o repassa aos formularios de envio como `venueId`. `/proposal/:id/view` usa o id do orcamento, nao o id da casa.

## Problema atual

Quem recebe o link da casa ve um UUID no endereco. A apresentacao e o formulario de orcamento sao os dois links publicos que carregam o id da casa.

## Objetivo da mudanca

O link novo da apresentacao e o link novo do formulario de orcamento identificam a casa pelo nome gravado do espaco, e os dois continuam abrindo a casa certa sem login.

## Escopo inicial percebido

Troca do identificador publico nesses dois enderecos, da montagem do link ate a leitura da casa. Toca `frontend` e `backend`. Nao ha campo novo.

## Itens incluidos neste request

- apresentacao em `/venue/{nome}/apresentacao`, no mesmo host dos outros links publicos
- formulario de orcamento em `/venue/{nome}/form`
- o item Apresentação da sidebar e o botao de copiar o formulario passam a usar o nome
- a leitura publica encontra a casa por esse nome
- o envio do formulario continua gravando no id real da casa
- nome com espaco, acento ou caractere reservado entra codificado na URL

## Requisitos implicitos ja visiveis

- o nome usado e o `name` ja gravado e unico; esta entrega nao cria slug
- o exemplo concreto e a AR756: `/venue/AR756/apresentacao` e `/venue/AR756/form`
- as paginas publicas continuam na allowlist, sem login
- o pacote devolvido continua o recorte que cada pagina ja recebe
- rotas internas do painel continuam com o id
- `/proposal/:id/view` continua com o id do orcamento

## Casos de erro e borda ja percebidos

- nome que nao existe: a pagina nao mostra dado de outra casa
- nome com espaco ou acento: a URL codifica e a busca usa o nome decodificado
- casa renomeada: o link antigo com o nome anterior deixa de ser o endereco atual
- link ja enviado com o UUID: ver pergunta em aberto
- o trecho da URL nao pode ser gravado como `venueId` do orcamento

## Dependencias

- a apresentacao publica e o formulario publico ja existem
- `Venue.name` ja e unico
- a sidebar e o botao de copiar ja montam esses dois links com o id

## Restricoes e cuidados

- nao ler nem versionar valores de `.env`
- nao ampliar o que a rota publica devolve; dono, contrato e pagamento continuam fora
- nao criar permissao nova
- nao mudar o calculo nem o destino do orcamento criado pelo formulario
- a rota publica segue intencional e na allowlist do backend e do frontend

## Perguntas em aberto

- Um link ja enviado com o UUID continua abrindo? Premissa: sim; a pagina aceita o nome e tambem o id antigo, e so os links novos usam o nome.

## Prioridade sugerida

Media. O endereco publico da casa fica legivel; o fluxo de orcamento e a apresentacao continuam os mesmos.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: a troca do identificador publico atravessa `frontend` e `backend`, mexe em duas rotas publicas e precisa separar o nome da URL do id usado para gravar o orcamento. Nao e seguro executar como uma task isolada.

## Sugestao de slug da spec

- `framework_core/specs/url-publica-nome-do-espaco/`

## Sugestao de nome do arquivo

- `url-publica-nome-do-espaco-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-19-url-publica-nome-do-espaco/`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `opcional`
