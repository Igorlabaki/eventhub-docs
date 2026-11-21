# API Endpoints — EventHub

Catalogo da superficie HTTP do `backend` (`art56_server_v3/src/router/`), observado em 2026-11-10. Estado atual, nao alvo. Contratos de payload detalhados: `docs/referencias/API_CONTRACTS.md`.

## Totais

| Metrica | Valor |
|---|---|
| routers | 34 |
| endpoints | 193 + `GET /` (192 alcancaveis; segundo `GET /person/list` nunca roda) |
| com `ensureAuthenticate` | 108 |
| com `ensurePermission` | 6 (Google Calendar) |
| publicos | 85 + `GET /` |
| com upload multer (`single("file")`, memoria) | 17, sendo 12 publicos; so `contact` e `service` limitam tamanho. `POST /venue/create` e `PUT /venue/update` aceitam `file` (logo) e `favicon` (icone da aba). `POST /venue-photo/upload` e multipart `files` (1 a 20, 5 MB), autenticado |
| routers 100% publicos | 13: text, email, token, person, clause, payment, contact, contract, question, document, schedule, seasonalFee, emailConfig |

Legenda: **PUB** = sem auth; `auth` = `ensureAuthenticate`; `auth+P` = auth + `ensurePermission(P)`; `up` = upload. Padroes Express do tipo `/list?:x?/:y?` sao chamados na pratica como `/list` com query string.

## Prefixos

| Prefixo | Arquivo | Auth no router inteiro |
|---|---|---|
| `/auth` | `auth.ts` | nao |
| `/token` | `token.ts` | nao |
| `/user` | `user.ts` | sim |
| `/organization` | `organization.ts` | parcial |
| `/userOrganization` | `userOrganization.ts` | sim |
| `/userOrganizationPermission` | `useOrganizationPermission.ts` | sim |
| `/userVenuePermission` | `userVenuePermission.ts` | sim |
| `/owner` | `owner.ts` | sim |
| `/venue` | `venue.ts` | parcial |
| `/proposal` | `proposal.ts` | parcial |
| `/dateEvent` | `dateEvent.ts` | sim |
| `/payment` | `payment.ts` | nao |
| `/document` | `document.ts` | nao |
| `/person` | `person.ts` | nao |
| `/schedule` | `schedule.ts` | nao |
| `/contract` | `contract.ts` | nao |
| `/clause` | `clause.ts` | nao |
| `/attachment` | `attachment.ts` | sim |
| `/service` | `service.ts` | parcial |
| `/seasonalFee` | `seasonal-fee.ts` | nao |
| `/minimumPricePeriod` | `minimum-price-period.ts` | sim |
| `/goal` | `goal.ts` | sim |
| `/expense` | `expense.ts` | sim |
| `/venue-rule` | `venue-rule.ts` | sim, exceto `/public/:venueId` |
| `/venue-amenity` | `venue-amenity.ts` | sim |
| `/venue-photo` | `venue-photo.ts` | sim |
| `/contact` | `contact.ts` | nao |
| `/question` | `question.ts` | nao |
| `/text` | `text.ts` | nao |
| `/image` | `image.ts` | parcial: escritas do venue autenticadas; leituras e rotas de organizacao publicas |
| `/emailConfig` | `email-config.ts` | nao |
| `/email` | `email.ts` | nao |
| `/notification` | `notification.ts` | parcial |
| `/integrations/google-calendar` | `integrations-google-calendar.ts` | parcial |

## Identidade e acesso

