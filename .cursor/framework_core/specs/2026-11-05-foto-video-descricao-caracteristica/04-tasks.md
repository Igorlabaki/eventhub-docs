# Tasks — Foto ou video e descricao na caracteristica

## Ordem macro

`T-01` grava descricao e uma midia. `T-02` e `T-03` dependem dela e podem seguir em paralelo. `T-04` depende de `T-02`.

## Tasks

### T-01 - Gravar descricao e uma midia na caracteristica

- objetivo: criar, editar e excluir caracteristica com descricao opcional e no maximo uma midia, foto ou YouTube
- cobre requisitos: `R-01`, `R-02`, `R-03`, `R-04`, `R-05`, `R-06`, `R-07`, `R-08`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: `uploadServiceImage`, `deleteServiceImage`, `isYoutubeUrl` extraido do schema do tour
- prompt recomendado: normal
- estrategia de teste: unitario no use case, no schema e na validacao do arquivo
- cenarios obrigatorios: descricao vazia vira nulo; acima de 500 recusa; YouTube valido grava; mp4, http e outro host recusam; foto e video no mesmo envio recusam; trocar foto por video apaga o objeto anterior; excluir com foto apaga o objeto; sem permissao nao grava; item antigo sem midia continua
- definition of done: migration aditiva no repositorio; `npx prisma validate`; testes do arquivo `venue-amenity.spec.ts` verdes; linha de `VenueAmenity` atualizada em `product/08-data-model.md`

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — upload de imagem e URL gravada
- risco principal: gravar foto e video juntos, ou aceitar link que nao e do YouTube
- repos tocados: `backend`
- fora de escopo desta task: formulario do painel, bloco publico, storage privado, tour e galeria
- prova minima desta task: `npx prisma validate` e `npm test -- --run src/use-cases/venue-amenity/venue-amenity.spec.ts`
- criterio de escalada: se a foto precisar de bucket privado, parar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `database`, `node`, `patterns`
- documentos obrigatorios: `03-design.md#Contratos e dados`, `03-design.md#Falhas, casos de borda e invariantes`, `03-design.md#Reuso previsto`, `topics/data-and-migrations.md#Regras`
- caminhos candidatos: `prisma/schema.prisma` modelo `VenueAmenity`; `src/use-cases/venue-amenity/`; `src/zod/venue/tour-video-url-schema.ts`; `src/functions/service-image-storage.ts`
- palavras-chave ou simbolos de busca: `VenueAmenity`, `uploadServiceImage`, `isYoutubeUrl`, `EDIT_VENUE_AMENITIES`
- testes provaveis: `src/use-cases/venue-amenity/venue-amenity.spec.ts`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, skills de upload privado

### T-02 - Levar descricao e midia na apresentacao publica

- objetivo: a apresentacao publica da proposta devolve descricao, foto e video da caracteristica, e nada alem disso
- cobre requisitos: `R-09`
- depende de: `T-01`
- pode rodar em paralelo com: `T-03`
- reusa: `toProposalPresentation` e o select de `amenities`
- prompt recomendado: smart
- estrategia de teste: unitario do pacote publico
- cenarios obrigatorios: os tres campos saem no item; venueId, dono, contrato e pagamento continuam de fora
- definition of done: teste do pacote publico verde com os tres campos preenchidos

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — resposta publica
- risco principal: devolver dado interno do venue junto da midia
- repos tocados: `backend`
- fora de escopo desta task: desenho da pagina, upload, formulario
- prova minima desta task: `npm test -- --run src/use-cases/proposal/get-proposal-presentation/use-case-get-proposal-presentation.spec.ts`
- criterio de escalada: se o select precisar de campo alem de nome, posicao, descricao, foto e video, parar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`
- documentos obrigatorios: `03-design.md#Contratos e dados`
- caminhos candidatos: `src/functions/to-proposal-presentation.ts`; select de `amenities` em `proposal-in-prisma-repository.ts`; `ProposalPresentationAmenity`
- palavras-chave ou simbolos de busca: `ProposalPresentationAmenity`, `amenities`
- testes provaveis: `src/use-cases/proposal/get-proposal-presentation/use-case-get-proposal-presentation.spec.ts`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `security`

### T-03 - Formulario de descricao, foto ou YouTube

- objetivo: o cadastro da caracteristica envia descricao e uma midia, e impede foto e link juntos
- cobre requisitos: `R-01`, `R-04` no formulario
- depende de: `T-01`
- pode rodar em paralelo com: `T-02`
- reusa: `FormData` com `payload` do servico; preview de foto do formulario de servico
- prompt recomendado: normal
- estrategia de teste: unitario da funcao pura que prepara o envio
- cenarios obrigatorios: descricao em branco vira nulo; foto e link juntos recusam; link que nao e YouTube recusa; escolher arquivo zera o link no payload
- definition of done: formulario com descricao, arquivo e link; service em `multipart`; teste da funcao pura verde

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — envio do arquivo
- risco principal: o formulario enviar foto e video no mesmo payload
- repos tocados: `frontend`
- fora de escopo desta task: bloco publico, schema, miniatura na tabela
- prova minima desta task: `npm test -- --run src/lib/amenity-form.test.ts`
- criterio de escalada: se o envio deixar de ser o `payload` JSON do servico, parar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Decisoes arquiteturais importantes`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios: `03-design.md#Decisoes arquiteturais importantes`, `03-design.md#Reuso previsto`
- caminhos candidatos: `src/components/venue-amenity/venue-amenity-form.tsx`; `src/services/venue-amenity.service.ts`; `src/services/service.service.ts` funcao `serviceFormData`
- palavras-chave ou simbolos de busca: `VenueAmenityForm`, `serviceFormData`, `removeImage`
- testes provaveis: `src/lib/amenity-form.test.ts`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `security`

### T-04 - Mostrar descricao e midia na proposta publica

- objetivo: o bloco "Conheça nosso espaço" mostra descricao e foto ou player, e o item sem complemento fica como esta
- cobre requisitos: `R-07`, `R-10`
- depende de: `T-02`
- pode rodar em paralelo com: nenhuma
- reusa: o grid atual do bloco; nao reusa `resolveTourVideo`
- prompt recomendado: smart
- estrategia de teste: unitario do embed e da escolha entre foto e video
- cenarios obrigatorios: watch, youtu.be, Shorts e embed viram `https://www.youtube.com/embed/{id}?rel=0`; mp4, http e vazio nao geram player; foto e video juntos mostram so a foto; descricao em branco some
- definition of done: componente do item publico usado no bloco; `npm test -- --run src/lib/amenity-video.test.ts` verde

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — iframe na pagina publica
- risco principal: usar a URL crua como `src` do player, ou o embed mudo do tour
- repos tocados: `frontend`
- fora de escopo desta task: formulario, upload, tour do espaco
- prova minima desta task: `npm test -- --run src/lib/amenity-video.test.ts`
- criterio de escalada: se o player precisar de autoplay, parar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Falhas, casos de borda e invariantes`
- libs obrigatorias: `react`
- documentos obrigatorios: `03-design.md#Falhas, casos de borda e invariantes`, `03-design.md#Decisoes arquiteturais importantes`
- caminhos candidatos: bloco "Conheça nosso espaço" em `src/pages/ProposalView.tsx`; `src/lib/tour-video.ts` so para nao reutilizar o embed
- palavras-chave ou simbolos de busca: `Conheça nosso espaço`, `resolveTourVideo`
- testes provaveis: `src/lib/amenity-video.test.ts`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `security`
