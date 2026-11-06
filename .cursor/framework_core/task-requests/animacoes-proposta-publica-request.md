# Solicitacao da Tarefa

## Nome sugerido da tarefa

Animar a entrada da pagina publica do orcamento

## Resumo da solicitacao

A pagina publica do orcamento ganha uma entrada curta: o logo aparece, a capa e o card da proposta entram no carregamento, e galeria, cards seguintes e mapa revelam uma unica vez ao entrar na tela. O rodape fica parado e o WhatsApp continua clicavel na hora.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: a entrada esconder conteudo, deslocar o layout ou atrasar o clique no WhatsApp
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: animar o rodape, painel, textos, fotos, links, calculo, cores, schema e API
- prova minima desta execucao: abrir `/proposal/:id/view` e ver o logo surgir, a capa encolher de leve para o tamanho final e o card da proposta subir 16 px, sem mudar o lugar que ocupam; rolar e ver galeria, cards de estrutura, servicos, investimento e mapa revelarem uma unica vez; o rodape parado; o WhatsApp clicavel durante a entrada; com `prefers-reduced-motion`, a pagina aparece inteira e parada
- criterio de escalada: promover para `normal` se o movimento precisar virar sistema de motion do painel inteiro; `spec` nao se aplica
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/ProposalView.tsx` no header, nos cards e na galeria
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/design/rules/08_motion_and_microinteractions.md`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `eventhub-vista-dashboard/tailwind.config.ts#keyframes`
- caminhos candidatos: pagina publica da proposta; keyframes `fade-in` e `slide-in` ja declarados no Tailwind
- palavras-chave ou simbolos de busca: `ProposalView`, `logoUrl`, `orderedImages`, `Agendar uma visita`, `Conversar com nossa equipe`
- testes provaveis: abrir a pagina no desktop e no celular; rolar ate galeria, cards e mapa; voltar e rolar de novo para confirmar que nao anima outra vez; simular reducao de movimento
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, com a proposta AR756 como exemplo da peca que o cliente recebe. A pagina esta estatica. A referencia e site de arquitetura e hotelaria: movimento curto, escuro e sem efeito de palco. A conversa anterior pedia o logo aparecendo e os blocos vindo de baixo; este pedido fecha duracoes, distancias e o que so anima ao entrar na tela.

## Problema atual

Quem abre o link ve logo, capa, card, fotos, investimento e mapa aparecerem juntos, sem hierarquia de entrada. A peca parece um formulario parado, nao uma proposta de um espaco.

## Objetivo da mudanca

Na pagina publica de qualquer orcamento, a entrada e curta e acontece uma so vez: logo, capa e card no carregamento; galeria, cards seguintes e mapa ao entrarem na tela; rodape parado; WhatsApp usavel o tempo todo.

## Escopo inicial percebido

Ajuste visual de uma pagina que ja existe, no mesmo link. Textos, imagens, dados, cores e acoes permanecem. O movimento usa React, Tailwind, keyframes ja existentes e `IntersectionObserver`, sem biblioteca nova.

## Itens incluidos neste request

- logo: fade e escala de 0.94 para 1, em 650 ms
- foto de capa: fade e escala de 1.03 para 1, em 900 ms, sem mudar o tamanho ocupado na pagina
- card da proposta: fade e subida de 16 px, em 500 ms
- galeria: a grade inteira entra uma vez, com fade, quando fica visivel
- cards de estrutura, servicos e investimento: fade e subida de 12 a 16 px, uma vez, ao entrarem na tela
- mapa: a mesma revelacao, uma vez, ao entrar na tela
- rodape sem animacao de entrada
- botoes de acao: hover em 200 ms, com elevacao pequena e resposta ao clique
- fotos: hover com zoom ate 1.025, so em dispositivo que tem hover
- `prefers-reduced-motion` desliga o movimento decorativo e deixa o conteudo visivel
- sem `IntersectionObserver` ou sem JavaScript, o conteudo continua visivel
- a pagina segue utilizavel enquanto a entrada acontece, inclusive o WhatsApp

## Requisitos implicitos ja visiveis

- a mudanca vale para toda pagina publica de orcamento; AR756 e o exemplo, nao um estilo so daquele registro
- bloco que o orcamento nao tem (galeria, estrutura, servicos, WhatsApp) simplesmente nao entra
- animar so `transform` e `opacity`, para nao empurrar o layout
- a revelacao por scroll nao se repete
- o arraste das fotos, o carrossel e os links continuam iguais
- o botao de WhatsApp nao tem entrada propria; ele aparece junto do card e ja pode ser clicado
- no celular, o hover das fotos nao dispara no toque

## Casos de erro e borda ja percebidos

- orcamento sem capa, galeria, estrutura ou servicos: os blocos que existem animam; os ausentes nao deixam buraco
- espaco sem logo: o fallback com o nome EventHub recebe a mesma entrada do logo
- `prefers-reduced-motion` ligado: nada se move e nada fica escondido
- navegador sem `IntersectionObserver`: galeria, cards e mapa aparecem parados, ja visiveis
- JavaScript nao aplica a classe de espera: o conteudo nao nasce invisivel
- foto de capa com escala inicial 1.03: o recorte segura o excesso e a altura do bloco nao muda
- dono arrastando fotos: o zoom de hover nao impede o arraste nem o clique que abre o carrossel
- card de investimento ainda fora da tela: o WhatsApp nao fica preso atras de uma animacao depois que o card entra

## Dependencias

- a pagina publica da apresentacao ja existe em `ProposalView.tsx`
- Tailwind e `tailwindcss-animate` ja estao no frontend; nao instalar pacote
- keyframes `fade-in` e `slide-in` ja existem em `tailwind.config.ts`; duracao e distancia novas podem completar esse tema, sem biblioteca

## Restricoes e cuidados

- nao instalar biblioteca de animacao
- nao animar o rodape
- nao usar bounce, parallax, loop ou atraso que segure o clique
- nao alterar texto, imagem, dado, link, cor, calculo nem a rota publica
- nao esconder conteudo como estado inicial no HTML; a espera da revelacao so vale depois que o script confirma que pode animar
- respeitar `prefers-reduced-motion`
- manter a pagina utilizavel no celular

## Perguntas em aberto

- A galeria sobe quantos pixels? Premissa: fade com subida de 16 px, no mesmo ritmo de 500 ms do card da proposta, a grade como um unico bloco.
- Os cards de estrutura, servicos, investimento e o mapa usam 12 ou 16 px? Premissa: 16 px e 500 ms, iguais ao card da proposta.
- O zoom de 1.025 vale para a capa e para a grade? Premissa: sim, so onde existe hover real, com o excesso cortado para o layout nao mudar.
- Quais botoes recebem o hover de 200 ms? Premissa: os de acao do miolo (agendar visita e WhatsApp); o rodape nao ganha movimento novo.
- O card da proposta espera a capa terminar? Premissa: nao; logo, capa e card comecam juntos, cada um na propria duracao, para a pagina nao ficar parada.

## Prioridade sugerida

Media. Melhora a peca que o cliente recebe, sem corrigir um fluxo quebrado.

## Faixa sugerida para task workflow

- `A` — uma pagina, um repo, sem contrato nem schema
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: polimento visual da pagina publica que ja existe na spec `apresentacao-publica-orcamento`; nao abre jornada, contrato nem migration

## Sugestao de slug da spec

- nao se aplica; permanece em `framework_core/specs/2026-11-04-apresentacao-publica-orcamento/`

## Sugestao de nome do arquivo

- `animacoes-proposta-publica-request.md`

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
