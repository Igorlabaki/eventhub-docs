# Spec — Icone da aba do espaco

## Problema

Quem abre a proposta, a apresentacao, a lista publica, o painel do espaco ou o formulario da proposta ve o nome do lugar na aba e o favicon do EventHub. O logo nao serve de icone, e nao existe outro arquivo para isso.

## Objetivos

- gravar um icone separado, ao lado do logo, na configuracao e na criacao do espaco
- a aba das telas que ja trocam o titulo usa esse arquivo
- sem icone, ou ao sair da tela, a aba volta para `/favicon.ico`

## Fora de escopo

- apple-touch-icon, manifest e PWA
- recorte, redimensionamento e geracao de tamanhos
- usar o logo como icone da aba
- botao de remover o icone
- mudar `venueTabTitle` ou o texto da aba
- pagina que hoje nao troca `document.title`
- limite novo de tamanho de arquivo
- aplicar a migration na `main` do PlanetScale
- endurecer o upload do logo que ja existe

## User stories ou cenarios principais

- na aba Apresentacao, ao lado de Logo do Espaco, a pessoa envia um PNG quadrado e salva; a aba da proposta daquele espaco mostra esse PNG
- na criacao do espaco, o mesmo campo sobe junto do logo
- a pessoa salva de novo sem escolher arquivo; o icone continua
- a pessoa escolhe outro arquivo; o novo substitui o anterior
- o espaco nao tem icone; a aba continua com o favicon do EventHub
- a pessoa sai da proposta; a aba volta o favicon do EventHub

## Criterios de aceite

- `R-01`: `Venue.faviconUrl` e `String?`, nasce nulo nas casas que ja existem, e a migration so adiciona a coluna
- `R-02`: Configuracoes, aba Apresentacao, e o formulario de criar espaco tem o campo Icone da aba ao lado do logo, com `accept="image/*"`, previa e o texto de que fica melhor quadrado e pequeno
- `R-03`: no mesmo save, o logo segue no campo `file` e o icone no campo `favicon`; um nao grava a URL do outro
- `R-04`: arquivo novo de icone substitui o anterior; campo vazio nao apaga `faviconUrl`; falha no envio nao apaga o icone ja gravado
- `R-05`: arquivo cujo tipo nao comeca com `image/` nao sobe ao S3, responde erro e deixa `faviconUrl` como estava
- `R-06`: a apresentacao publica do espaco e a apresentacao publica do orcamento devolvem `faviconUrl` junto de `logoUrl`
- `R-07`: `ProposalView`, `VenuePresentation`, `PublicVenueListShell`, `VenueDashboard` e `ProposalForm` apontam `<link rel="icon">` para `faviconUrl` quando a URL existe
- `R-08`: sem `faviconUrl`, essas telas deixam o icone em `/favicon.ico`
- `R-09`: ao sair de qualquer uma dessas telas, o icone volta para `/favicon.ico`, no mesmo efeito em que o titulo volta para `EVENTHUB_TAB_TITLE`
- `R-10`: uma string `faviconUrl` mandada no corpo nao grava a coluna; so o arquivo enviado grava
- `R-11`: nao ha apple-touch-icon, manifest, recorte, fallback para o logo nem botao de remover

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: create e update continuam autenticados; nao nasce rota nova; `GET /venue/getById` ja devolve os campos do espaco e passa a incluir `faviconUrl` como inclui `logoUrl`
- erros e mensagens esperadas: tipo invalido volta erro da API e a tela mostra a falha sem limpar a previa do icone anterior
- observabilidade minima: sem metrica nova; a prova e o teste e o `href` da aba
- concorrencia, idempotencia ou retry: o ultimo save ganha; o objeto novo sobe antes de apagar o antigo
- rollout, fallback ou degradacao: coluna nula; API antiga sem o campo deixa a aba no favicon do EventHub

## Casos de erro e borda obrigatorios

- caso: logo e icone no mesmo envio
  impacto: cada um precisa da propria URL
  cobertura esperada: `R-03` em `T-02`
- caso: so o icone, ou so o logo
  impacto: o outro campo nao pode mudar
  cobertura esperada: `R-03` e `R-04` em `T-02`
- caso: tipo que nao e imagem
  impacto: nao pode substituir o icone nem criar objeto
  cobertura esperada: `R-05` em `T-02`
- caso: o upload do icone falha
  impacto: `faviconUrl` anterior permanece
  cobertura esperada: `R-04` em `T-02`
- caso: sair da tela, ou abrir em seguida um espaco sem icone
  impacto: a aba nao pode ficar com o icone da casa anterior
  cobertura esperada: `R-08` e `R-09` em `T-05`
- caso: o `index.html` nao tem `<link rel="icon">`
  impacto: a troca precisa criar o link e, ao sair, aponta-lo para `/favicon.ico`
  cobertura esperada: `R-07` e `R-09` em `T-05`

## Impacto esperado

A marca do espaco ganha o icone da aba. O logo, o titulo e as cores continuam como estao.

## Areas impactadas

- `art56_server_v3`: schema, create e update do espaco, apresentacao publica do espaco e do orcamento
- `eventhub-vista-dashboard`: Configuracoes, criacao do espaco e as cinco telas que ja trocam o titulo da aba

## Restricoes e cuidados

- seguir o upload publico do logo; nao migrar o logo para storage privado
- nao aplicar a migration em producao nesta spec
- nao ler nem versionar `.env`
- `PublicVenueListShell` ja troca o titulo das listas, das regras e dos contratos publicos; o icone entra nesse mesmo efeito, nao numa pagina nova

## Dependencias

- `logoUrl`, `upload.single("file")` e `venueTabTitle` ja existem
- a apresentacao publica ainda nao devolve icone de aba

## Mapeamento leve requisito -> task -> prova

- `R-01` -> `T-01` -> `npx prisma validate` e a migration revisada
- `R-02` -> `T-04` -> teste de markup dos dois formularios
- `R-03`, `R-04`, `R-05`, `R-10` -> `T-02` -> unitario do upload com S3 mockado
- `R-06` -> `T-03` -> unitario dos dois mapeamentos
- `R-07`, `R-08`, `R-09`, `R-11` -> `T-05` -> unitario do `href` e presenca da chamada nas cinco telas

## Perguntas em aberto

Nenhuma bloqueante. O tamanho do arquivo e a unica premissa ainda larga: nao ha limite novo, igual ao logo. Detalhe em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `smart`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
