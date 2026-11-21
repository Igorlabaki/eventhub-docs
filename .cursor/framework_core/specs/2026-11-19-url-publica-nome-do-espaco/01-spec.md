# Spec — URL publica pelo nome do espaco

## Problema

A apresentacao publica e o formulario de orcamento identificam a casa pelo UUID. Quem recebe o link ve `8159e209-0057-4df3-ae72-855363c3b84e` em vez do nome do espaco.

## Objetivos

- o link novo da apresentacao usa o nome gravado do espaco
- o link novo do formulario de orcamento usa o mesmo nome
- as duas paginas abrem a casa certa sem login
- o envio do formulario continua gravando no id real da casa

## Fora de escopo

- rotas do painel (`/venue/:id/settings` e as demais)
- `/proposal/:id/view` e os outros links do orcamento
- regras, parceiros e colaboradores
- criar slug, renomear `Venue.name` ou migration
- limpar o pacote que `GET /venue/getById` ja devolve hoje
- `GET /service/list/:venueId` e a criacao da proposta passarem a aceitar nome

## User stories ou cenarios principais

- quem copia a apresentacao da AR756 envia `https://event-hub-dashboard.vercel.app/venue/AR756/apresentacao`
- quem copia o formulario envia `https://event-hub-dashboard.vercel.app/venue/AR756/form`
- quem abre um desses links sem sessao ve a AR756
- quem envia o formulario cria o orcamento na AR756, nao num id igual ao nome

## Criterios de aceite

- `R-01`: o item Apresentação e `publicVenuePresentationShareUrl` usam o `name` gravado, codificado, no lugar do id
- `R-02`: o botao de copiar o formulario usa o mesmo nome, no mesmo host fixo
- `R-03`: `GET /venue/presentation/:chave` encontra a casa pelo nome e devolve o mesmo recorte de apresentacao de hoje
- `R-04`: `GET /venue/getById` sem `userId` encontra a casa pelo nome e nao adiciona campo ao pacote atual
- `R-05`: com `userId`, `getById` continua buscando so por id
- `R-06`: uma chave que e UUID continua abrindo a casa daquele id na apresentacao e no formulario
- `R-07`: nome desconhecido responde casa ausente e a pagina nao mostra outra casa
- `R-08`: o formulario lista servicos e cria a proposta com `venue.id`, nunca com o trecho da URL quando ele for o nome
- `R-09`: nome com espaco ou acento funciona na URL codificada
- `R-10`: as duas rotas seguem publicas, na allowlist, sem permissao nova

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: as rotas continuam publicas de proposito; nome adivinhavel e o objetivo do link. `getById` com `userId` nao ganha busca por nome
- erros e mensagens esperadas: casa ausente usa o 404 que cada leitura ja tem; a pagina do formulario mostra a falha que ja existe
- observabilidade minima: nenhuma metrica nova; o 404 atual prova a casa ausente
- concorrencia, idempotencia ou retry: nao se aplica; leitura por chave unica e um POST de proposta que ja existe
- rollout, fallback ou degradacao: link antigo com UUID continua valido; nao ha redirect de nome antigo depois de renomear a casa

## Casos de erro e borda obrigatorios

- caso: nome que nao existe
  impacto: nao pode cair em outra casa
  cobertura esperada: `T-01` unitario e `T-02` pagina sem dado
- caso: UUID antigo
  impacto: link ja enviado deixa de abrir se a busca por nome vier antes
  cobertura esperada: `T-01` e `T-02`
- caso: nome com espaco ou acento
  impacto: a URL quebra ou a busca usa o texto codificado
  cobertura esperada: `T-02` na montagem e `T-01` na busca do texto decodificado
- caso: formulario recebe o nome e o repassa como `venueId`
  impacto: servicos e proposta nao gravam na casa
  cobertura esperada: `T-02`
- caso: `getById` com `userId` e um nome
  impacto: a busca do painel passaria a achar casa sem o id
  cobertura esperada: `T-01`

## Impacto esperado

Os dois links publicos da casa ficam legiveis. O painel e o orcamento ja fechado nao mudam de endereco.

## Areas impactadas

- frontend: montagem dos dois links, leitura da apresentacao e do formulario
- backend: `GET /venue/presentation/:venueId` e `GET /venue/getById` sem `userId`
- docs: `project/api-endpoints.md#Venue, precos e configuracao` e `topics/public-pages-and-branding.md`

## Restricoes e cuidados

- `Venue.name` ja e unico; a URL usa esse texto, nao um slug derivado
- nao ler nem versionar `.env`
- nao ampliar dono, contrato, pagamento nem o pacote interno alem do que a rota ja devolve
- `GET /venue/getById` sem `userId` ja inclui `contracts` e `attachments`; esta feature nao mexe nessa lista
- a criacao da proposta e `GET /service/list/:venueId` continuam exigindo o id

## Dependencias

- apresentacao publica e formulario publico ja existem
- `publicVenuePresentationShareUrl` e o botao em Orcamentos ja montam os links com o id
- `ProposalForm` hoje compara `selectedVenue.id` com o parametro da URL e repassa esse parametro aos formularios

## Mapeamento leve requisito -> task -> prova

- `R-01` -> `T-02` -> unitario
- `R-02` -> `T-02` -> unitario
- `R-03` -> `T-01` -> unitario
- `R-04` -> `T-01` -> unitario
- `R-05` -> `T-01` -> unitario
- `R-06` -> `T-01` -> unitario; `T-02` -> unitario
- `R-07` -> `T-01` -> unitario
- `R-08` -> `T-02` -> unitario
- `R-09` -> `T-01` -> unitario; `T-02` -> unitario
- `R-10` -> `T-01` -> unitario da rota publica; `T-02` -> allowlist existente

## Perguntas em aberto

Nenhuma bloqueante. Premissas em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