| Metodo | Caminho | Auth | Handler |
|---|---|---|---|
| POST | `/auth/register` | PUB | registerUser |
| POST | `/auth/register/google` | PUB | registerGoogleUser (login e cadastro Google) |
| POST | `/auth/authenticate` | PUB | authenticateUser |
| GET | `/auth/refresh` | PUB | refreshToken (usado pelo Axios) |
| PUT | `/auth/reset-password` | PUB | resetPassword |
| POST | `/auth/forgot-password` | PUB | forgotPassword |
| PUT | `/auth/update-password` | auth | updateUserPassword |
| POST | `/token/refresh` | PUB | refreshToken (mesma factory, contrato alternativo) |
| PUT | `/user/update` | auth, up | updateUser |
| PUT | `/user/updatePassword` | auth | updateUserPassword |
| POST | `/user/createNewUser` | auth | createNewUser |
| GET | `/user/getById?:userId?` | auth | getByIdUser |
| GET | `/user/getByEmail?:email?` | auth | getByEmailUser |
| DELETE | `/user/delete/:userId` | auth | deleteUser |
| GET | `/user/list?:organizationId?/:email?` | auth | listUser |
| GET | `/userOrganization/list?:userId?/:username?` | auth | listUserOrganization |
| POST | `/userOrganization/create` | auth | createUserOrganization |
| PUT | `/userOrganization/update` | auth | updateUserOrganization |
| GET | `/userOrganization/byOrganizationlist/:organizationId?/:username?` | auth | listByOrganization |
| GET | `/userOrganization/getById/:organizationId?` | auth | getUserOrganizationById |
| DELETE | `/userOrganization/delete/:userOrganizationId?` | auth | deleteUserOrganization |
| GET | `/userOrganizationPermission/list?:id?` | auth | list |
| GET | `/userOrganizationPermission/byId?:organizationId?/:userId?` | auth | getById |
| POST | `/userOrganizationPermission/create` | auth | create |
| PUT | `/userOrganizationPermission/update` | auth | update |
| DELETE | `/userOrganizationPermission/delete/:id?` | auth | delete |
| GET | `/userVenuePermission/list?:id?` | auth | list |
| GET | `/userVenuePermission/get?:venueId?/:organizationId?/:userId?` | auth | get |
| POST | `/userVenuePermission/create` | auth | create |
| PUT | `/userVenuePermission/update` | auth | update |
| DELETE | `/userVenuePermission/delete/:id?` | auth | delete |

## Organizacao, proprietarios e contratos

| Metodo | Caminho | Auth | Handler |
|---|---|---|---|
| POST | `/organization/create` | auth, up | createOrganization |
| GET | `/organization/list?:userId?:name` | auth | listOrganization |
| GET | `/organization/getHubData?:organizationId` | PUB | getHubData (site) |
| GET | `/organization/getById?:organizationId?:venueName` | auth | getOrganizationById |
| DELETE | `/organization/delete/:organizationId` | auth | deleteOrganization |
| GET | `/organization/getOrganizationWebData/:organizationId?` | PUB | getOrganizationWebData (site) |
| PUT | `/organization/update` | auth, up | updateOrganization |
| PUT | `/organization/update-venue-organization-images` | auth | updateVenueOrganizationImage |
| POST | `/owner/createOrganizationOwner` | auth + membro da org (`OwnerAuthorizer`) | createOrganizationOwner; `venueIds` so da org (403) |
| POST | `/owner/createVenueOwner` | auth + membro da org | createVenueOwner; `venueId` so da org (403) |
| GET | `/owner/listByOrganization/:organizationId?/:venueName?` | auth + membro da org | listOwner |
| GET | `/owner/listByVenue/:organizationId?/:venueId?/:venueName?` | auth + membro da org | listOwnerByVenue; espaco de outra org 403 |
| PUT | `/owner/update` | auth + membro da org do registro (senao 404) | updateOwner; edicao parcial, `venueIds` omitido preserva vinculos, `[]` remove; `data.organizationId` descartado |
| DELETE | `/owner/delete/:ownerId` | auth + membro da org do registro (senao 404) | deleteOwner |

Corpo de escrita de `/owner` (2026-11-11): alem dos campos de sempre, `personType` (`PF`/`PJ`, ausente = `PF` na criacao e o gravado na edicao), `companyName`, `cnpj` (14 posicoes, 12 letras ou digitos + 2 digitos, com ou sem pontuacao, gravado normalizado) e `companySize` (`MEI`/`ME`/`EPP`/`DEMAIS` ou `null`). Em PJ, `completeName`/`cpf`/`rg` sao do representante (titular no MEI). Duplicidade: PJ por CNPJ dentro da org, criacao e edicao (409 "Proprietario com este CNPJ ja registrado."); PF por `completeName` exato entre os PF da org, so na criacao. Membro = linha em `userOrganization`; negativa sai 403 "Você não tem acesso a esta organização." com `console.error` sem PII.
| POST | `/contract/create` | PUB | createContract |
| GET | `/contract/list/:venueId?/:venueId?/:name?` | PUB | listContract (param repetido) |
| DELETE | `/contract/delete/:contractId` | PUB | deleteContract |
| PUT | `/contract/update` | PUB | updateContract |
| GET | `/contract/getById/:contractId` | PUB | getContractById |
| POST | `/clause/create` | PUB | createClause |
| GET | `/clause/list?:organizationId?/:title?` | PUB | listClause |
| DELETE | `/clause/delete/:clauseId` | PUB | deleteClause |
| PUT | `/clause/update` | PUB | updateClause |
| POST | `/attachment/create` | auth | createAttachment |
| GET | `/attachment/list/:venueId?/:name?` | auth | listAttachment |
| DELETE | `/attachment/delete/:attachmentId` | auth | deleteAttachment |
| PUT | `/attachment/update` | auth | updateAttachment |

