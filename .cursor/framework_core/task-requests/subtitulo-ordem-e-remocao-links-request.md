# Solicitacao da Tarefa

## Nome sugerido da tarefa

Subtitulo, ordem e remocao na pagina de links do espaco

## Resumo da solicitacao

Na pagina publica de links, cada botao mostra um subtitulo embaixo do titulo. Quem edita o site daquele espaco arrasta a ordem na propria pagina, como nas fotos da apresentacao, e remove um link so depois de confirmar; ao confirmar, o link some da pagina.

## Context Pack

- frente principal: produto (frontend e backend); a pagina publica de links ganha texto e, para quem edita o site, gravacao de ordem e de oculto
- superficie sensivel: sim — a leitura continua publica; a gravacao na propria pagina nao pode valer para visitante nem para quem nao edita o site daquele espaco
- camadas transversais: `design`, `security`, `patterns`
- risco principal: um visitante arrastar ou omitir um link, ou a confirmacao apagar a linha em vez de so tirar o botao da pagina
- repos tocados: `frontend` (`eventhub-vista-dashboard/`), `backend` (`art56_server_v3/`)
- fora de escopo operacional: editar o texto do subtitulo na pagina; campo livre de subtitulo; apagar a linha do catalogo; mudar a lixeira da aba Redes; tipo novo de link; nome livre de botao; formulario de parceiro ou de colaborador; reabrir o desenho do card ja pedido em `visual-redes-e-link-tree-request.md` (icone, seta e titulo continuam)
- prova minima desta execucao: em `/espaco/AR756/links`, cada botao visivel mostra o titulo e uma linha de subtitulo embaixo; logado com Site naquele espaco, arrastar WhatsApp para cima de Regras grava e sobrevive a recarregar; Remover pergunta "Tem certeza que quer remover?", Cancelar mantem o botao e confirmar tira o botao da pagina; sem login nao ha alca nem Remover, e o link omitido nao aparece; vitest do front e do back verdes
- criterio de escalada: a spec e o caminho; a faixa C nao volta para task isolada. Se o subtitulo passar a ser texto livre gravado pelo dono, a spec inclui a coluna e a migration
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `design`, `node`, `patterns`, `security`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/security/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/topics/public-pages-and-branding.md#Demais paginas publicas`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/VenueLinks.tsx`; `eventhub-vista-dashboard/src/components/venue/VenueLinkEditor.tsx`; `eventhub-vista-dashboard/src/lib/venue-link.ts`; `eventhub-vista-dashboard/src/components/proposal/public-photo-edit.tsx`; `eventhub-vista-dashboard/src/pages/VenuePresentation.tsx`; `art56_server_v3/prisma/schema.prisma` no model `VenueLink`; o use case que marca `canReorder` na apresentacao
- palavras-chave ou simbolos de busca: `VenueLinksView`, `link.label`, `canReorder`, `EDIT_VENUE_SITE`, `usePublicPhotoEdit`, `reorderVenueLinks`, `visible`, `VenueLink`
- testes provaveis: `eventhub-vista-dashboard/src/pages/VenueLinks.test.tsx`; `eventhub-vista-dashboard/src/components/venue/VenueLinkEditor.test.tsx`; o spec de `canReorder` da apresentacao do espaco
- nao ler por padrao: `database` e `observability` nesta premissa (sem coluna nova); specs de orcamento; formulario de criar espaco

## Contexto informado na entrada

Pedido em chat, com print de `/espaco/AR756/links`. Os botoes mostram icone, seta e o titulo (`Apresentacao`, `Fazer orcamento`, `Regras`, `WhatsApp`, `Instagram`). O pedido e um subtitulo embaixo do titulo. Logado no espaco, a ordem muda na propria pagina, do mesmo jeito que as fotos da apresentacao. Remover um link pergunta se tem certeza; confirmar omite o link da pagina.

Confirmado no codigo durante o chat, sem fechar desenho: o card publico so escreve `link.label`. `VenueLink` guarda tipo, URL, `visible` e `position`, sem subtitulo. Ordem e olho hoje ficam na aba Redes e gravam no Salvar; a pagina publica nao edita. Link automatico so se oculta; link colado tem lixeira sem dialogo e sai da lista. Link oculto nao sai na pagina. Nas fotos, quem tem `EDIT_VENUE_SITE` ve a alca, arrasta e a ordem grava na hora; visitante nao ve a alca. A leitura publica dos links nao devolve `canReorder`.

## Problema atual

O botao da pagina de links nao tem a segunda linha. Quem quer mudar a ordem ou tirar um link da pagina precisa ir na aba Redes. Na pagina, ninguem arrasta nem remove.

