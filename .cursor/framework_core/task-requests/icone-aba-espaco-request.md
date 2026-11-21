# Solicitacao da Tarefa

## Nome sugerido da tarefa

Icone da aba do espaco

## Resumo da solicitacao

Ao lado do logo do espaco, a pessoa envia um arquivo separado. Esse arquivo vira o icone da aba do navegador naquele lugar. Sem arquivo, a aba continua com o favicon do EventHub.

## Context Pack

- frente principal: produto (banco, upload e paginas que ja trocam o titulo da aba)
- superficie sensivel: sim — upload de imagem no create/update autenticado do espaco, URL publica no mesmo tipo do `logoUrl`, e coluna nova em `venue`; aplicar na `main` do PlanetScale exige aprovacao nomeada
- risco principal: o segundo arquivo substituir o logo, ou a aba de outra casa ficar com o icone errado depois que a pessoa sai da pagina
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: apple-touch-icon, manifest e PWA; recorte, redimensionamento e geracao de tamanhos; usar o logo como icone da aba; botao de remover o icone; mudar o texto da aba; paginas que hoje nao trocam `document.title`
- prova minima desta execucao: `npx prisma validate` aceita a coluna nova em `Venue`; em Configuracoes, aba Apresentacao, e no formulario de criar espaco, o campo fica ao lado de Logo do Espaco; um arquivo novo grava, recarrega e substitui o anterior; salvar sem arquivo novo mantem o icone; nas cinco telas que ja trocam o titulo, a aba mostra esse icone e, ao sair, volta o favicon do EventHub; sem icone, a aba permanece com o favicon do EventHub
- criterio de escalada: ja e spec; nao executar como task unica
- nivel de autonomia: `L2`
- flags transversais: `security` (upload), `database` (coluna em `venue`), `design` (campo ao lado do logo)

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `database`, `node`, `react`, `design`, `aws`, `security`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/agent-entrypoint.md#Provas`
  - `.cursor/framework_core/topics/public-pages-and-branding.md#Marca do espaco`
  - `.cursor/framework_core/topics/data-and-migrations.md#Regras`
  - `.cursor/framework_core/project/planetscale.md#Fluxo real de schema`
- caminhos candidatos: `logoUrl` em `Venue` (`art56_server_v3/prisma/schema.prisma`); `upload.single("file")` em `art56_server_v3/src/router/venue.ts`; `controller-update-venue.ts`; `to-venue-presentation.ts`; `venue.service.ts`; `VenueSettings.tsx`; `CreateVenueForm.tsx`; `venue-settings-tabs.ts`; `venue-tab-title.ts`; `ProposalView.tsx`; `VenuePresentation.tsx`; `PublicVenueListShell.tsx`; `VenueDashboard.tsx`; `ProposalForm.tsx`; `eventhub-vista-dashboard/public/favicon.ico`
- palavras-chave ou simbolos de busca: `logoUrl`, `logoFile`, `upload.single`, `document.title`, `venueTabTitle`, `EVENTHUB_TAB_TITLE`, `favicon.ico`
- testes provaveis: `npx prisma validate`; schema de create/update aceitando o icone ausente; salvar com arquivo, sem arquivo e com arquivo novo por cima; a aba usa o icone nas cinco telas e volta o favicon do EventHub ao sair
- nao ler por padrao: `topics/` alem de `public-pages-and-branding.md` e `data-and-migrations.md`; specs de titulo de aba; `observability`; `patterns`

## Contexto informado na entrada

Pedido em chat. Ao lado de onde se cadastra o logo do lugar, a pessoa envia um icone para a aba do navegador. O logo ja fica em Configuracoes, aba Apresentacao, e tambem na criacao do espaco. O arquivo sobe sozinho no campo `file` e grava `logoUrl`. Nao existe coluna de icone. Cinco telas ja trocam o texto da aba e restauram o titulo do EventHub ao sair. Nenhuma troca o icone. O favicon fixo e `public/favicon.ico`.

## Problema atual

O logo do espaco nao serve de icone da aba, e nao ha outro arquivo para isso. Quem abre a proposta, a apresentacao, a lista publica, o painel do espaco ou o formulario da proposta ve o nome do lugar na aba e o favicon do EventHub.

## Objetivo da mudanca

Ao lado do logo, da para gravar um icone daquele espaco, e a aba das telas que ja mostram o nome do espaco passa a usar esse icone.

## Escopo inicial percebido

Coluna nova, segundo arquivo no create e no update do espaco, campo ao lado do logo na configuracao e na criacao, URL na apresentacao publica, e troca do icone da aba nas cinco telas que ja mudam o titulo. Toca `backend` e `frontend`. Cabe em spec, nao em uma task so.

## Itens incluidos neste request