## Venue, precos e configuracao

| Metodo | Caminho | Auth | Handler |
|---|---|---|---|
| POST | `/venue/create` | auth, up | createVenue (concede todas as permissoes ao criador); multipart `file` (logo) e `favicon` (icone da aba) |
| GET | `/venue/list?:organizationId?/:name?` | auth | listVenue |
| GET | `/venue/permittedVenueList?:organizationId?/:name?/:userId?` | auth | listPermittedVenue |
| GET | `/venue/trafficCount?:venueId/:year?/:approved?` | auth | trafficCount (origem e categorias) |
| GET | `/venue/analysisByMonth?:venueId/:year?/:approved?` | auth | analysisByMonth (`average=true` opcional) |
| GET | `/venue/analytics/:venueId` | auth | getVenueAnalytics (KPIs da visao geral) |
| GET | `/venue/reports/occupancy?venueId&year&month?` | auth + `VIEW_VENUE_ANALYSIS` (use case) | ocupacao da agenda: 84 celulas dia x faixa de 2 h, minutos por grupo |
| GET | `/venue/reports/lead-time?venueId&year&eventCategory?` | auth + `VIEW_VENUE_ANALYSIS` (use case) | antecedencia dos pedidos: mediana e faixas 0–7/8–30/31–90/90+ |
| GET | `/venue/reports/service-adherence?venueId&year&eventCategory?` | auth + `VIEW_VENUE_ANALYSIS` (use case) | aderencia dos servicos adicionais nas aprovadas |
| GET | `/venue/reports/event-profile?venueId&year` | auth + `VIEW_VENUE_ANALYSIS` (use case) | porte (faixas de convidados), categorias e uso da capacidade |
| GET | `/venue/reports/event-origin?venueId&year` | auth + `VIEW_VENUE_ANALYSIS` (use case) | cidade, estado e bairro dos eventos aprovados do ano (`type: "EventOriginReport"`); `month` e `eventCategory` nao filtram |
| GET | `/venue/reports/ads?venueId&year` | auth + `VIEW_VENUE_ANALYSIS` (use case) | investimento em anuncios por canal: investido, orcamentos, eventos, receita, custos e retorno (`type: "AdsReport"`) |
| GET | `/venue/getById?:venueId?/:userId?` | PUB | getVenueById (formularios publicos); sem `userId` a chave e nome ou UUID; com `userId` so o id; `ownerVenue` so com `ownerId` e `venueId`, sem o objeto `owner` |
| GET | `/venue/getWebData/:venueId?` | PUB | getWebData (site) |
| GET | `/venue/presentation/:venueId` | PUB (+ user opcional) | getVenuePresentation (casa, fotos da proposta, caracteristicas, servicos sem preco, preco do modelo ativo, `links` visiveis com kind, label e href); a chave e nome ou UUID; `canReorder` e `catalog` so com `EDIT_VENUE_SITE`; colunas de rede podem continuar no JSON |
| GET | `/venue/links/:venueId` | PUB (+ user opcional) | getVenueLinks (logo, slogan, cores e os links visiveis com destino); rede nao criada nao entra; cada item traz `subtitle` fixo do tipo; `canReorder` so com `EDIT_VENUE_SITE`; `usedKinds` so com `canReorder`, inclusive o link oculto; link oculto nao entra; coluna verde de site, Instagram, Facebook ou TikTok sem linha vira linha visivel (insert idempotente, sem escrever as quatro colunas) |
| PUT | `/venue/links/:venueId/order` | auth + `EDIT_VENUE_SITE` | orderVenueLinks (`{ kinds }` exatamente os botoes mostrados; oculto fica no intervalo) |
| PUT | `/venue/links/:venueId/hide` | auth + `EDIT_VENUE_SITE` | hideVenueLink (`{ kind }` so marca `visible` falso; a linha fica) |
| PUT | `/venue/links/:venueId/visible` | auth + `EDIT_VENUE_SITE` | setVenueLinkVisible (`{ kind, visible }` grava o valor pedido; o mesmo valor nao grava; nao escreve as quatro colunas) |
| PUT | `/venue/links/:venueId/create` | auth + `EDIT_VENUE_SITE` | createVenueLink (`{ kind, url?, visible? }`; rede colada grava o `visible` recebido, default visivel; so com URL verde; rede do sistema sem destino responde 400 e nao grava; tipo repetido, inclusive oculto, responde 400) |
| PUT | `/venue/presentation/:venueId/image-order` | auth | reorderVenueImages |
| PUT | `/venue/presentation/:venueId/image-choice` | auth | chooseVenueImage |
| PUT | `/venue/update` | auth, up | updateVenue (logo em `file`, icone da aba em `favicon`, cores, tour, slogan); ignora `url`, `instagramUrl`, `facebookUrl` e `tiktokUrl`; WhatsApp e tour com valor criam a linha desligada, e vazios apagam a linha |
| PUT | `/venue/update/payment-info` | auth | updateVenuePaymentInfo (modelo e precos) |
| PUT | `/venue/update/info` | auth | updateVenueInfo; ignora `url`, `instagramUrl`, `facebookUrl` e `tiktokUrl` |
| DELETE | `/venue/delete/:venueId` | auth | deleteVenue |
| POST | `/service/create` | auth, up (limite) | createService (authorizer) |
| GET | `/service/list/:venueId?/:name?` | PUB | listService |
| DELETE | `/service/delete/:serviceId` | auth | deleteService |
| PUT | `/service/update` | auth, up (limite) | updateService |
| POST | `/seasonalFee/create` | PUB | createSeasonalFee |
| GET | `/seasonalFee/list/:venueId?/:title?` | PUB | listSeasonalFee |
| DELETE | `/seasonalFee/delete/:seasonalFeeId` | PUB | deleteSeasonalFee |
| PUT | `/seasonalFee/update` | PUB | updateSeasonalFee |
| POST | `/minimumPricePeriod/create` | auth | create (authorizer de precos) |
| GET | `/minimumPricePeriod/list/:venueId` | auth | list |
| PUT | `/minimumPricePeriod/update` | auth | update |
| DELETE | `/minimumPricePeriod/delete/:id` | auth | delete |
| POST | `/goal/create` | auth | createGoal |
| GET | `/goal/list/:venueId?/:minValue?` | auth | listGoal |
| DELETE | `/goal/delete/:goalId` | auth | deleteGoal |
| PUT | `/goal/update` | auth | updateGoal |
| POST | `/expense/create` | auth | createExpense; `trafficSource?` (INSTAGRAM, FACEBOOK, TIKTOK, GOOGLE, OTHER ou `null`) obrigatorio em `ADVERTISING` (400 "Informe o canal da despesa de Publicidade."), `null` nas demais; create e update devolvem e a listagem traz `trafficSource` |
| GET | `/expense/list/:venueId?/:name?` | auth | listExpense |
| DELETE | `/expense/delete/:expenseId` | auth | deleteExpense |
| PUT | `/expense/update` | auth | updateExpense |
| GET | `/expense/analysis?:venueId?/:year?` | auth | analysisExpense |
| GET | `/venue-rule/public/:venueId` | PUB | listPublicVenueRule; `:venueId` aceita o nome unico ou o id; a resposta continua so `id`, `title`, `text` e `position` |
| POST | `/venue-rule/create` | auth | createVenueRule |
| GET | `/venue-rule/list/:venueId` | auth | listVenueRule |
| PUT | `/venue-rule/update` | auth | updateVenueRule |
| DELETE | `/venue-rule/delete/:ruleId` | auth | deleteVenueRule |
| POST | `/venue-amenity/create` | auth, multipart `payload` + `files` (ate 3, na ordem) | createVenueAmenity |
| GET | `/venue-amenity/list/:venueId` | auth; cada item com `images` ordenadas | listVenueAmenity |
| PUT | `/venue-amenity/update` | auth, multipart `payload` (`images?`: lista final `{ id }` / `{ newIndex }`) + `files` | updateVenueAmenity |
| DELETE | `/venue-amenity/delete/:amenityId` | auth | deleteVenueAmenity |
| GET | `/venue-photo/list?venueId=` | auth, `VIEW_VENUE_PHOTOS` | listVenuePhoto (`createdAt` desc) |
| POST | `/venue-photo/upload` | auth, `EDIT_VENUE_PHOTOS`, multipart `files` (1 a 20) + `venueId` | uploadVenuePhoto (WebP, key `venues/{venueId}/photos/{uuid}.webp`) |
| PUT | `/venue-photo/:id` | auth, `EDIT_VENUE_PHOTOS`, corpo `{ description }` | updateVenuePhotoDescription |
| GET | `/venue-photo/:id/usages` | auth, `VIEW_VENUE_PHOTOS` | listVenuePhotoUsages |
| DELETE | `/venue-photo/:id` | auth, `EDIT_VENUE_PHOTOS`; 409 com a lista de usos se ainda referenciada | deleteVenuePhoto |
| POST | `/contact/create` | PUB, up (limite) | createContact (tambem formularios de parceiro e equipe) |
| GET | `/contact/list/:venueId?/:name?/:type?` | PUB | listContact (paginado, `summary`) |
| DELETE | `/contact/delete/:contactId` | PUB | deleteContact |
| PUT | `/contact/update` | PUB, up (limite) | updateContact |
| POST | `/emailConfig/create` | PUB, up | createEmailConfig |
| GET | `/emailConfig/list/:venueId` | PUB | listEmailConfig |
| GET | `/emailConfig/getByType/:venueId?/:type?` | PUB | getEmailConfigByType |
| DELETE | `/emailConfig/delete/:id` | PUB | deleteEmailConfig |
| PUT | `/emailConfig/update` | PUB, up | updateEmailConfig |

