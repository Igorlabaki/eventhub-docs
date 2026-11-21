# Data Model — EventHub

Snapshot de `art56_server_v3/prisma/schema.prisma` em 2026-11-10 (42 models: 39 de dominio + 3 tabelas de juncao; 16 enums; 19 migrations). Banco: PlanetScale MySQL (`project/planetscale.md`).

## Tecnologia e convencoes

- `provider = "mysql"`, `relationMode = "prisma"`, `shadowDatabaseUrl`; sem FKs fisicas, por isso ha `@@index` em toda coluna de relacao;
- IDs: `uuid()` na maioria; `cuid()` em Expense, DateEvent, Image, Text, Document, Question, Contract, Clause, Attachment, EmailConfig e Schedule;
- dinheiro sempre `Float`; datas `DateTime` com convencao wall-clock para agenda (`docs/planos/horario-wall-clock/03-convencao-wall-clock.md`);
- tabelas com `@@map` em snake/camel misto; `Goal` e `SeasonalFee` sem `@@map` (tabelas PascalCase);
- listas CSV em texto: permissoes, `Goal.months`, `SeasonalFee.affectedDays`.

## Models por area

### Identidade e acesso

| Model (tabela) | Campos principais | Relacoes e chaves |
|---|---|---|
| User (`user`) | email, username, password, avatarUrl, googleId, fcmToken (sem uso), tokens de reset e confirmacao, emailConfirmed | unique email, googleId |
| Session (`session`) | userId, refreshTokenId, ipAddress, isValid, expiresAt | User, RefreshToken |
| RefreshToken (`refresh_token`) | expireIn, userId | User (cascade), Session[] |
| Organization (`organization`) | name, whatsappNumber, redes, url, email, logoUrl | unique name, email; Venue[], Owner[], Clause[], Contract[], Attachment[], Image[], Text[] |
| UserOrganization (`userOrganization`) | userId, organizationId, joinedAt | unique (userId, organizationId) |
| UserOrganizationPermission | role, permissions (LongText CSV) | unique userOrganizationId |
| UserVenuePermission | venueId, role, permissions (LongText CSV) | unique (userOrganizationId, venueId) |
| GoogleCalendarIntegration (`google_calendar_integration`) | userId, organizationId, googleCalendarId, accessTokenEncrypted, refreshTokenEncrypted, scope, tokenExpiresAt | unique (userId, organizationId); sem relacao Prisma |

### Espaco e configuracao

