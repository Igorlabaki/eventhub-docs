# Board — EventHub

Visao unica dos artefatos do framework. O backlog historico continua em `docs/estado/integracao/TODO_MASTER.md` ate cada item ser selecionado e convertido por `fw:intake` ou `fw:spec`; nao foram criadas specs retroativas.

## Roadmaps ativos

| Roadmap | Fase atual | Status | Proximo passo |
|---|---|---|---|
| [Evolucao tecnica do EventHub](roadmaps/eventhub-evolucao-tecnica.md) | Fase 1 — seguranca e contratos basicos | descoberta | priorizar uma iniciativa e abrir `fw:spec` |

## Em execucao

| Artefato | Tipo | Origem | Proximo passo |
|---|---|---|---|
| [Assinar o contrato da proposta no DocuSign](specs/2026-11-05-assinatura-contrato-docusign/00-overview.md) | spec | [task-request](task-requests/assinatura-contrato-docusign-request.md) | `T-01` a `T-03` no codigo; vitest 16+5; migration nao aplicada; browser e Connect real pendentes |
| [Foto ou video e descricao na caracteristica](specs/2026-11-05-foto-video-descricao-caracteristica/00-overview.md) | spec | [task-request](task-requests/foto-video-descricao-caracteristica-request.md) | schema no `main` (deploy request 43); falta gravar uma caracteristica no browser |
| [Graficos da visao geral no estilo dos relatorios](task-requests/graficos-visao-geral-estilo-relatorios-request.md) | task-request | chat: desempenho mensal e anual no estilo de financeiro, eventos e orcamentos | revisar entrega (`fw:review`) |
| [Animar os toggles dos relatorios](task-requests/animacao-toggles-relatorios-request.md) | task-request | chat: pilulas e abas dos relatorios sem movimento | revisar entrega (`fw:review`) |
| [Financeiro no formato de orcamentos e evento](task-requests/financeiro-formato-orcamentos-request.md) | task-request | chat: numeros da referencia na aba Financeiro, no desenho de Orcamentos e Evento | revisar entrega (`fw:review`) |
| [Botao Anual na visao geral para o relatorio anual](task-requests/botao-todos-visao-geral-request.md) | task-request | chat: voltar a opcao do ano inteiro na visao geral | revisar entrega (`fw:review`) |
| [Containers da visao geral iguais aos de orcamentos](task-requests/containers-visao-geral-igual-orcamentos-request.md) | task-request | chat: visao geral num bloco unico; filtro e KPIs como em orcamentos | revisar entrega (`fw:review`) |
| [Carregar so os numeros dos KPIs ao trocar mes ou ano](task-requests/loading-kpis-troca-mes-ano-request.md) | task-request | chat: troca de mes ou ano na visao geral coloca a pagina inteira em loading | revisar entrega (`fw:review`) |
| [Mover o filtro de dia e o botao de novo orcamento](task-requests/botao-novo-orcamento-no-lugar-do-dia-request.md) | task-request | chat: dia a direita do status; novo orcamento no lugar do dia | revisar entrega (`fw:review`) |
| [Seletor de ano e mes da visao geral igual ao de orcamentos](task-requests/seletor-ano-mes-visao-geral-request.md) | task-request | chat: menus nativos de mes e ano na visao geral | revisar entrega (`fw:review`) |
| [Segurar o menu da sidebar na troca de nivel](task-requests/menu-sidebar-troca-de-nivel-request.md) | task-request | chat: de espaco para orcamento a sidebar fica em branco | revisar entrega (`fw:review`) |
| [Tirar titulo e subtitulo da visao geral do espaco](task-requests/tirar-titulo-visao-geral-request.md) | task-request | chat: titulo e subtitulo acima dos indicadores do espaco AR756 | revisar entrega (`fw:review`) |
| [Loading so na area que a sidebar abre](task-requests/loading-so-na-area-carregada-request.md) | task-request | chat: troca de item da sidebar coloca a tela inteira em loading | revisar entrega (`fw:review`) |
| [Painel de metas e precos igual a referencia](specs/2026-11-05-painel-metas-precos/00-overview.md) | spec | [task-request](task-requests/painel-metas-precos-referencia-request.md) | `T-01` e `T-02` no codigo; vitest 19; browser parado no login |
| [KPIs, filtros, paginas e leitura na lista de notificacoes](specs/2026-11-05-lista-notificacoes-painel/00-overview.md) | spec | [task-request](task-requests/lista-notificacoes-painel-request.md) | `T-01` a `T-04` escritas; vitest 16+2; browser nao exercitado |
| [KPIs, filtros e paginas de dez na lista de contatos](specs/2026-11-05-kpis-filtros-lista-contatos/00-overview.md) | spec | [task-request](task-requests/kpis-filtros-lista-contatos-request.md) | `T-01` e `T-02` escritas; vitest 7; browser parado no login |
| [Logo, descricao e card vertical do parceiro](specs/2026-11-05-logo-descricao-card-parceiro/00-overview.md) | spec | [task-request](task-requests/logo-descricao-card-parceiro-request.md) | schema no `main` (deploy request 42); falta gravar um card real no browser |
| [Variacao anual dos KPIs na lista de orcamentos](specs/2026-11-05-variacao-anual-kpis-orcamentos/00-overview.md) | spec | [task-request](task-requests/variacao-anual-kpis-painel-orcamentos-request.md) | `T-01` e `T-02` escritas; vitest 15+3; browser parado no login |
| [Filtros de status e valor na lista de orcamentos](specs/2026-11-05-filtros-status-valor-orcamentos/00-overview.md) | spec | [task-request](task-requests/filtros-status-valor-painel-orcamentos-request.md) | `T-01` e `T-02` escritas; vitest 12; browser parado no login |
| [Lista paginada de orcamentos no painel](specs/2026-11-05-lista-painel-orcamentos/00-overview.md) | spec | [task-request](task-requests/lista-painel-orcamentos-request.md) | indice no `main` (deploy request 40); falta a prova no browser |
| [Deixar as secoes da sidebar sempre abertas](task-requests/sidebar-secoes-sempre-abertas-request.md) | task-request | chat: sanfona do orcamento; nome do cliente igual ao rotulo da secao | revisar entrega (`fw:review`) |
| [Organizar a sidebar do painel por secoes](task-requests/organizar-sidebar-por-secoes-request.md) | task-request | chat: sidebar do espaco AR756 plana; grupos para espaco, orcamento e organizacao | revisar entrega (`fw:review`) |
| [Abrir o link universal do orcamento na sidebar](task-requests/link-universal-orcamento-request.md) | task-request | chat: item na sidebar com a pagina publica do evento, resumo, contagem e botoes das listas | revisar entrega (`fw:review`) |
| [Esconder o preco do servico no orcamento e abrir foto e descricao](task-requests/preco-e-detalhe-servico-orcamento-request.md) | task-request | chat: formulario publico sem preco; `?` abre foto e descricao do servico | revisar entrega (`fw:review`) |
| [Mostrar a descricao do espaco abaixo do logo na proposta publica](task-requests/descricao-abaixo-do-logo-request.md) | task-request | chat: embaixo do logo, tambem no formulario publico de gerar orcamento | revisar entrega (`fw:review`) |
| [Agendar visita no card do espaco da proposta publica](task-requests/agendar-visita-proposta-publica-request.md) | task-request | chat: botao de visita no card Conheça nosso espaço | revisar entrega (`fw:review`) |
| [Aplicar o copy comercial na proposta publica](task-requests/copy-proposta-publica-request.md) | task-request | chat: copy do evento, investimento e locacao exclusiva | revisar entrega (`fw:review`) |
| [Aplicar adicionais e descontos na edicao do orcamento](task-requests/edicao-orcamento-adicionais-descontos-request.md) | task-request | chat: editar orcamento sem adicional nem desconto | revisar entrega (`fw:review`) |
| [Precos minimos por periodo](specs/2026-11-02-precos-minimos-por-periodo/00-overview.md) | spec | [task-request](task-requests/precos-minimos-por-periodo-request.md) | codigo das 4 tasks pronto; falta provar a aba no browser |
| [Regras do espaco](specs/2026-11-02-regras-do-espaco/00-overview.md) | spec | [task-request](task-requests/regras-do-espaco-request.md) | codigo das 4 tasks pronto; falta provar a tela no painel |
| [E-mail opcional na criacao do orcamento](specs/2026-11-02-email-opcional-orcamento/00-overview.md) | spec | [task-request](task-requests/email-opcional-orcamento-request.md) | codigo das 4 tasks pronto; falta provar painel e links |
| [Caracteristicas do espaco](specs/2026-11-02-caracteristicas-do-espaco/00-overview.md) | spec | [task-request](task-requests/caracteristicas-do-espaco-request.md) | codigo das 4 tasks pronto; falta provar a tela no painel |
| [Apresentacao publica do orcamento](specs/2026-11-04-apresentacao-publica-orcamento/00-overview.md) | spec | [task-request](task-requests/apresentacao-publica-orcamento-request.md) | colunas no main; papel das cores corrigido na pagina publica |
| [Corrigir o papel das cores na proposta publica](task-requests/papeis-cores-proposta-request.md) | task-request | chat: primaria no fundo, secundaria nos cards, texto na fonte | revisar entrega (`fw:review`) |
| [Levar a descricao ao fim da proposta e abrir o mapa do espaco](task-requests/descricao-e-mapa-proposta-publica-request.md) | task-request | chat: descricao por ultimo, icones sem o nome, mapa do espaco | revisar entrega (`fw:review`) |
| [Personalizar o rodape da pagina publica do orcamento](task-requests/rodape-proposta-publica-request.md) | task-request | chat: rodape do orcamento com marca, cor e redes do espaco | revisar entrega (`fw:review`) |
| [Dar cara de proposta comercial a pagina publica do orcamento](task-requests/tipografia-proposta-publica-request.md) | task-request | chat: tipografia Manrope na proposta publica | revisar entrega (`fw:review`) |
| [Reordenar as fotos da proposta publica arrastando](specs/2026-11-04-reordenar-fotos-proposta-publica/00-overview.md) | spec | [task-request](task-requests/reordenar-fotos-proposta-publica-request.md) | codigo das 3 tasks escrito; falta o arraste do dono no browser |
| [Abrir carrossel infinito nas fotos da proposta publica](task-requests/carrossel-fotos-proposta-publica-request.md) | task-request | chat: fotos de A casa abrem carrossel infinito | revisar entrega (`fw:review`) |
| [Abrir o detalhe do orcamento em nova aba e resetar o formulario](task-requests/detalhe-orcamento-em-nova-aba-request.md) | task-request | chat: criar orcamento abre o detalhe na mesma aba | revisar entrega (`fw:review`) |
| [Trocar as redes do rodape pelo mapa do espaco](task-requests/mapa-no-rodape-proposta-publica-request.md) | task-request | chat: rodape sem redes, com mapa do espaco | revisar entrega (`fw:review`) |
| [Trocar a tela de carregamento do link publico do orcamento pela marca do espaco](task-requests/carregamento-proposta-publica-request.md) | task-request | chat: carregamento do link com logo e cores do espaco | revisar entrega (`fw:review`) |
| [Animar a entrada da pagina publica do orcamento](task-requests/animacoes-proposta-publica-request.md) | task-request | chat: animacoes discretas na proposta AR756 | revisar entrega (`fw:review`) |
| [Video do tour na proposta publica](specs/2026-11-04-video-tour-do-espaco/00-overview.md) | spec | [task-request](task-requests/video-tour-do-espaco-request.md) | coluna no main (deploy request 36); falta provar o video na tela |
| [Indicacoes publicas do orcamento](specs/2026-11-05-indicacoes-publicas-do-orcamento/00-overview.md) | spec | [task-request](task-requests/indicacoes-publicas-do-orcamento-request.md) | `T-01` a `T-05` escritas; tabela no main (deploy request 39); falta o fluxo com orcamento real no browser |
| [Trocar a foto do link de orcamento](specs/2026-11-04-trocar-foto-proposta-publica/00-overview.md) | spec | [task-request](task-requests/trocar-foto-proposta-publica-request.md) | codigo das 3 tasks escrito; coluna no main; falta a troca do dono no browser |
| [Ligar o som do tour e coloca-lo no lugar da capa na proposta publica](task-requests/som-e-posicao-tour-proposta-publica-request.md) | task-request | chat: tour sem som; video no lugar da capa, capa no lugar do grid, grid no lugar do video | revisar entrega (`fw:review`) |
| [Mostrar nome e descricao do espaco na aba do painel](task-requests/titulo-aba-espaco-request.md) | task-request | chat: aba de `/venue/:id` com titulo generico do EventHub | revisar entrega (`fw:review`) |
| [Recalcular o orcamento no link publico](specs/2026-11-04-recalcular-orcamento-proposta-publica/00-overview.md) | spec | [task-request](task-requests/recalcular-orcamento-proposta-publica-request.md) | codigo das 3 tasks escrito; botao no alto a direita; falta provar a gravacao no browser |
| [Mostrar nome e descricao do espaco na aba do link publico do orcamento](task-requests/titulo-aba-link-orcamento-request.md) | task-request | chat: aba de `/proposal/:id/view` ainda com titulo EventHub | revisar entrega (`fw:review`) |
| [Mover Alterar orcamento para baixo do WhatsApp no celular](task-requests/botao-alterar-orcamento-mobile-request.md) | task-request | chat: botao Alterar orcamento abaixo de Conversar com nossa equipe | revisar entrega (`fw:review`) |
| [Segurar a pagina publica do orcamento ate a midia baixar](task-requests/skeleton-proposta-publica-request.md) | task-request | chat: skeleton do link ate tudo baixar, depois as animacoes | revisar entrega (`fw:review`) |
| [Pintar os cards do skeleton com a cor secundaria](task-requests/skeleton-cor-secundaria-request.md) | task-request | chat: skeletons do link e da criacao de orcamento ficam brancos | revisar entrega (`fw:review`) |
| [Aplicar a marca do espaco na tela publica de criar orcamento](task-requests/marca-espaco-formulario-publico-request.md) | task-request | chat: formulario publico com cores, logo, aba, rodape e skeleton do espaco | revisar entrega (`fw:review`) |
| [Dividir o formulario publico de orcamento em tres passos](task-requests/passos-formulario-publico-orcamento-request.md) | task-request | chat: formulario AR756 longo demais; tres passos | revisar entrega (`fw:review`) |
| [Remover a estrutura de Firebase](task-requests/remover-firebase-request.md) | task-request | chat: erro de `project_id` ao enviar orcamento publico; pedido de remover o Firebase | revisar entrega (`fw:review`) |
| [Animar a entrada do formulario publico de orcamento](task-requests/animacoes-formulario-publico-orcamento-request.md) | task-request | chat: formulario publico sem as animacoes do link | revisar entrega (`fw:review`) |
| [Preco, foto e descricao do servico](specs/2026-11-04-preco-foto-descricao-servico/00-overview.md) | spec | [task-request](task-requests/preco-foto-descricao-servico-request.md) | codigo de `T-01` a `T-05`; 27+4 testes verdes; schema ainda fora do `main`; falta o fluxo no browser |
| [Adicionar ou tirar servico no link publico](specs/2026-11-04-adicionar-servico-proposta-publica/00-overview.md) | spec | [task-request](task-requests/adicionar-servico-proposta-publica-request.md) | codigo das 3 tasks escrito; unitarios verdes; browser bloqueado pelo banco local |
| [Pedir quantas horas o cliente quer no servico por hora](specs/2026-11-04-horas-servico-por-hora/00-overview.md) | spec | [task-request](task-requests/horas-servico-por-hora-request.md) | codigo de `T-01` a `T-06`; unitarios verdes; falta o campo no browser |
| [Colocar o numero do servico a direita da linha](task-requests/numero-servico-a-direita-request.md) | task-request | chat: horas e quantidade do servico no fim da linha, do outro lado do card | revisar entrega (`fw:review`) |
| [Ajustar titulo, total por hora e ordem no modal de servicos da proposta publica](task-requests/modal-alterar-servicos-proposta-publica-request.md) | task-request | chat: modal Adicionar servico com titulo, preco da hora e ordem fora do padrao | revisar entrega (`fw:review`) |
| [Abrir foto e descricao do servico por um icone na proposta publica](task-requests/detalhe-servico-proposta-publica-request.md) | task-request | chat: lista Sua experiência inclui sem foto nem descricao; `?` abre o modal | revisar entrega (`fw:review`) |
| [Usar no link publico o mesmo modal de servico da criacao do orcamento](task-requests/modal-servico-link-igual-criacao-request.md) | task-request | chat: modal do servico no link igual ao container da criacao; criacao e o modelo | revisar entrega (`fw:review`) |
| [Ordenar os servicos da proposta publica por tipo de custo](task-requests/ordenar-servicos-proposta-publica-request.md) | task-request | chat: nos dois cards, custo fixo, depois por hora, depois por pessoa | revisar entrega (`fw:review`) |
| [Mostrar as horas do servico e trocar o botao para Alterar servicos](task-requests/horas-embaixo-servico-proposta-publica-request.md) | task-request | chat: horas embaixo do servico por hora; botao Alterar servicos | revisar entrega (`fw:review`) |
| [Levar a marca do espaco as listas publicas](task-requests/marca-espaco-listas-publicas-request.md) | task-request | chat: cores, fonte, animacao, logo, rodape e a diagramacao da proposta em convidados, colaboradores e programacao | revisar entrega (`fw:review`) |
| [Importar planilha nas listas de convidados e colaboradores](task-requests/importar-planilha-listas-publicas-request.md) | task-request | chat: cliente envia Excel com nomes; a tela le e grava a lista | revisar entrega (`fw:review`) |
| [Levar a marca e a diagramacao as paginas publicas de contrato](task-requests/marca-diagramacao-contrato-publico-request.md) | task-request | chat: `/person-contract` e `/b2b-contract` fora da marca e da diagramacao da proposta | revisar entrega (`fw:review`) |
| [Mostrar um obrigado ao salvar o contrato publico](task-requests/feedback-salvar-contrato-publico-request.md) | task-request | chat: Salvar Alteracoes nas paginas de contrato nao mostra que deu certo | revisar entrega (`fw:review`) |
| [Liberar colaboradores quando a lista de convidados esta cheia](task-requests/colaborador-sem-limite-de-convidados-request.md) | task-request | chat: link de colaboradores recusa pessoa nova quando a lista de convidados esta cheia | revisar entrega (`fw:review`) |
| [Lista de servicos ao criar e editar orcamento no painel](specs/2026-11-05-lista-servicos-painel-orcamento/00-overview.md) | spec | [task-request](task-requests/lista-servicos-painel-orcamento-request.md) | codigo das 3 tasks escrito; browser parado no login |
| [Abrir o link publico das regras do espaco](specs/2026-11-05-link-publico-regras-do-espaco/00-overview.md) | spec | [task-request](task-requests/link-publico-regras-do-espaco-request.md) | `T-01` a `T-03` escritas; vitest 6+13; pagina vazia e venue ausente no browser; falta o clique no destino Regras do espaço; o copiar do painel ficou na spec dos links |
| [Links do painel e formularios de cadastro](specs/2026-11-05-links-painel-e-formularios/00-overview.md) | spec | [lote](task-requests/2026-11-05-links-painel-e-formularios/README.md) | `T-01` a `T-03` escritas; vitest 26; browser parado no login |
| [Mostrar as regras publicas em sanfona, sem etiqueta](task-requests/sanfona-regras-publicas-request.md) | task-request | chat: pagina publica de regras parecida com a referencia, sem Proibido, Orientacao ou Permitido | revisar entrega (`fw:review`) |
| [Icones clicaveis no preview do card do parceiro](task-requests/icones-clicaveis-preview-parceiro-request.md) | task-request | chat: icones do preview abrem a URL digitada | revisar entrega (`fw:review`) |
| [Relatorios no formato da referencia](task-requests/relatorios-formato-referencia-request.md) | task-request | chat: tela /reports no formato da primeira imagem | revisar entrega (`fw:review`) |

