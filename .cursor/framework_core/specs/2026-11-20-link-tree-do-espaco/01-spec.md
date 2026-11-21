# Link tree do espaco

## Problema

O dono nao tem uma pagina publica so com os links da casa. Instagram, Facebook, TikTok e site ficam soltos em Configuracoes, aba Apresentacao, e qualquer URL cabe em qualquer campo. Nao da para ordenar nem esconder um link.

## Objetivos

Quem abre o Link tree ve so o que o dono ligou, na ordem arrastada. Quem esta no painel monta essa lista na aba Redes e abre a pagina pela sidebar.

## Fora de escopo

- formulario de parceiro, formulario de colaborador e links de um orcamento
- segunda conta da mesma rede, link com nome livre e rede fora do catalogo
- editor na pagina publica
- mudar o formulario de criar espaco
- esconder Instagram, Facebook, TikTok ou site na apresentacao e no rodape do orcamento quando o olho do link tree esta desligado
- backfill em massa no banco de producao
- deploy request na `main` nesta spec

## User stories ou cenarios principais

- O dono da AR756 abre Configuracoes, aba Redes, ve site, Instagram, Facebook e TikTok ja ligados, arrasta Regras para o topo e desliga o TikTok. Salvar. O link tree publico mostra Regras antes e nao mostra o TikTok.
- Alguem sem login abre `https://event-hub-dashboard.vercel.app/espaco/AR756/links` e ve logo, cores e a lista.
- O dono escolhe Instagram e cola um link do Facebook. O aviso fica vermelho e Salvar nao envia.

## Criterios de aceite

- `R-01`: na secao A casa, Link tree abre `https://event-hub-dashboard.vercel.app/espaco/{nome}/links` em outra aba, para quem ja ve Site
- `R-02`: sem login, a pagina mostra logo e cores do espaco e, em lista vertical, so os links ligados e resolviveis, na posicao gravada
- `R-03`: a leitura publica nao devolve dono, contrato, pagamento, preco nem dado interno; casa inexistente nao mostra outra casa
- `R-04`: as abas ficam Geral, Endereco, Precos, Redes, Apresentacao; site, Instagram, Facebook e TikTok saem de Apresentacao
- `R-05`: o seletor oferece tipo ainda ausente, com icone, nome e formato; a URL cola depois; uma vez por tipo
- `R-06`: a checagem avisa verde, ambar ou vermelho, completa `https://` e impede Salvar enquanto houver linha colada ambar ou vermelha
- `R-07`: arrastar, Subir e Descer mudam a ordem; o olho esconde sem tirar a linha do lugar; a pagina publica pula o que esta oculto
- `R-08`: o catalogo automatico e o colado sao os desta spec; origem vazia nao sai na pagina publica e o editor diz onde preencher
- `R-09`: sem linhas gravadas, a lista padrao liga Apresentacao, Fazer orcamento, Regras e os quatro links que ja tem URL
- `R-10`: Salvar grava a lista e copia a URL verde de site, Instagram, Facebook e TikTok para as colunas atuais, com ou sem o olho ligado
- `R-11`: o formulario de criar espaco continua com os quatro campos

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: leitura publica sem token; gravar a lista exige a mesma permissao de salvar Configuracoes do espaco; o item da sidebar reutiliza `VIEW_VENUE_SITES`
- erros e mensagens esperadas: aviso na propria linha; Salvar nao segue com checagem ambar ou vermelha; a API recusa URL colada que nao esteja verde
- observabilidade minima: sem metrica nova; a prova e o teste e a pagina abrindo sem token
- concorrencia, idempotencia ou retry: gravar de novo a mesma lista nao duplica tipo; o par espaco+tipo e unico
- rollout, fallback ou degradacao: sem linhas gravadas, a leitura usa a lista padrao; as colunas atuais continuam alimentando apresentacao e rodape

## Casos de erro e borda obrigatorios

- caso: Instagram com post, reel, story ou explore; TikTok `/video/`; YouTube `watch?v=` ou `youtu.be`
  impacto: aviso ambar e Salvar bloqueado
  cobertura esperada: unitario
- caso: Facebook `profile.php?id=100085832906065`
  impacto: verde
  cobertura esperada: unitario
- caso: site com dominio de Instagram, Facebook ou TikTok
  impacto: nao passa como site
  cobertura esperada: unitario
- caso: WhatsApp, e-mail, endereco, video ou site da organizacao vazios
  impacto: o editor explica onde preencher e a pagina publica omite
  cobertura esperada: unitario
- caso: nenhum link ligado
  impacto: a pagina abre com logo e sem lista
  cobertura esperada: unitario
- caso: Salvar Configuracoes sem reenviar os quatro campos
  impacto: as colunas nao zeram
  cobertura esperada: unitario

## Impacto esperado

A casa passa a ter uma pagina de links ordenavel. Apresentacao e rodape do orcamento continuam lendo as quatro colunas.

## Areas impactadas

- `art56_server_v3`: schema, leitura publica e gravacao da lista
- `eventhub-vista-dashboard`: aba Redes, pagina publica, sidebar, allowlists

## Restricoes e cuidados

- migration aditiva; nao aplicar na `main` sem aprovacao nomeada
- a rota publica entra na allowlist do backend e nas duas listas `PUBLIC_ROUTES` do frontend
- nao ler nem versionar `.env`

## Dependencias

- apresentacao, formulario e regras publicas ja existem
- `GET /venue/presentation/:venueId` ja e publico e sem `ensureAuthenticate`
- WhatsApp, e-mail, endereco, video do tour e `Organization.url` ja existem

## Mapeamento leve requisito -> task -> prova

- `R-06`, `R-08`, `R-09` -> `T-01` -> unitario
- `R-02`, `R-03`, `R-10` -> `T-02` -> unitario
- `R-04`, `R-05`, `R-06`, `R-07`, `R-11` -> `T-03` -> unitario
- `R-01`, `R-02`, `R-03` -> `T-04` -> unitario

## Perguntas em aberto

Nenhuma bloqueante. Premissas em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `smart`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