| Model (tabela) | Campos principais | Relacoes e chaves |
|---|---|---|
| Venue (`venue`) | name, description, slogan (Text, opcional), email, url, redes, endereco, logoUrl, faviconUrl (opcional, icone da aba), `proposalPrimary/Secondary/TextColor` (VarChar 7), `tourVideoUrl` (2048), `isShowOnOrganization`, checkIn/checkOut (padrao `12:00`), openingHour, closingHour, hasOvernightStay, minimumNights, `pricingModel`, pricePerPerson/Day/PersonDay/PersonHour, `minimumPrice` (padrao 0), standardEventDuration, maxGuest | unique name, email; agrega quase todo o operacional |
| Service (`service`) | name, price, `pricingType` (padrao FIXED), description (500), imageUrl, photoId (opcional, sem FK), rpaRequired, rpaMinPeople | unique (name, venueId); index photoId |
| SeasonalFee | type (SURCHARGE/DISCOUNT), title, startDay/endDay `dd/MM`, fee (Int %), affectedDays | Venue |
| MinimumPricePeriod (`minimum_price_period`) | title, startDay/endDay `dd/MM`, price | Venue |
| Goal | minValue, maxValue, increasePercent, months (CSV) | Venue |
| TieredPrice (`tiered_price`) / Tier (`tier`) | minGuests, maxGuests, price | unique venueId; sem calculo no codigo |
| VenueRule (`venue_rule`) | title (120), text, position | Venue |
| VenueAmenity (`venue_amenity`) | name (120), position, description (500)?, videoUrl (2048, so YouTube)?; imageUrl (text)? legado, sem uso desde 2026-11-13 | unique (name, venueId), VenueAmenityImage[] |
| VenueAmenityImage (`venue_amenity_image`) | imageUrl (text), photoId (opcional, sem FK), position; ate 3 por caracteristica (regra na API) | VenueAmenity; index amenityId, photoId |
| VenuePhoto (`venue_photo`) | url (1024), storageKey (512), width?, height?, sizeBytes?, description?; biblioteca do espaco | Venue (`photos`); index venueId e (venueId, url prefix 191); sem FK fisica |
| Expense (`expense`) | name, description, amount, paymentDate, type, category, trafficSource (canal, so em Publicidade; indice `[venueId, category]`), recurring | Venue |
| Contact (`contact`) | name, role, redes, whatsapp, email, type (padrao TEAM_MEMBER), category (PartnerCategory), logoUrl, description (400) | Venue, ProposalIndication[] |
| Question (`question`) | question, response (FAQ) | Venue |
| Image (`image`) | imageUrl, group, description, position, responsiveMode, tag, isShowOnOrganization, isShowOnProposal, photoId (opcional, sem FK) | Venue ou Organization; index photoId |
| Text (`text`) | area, title, position, text | Venue ou Organization |
| EmailConfig (`emailConfig`) | backgroundImageUrl, backgroundPhotoId (opcional, sem FK), title, type (String, ex. `PROPOSAL`), message | Venue; index backgroundPhotoId |
| Owner (`owner`) / OwnerVenue (`ownerVenue`) | personType (`PF`/`PJ`, padrao `PF`), completeName, rg, cpf (em PJ: representante legal), companyName (razao social), cnpj (14 caracteres normalizados, numerico ou alfanumerico), companySize (`MEI`/`ME`/`EPP`/`DEMAIS`, opcional), pix, endereco, bankName, bankAgency, bankAccountNumber; role padrao `ADMIN` | Organization; unique (ownerId, venueId) |

### Comercial e evento

| Model (tabela) | Campos principais | Relacoes e chaves |
|---|---|---|
| Proposal (`proposal`) | completeClientName, completeCompanyName, cpf, cnpj, rg, endereco, email (opcional), whatsapp, `type`, `eventCategory`, `trafficSource`, guestNumber, knowsVenue, startDate, endDate, description, hostMessage, basePrice, extraHoursQty, extraHourPrice, totalAmount (liquido, ja com desconto), `discountPercent` (double, default 0, 0..100), `discountAmount` (double, default 0; subtotal = `totalAmount + discountAmount`), termsAccepted, `approved`, contact, `paid`, `amountPaid` | Venue; idx (venueId, startDate), trafficSource, (email, startDate), (completeClientName, startDate) |
| ProposalService (`proposalService`) | serviceId, pricingType, unitPrice, quantity, `courtesyQuantity` (int, default 0; `amount = unitPrice x (quantity - courtesyQuantity)`), amount (snapshot), `teste` legado | Proposal, Service |
| ProposalCost (`proposalCost`) | name (ProposalName), amount, `teste` legado | m2m com Proposal |
| ProposalIndication (`proposal_indication`) | contactId, position | unique (proposalId, contactId) |
| DateEvent (`dataEvent`) | title, startDate, endDate, `type`, googleEventId, googleCalendarId | Venue, Proposal opcional, Notification[] |
| Payment (`payment`) | amount, paymentDate, paymentMethod, imageUrl | Proposal, Venue, Document[] |
| Document (`document`) | imageUrl, title, thumbnailUrl, fileType | Proposal, Payment opcional |
| Person (`person`) | name, email, rg, type (GUEST/WORKER), attendance, confirmAttendanceEmail | Proposal |
| Schedule (`schedule`) | name, workerNumber, description, startHour, endHour | Proposal |
| History (`history`) | action, username, userId | Proposal, User opcional |
| Notification (`notification`) | content, type, isRead, proposalId, dateEventId | Venue |

