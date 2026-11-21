# Spec — Criar a rede do espaco

## Problema

A aba Redes lista Apresentacao, orcamento, regras e WhatsApp mesmo sem ninguem ter criado, e o link tree publica as que o padrao deixa visiveis. Escolher uma rede ja cria a linha vazia. A URL se edita no campo da tabela. O texto de link reconhecido fica verde; a linha, nao.

## Objetivos

A pessoa cria cada rede uma vez. Rede de link colado so entra com URL reconhecida. A linha que esta no link tree fica verde, como parceiro indicado. O lapis abre um modal para a URL. Rede ainda nao criada nao aparece na lista nem no link tree, e o select nao a oferece de novo.

## Fora de escopo

- coluna, tabela ou tipo novo de rede
- card da pagina publica (icone, seta, titulo, cores)
- faixa de KPIs, busca e filtro de visibilidade, alem de passarem a contar so rede criada
- tela Indicar parceiros, alem do reuso do verde da linha
- gravar a aba Redes fora do salvamento que Configuracoes ja faz
- spec `2026-11-21-visual-redes-e-link-tree`

## User stories ou cenarios principais

- Na aba Redes de um espaco sem redes criadas, a tabela nao mostra Apresentacao nem WhatsApp, e o link tree publico tambem nao.
- A pessoa escolhe Instagram, cola o perfil, confirma, ve a linha verde e nao consegue criar Instagram de novo.
- A pessoa clica no lapis, troca a URL por outro perfil valido e a linha mostra a URL nova.
- A pessoa cria Apresentacao sem colar URL. A linha entra na lista e no link tree.
- A pessoa cria WhatsApp sem numero no espaco. A linha entra na lista, branca, e nao entra no link tree.

## Criterios de aceite

- `R-01`: com `venue_link` vazio, `GET /venue/links/:venueId` devolve `links: []` e o editor devolve lista vazia
- `R-02`: destino gerado com `url` null, e link colado sem URL verde, nao entram no editor nem no link tree
- `R-03`: destino gerado conta como criado so com `url` igual ao marcador `created`; link colado conta so com `checkVenueLinkUrl` verde
- `R-04`: criar Instagram com perfil valido grava uma linha e tira Instagram do select; URL invalida ou ambigua nao grava; o mesmo tipo nao entra duas vezes
- `R-05`: o lapis abre modal; confirmar URL que nao esta verde nao troca a URL anterior
- `R-06`: linha visivel e com destino usa `bg-emerald-50` e borda esquerda emerald; linha oculta fica branca e continua na lista
- `R-07`: apagar tira a rede da lista e do link tree e devolve o tipo ao select
- `R-08`: WhatsApp criado sem numero fica na lista, fora do link tree, com linha branca, ate o numero existir
- `R-09`: o olho so alterna `visible`; nao devolve a rede ao select
- `R-10`: o card publico e as permissoes atuais nao mudam
- `R-11`: nao ha coluna nova; o corpo gravado continua `{ kind, url, visible, position }`

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: editor e gravacao seguem `EDIT_VENUE_INFO`; ordem e ocultar na pagina publica seguem `EDIT_VENUE_SITE`; o `GET` publico continua sem token
- erros e mensagens esperadas: o modal mostra a mensagem ja devolvida por `checkVenueLinkUrl`; tipo repetido continua `Cada rede entra uma vez.`
- observabilidade minima: nenhuma; a prova e o teste e o 400 que ja existe
- concorrencia, idempotencia ou retry: o `replace` continua trocando o conjunto inteiro; duas gravacoes seguidas, a ultima vence
- rollout, fallback ou degradacao: a leitura ja esconde a linha legada; ela so sai da tabela no proximo `replace`

## Casos de erro e borda obrigatorios

- caso: URL invalida ou ambigua na criacao
  impacto: a rede nao entra na lista
  cobertura esperada: unitario do modal e de `createVenueLink`
- caso: editar uma URL verde para uma URL nao verde
  impacto: a URL anterior permanece
  cobertura esperada: unitario de `replaceVenueLinkUrl`
- caso: espaco que ja tem o conjunto padrao gravado
  impacto: destino gerado com `url` null e link colado sem URL verde somem da leitura; link colado verde fica
  cobertura esperada: unitario de `createdVenueLinks` e do use case com fixture legado
- caso: criar destino gerado e ler de novo
  impacto: a linha continua, com o marcador, e nao e filtrada como legado
  cobertura esperada: unitario do use case de gravacao e leitura
- caso: select sem tipo restante
  impacto: nao ha opcao para criar
  cobertura esperada: unitario do editor
- caso: ocultar e apagar
  impacto: ocultar deixa a linha e tira do link tree; apagar devolve o tipo ao select
  cobertura esperada: unitario do editor

## Impacto esperado

O link tree deixa de abrir Apresentacao, orcamento e regras so porque o padrao ligou. Quem quiser esses destinos cria na aba Redes. Instagram, Facebook, TikTok e site ja gravados com URL verde continuam.

## Areas impactadas

- `art56_server_v3`: `functions/venue-link.ts` e `use-cases/venue/venue-links/use-case-venue-links.ts`
- `eventhub-vista-dashboard`: `src/lib/venue-link.ts` e `src/components/venue/VenueLinkEditor.tsx`
- topic `public-pages-and-branding.md` e a linha do `GET /venue/links/:venueId` em `project/api-endpoints.md`

## Restricoes e cuidados

- as duas copias de `venue-link.ts` nao sao pacote compartilhado; a regra entra nas duas
- `normalize` hoje zera `url` de destino gerado; passar a gravar o marcador, senao a linha some no proximo save
- o marcador nao aparece na tabela
- nao filtrar todo destino gerado para sempre: isso apagaria a Apresentacao criada, que antes tambem tinha `url` null

## Dependencias

- a spec visual da aba Redes e do card publico esta em revisao e nao e substituida por esta

## Mapeamento leve requisito -> task -> prova

- `R-01` -> `T-01` -> unitario
- `R-02` -> `T-01` -> unitario
- `R-03` -> `T-01` -> unitario
- `R-04` -> `T-01`, `T-02` -> unitario
- `R-05` -> `T-02` -> unitario
- `R-06` -> `T-02` -> unitario
- `R-07` -> `T-02` -> unitario
- `R-08` -> `T-01`, `T-02` -> unitario
- `R-09` -> `T-02` -> unitario
- `R-10` -> `T-01` -> unitario
- `R-11` -> `T-01` -> unitario

## Perguntas em aberto

Nenhuma bloqueante. Premissas e o risco de cada uma estao em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
