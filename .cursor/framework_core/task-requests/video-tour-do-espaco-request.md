# Solicitacao da Tarefa

## Nome sugerido da tarefa

Salvar o video do tour do espaco e mostrar na proposta publica

## Resumo da solicitacao

Nas configuracoes do espaco da para salvar um link de video do tour. Se o link estiver salvo, a pagina publica do orcamento mostra esse video entre "Sua experiencia inclui" e o bloco do investimento, em autoplay, repetindo sem fim e sem controle para quem assiste.

## Context Pack

- frente principal: produto (backend e frontend)
- superficie sensivel: sim — a pagina publica do orcamento, sem login, passa a reproduzir midia a partir de um link salvo
- risco principal: o link vazar como pagina ou player com controle, ou o video aparecer fora do lugar e com som
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: upload do arquivo de video; video no site, no e-mail, no contrato ou no painel; alterar servicos, valores, visita, fotos ou rodape da proposta
- prova minima desta execucao: em Configuracoes do espaco, salvar um link de video, abrir `/proposal/:id/view` e ver o video entre a experiencia e o investimento, tocando sozinho, em loop e sem controles; apagar o link, recarregar a pagina publica e o bloco sumir
- criterio de escalada: a spec e o caminho; voltar para `normal` somente se o pedido for reduzido a um campo que ja existe na apresentacao, sem coluna nova
- nivel de autonomia: `L2`
- camadas transversais: `security`, `database`, `design`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `database`, `node`, `react`, `design`, `security`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/database/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_global/framework-libs/security/index.md`
- caminhos candidatos: formulario de configuracoes do espaco, no bloco das URLs; pagina publica do orcamento, entre "Sua experiencia inclui" e "Seu investimento"; gravacao do espaco e pacote publico da apresentacao
- palavras-chave ou simbolos de busca: `VenueSettings`, `ProposalView`, `Sua experiência inclui`, `Seu investimento`, `instagramUrl`, `getPresentation`
- testes provaveis: `npx prisma validate` no backend; salvar, ver e limpar o link na pagina publica
- nao ler por padrao: `topics/`, `specs/`, site da organizacao, e-mail da proposta e contrato

## Contexto informado na entrada

Pedido em chat, com a pagina publica do orcamento aberta: nas configuracoes do espaco, salvar mais um dado, o link de um video de tour. Com o link salvo, entre o bloco do que a experiencia inclui e o container do valor, o video entra ja em autoplay, com replay infinito e sem nenhum controle para o usuario.

## Problema atual

O espaco nao tem onde guardar um video de tour, e a pagina publica do orcamento nao mostra esse video entre a experiencia e o investimento.

## Objetivo da mudanca

Com um link de tour salvo nas configuracoes do espaco, a pagina publica do orcamento mostra esse video entre "Sua experiencia inclui" e "Seu investimento", tocando sozinho, em repeticao continua e sem controle para quem assiste.

## Escopo inicial percebido

Um campo novo no espaco, gravado nas configuracoes que ja existem, e um bloco novo na pagina publica que ja existe. O link vazio nao mostra video.

## Itens incluidos neste request

- campo de link do tour nas configuracoes do espaco
- persistir o link no espaco e devolve-lo na apresentacao publica do orcamento
- video na pagina publica somente quando o link estiver salvo
- posicao entre "Sua experiencia inclui" e o bloco "Seu investimento"
- autoplay, repeticao continua e ausencia de controles

## Requisitos implicitos ja visiveis

- a pagina continua publica, no mesmo link
- quem ja edita as configuracoes do espaco e quem salva o link; a permissao do painel nao substitui a autorizacao no backend
- sem link, o bloco nao aparece, mesmo que a secao de experiencia tambem nao apareca
- a migration de producao e aditiva
- o video comeca mudo: o navegador nao libera autoplay com som

## Casos de erro e borda ja percebidos

- link vazio ou apagado nao pode deixar um player quebrado
- link que nao e video nao pode virar pagina embutida arbitratria
- arquivo direto e link de YouTube nao se comportam do mesmo jeito; os dois precisam cumprir autoplay, loop e sem controle, dentro do que cada um permite
- a secao "Sua experiencia inclui" pode nao existir; o video continua acima do investimento
- som ligado impede o autoplay

## Dependencias

- configuracoes do espaco e pagina publica da apresentacao ja existem
- mudanca multi-repo: o request pode ser derivado depois com `tasking/task-request-repo-split-prompt.md`, de preferencia depois da spec

## Restricoes e cuidados

- nao ler nem versionar valores de `.env`
- nao criar rota publica nova; o video entra na apresentacao que ja e publica
- nao aceitar o link como pagina solta para o visitante interagir
- o player nao oferece play, pause, volume nem barra de progresso

## Perguntas em aberto

- O link e arquivo direto, YouTube, ou os dois? Premissa: os dois; arquivo direto toca no player nativo; YouTube vira embed mudo, em loop e sem controles.
- O video pode ter som? Premissa: nao; comeca mudo para o autoplay valer.
- Onde fica se nao houver servicos na experiencia? Premissa: ainda acima do bloco de investimento.
- Apagar o campo esconde o video? Premissa: sim.

## Prioridade sugerida

Media. E complemento da proposta publica, sem correcao de fluxo que ja esteja quebrado.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: o pedido cria um dado novo do espaco, toca `backend` e `frontend`, inclui migration e o contrato da apresentacao publica, e se quebra em gravar o link, expo-lo na proposta e montar o player. Nao e seguro executar como uma task isolada.

## Sugestao de slug da spec

- `framework_core/specs/video-tour-do-espaco/`

## Sugestao de nome do arquivo

- `video-tour-do-espaco-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-04-video-tour-do-espaco/`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `necessaria`
