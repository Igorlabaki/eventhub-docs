# Spec — Card da casa na apresentacao publica

## Problema

Em `/venue/:id/apresentacao`, o lugar do card da proposta esta ocupado por uma foto. A descricao da casa aparece embaixo do logo, no lugar do slogan. Horario, capacidade, noites minimas e o bairro nao entram nesse ponto da pagina.

## Objetivos

- um card da casa entre o video (ou a capa) e a foto
- a descricao nesse card, e o slogan embaixo do logo
- horario, capacidade, noites minimas e bairro com cidade no mesmo card

## Fora de escopo

- topo do orcamento publico e do formulario publico, inclusive o titulo da aba dessas paginas
- card Proposta personalizada
- preco, duracao padrao, servicos, caracteristicas, WhatsApp e mapa
- rua, numero, CEP, e-mail e proprietarios escritos na pagina
- coluna nova, migration e permissao nova
- mudar quais fotos caem no hero, na foto solta e no grid

## User stories ou cenarios principais

- Visitante abre a apresentacao e le a casa entre o video e a foto.
- Casa com pernoite mostra check-in, check-out e noites minimas.
- Casa sem pernoite mostra abertura e fechamento.
- Casa sem slogan, sem descricao ou sem horario abre o card com o nome e a capacidade.

## Criterios de aceite

- `R-01`: `GET /venue/presentation/:venueId` inclui `slogan` (`string` ou `null`) e conserva as chaves atuais; a resposta continua sem e-mail, CEP, complemento e dono
- `R-02`: embaixo do logo entra o slogan com espacos das pontas removidos; slogan vazio ou so com espaco some; a descricao sai desse lugar
- `R-03`: o titulo da aba desta pagina usa `venueTabTitle(nome, slogan)`; slogan vazio deixa so o nome
- `R-04`: a ordem visivel e logo e slogan, video ou capa, card da casa, uma foto, Conheça nosso espaço, Serviços disponíveis, grid, Seu investimento, mapa e rodape
- `R-05`: o card tem o rotulo A casa, o titulo e o nome do espaco, e a descricao no corpo, preservando quebras de linha; descricao vazia some
- `R-06`: o card mostra Até N pessoas, com N igual a `maxGuest`
- `R-07`: sem pernoite, a linha e o horario de funcionamento; com pernoite, a linha e check-in e check-out; o outro modo nao aparece
- `R-08`: noites minimas so aparecem com pernoite e valor maior que zero, no texto Minimo de N noite ou noites
- `R-09`: a linha de local e bairro e cidade unidos por ` — `; o lado ausente sai da linha; rua e numero nao aparecem escritos
- `R-10`: horario ou local vazio some; o card permanece com o nome e a capacidade
- `R-11`: com video, a foto depois do card e a primeira e o grid sao as demais; sem video, a capa e o hero, a foto seguinte fica depois do card e o restante vai para o grid
- `R-12`: `/proposal/:id/view` e `/venue/:id/form` conservam a descricao embaixo do logo

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: o GET continua publico e sem token; nenhuma permissao nova
- erros e mensagens esperadas: venue inexistente segue 404; a pagina de falha nao muda
- observabilidade minima: sem metrica nova; a prova e o teste da lista de chaves e da ordem dos blocos
- concorrencia, idempotencia ou retry: nao se aplica; leitura unica
- rollout, fallback ou degradacao: API com `slogan` antes do frontend; frontend antigo ignora a chave

## Casos de erro e borda obrigatorios

- caso: sem video
  impacto: o card fica entre a capa e a foto seguinte
  cobertura esperada: `T-02`, funcao pura dos blocos
- caso: sem foto
  impacto: o card permanece e os blocos de imagem continuam ocultos
  cobertura esperada: `T-02`
- caso: pernoite sem check-in ou sem check-out
  impacto: a linha mostra so o horario que existir; os dois vazios escondem a linha
  cobertura esperada: `T-02`
- caso: so abertura ou so fechamento
  impacto: a linha mostra o lado que existir, sem traco no lugar do outro
  cobertura esperada: `T-02`
- caso: slogan ou descricao so com espaco
  impacto: a linha e o paragrafo somem
  cobertura esperada: `T-02`
- caso: `minimumNights` nulo ou zero
  impacto: a linha de noites nao aparece
  cobertura esperada: `T-02`
- caso: `slogan` nulo no banco
  impacto: a chave sai `null` e o topo fica sem texto
  cobertura esperada: `T-01` e `T-02`

## Impacto esperado

A apresentacao passa a contar a casa no vao do card da proposta. O contrato publico ganha uma chave. Orcamento e formulario nao mudam.

## Areas impactadas

- `backend`: mapper, select e teste de `GET /venue/presentation/:venueId`
- `frontend`: `VenuePresentation.tsx`, `venue-presentation.ts` e o teste da ordem dos blocos
- `topics/public-pages-and-branding.md`: a frase da ordem da apresentacao

## Restricoes e cuidados

- nao acrescentar outra chave alem de `slogan`
- nao escrever rua, numero, CEP, e-mail nem dono
- nao extrair componente compartilhado com `ProposalView`
- a hora segue o rotulo ja usado na proposta: `8:00` vira `8h` e `8:30` vira `8h30`

## Dependencias

- a pagina e o GET da apresentacao ja existem
- `slogan` ja esta em `venue` e em Configuracoes
- capacidade, horarios, pernoite, bairro e cidade ja saem nesse GET

## Mapeamento leve requisito -> task -> prova

- `R-01` -> `T-01` -> unitario
- `R-02` -> `T-02` -> unitario
- `R-03` -> `T-02` -> unitario
- `R-04` -> `T-02` -> unitario
- `R-05` -> `T-02` -> unitario
- `R-06` -> `T-02` -> unitario
- `R-07` -> `T-02` -> unitario
- `R-08` -> `T-02` -> unitario
- `R-09` -> `T-02` -> unitario
- `R-10` -> `T-02` -> unitario
- `R-11` -> `T-02` -> unitario
- `R-12` -> `T-02` -> unitario

## Perguntas em aberto

- Nenhuma que bloqueie. O titulo da aba desta pagina usa o slogan; ver `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `smart`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `executar task`
- entrada publica recomendada: `fw:run`