## Objetivo da mudanca

Na pagina de links, cada botao visivel mostra titulo e subtitulo; quem edita o site daquele espaco reordena na propria pagina e, depois de confirmar a remocao, o link deixa de aparecer na pagina.

## Escopo inicial percebido

Subtitulo no card publico, arraste da ordem na propria pagina para quem ja edita as fotos, e remocao com confirmacao que omite o link da pagina. Toca `frontend` e `backend`.

## Itens incluidos neste request

- uma linha de subtitulo embaixo do titulo de cada botao visivel
- alca e arraste na propria pagina, no mesmo criterio das fotos da apresentacao
- a ordem arrastada grava na hora e continua depois de recarregar
- acao de remover no botao, so para quem ve a alca
- confirmacao com a pergunta "Tem certeza que quer remover?"; cancelar mantem o botao
- confirmar omite o link da pagina publica
- visitante e quem nao edita o site daquele espaco nao veem alca nem remover, e nao gravam ordem nem oculto

## Requisitos implicitos ja visiveis

- o criterio de quem edita e o mesmo das fotos: `EDIT_VENUE_SITE` naquele espaco, o equivalente a `canReorder`
- arrastar nao segue o link; o clique de quem visita continua abrindo o destino
- falha ao gravar devolve a ordem ou o botao anterior, como o arraste das fotos
- a aba Redes continua o lugar de ligar de novo um link omitido
- a lixeira da aba Redes, que tira o link colado da lista, permanece sem este dialogo
- icone, seta, titulo, logo e slogan do card atual permanecem
- a leitura publica segue sem dono, contrato, pagamento ou dado interno

## Casos de erro e borda ja percebidos

- um unico botao visivel: nao ha o que arrastar
- cancelar a confirmacao: o botao continua
- confirmar e a gravacao falhar: o botao volta
- link ja oculto: a pagina publica continua sem ele
- espaco inexistente: a pagina nao mostra dado de outra casa
- sessao de outro espaco: nao edita os links desta casa

## Dependencias

- a pagina `/espaco/{casa}/links` e a aba Redes ja existem, com ordem e `visible` gravados
- a apresentacao publica ja reordena fotos na propria pagina para quem tem Site naquele espaco

## Restricoes e cuidados

- nao reabrir o catalogo, a aba Redes nem o desenho de icone, seta e titulo
- nao criar permissao nova
- nao colocar editor de texto do subtitulo na pagina publica
- a rota de leitura continua publica e intencional; a gravacao exige o mesmo tipo de autorizacao das fotos
- nao ler nem versionar valores de `.env`
- a execucao futura e multi-repo e pode ser derivada com `tasking/task-request-repo-split-prompt.md`

## Perguntas em aberto

- Qual texto fica no subtitulo? O chat nao trouxe as frases. Premissa: frase curta fixa por tipo, no mesmo lugar do rotulo do catalogo, sem campo novo e sem edicao nesta entrega. A execucao usa uma linha neutra que diz o que o botao abre, e nao trata texto comercial como decisao fechada.
- Confirmar a remocao apaga a linha ou so esconde? Premissa: esconde (`visible` desligado). O link continua na aba Redes e o olho mostra de novo. Nao apaga a linha.
- Se a premissa do subtitulo virar texto livre, onde se escreve? Premissa desta entrega: nao se escreve. Se virar texto livre, o dono grava na aba Redes, a pagina so exibe, subtitulo vazio deixa so o titulo, e a spec passa a incluir coluna em `VenueLink` e migration.

## Prioridade sugerida

Media. A pagina de links ja esta no ar. O pedido completa o botao e permite ajustar ordem e presenca sem sair dela.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: a pagina publica passa a gravar ordem e oculto para quem edita o site, no mesmo tipo de fluxo das fotos, e o subtitulo entra no card. Toca `frontend` e `backend` e se separa em subtitulo, arraste e remocao com confirmacao.

## Sugestao de slug da spec

- `framework_core/specs/subtitulo-ordem-e-remocao-na-pagina-de-links/`

## Sugestao de nome do arquivo

- `subtitulo-ordem-e-remocao-links-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-21-subtitulo-ordem-e-remocao-na-pagina-de-links/`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `necessaria`
- promocao: usar `C:\Users\AR756\Desktop\igor\eventhub\eventhub-docs\framework_global\framework-base\prompts\spec-driven\spec-feature-bootstrap-prompt.md` a partir deste request
- split posterior: `framework_global/framework-base/prompts/tasking/task-request-repo-split-prompt.md`