## A executar

| Artefato | Tipo | Faixa | Origem | Proximo passo |
|---|---|---|---|---|
| (nenhum) | | | | |

## Em descoberta ou rascunho

| Artefato | Tipo | Perguntas em aberto |
|---|---|---|
| [Backlog legado e lacunas](topics/delivery-and-known-gaps.md) | inventario legado | prioridade atual, owners e itens resolvidos precisam de confirmacao |
| [Roadmap tecnico](roadmaps/eventhub-evolucao-tecnica.md) | roadmap | sequenciamento depende de prioridade de negocio e capacidade do time |

## Bloqueados

| Artefato | Bloqueado por | Desde |
|---|---|---|
| (nenhum) | | |

## Concluidos recentes

| Artefato | Tipo | Concluido em | Prova |
|---|---|---|---|
| [Desempenho mensal do mesmo mes em todos os anos](specs/2026-11-05-desempenho-mensal-mesmo-mes-nos-anos/00-overview.md) | spec | 2026-11-05 | `T-01` e `T-02`; vitest 5+5. Browser parado no login |
| [Categorizar o parceiro no cadastro e na pagina publica](specs/2026-11-05-categoria-parceiro/00-overview.md) | spec | 2026-11-05 | `T-01` a `T-05`; vitest 12+3; deploy request 41 no main; 41 fornecedores em OUTROS. Browser nao exercitado |
| [Limitar as horas do servico a duracao do evento](specs/2026-11-04-limite-horas-servico-duracao-evento/00-overview.md) | spec | 2026-11-04 | `T-01` e `T-02`; vitest 44+7. No browser, a frase apareceu no modal (7 num evento de 6) e na criacao publica (5 num evento de 4), sem gravar |
| Bootstrap do framework | documentacao | 2026-11-02 | core validado e repositorios mapeados |
| [Horario de evento sem fuso](specs/2026-11-02-horario-wall-clock/00-overview.md) | spec | 2026-11-02 | `T-01` a `T-08`; vitest 9+12 testes verdes. Tela e Google real nao exercitados |
| [Redirecionar para a visao geral ao criar orcamento](task-requests/redirecionar-visao-geral-orcamento-request.md) | task-request | 2026-11-02 | navegacao para `/proposal/:id` nos dois formularios do painel; eslint sem erro novo. Fluxo no browser nao exercitado |
