# Biblioteca de fotos do espaco

## Identificacao

- nome da feature: Biblioteca de fotos do espaco, com item "Fotos" na sidebar
- slug: `catalogo-fotos-espaco`
- status: codigo de `T-01` a `T-08` no painel; browser parado no login; nao pronto para producao
- origem: `.cursor/framework_core/task-requests/catalogo-fotos-espaco-request.md`
- owner: nao documentado

## Objetivo rapido

- problema que resolve: cada tela sobe a propria foto (site, orcamento, hub, servicos, caracteristicas, e-mail); a mesma foto da casa e enviada varias vezes e nao ha um lugar unico para gerir o catalogo
- resultado esperado: pagina "Fotos" por espaco; todo uso grava `photoId` da biblioteca; seletor com "enviar nova" que ja deixa a foto selecionada; paginas publicas continuam lendo as mesmas URLs

## Contexto base

- requests relacionados: `task-requests/catalogo-fotos-espaco-request.md`
- specs relacionadas: `2026-11-13-multiplas-fotos-caracteristica` (`VenueAmenityImage`); `2026-11-04-trocar-foto-proposta-publica`; `2026-11-04-reordenar-fotos-proposta-publica`; `2026-11-04-preco-foto-descricao-servico`
- documentos de produto relacionados: `product/08-data-model.md`
- topics relacionados: `topics/permissions-catalog.md`, `topics/public-pages-and-branding.md`, `topics/data-and-migrations.md`, `topics/auth-and-security.md`
- ADRs relacionados: nenhum

## Estado atual da feature

- fase atual: `T-01` a `T-08` no codigo; schema na `main` (deploy request `#50`)
- task em andamento: nenhuma
- proxima task recomendada: revisar entrega (`fw:review`); abrir `/venue/:id/photos` logado

## Observacoes

- restricoes: sem biblioteca da organizacao; sem alterar `guaeca-house-escapade`; sem apagar colunas de URL; logo fora
- riscos principais: quebrar `getWebData`/`getHubData`/proposta; apagar do S3 arquivo ainda referenciado; fechar leitura publica de `/image/*` usada pelo site avulso
- fontes do bootstrap: task-request, `api-endpoints.md` (rotas `/image/*` PUB), `permissions-catalog.md`, `planetscale.md`, schema Prisma (`Image`, `Service`, `VenueAmenityImage`, `EmailConfig`)