## Proposta e operacao do evento

| Metodo | Caminho | Auth | Handler |
|---|---|---|---|
| POST | `/proposal/createPerPerson` | PUB | createProposalPerPerson (formulario publico e painel) |
| POST | `/proposal/createPerDay` | PUB | createProposalPerDay |
| POST | `/proposal/quote` | auth (authorizer no use case) | quoteProposal (nao grava) |
| GET | `/proposal/byId/:proposalId` | PUB | getProposalById (proposta completa, com PII) |
| GET | `/proposal/presentation/:proposalId` | PUB (+ user opcional) | getProposalPresentation (inclui o slogan do espaco; nao devolve dono, contrato nem pagamento) |
| PUT | `/proposal/presentation/:proposalId/image-order` | auth | reorderProposalImages |
| PUT | `/proposal/presentation/:proposalId/image-choice` | auth | chooseProposalImage |
| PUT | `/proposal/presentation/:proposalId/recalculate` | PUB intencional | recalculatePublicProposal |
| GET | `/proposal/presentation/:proposalId/services` | PUB intencional | listPublicProposalServices |
| PUT | `/proposal/presentation/:proposalId/services` | PUB intencional | updatePublicProposalServices |
| GET | `/proposal/indications/:proposalId` | PUB intencional | listProposalIndications |
| PUT | `/proposal/indications/:proposalId` | auth (SEND_PROPOSAL_INFO no use case) | replaceProposalIndications |
| PUT | `/proposal/updatePerPerson` | auth | updateProposalPerPerson |
| PUT | `/proposal/updatePerDay` | auth | updateProposalPerDay |
| PUT | `/proposal/updatePersonalInfo` | PUB | updateProposalPersonalInfo (contrato PF/PJ) |
| GET | `/proposal/list?:venueId?/:name?/:month?/:year?/:approved?` | auth | listProposal (paginado 10, `summary=true`; `whatsapp` opcional filtra por trecho do numero gravado com mascara, junto com `completeClientName`) |
| DELETE | `/proposal/delete/:proposalId` | auth | deleteProposal |
| POST | `/dateEvent/createSameDay` | auth | createDate (aprova proposta; sync Google) |
| POST | `/dateEvent/createOvernigth` | auth | createOvernightDate (grafia do backend) |
| POST | `/dateEvent/updateSameDay` | auth | updateSameDayDateEvent |
| POST | `/dateEvent/updateOverNight` | auth | updateOvernightDateEvent |
| GET | `/dateEvent/list/:venueId?/:proposalId?` | auth | listDateEvent |
| DELETE | `/dateEvent/delete/:dateEventId` | auth | deleteDateEvent (desaprova proposta) |
| POST | `/payment/create` | PUB, up | createPayment (atualiza `amountPaid`) |
| GET | `/payment/list?:venueId?/:proposalId?` | PUB | listPayment |
| DELETE | `/payment/delete/:paymentId` | PUB | deletePayment |
| PUT | `/payment/update` | PUB, up | updatePayment |
| POST | `/document/create` | PUB, up | createDocument |
| GET | `/document/list?:proposalId?/:title?` | PUB | listDocument |
| DELETE | `/document/delete/:documentId` | PUB | deleteDocument (apaga no S3) |
| PUT | `/document/update` | PUB, up | updateDocument |
| POST | `/person/create` | PUB | createPerson (envia confirmacao por e-mail) |
| POST | `/person/createMany` | PUB | createManyPerson |
| GET | `/person/list?:proposalId?/:type?/:name?` | PUB | listPerson |
| GET | `/person/list?...` (duplicado) | PUB | listWebPerson, inalcancavel |
| DELETE | `/person/delete/:personId` | PUB | deletePerson |
| PUT | `/person/update` | PUB | updatePerson |
| PUT | `/person/getById/:personId` | PUB | getByIdPerson (leitura como PUT) |
| POST | `/schedule/create` | PUB | createSchedule |
| GET | `/schedule/list?:proposalId?/:name?` | PUB | listSchedule |
| DELETE | `/schedule/delete/:scheduleId` | PUB | deleteSchedule |
| PUT | `/schedule/update` | PUB | updateSchedule |
| GET | `/schedule/getById/:scheduleId` | PUB | getByIdSchedule |
| GET | `/notification/list/:venueId` | PUB | listNotification (paginado, `summary`) |
| PATCH | `/notification/read-by-proposal/:proposalId` | auth | readNotificationsByProposal |
| PATCH | `/notification/read-all/:venueId` | auth | readAllNotifications |
| POST | `/email/proposal` | PUB | sendProposalEmail |
| POST | `/email/contract` | PUB | sendContractEmail (PDF base64 do cliente) |

