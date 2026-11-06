# Design — Logo, descricao e card vertical do parceiro

## Visao geral da solucao

O contato fornecedor ganha `description` e `logoUrl`. O cadastro publico e o painel enviam a descricao no corpo e a logo como arquivo. O servidor grava a imagem no S3 e so entao preenche `logoUrl`. Um componente vertical unico serve o preview do formulario e o card de `/proposal/:id/indications`.

## Passada transversal

- architecture: nao. O fluxo continua no modulo `contact` e na pagina de indicacoes. Sem ADR.
- database: sim. Duas colunas nullable em `contact`. Migration aditiva, sem indice novo.
- design: sim. Campos novos, preview e card. Um componente com variante preview e variante publica.
- observability: nao. Nao ha servico novo. Erro segue `{ title, message }` e o toast atual.
- security: sim. A rota publica de criar contato passa a receber arquivo. Allowlist, tamanho, chave gerada pelo servidor e recusa de `logoUrl` vindo do cliente. Nao autenticar o restante das rotas de contato nesta spec.
- patterns/rules/06: nao. Sem fila, retry ou corrida nova. Upload sincrono, como a foto de servico. Falha ao apagar o objeto antigo nao reverte a linha.

## Componentes e modulos impactados

- `art56_server_v3/prisma/schema.prisma`: `Contact.logoUrl` e `Contact.description`
- schemas `create-contact-params-schema` e `update-contact-params-schema`
- `src/router/contact.ts`: `multer` opcional em `POST /create` e `PUT /update`
- controllers de criar e atualizar contato: leem `payload` JSON quando o corpo e multipart, sobem o arquivo, apagam a logo anterior
- select publico em `proposal-indication-in-prisma-repository.ts`: inclui `logoUrl` e `description`
- `eventhub-vista-dashboard/src/pages/PartnerForm.tsx`
- `eventhub-vista-dashboard/src/components/contact/contact-form.tsx`
- `eventhub-vista-dashboard/src/pages/ProposalIndications.tsx`
- componente novo do card, ao lado dos componentes publicos da proposta
- tipos `Contact`, `CreateContactParams`, `UpdateContactParams` e `PublicIndication`
- `contactService`: JSON quando nao ha arquivo; `FormData` com `payload` e `file` quando ha, no mesmo formato de `service.service.ts`

## Reuso previsto

- limite de 5 MB e a checagem de imagem de `src/functions/service-image.ts`, com recusa explicita de SVG
- Sharp, bucket e URL publica de `src/functions/service-image-storage.ts`, com prefixo proprio
- `indicationLinks` para os icones
- classes de `public-list-pattern.ts` no card publico
- `Textarea` de `@/components/ui/textarea`
- leitura de corpo `payload` ja usada em `controller-create-service.ts`

## Contratos e dados

Colunas novas, as duas opcionais:

- `logoUrl String?`
- `description String?` com `@db.VarChar(400)`

`description` no Zod: string opcional, trim, maximo 400. String vazia vira `null`. Acima de 400 falha a validacao.

`logoUrl` nao entra no schema do corpo. O controller atribui a URL depois do upload. Se o JSON trouxer `logoUrl`, o parse descarta o campo.

Arquivo:

- campo `file`, um so
- tipos `image/jpeg`, `image/png`, `image/webp`, `image/gif`
- ate 5 MB
- Sharp gera WebP com largura maxima de 512
- chave `contact-logo/<timestamp>-<uuid>.webp`
- URL no formato publico ja usado pelas fotos de servico

Atualizar aceita `removeLogo: true`. Se vier arquivo e `removeLogo` juntos, o arquivo vence. Remover ou trocar apaga a chave anterior somente se ela for do bucket do projeto e comecar com `contact-logo/`.

Tipo `TEAM_MEMBER` no criar: descricao ou arquivo responde erro "Membro da equipe nao tem logo nem descricao". No atualizar, passar a equipe zera `description` e `logoUrl` e apaga o objeto. `SUPPLIER` exige categoria como hoje.

