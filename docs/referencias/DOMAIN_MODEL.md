# Modelo de domínio — EventHub

**Objetivo:** Glossário de termos, ciclo de vida da Proposal (estados implícitos no código), invariantes e regras, dependências entre domínios. Baseado no repositório (Prisma, use cases, FE).

**Fontes no repositório:** `art56_server_v3/prisma/schema.prisma`, [database.dbml](./database.dbml), `art56_server_v3/src/use-cases/`, `eventhub-vista-dashboard/src/types/`, [BACKEND_ANALISE_ATUAL.md](./BACKEND_ANALISE_ATUAL.md).

---

## 1. Glossário de termos

| Termo | Descrição (conforme código) |
|-------|-----------------------------|
| **Organization** | Entidade que agrupa venues e donos; tem nome único, contatos, logo, textos e imagens de site. |
| **Venue** | Espaço vinculado a uma organização; tem endereço, preços (por pessoa/dia/tier), serviços, propostas, eventos (DateEvent), despesas, metas, contatos, FAQ, imagens/textos de site. |
| **Proposal** | Orçamento/proposta de evento vinculada a um venue; contém dados do cliente (nome, CPF/CNPJ, contato), datas (startDate/endDate), valores (basePrice, totalAmount, extraHours), tipo (EVENT, OVERNIGHT, PRODUCTION, etc.), origem do tráfego (TrafficSource), lista de pessoas (Person), pagamentos (Payment), documentos (Document), eventos na agenda (DateEvent), escalas (Schedule). |
| **DateEvent** | Evento no calendário do venue; pode estar vinculado a uma proposal (proposalId opcional); tem title, startDate, endDate, type (VISIT, EVENT, OVERNIGHT, etc.). |
| **Payment** | Pagamento vinculado a proposal e venue; amount, paymentDate, paymentMethod (PIX, CREDIT_CARD), imageUrl (comprovante). |
| **Document** | Arquivo (PDF/IMAGE) vinculado a proposal e opcionalmente a payment; imageUrl, title, fileType. |
| **Contract** | Modelo de contrato da organização; nome, título; N:N com Clause e com Venue. |
| **Clause** | Cláusula reutilizável; texto, título, position; vinculada a organization; usada em Contract. |
| **Attachment** | Anexo (texto/título) vinculado a organization e opcionalmente venue. |
| **Owner** | Dono (organização ou venue); dados cadastrais (nome, RG, CPF, PIX, endereço, banco); OwnerVenue liga owner a venue com role (ex.: ADMIN). |
| **Permissions** | No FE: enums VIEW_ORG_* (VENUES, OWNERS, SITE, CONTRACTS, PERMISSIONS, INFO), VIEW_VENUE_* (INFO, SITES, PRICES, EVENTS, ANALYSIS, CALENDAR, CONTACTS, SERVICES, EXPENSES, PROPOSALS, NOTIFICATIONS, CONFIG), VIEW_PROPOSAL_*, EDIT_*, SEND_*. No BE: campo `permissions` (LongText) em UserVenuePermission e UserOrganizationPermission — lista/string; **não confirmado no repositório** se o BE valida essas strings por rota. |
| **UserOrganization** | Vínculo User ↔ Organization (N:N). |
| **UserVenuePermission** | Permissões de um usuário em um venue; ligado a UserOrganization; role + permissions (LongText). |
| **UserOrganizationPermission** | Permissões de um usuário na organização (uma por UserOrganization); role + permissions (LongText). |
| **Person** | Pessoa vinculada a Proposal; type GUEST ou WORKER; attendance, confirmAttendanceEmail. |
| **Service** | Serviço do venue (nome, preço, rpaRequired, rpaMinPeople); vinculado a proposals via ProposalService. |
| **ProposalCost** | Custo nomeado (ProposalName: RECEPTIONIST, SECURITY, CLEANER) com amount; N:N com Proposal. |
| **History** | Registro de ação em proposta (action, username, userId, proposalId). |
| **Notification** | Notificação por venue (proposalId, dateEventId opcionais); content, type, isRead. |
| **SeasonalFee** | Taxa sazonal do venue (SURCHARGE/DISCOUNT), startDay/endDay, fee, affectedDays. |
| **Goal** | Meta do venue (minValue, maxValue, increasePercent, months). |
| **EmailConfig** | Configuração de e-mail do venue (type, title, message, backgroundImageUrl). |