### Contratos

| Model (tabela) | Campos principais | Relacoes |
|---|---|---|
| Contract (`contract`) | name, title | Organization; Venue[] (`_ContractVenues`); Clause[] (`_ContractClauses`) |
| Clause (`clause`) | title, text, position | Organization opcional |
| Attachment (`attachments`) | title, text | Organization ou Venue |

Juncoes explicitas: `_ContractClauses`, `_ContractVenues`, `_ProposalToProposalCost`.

## Enums

| Enum | Valores |
|---|---|
| PricingModel | PER_PERSON, PER_DAY, PER_PERSON_DAY, PER_PERSON_HOUR, TIERED |
| ServicePricingType | FIXED, PER_HOUR, PER_PERSON |
| ProposalType | EVENT, OVERNIGHT, PRODUCTION, BARTER, OTHER |
| EventCategory | CORPORATE, BIRTHDAY, BACHELOR_PARTY, WEDDING, COFFEE_BREAK, OTHER |
| TrafficSource | AIRBNB, GOOGLE, INSTAGRAM, TIKTOK, OTHER, FRIEND, FACEBOOK |
| DateEventType / NotificationType | VISIT, EVENT, OTHER, BARTER, PROPOSAL, OVERNIGHT, PRODUCTION |
| SeasonalFeeType | SURCHARGE, DISCOUNT |
| ContactType | TEAM_MEMBER, SUPPLIER |
| PartnerCategory | BUFFET, CHURRASCO, BAR, DJ, MUSICA_AO_VIVO, FOTOGRAFIA, FILMAGEM, DECORACAO, CENOGRAFIA, BOLOS_DOCES, RECREACAO, ENTRETENIMENTO, CERIMONIAL, AUDIOVISUAL, MOBILIARIO, BRINDES, OUTROS |
| PersonType | GUEST, WORKER |
| PaymentMethod | PIX, CREDIT_CARD |
| ProposalName | RECEPTIONIST, SECURITY, CLEANER |
| ExpenseType | WEEKLY, ANNUAL, MONTHLY, BIWEEKLY, SPORADIC |
| ExpenseCategory | TAX, INVESTMENT, MAINTENANCE, ADVERTISING |
| DocumentType | PDF, IMAGE |

## Migrations versionadas

Base historica de 2025 (`add_google_calendar_integration`, `f`, `google_id`) e as de 2026-11: preco minimo por periodo, regra do espaco (+ backfill de permissao), e-mail opcional na proposta, caracteristica (+ backfill), cores da proposta, video do tour, `isShowOnProposal`, preco do servico, tiered price, indicacao, categoria de parceiro, indice (venueId, startDate), logo e descricao de contato, categoria do evento, tipo de pessoa do proprietario, fotos da caracteristica, canal da despesa, biblioteca `venue_photo` (deploy request `#50`) e `slogan` em `venue` (`20261119180000_add_venue_slogan`, deploy request `#51`, com copia da descricao para o slogan). Aplicacao em producao por deploy request (`topics/data-and-migrations.md`).

## Dados sensiveis

- credenciais e tokens: password, reset/confirmation tokens, Session, RefreshToken, tokens Google cifrados;
- PII: CPF/CNPJ/RG, endereco, e-mail, WhatsApp em Proposal, Person, Contact e Owner;
- bancarios: PIX, banco, agencia e conta em Owner;
- financeiros: precos, totais, pagamentos, despesas, metas;
- permissoes: CSV em LongText.

## Convencoes e riscos

- dinheiro Float sem regra central de arredondamento;
- estado da proposta implicito em booleanos (`topics/pricing-and-proposal-calculation.md`);
- fluxos multi-escrita sem transacao em varios casos;
- campos legados `teste` e relacao `noificationList`.

## Fonte detalhada

`prisma/schema.prisma`, `docs/referencias/DATA_MODEL_EXPLAINED.md` e `database.dbml` (ambos anteriores aos models de 2026-11).
