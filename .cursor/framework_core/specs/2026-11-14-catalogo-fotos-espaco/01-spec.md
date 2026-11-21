# Spec — Biblioteca de fotos do espaco

## Problema

Cada lugar que mostra foto do espaco sobe o proprio arquivo para o S3, com regras diferentes. A mesma foto da casa e enviada varias vezes. Nao ha um lugar para ver todas as fotos do espaco. Trocar uma foto exige novo upload em cada tela. As rotas `/image/*` aceitam escrita sem autenticacao.

## Objetivos

- criar a biblioteca de fotos por espaco (`venue_photo`) e o item "Fotos" na sidebar
- gravar cada uso como `photoId` da mesma biblioteca (site, orcamento, hub, servicos, caracteristicas, fundo do e-mail)
- permitir enviar foto nova pelo seletor de qualquer tela; a foto entra na biblioteca e ja volta selecionada
- manter as URLs publicas iguais as de hoje depois do backfill

## Fora de escopo

- biblioteca de fotos da organizacao
- alterar `guaeca-house-escapade`
- mover `tag`, `group`, `position`, `isShowOnProposal` e `isShowOnOrganization` para fora de `image`
- apagar as colunas de URL antigas
- logo do espaco e da organizacao, avatar, contato, pagamento e documentos
- conversao em lote das fotos antigas para WebP

## User stories ou cenarios principais

- O dono abre "Fotos", arrasta 30 fotos da casa e as ve em grade com descricao e usos.
- Ao cadastrar uma caracteristica, abre o seletor, clica "enviar nova", a foto ja vem selecionada e aparece em "Fotos".
- Ao trocar a capa do orcamento, escolhe uma foto ja enviada, sem novo upload.
- Ao tentar apagar uma foto usada no site e num servico, a exclusao e bloqueada e mostra onde ela e usada.

## Criterios de aceite

- `R-01`: existe a tabela `venue_photo` por espaco (`venueId`), com `url`, `storageKey` e metadados opcionais; DDL so aditiva
- `R-02`: `Image`, `Service`, `VenueAmenityImage` e `EmailConfig` ganham `photoId`/`backgroundPhotoId` opcional; as colunas de URL antigas continuam preenchidas como copia
- `R-03`: backfill cria um `venue_photo` por URL distinta e `venueId`, reaproveita o arquivo do S3, preenche os `photoId` e e idempotente; fotos so de organizacao (sem `venueId`) ficam de fora
- `R-04`: `GET /venue-photo/list`, `POST /venue-photo/upload` (varias, WebP), `PUT /venue-photo/:id`, `GET /venue-photo/:id/usages` e `DELETE /venue-photo/:id` exigem autenticacao e as permissoes novas
- `R-05`: exclusao de foto em uso responde 409 com a lista de usos; so apaga banco e S3 se nao houver uso
- `R-06`: permissoes `VIEW_VENUE_PHOTOS` e `EDIT_VENUE_PHOTOS` existem no backend, no enum do front, nas rotas e na sidebar; backfill de quem tem `VIEW_VENUE_SITES` / `EDIT_VENUE_SITE`
- `R-07`: item "Fotos" na secao "A casa", rota `/venue/:id/photos` e pagina com grade, upload multiplo, descricao e exclusao com usos
- `R-08`: consumidores de site, orcamento, hub, servicos, caracteristicas e e-mail aceitam `photoId` do mesmo `venueId` e deixam de depender de upload proprio
- `R-09`: o seletor (`PhotoPicker`) lista a biblioteca, seleciona uma ou varias e tem "enviar nova", que sobe via `/venue-photo/upload` e ja deixa a foto selecionada
- `R-10`: quem nao tem `EDIT_VENUE_PHOTOS` nao ve "enviar nova" e o backend recusa o upload; ainda pode escolher fotos existentes se tiver a permissao da tela
- `R-11`: escritas de `/image/*` exigem `ensureAuthenticate` (e permissao de site quando couber); leituras publicas usadas por `getWebData`/`getByTag` continuam publicas
- `R-12`: depois do backfill, `getWebData`, `getHubData` e a proposta publica devolvem as mesmas URLs de antes; `guaeca-house-escapade` nao muda
- `R-13`: foto de outro espaco, arquivo invalido ou acima do limite e recusada com 400; falha parcial no upload multiplo nao deixa registro orfao inconsistente

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: permissao no front nao substitui a API; toda escolha valida `photoId.venueId === uso.venueId`
- erros e mensagens: 400/401/403/409 com `{ title, message }`; toast do painel
- observabilidade: sem metrica nova; prova por teste, HTTP e browser
- concorrencia e idempotencia: backfill e backfill de permissao idempotentes; duas exclusoes simultaneas, a segunda ve os usos atualizados
- rollout: API e backfill antes do front; colunas de URL mantem o site antigo funcionando