### Cortesia em servicos

- corpos com `serviceCourtesy?: { serviceId: string; quantity: int 0..100000 }[]` (ate 100 itens, sem `serviceId` repetido): `POST /proposal/createPerPerson`, `POST /proposal/createPerDay`, `PUT /proposal/updatePerPerson` (`data`), `PUT /proposal/updatePerDay` (`data`) e `POST /proposal/quote`;
- cortesia maior que zero exige token e `VIEW_VENUE_PROPOSALS` ou `EDIT_VENUE_INFO` no Venue: sem token 401, sem permissao 403 ("Você não tem permissão para dar cortesia neste espaço."); na edicao vale o Venue gravado da proposta;
- cortesia acima da quantidade do servico responde 400 ("Informe uma cortesia inteira, de 0 até a quantidade do serviço.");
- rotas publicas nunca leem cortesia do corpo: `GET` e `PUT /proposal/presentation/:proposalId/services` devolvem `courtesyQuantity` e `courtesyAmount` por servico (0 quando nao marcado), nunca `unitPrice`; o `PUT` mantem a cortesia gravada e a reduz ate as horas novas.

### Desconto em %

- corpos com `discountPercent?: number` (0..100, ate 2 casas; omitido vale 0): `POST /proposal/createPerPerson` e `PUT /proposal/updatePerPerson` (`data`); por dia, `/quote` e rotas publicas nao tem o campo;
- % maior que zero exige token e `VIEW_VENUE_PROPOSALS` ou `EDIT_VENUE_INFO` no Venue: sem token 401, sem permissao 403 ("Você não tem permissão para dar desconto neste espaço."); fora do limite 400 ("Informe um desconto de 0 a 100%, com até duas casas decimais."); espaco sem preco de catalogo 400; na edicao vale o Venue gravado;
- a proposta devolvida ganha `discountPercent` e `discountAmount`; `totalAmount` e o liquido;
- `PUT /proposal/presentation/:proposalId/services` e `PUT /proposal/presentation/:proposalId/recalculate` ignoram `discountPercent` no corpo e devolvem `discountPercent` e `discountAmount` em `data` (0 quando o cliente mudou algo).

