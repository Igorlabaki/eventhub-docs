# Solicitacao da Tarefa

## Nome sugerido da tarefa

Apresentacao e Regras selecionaveis na pagina interna do link tree, sem URL

## Resumo da solicitacao

Na pagina interna do link tree, Apresentacao e Regras ja aparecem para o dono marcar ou desmarcar. Sao links internos: nao ha campo de URL nem URL gravada. Marcado, o link entra na pagina publica; desmarcado, sai.

## Context Pack

- frente principal: produto (frontend); o write reusa o cadastro de link interno que ja existe
- superficie sensivel: sim — marcar passa a mostrar Apresentacao ou Regras na pagina publica de links; desmarcar tira
- risco principal: a linha sumir da pagina interna ao desmarcar, ou Instagram e site passarem a aparecer sem URL
- repos tocados: `frontend` (`eventhub-vista-dashboard/`); `backend` (`art56_server_v3/`) so se o write atual nao cobrir marcar sem linha previa
- fora de escopo operacional: cadastrar URL para Apresentacao ou Regras; colocar Fazer orcamento, WhatsApp, e-mail, mapa ou video do tour nessa lista fixa; arrastar, remover ou abrir cadastro na pagina interna; mudar a pagina publica alem de incluir ou omitir esses dois links
- prova minima desta execucao: em `/venue/{id}/link-tree`, Apresentacao e Regras aparecem desmarcadas numa casa que nunca as cadastrou; marcar Apresentacao sem colar URL faz o link sair em `/espaco/{nome}/links`; desmarcar tira da pagina publica e a linha continua na pagina interna, desmarcada; Instagram continua so depois do cadastro com URL
- criterio de escalada: se marcar exigir schema, coluna nova ou endpoint publico novo, parar e promover para spec
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Regras de ouro`
  - `.cursor/framework_core/project/frontend-map.md`
  - `.cursor/framework_core/topics/public-pages-and-branding.md#Demais paginas publicas`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/VenueLinkTree.tsx`; `eventhub-vista-dashboard/src/lib/venue-link.ts`; `eventhub-vista-dashboard/src/services/venue.service.ts`; `art56_server_v3/src/use-cases/venue/venue-links/use-case-venue-links.ts`
- palavras-chave ou simbolos de busca: `panelLinksFromHouse`, `setVenueLinkVisible`, `PRESENTATION`, `RULES`, `isPastedVenueLink`, `createVenueLink`
- testes provaveis: `eventhub-vista-dashboard/src/pages/VenueLinkTree.test.tsx`
- nao ler por padrao: `security`, `database`, `topics/` fora do trecho de paginas publicas, specs inteiras

## Contexto informado na entrada

Chat. O dono quer, na pagina interna do link tree, escolher se Apresentacao e Regras entram na pagina publica. Os dois sao paginas da propria casa, entao nao se cola nem se grava URL. Redes coladas, como Instagram e site, continuam dependendo do cadastro com URL.

Decisoes fechadas na conversa, que a execucao nao reabre: so Apresentacao e Regras entram nessa lista fixa; sem campo de URL; marcado aparece na pagina publica e desmarcado sai, mas a linha permanece na pagina interna.

## Problema atual

A pagina interna so lista o link que ja virou linha. Apresentacao e Regras nao aparecem para marcar enquanto ninguem as cadastrou. O clique de visibilidade numa rede que ainda nao existe falha.

## Objetivo da mudanca

Quem abre a pagina interna do link tree ve Apresentacao e Regras e escolhe, ali, se cada uma aparece na pagina publica, sem informar URL.

## Escopo inicial percebido

Ajuste da pagina interna do link tree e do clique que grava a escolha. A pagina publica de links so passa a mostrar o item quando ele estiver marcado. Toca `frontend` e, se o write atual nao aceitar a primeira marcacao, `backend`.

## Itens incluidos neste request

- Apresentacao e Regras sempre visiveis na pagina interna, mesmo sem cadastro previo
- marcar e desmarcar ali, sem URL
- marcado entra na pagina publica; desmarcado sai e continua na lista interna
- redes coladas seguem so na lista depois do cadastro com URL

## Requisitos implicitos ja visiveis

- quem ja edita o site continua sendo quem marca; nao criar permissao nova
- a pagina interna nao ganha botao de cadastrar, arraste nem remocao
- o destino publico continua o da apresentacao e o das regras da casa, resolvido na leitura
- desmarcar nao apaga a linha da pagina interna

## Casos de erro e borda ja percebidos

- casa que nunca cadastrou Apresentacao nem Regras: as duas linhas aparecem desmarcadas
- marcar de novo uma que ja estava marcada nao duplica
- desmarcar uma que ja estava na pagina publica tira o botao de la
- Instagram, site e as outras redes coladas nao aparecem so por existir no catalogo
- quem nao edita o site ve a lista e nao grava

## Dependencias

- a pagina interna do link tree ja existe
- a pagina publica de links ja existe
- apresentacao publica e regras publicas ja existem
- o cadastro de link interno sem URL ja existe para esses dois tipos

## Restricoes e cuidados

- nao gravar a URL de Apresentacao nem de Regras
- nao incluir Fazer orcamento, WhatsApp, e-mail, mapa, video do tour nem site da organizacao nesta lista fixa
- nao reabrir o catalogo de redes coladas nem o cadastro da aba Redes
- nao criar schema nem coluna
- a rota publica de leitura continua a que ja existe; o pacote nao leva dono, contrato, pagamento nem dado interno

## Perguntas em aberto

- Onde a linha nova fica na ordem da pagina publica. Default: no fim da lista, ate o dono mudar a ordem no lugar que ja ordena.
- Fazer orcamento no mesmo tratamento. Default: fora; so Apresentacao e Regras.

## Prioridade sugerida

Media. A pagina interna ja escolhe o que aparece; falta esses dois links internos estarem sempre a disposicao.

## Faixa sugerida para task workflow

- `B` = executar com `tasking/task-workflow-prompt-normal.md`

## Candidato a spec

- `nao`
- motivo: um comportamento numa pagina que ja existe, reusando o write de link interno; nao ha jornada nova, schema nem contrato novo

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `apresentacao-e-regras-no-link-tree-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `opcional`
- camadas transversais: `design`