---

## 2. Ciclo de vida da Proposal (estados implícitos)

Não existe máquina de estados explícita no código. Estados inferidos dos campos e fluxos:

| Campo / conceito | Uso no código |
|------------------|----------------|
| `approved` | Boolean; indica se proposta foi aprovada. |
| `termsAccepted` | Boolean; termos aceites. |
| `paid` | Boolean; se foi pago. |
| `amountPaid` | Float; valor pago. |
| `contact` | Boolean; contato. |
| Histórico | Tabela History registra ações (action, username, proposalId). |

**Estados implícitos (não confirmado no repositório como enum oficial):** rascunho → enviada → aprovada/rejeitada → paga (parcial/total). Transições não centralizadas; cada fluxo (update, payment, document) altera campos conforme use case.

---

## 3. Invariantes e regras (o que “sempre” deve ser verdade)

- **Organization:** nome único; pelo menos um venue para uso típico (não enforced no schema). |
- **Venue:** pertence a uma organization; name único; pricingModel e preços (pricePerPerson, pricePerDay, etc.) conforme modelo. |
- **Proposal:** venueId obrigatório; startDate ≤ endDate (validação não confirmada centralmente no repositório); totalAmount/basePrice coerentes com regras de negócio (não enforced no schema). |
| **Payment:** proposalId e venueId obrigatórios; amount > 0 (não confirmado no Zod). |
| **UserOrganization:** unique(userId, organizationId). |
| **UserVenuePermission:** unique(userOrganizationId, venueId). |
| **UserOrganizationPermission:** uma por UserOrganization (userOrganizationId unique). |
| **Session/RefreshToken:** usados no fluxo de auth; expiração em Session.expiresAt. |

**Regras de negócio em use cases:** Cálculo de totais, validação de datas e capacidade (maxGuest) estão nos use cases (ex.: create-proposal-per-person, create-proposal-per-day); não há camada de domínio rica com invariantes explícitas em um único lugar.

---

## 4. Dependências entre domínios

| Domínio A | Depende de | Observação |
|-----------|------------|------------|
| Venue | Organization | organizationId obrigatório |
| Proposal | Venue | venueId obrigatório |
| Person, Payment, Document, Schedule, History | Proposal | proposalId |
| DateEvent | Venue; Proposal (opcional) | venueId obrigatório; proposalId opcional |
| Payment | Venue | venueId obrigatório |
| Document | Proposal; Payment (opcional) | proposalId obrigatório |
| Service, Expense, Goal, Contact, SeasonalFee, Notification, Question, EmailConfig | Venue | venueId |
| Contract | Organization; Clause (N:N); Venue (N:N) | |
| Clause, Attachment | Organization; Attachment também pode ter venueId | |
| Image, Text | Venue e/ou Organization | venueId e/ou organizationId |
| UserVenuePermission | UserOrganization, Venue | |
| UserOrganizationPermission | UserOrganization | |
| Owner | Organization; OwnerVenue liga a Venue | |

---

## Decisões e recomendações

- Documentar em ADR ou no próprio código os estados oficiais da Proposal e transições permitidas, se a equipe quiser consistência entre FE/BE.
- Centralizar validações de invariantes (datas, totais, capacidade) em use cases ou em uma camada de domínio para evitar divergência.
- Manter glossário e [DATA_MODEL_EXPLAINED.md](./DATA_MODEL_EXPLAINED.md) alinhados ao schema Prisma e ao DBML.