## Site e conteudo

| Metodo | Caminho | Auth | Handler |
|---|---|---|---|
| POST | `/text/create` | PUB | createText |
| POST | `/text/create-text-organization` | PUB | createTextOrganization |
| GET | `/text/list/:venueId?/:area?` | PUB | listText |
| GET | `/text/list-text-organization/:organizationId?/:area?` | PUB | listTextOrganization |
| DELETE | `/text/delete/:textId` | PUB | deleteText |
| PUT | `/text/update` | PUB | updateText |
| PUT | `/text/update-text-organization` | PUB | updateTextOrganization |
| POST | `/image/upload` | auth, up | createImage (sharp); `photoId` copia a URL e nao sobe arquivo |
| POST | `/image/upload/image-organization` | PUB, up | createImageOrganization |
| GET | `/image/list?:venueId?/:description?` | PUB | listImage |
| GET | `/image/organization/list?:organizationId?/:description?` | PUB | listImageOrganization |
| DELETE | `/image/delete/:imageId` | auth | deleteImage (apaga no S3) |
| GET | `/image/getByTag?:venueId?/:tag?/:responsiveMode?` | PUB | getByTagImage |
| GET | `/image/getByTag/image-organization?...` | PUB | getByTagImageOrganization |
| PUT | `/image/update` | auth, up | updateImage; `photoId` copia a URL |
| PUT | `/image/organization/update` | PUB, up | updateImageOrganization |
| POST | `/question/create` | PUB | createQuestion |
| GET | `/question/list/:venueId?/:question?` | PUB | listQuestion |
| DELETE | `/question/delete/:questionId` | PUB | deleteQuestion |
| PUT | `/question/update` | PUB | updateQuestion |