- coluna opcional de URL no `Venue`, no padrao de `logoUrl`
- campo de arquivo ao lado de Logo do Espaco em Configuracoes, aba Apresentacao, e no formulario de criar espaco
- o logo continua no campo `file`; o icone vai em outro campo do mesmo save
- arquivo novo substitui o icone anterior; campo vazio nao apaga o que ja esta gravado
- a apresentacao publica devolve a URL do icone junto de `logoUrl`
- as cinco telas que ja definem `document.title` apontam a aba para essa URL e, ao sair, devolvem o favicon do EventHub
- sem icone, a aba fica com o favicon do EventHub
- texto curto no campo: o icone fica melhor quadrado e pequeno
- aceite de imagem no mesmo `accept="image/*"` do logo

## Requisitos implicitos ja visiveis

- o icone e outro arquivo; o logo nao e reaproveitado como icone
- o arquivo enviado e o que a aba usa, sem recorte nem tamanhos gerados
- so o icone da aba (`rel="icon"`); sem apple-touch-icon, manifest ou PWA
- casa nova pode ficar sem icone
- a migration no repositorio nao e aplicada na `main` sem aprovacao nomeada
- a URL do icone e publica no mesmo tipo da URL do logo; nao abre rota nova

## Casos de erro e borda ja percebidos

- salvar logo e icone no mesmo envio nao pode gravar o icone por cima de `logoUrl`
- salvar sem arquivo novo mantem o icone ja gravado
- sair da tela restaura o favicon do EventHub, no mesmo efeito em que o titulo volta para `EVENTHUB_TAB_TITLE`
- espaco sem icone nao troca o favicon
- falha no upload mostra o erro na propria tela e nao apaga o icone anterior
- `index.html` nao declara `rel="icon"` no head lido; a troca precisa achar ou criar o link da aba

## Dependencias

- `logoUrl`, o upload `file` e o titulo da aba ja existem
- create e update do espaco hoje aceitam um arquivo so (`upload.single("file")`)
- a apresentacao publica ja devolve `logoUrl` e ainda nao devolve icone de aba

## Restricoes e cuidados

- nao usar o logo como icone da aba
- nao criar botao de remover nesta v1
- nao mudar o texto da aba nem o helper `venueTabTitle`
- nao aplicar o icone em pagina que hoje nao troca `document.title`
- nao ler nem versionar valores de `.env`
- nao aplicar a migration em producao nesta execucao
- o request pode ser dividido entre `backend` e `frontend` com `tasking/task-request-repo-split-prompt.md` antes da spec, se a promocao separar os repos

## Insumo para o bootstrap

- o update do logo sobe no S3, apaga o objeto anterior pela ultima parte da URL e grava `https://{bucket}.s3.{region}.amazonaws.com/{key}`; o icone segue esse padrao, em objeto proprio
- `upload.single("file")` em POST `/venue/create` e PUT `/venue/update` nao recebe os dois arquivos; o logo permanece em `file`
- `to-venue-presentation.ts` e o tipo no frontend precisam da URL, senao a proposta e a pagina publica nao tem o que colocar na aba
- a troca cabe no `useEffect` que ja define `document.title` em `ProposalView.tsx`, `VenuePresentation.tsx`, `PublicVenueListShell.tsx`, `VenueDashboard.tsx` e `ProposalForm.tsx`
- schemas de create/update e `venue-settings-tabs.ts` hoje so conhecem `logoUrl` e `logoFile`
- `topics/public-pages-and-branding.md` lista mais paginas com a marca do espaco; nesta v1 o icone fica nas cinco que ja trocam o titulo
- o nome da coluna nao foi fechado; o comportamento e uma URL opcional ao lado de `logoUrl`

## Perguntas em aberto

- O campo entra nos dois lugares que ja tem o logo? Premissa: sim, em Configuracoes, aba Apresentacao, e no formulario de criar espaco.
- Em quais telas a aba usa o icone? Premissa: nas cinco que ja trocam `document.title`, e ao sair volta o favicon do EventHub.
- Sem icone cadastrado, a aba fica com o favicon do EventHub? Premissa: sim.
- Da para trocar o icone no mesmo save? Premissa: sim, arquivo novo substitui o anterior; campo vazio nao apaga.
- Qual arquivo a pessoa pode enviar? Premissa: imagem, no mesmo `accept="image/*"` do logo, com texto curto de que fica melhor quadrado e pequeno.

## Prioridade sugerida

Media. A aba ja mostra o nome do espaco. Falta o icone daquele lugar. Nao desbloqueia um fluxo quebrado.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: coluna nova, segundo arquivo no upload do espaco, URL na apresentacao publica e troca da aba em cinco telas. Toca backend e frontend e se quebra em mais de uma task.

## Sugestao de slug da spec

- `framework_core/specs/icone-aba-espaco/`

## Sugestao de nome do arquivo

- `icone-aba-espaco-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-20-icone-aba-espaco/`
- entrada publica recomendada: `fw:spec`
- derivacao repo-local: `opcional`
- promocao: usar `C:\Users\AR756\Desktop\igor\eventhub\eventhub-docs\framework_global\framework-base\prompts\spec-driven\spec-feature-bootstrap-prompt.md` a partir deste request