## Casos de erro e borda obrigatorios

- mesma URL em `image` e `service` do mesmo espaco vira uma foto so (`T-03`)
- URL apontando para arquivo ausente no S3: listada no relatorio do backfill, sem quebrar o script (`T-03`)
- `image` so com `organizationId`: fora do backfill (`T-03`)
- excluir foto usada em varios lugares: 409 com usos (`T-02`)
- enviar foto pelo seletor e cancelar o cadastro: foto permanece na biblioteca (`T-06`, `T-08`)
- usuario com `EDIT_VENUE_AMENITIES` sem `EDIT_VENUE_PHOTOS`: sem "enviar nova", escolha de existentes ok (`T-06`, `T-08`)
- quatro arquivos no upload da biblioteca: processa os validos conforme o contrato de `T-02`; invalidos voltam com erro claro
- backfill rodado duas vezes nao duplica (`T-03`)

## Impacto esperado

Surge a biblioteca por espaco. As telas passam a escolher foto em vez de subir arquivo. Escritas de `/image/*` deixam de ser publicas. As paginas publicas nao mudam de contrato.

## Areas impactadas

- `backend`: schema, upload S3, rotas `venue-photo` e consumidores, permissoes
- `frontend`: sidebar, pagina Fotos, `PhotoPicker`, formularios dos seis consumidores
- `docs`: `api-endpoints.md`, `permissions-catalog.md`, `product/08-data-model.md`

## Restricoes e cuidados

- migration so aditiva; deploy request na `main`; backfill e escrita real com aprovacao nomeada
- nao fechar leituras publicas de `/image/*` sem teste negativo
- nao ler nem versionar `.env`
- confirmar que `VenueAmenityImage` existe no codigo dos repos antes de ligar `photoId` nela

## Dependencias

- `specs/2026-11-13-multiplas-fotos-caracteristica/` (tabela `venue_amenity_image` na `main`, codigo em revisao)
- preservar comportamento de trocar e reordenar fotos da proposta
- multi-repo: derivacao com `spec-repo-split-prompt.md` depois do bootstrap, se a execucao for repo-local

## Mapeamento leve requisito -> task -> prova

- `R-01`, `R-02` -> `T-01` -> `prisma validate`
- `R-04`, `R-05`, `R-06` (API), `R-13` -> `T-02` -> vitest
- `R-03`, `R-12` (URLs) -> `T-03` -> script + leitura `main` (aprovacao)
- `R-08` (API), `R-11` -> `T-04` -> vitest
- `R-06` (front), `R-07` -> `T-05` -> build + browser
- `R-09`, `R-10` -> `T-06` -> vitest/component + build
- `R-08` (site, proposta, hub), `R-12` -> `T-07` -> build + browser
- `R-08` (servicos, amenities, e-mail), `R-09` (enviar nova) -> `T-08` -> build + browser

## Perguntas em aberto

Premissas em `02-clarify.md`; nenhuma bloqueante para comecar `T-01`.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- proxima acao: `executar`
- entrada publica recomendada: `fw:run`