## Google Calendar

| Metodo | Caminho | Auth | Handler |
|---|---|---|---|
| GET | `/integrations/google-calendar/auto-status` | auth+VIEW_VENUE_CALENDAR | status da integracao |
| GET | `/integrations/google-calendar/connect` | auth+VIEW_VENUE_CALENDAR | assina `state` JWT (10 min) e redireciona |
| GET | `/integrations/google-calendar/connect-url` | auth+VIEW_VENUE_CALENDAR | devolve `{ redirectUrl }` |
| GET | `/integrations/google-calendar/callback` | PUB (protegido pelo `state`) | troca code, cifra tokens, redireciona para `FRONTEND_URL` |
| GET | `/integrations/google-calendar/calendars` | auth+VIEW_VENUE_CALENDAR | lista calendarios |
| POST | `/integrations/google-calendar/select-calendar` | auth+EDIT_VENUE_CALENDAR | grava calendario escolhido |
| POST | `/integrations/google-calendar/disconnect` | auth+EDIT_VENUE_CALENDAR | remove integracao |

## Endpoints publicos sensiveis (estado atual, nao regra de produto)

- financeiro: todo `/payment`, todo `/seasonalFee`;
- documentos e contratos: todo `/document`, `/contract`, `/clause`;
- PII: todo `/person`, `/contact`, `GET /proposal/byId/:id`, `PUT /proposal/updatePersonalInfo`, `GET /notification/list/:venueId`;
- abuso de e-mail: `/email/*` e todo `/emailConfig` (com upload);
- arquivos S3 sem limite: `/image/*` upload/update/delete;
- conteudo: `/text`, `/question`, `/schedule` inteiros;
- auth sem rate limit: register, authenticate, forgot/reset, refresh.

Os publicos intencionais de proposta (`presentation/*`, `indications` GET, criacao) dependem de o `proposalId` (UUID) ser dificil de adivinhar. `GET /venue/presentation/:venueId` e `GET /venue/getById` sem `userId` tambem aceitam o nome unico do espaco; com `userId`, `getById` continua so pelo id. Qualquer mudanca nesta lista usa a lib `security` e testes 401/403/ownership.

## Chamadas do frontend sem rota no backend

O frontend declara services para rotas inexistentes: `GET /payment/byId/:id`, `GET /document/:id`, `GET /clause/getById`, `GET /attachment/getById`, `GET /owner/getById`, `GET /service/getById`, `GET /goal/getById/:id`, `GET /seasonalFee/getById/:id`, `GET /question/byId/:id`, `GET /text/byId/:id`, `GET /image/byId/:id`, `GET /emailConfig/getById/:id`, `GET /userVenuePermission/:id`. Tambem chama `GET /person/getById/:id`, que no backend esta registrado como `PUT`. Antes de usar algum, confirmar se a tela chama de fato.
