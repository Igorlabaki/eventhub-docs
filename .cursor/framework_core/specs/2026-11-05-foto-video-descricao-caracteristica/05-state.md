# State — Foto, video e descricao na caracteristica

## Snapshot

- status: `T-01` a `T-04` no codigo em 2026-11-12, nao commitado; tela nao provada no browser
- ultima task concluida: `T-04`
- task em andamento: nenhuma
- proxima task exata: nenhuma; falta prova no browser
- prova mais recente: backend `venue-amenity.spec.ts` (15), `use-case-get-proposal-presentation.spec.ts` (10) e `tour-video-url-schema.spec.ts` verdes; `npx prisma validate` ok; frontend `amenity-form.test.ts` (6), `amenity-video.test.ts` (4), `PublicServiceDetail.test.tsx` (3) e `tour-video.test.ts` (10) verdes; `npm run build` ok; eslint limpo nos arquivos tocados
- colunas lidas no `main` com `pscale sql --role reader`: `description varchar(500)`, `imageUrl text`, `videoUrl varchar(2048)`, nulas; batem com o design

## Delta da ultima task

- mudou: backend grava descricao, foto e link do YouTube independentes (multipart `payload` + `file`), apresentacao publica devolve os tres campos; painel tem descricao, foto e link; proposta mostra "?" e modal com foto, descricao e player
- ficou pendente: criar uma caracteristica real no painel e abrir a proposta
- lacunas de prova: browser nao exercitado; sem teste HTTP do multer; `tsc` do backend tem 76 erros antigos e o do frontend 53, nenhum nos arquivos desta spec

## Decisoes recentes

- migration `20261112120000_add_venue_amenity_media` so registra as colunas que o deploy request 43 ja aplicou; em producao, marcar como aplicada, nao reaplicar
- validacao do arquivo e upload ficaram no use case, depois da autorizacao, via `AmenityImageStorage` injetado (`03-design.md#Decisoes arquiteturais importantes`)
- `isYoutubeUrl` (backend) e `youtubeVideoId` (frontend) extraidos dos helpers do tour, sem mudar o comportamento do tour
- modal reaproveita `PublicServiceDetailDialog` com `videoUrl` opcional; o texto `sr-only` sem descricao passou de "Foto do servico." para "Detalhes de {nome}."

## Riscos ou bloqueios

- deploy request 43 conferido em 2026-11-12 como `closed`/`complete`; colunas no `main`
- objeto orfao no S3 se a gravacao falhar depois do upload, igual ao servico
- bloqueio de tela: o painel recente para no login

## Memoria promovida

- `product/08-data-model.md`: linha de `VenueAmenity` com os tres campos; divergencia removida
- `project/api-endpoints.md`: criar e editar caracteristica em multipart
- `topics/delivery-and-known-gaps.md`: divergencia da caracteristica removida
- `topics/improvement-backlog.md`: DIV-02 resolvido
- `topics/public-pages-and-branding.md`: "?" no bloco "Conheca nosso espaco"
- project-decisions e ADRs: nenhum

## Veredito

- veredito: lote entregue em L2; nao marcar pronto para producao
- bloqueantes: prova no browser e commit nos dois repos
- achados: nenhum