Criar e atualizar sem arquivo continuam aceitando JSON. Com arquivo, o cliente manda `multipart/form-data`: `payload` (JSON) e `file`.

A listagem publica de indicacoes acrescenta `logoUrl` e `description` ao select que ja existe. Nao muda o filtro por orcamento.

## Falhas, casos de borda e invariantes

- imagem invalida ou grande demais: erro antes de escrever no banco; se o Sharp falhar, a mesma mensagem de imagem invalida
- upload que funciona e gravacao que falha: o objeto novo pode ficar orfao; nao ha compensacao alem do que a foto de servico ja faz
- apagar o objeto antigo falha: a linha fica com a logo nova; o erro de delete nao volta para o cliente
- descricao so com espacos: `null`
- quebra de linha conta no limite de 400 e aparece no card com `whitespace-pre-line`
- um contato tem no maximo uma logo

## Decisoes arquiteturais importantes

- A logo e asset publico. `skills/securing-private-file-upload-and-storage.md` nao se aplica a imagem de marketing de pagina publica. O endurecimento e allowlist, tamanho, reencode e nome gerado pelo servidor.
- Nao receber URL pronta. Isso impede o cadastro publico de apontar o card para um arquivo arbitrario.
- Um componente, duas variantes. `preview` mostra textos de espera e liga as redes preenchidas, com a mesma URL do card publico. `public` esconde descricao vazia e liga as redes. Os dois centralizam avatar, nome, descricao e icones, nessa ordem.
- A funcao fica fora do componente. O grupo da categoria na pagina de indicacoes continua no titulo da secao.
- O circulo do avatar tem 72 px, `object-cover`. Sem imagem, fundo neutro com a inicial. O artigo do card continua na coluna da pagina; o miolo e que fica estreito e centralizado.
- Rotulo do arquivo no formulario: "Logo". Rotulo da descricao: "Descrição do serviço".
- Membro da equipe nao ve esses campos no painel.

## Riscos e mitigacoes

- A rota `POST /contact/create` e publica e passa a aceitar arquivo. Mitigacao: um arquivo, tipos de imagem, 5 MB, WebP reencode, chave propria. Nao ampliar o limite de 50 MB do JSON para este arquivo; o multer da rota usa 5 MB.
- `PUT /contact/update` hoje nao exige login. Esta spec nao corrige isso. O arquivo novo obedece aos mesmos limites. Quem ja podia alterar um contato continua podendo.
- SVG fica de fora para nao guardar marcacao ativa atras de uma extensao de imagem.

## Rollout, observabilidade e rollback

- colunas nullable: o codigo antigo ignora o que nao conhece; o codigo novo trata `null` como ausencia
- rollback de aplicacao: as colunas podem ficar sem uso
- rollback de schema nao faz parte desta entrega
- prova de falha: resposta de validacao e toast. Sem log do corpo do arquivo e sem valor de `.env`

## Estrategia de validacao

- backend: `npm test -- --run` nos specs de contato e de indicacao; `npx prisma validate`
- frontend: teste do componente nas duas variantes; `npm test` do arquivo novo
- tela, na task de UI: preencher o cadastro publico e ver o preview mudar; abrir as indicacoes e ver o mesmo card; recusar um arquivo que nao e imagem

## Fontes determinantes

- `topics/data-and-migrations.md#Regras`: migration aditiva e `prisma migrate deploy`
- `topics/integrations.md#S3 e arquivos`: Multer, Sharp e S3, com tipo e tamanho validados
- `topics/auth-and-security.md#Estado atual`: indicacoes publicas ja sao de proposito; rotas de contato seguem sem auth
- `project/project-decisions.md#D-02`: a mudanca fica no use case de contato, sem servico novo
- `framework-libs/security/index.md#Upload, arquivos ou storage privado`: lido ate a skill, e descartado o storage privado porque a imagem e publica
- foto de servico em `src/functions/service-image.ts` e `service-image-storage.ts`: contrato de upload a copiar, com prefixo e largura proprios
