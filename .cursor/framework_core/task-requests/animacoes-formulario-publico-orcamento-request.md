# Solicitacao da Tarefa

## Nome sugerido da tarefa

Animar a entrada do formulario publico de orcamento

## Resumo da solicitacao

A tela publica de criar orcamento (`/venue/:id/form`) ganha a mesma entrada curta do link publico: o logo surge e o card do formulario sobe uma vez ao aparecer. O deslize entre os tres passos permanece. O rodape fica parado.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: a entrada esconder o formulario, brigar com o deslize dos passos ou atrasar o clique em Continuar
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: animar o link `/proposal/:id/view` de novo, o rodape, o painel, campos, textos, cores, schema e API; capa, galeria, mapa e zoom de foto nao existem nesta tela
- prova minima desta execucao: abrir `/venue/:id/form` e ver o logo surgir (fade e escala) e o card subir 16 px, uma vez, sem mudar o lugar que ocupam; clicar em Continuar e ver so o deslize horizontal dos passos, sem o logo animar de novo; o rodape parado; Continuar clicavel durante a entrada; com `prefers-reduced-motion`, a pagina aparece inteira e parada
- criterio de escalada: promover para `normal` se a entrada precisar de um sistema de motion compartilhado com o link; `spec` nao se aplica
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/ProposalView.tsx` no logo e no card (`animate-logo-in`, `animate-rise-in`)
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/design/rules/08_motion_and_microinteractions.md`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_core/task-requests/animacoes-proposta-publica-request.md#Itens incluidos neste request`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/ProposalForm.tsx`; `eventhub-vista-dashboard/src/components/proposal/forms/PublicBudgetFormSteps.tsx`; keyframes `logo-in` e `rise-in` em `eventhub-vista-dashboard/tailwind.config.ts`
- palavras-chave ou simbolos de busca: `ProposalForm`, `PublicBudgetStepStage`, `animate-logo-in`, `animate-rise-in`, `motion-reduce`, `prefers-reduced-motion`
- testes provaveis: abrir `/venue/:id/form` no desktop e no celular; passar os tres passos; voltar um passo; simular reducao de movimento; conferir que o link `/proposal/:id/view` continua com a entrada que ja tem
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, com a tela publica de criar orcamento da AR756 aberta no primeiro passo (informacoes pessoais, Continuar, rodape com redes). A pergunta foi se essa pagina tem as animacoes da pagina de links. Nao tem. A referencia e a entrada ja entregue em `/proposal/:id/view`.

## Problema atual

Quem abre `/venue/:id/form` ve logo, indicador de passos e card aparecerem juntos e parados. O link do mesmo espaco ja tem entrada curta. O formulario so se move ao trocar de passo, no deslize horizontal de 500 ms, e no pulso do skeleton enquanto carrega.

## Objetivo da mudanca

Em `/venue/:id/form`, logo e card do formulario entram uma vez, no mesmo ritmo do link publico; os passos seguintes continuam no deslize que ja existe; o rodape nao anima.

## Escopo inicial percebido

Ajuste visual de uma pagina que ja existe. Campos, passos, marca, cores e rodape permanecem. O movimento reusa os keyframes `logo-in` e `rise-in` do link, sem biblioteca nova.

## Itens incluidos neste request

- logo: fade e escala de 0.94 para 1, em 650 ms, igual ao link; o fallback com o nome EventHub recebe a mesma entrada
- card do formulario: fade e subida de 16 px, em 500 ms, igual ao card da proposta no link
- logo e card comecam juntos, cada um na propria duracao
- o deslize horizontal de 500 ms entre os tres passos permanece e nao repete a entrada do logo nem do card
- rodape sem animacao de entrada
- botoes de acao do formulario (Voltar, Continuar e envio): hover em 200 ms, com elevacao pequena e resposta ao clique
- `prefers-reduced-motion` desliga o movimento decorativo, inclusive o deslize dos passos, e deixa o conteudo visivel
- sem JavaScript, o conteudo continua visivel
- a pagina segue utilizavel enquanto a entrada acontece, inclusive Continuar

## Requisitos implicitos ja visiveis

- a mudanca vale para todo formulario publico de orcamento; AR756 e o exemplo, nao um estilo so daquele espaco
- vale para o formulario por dia e para o formulario por pessoa
- animar so `transform` e `opacity`, para nao empurrar o layout
- a entrada do logo e do card nao se repete ao trocar de passo nem ao voltar
- o skeleton de carregamento continua como esta; a entrada so comeca quando a pagina pronta substitui o skeleton
- o hover das redes do rodape permanece como esta

## Casos de erro e borda ja percebidos

- espaco sem logo: o fallback EventHub recebe a entrada do logo
- `prefers-reduced-motion` ligado: nada se move, o passo nao desliza e nada fica escondido
- JavaScript nao aplica a classe de espera: o conteudo nao nasce invisivel
- troca de passo no meio da entrada: o deslize dos passos segue e o logo nao reinicia
- formulario por dia e por pessoa: os dois recebem a mesma entrada

## Dependencias

- a entrada do link ja existe em `ProposalView.tsx` e nos keyframes `logo-in` e `rise-in`
- o formulario publico, a marca do espaco e os tres passos ja existem em `ProposalForm.tsx` e `PublicBudgetFormSteps.tsx`
- Tailwind e `tailwindcss-animate` ja estao no frontend; nao instalar pacote

## Restricoes e cuidados

- nao instalar biblioteca de animacao
- nao animar o rodape
- nao trazer capa, galeria, mapa nem zoom de foto para esta tela
- nao usar bounce, parallax, loop ou atraso que segure o clique
- nao alterar texto, campo, passo, cor, link nem a rota publica
- nao esconder conteudo como estado inicial no HTML; a espera da entrada so vale depois que o script confirma que pode animar
- respeitar `prefers-reduced-motion`
- manter a pagina utilizavel no celular

## Perguntas em aberto

- O indicador de passos anima junto do card ou fica parado? Premissa: fica dentro do card e sobe com ele; nao tem entrada propria.
- Cada passo repete o rise do card? Premissa: nao; so a primeira aparicao da pagina. Continuar e Voltar mantem o deslize horizontal.
- O hover de 200 ms vale para as redes do rodape? Premissa: nao; elas ficam como estao. Vale para Voltar, Continuar e o botao de envio.
- O card espera o logo terminar? Premissa: nao; logo e card comecam juntos.

## Prioridade sugerida

Media. Alinha a peca que o cliente preenche com a entrada que o link ja tem, sem corrigir um fluxo quebrado.

## Faixa sugerida para task workflow

- `A` — uma pagina, um repo, sem contrato nem schema
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: polimento visual do formulario publico que ja existe; reusa a entrada do link e nao abre jornada, contrato nem migration

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `animacoes-formulario-publico-orcamento-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar entrega`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- status: executado em 2026-11-04; review de entrega ainda nao rodou
- derivacao repo-local: `nao se aplica`
