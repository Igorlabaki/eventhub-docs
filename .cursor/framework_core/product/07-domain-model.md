# Domain Model — EventHub

## Eixos

```text
User --< UserOrganization >-- Organization --< Venue --< Proposal
            |                      |              |          |
            |-- OrgPermission      |-- Owner      |-- config |-- operacao do evento
            |-- VenuePermission    |-- Contract   |-- site   |-- dinheiro
                                   |-- Clause
```

Organization contem Venues. Proposal pertence a Venue. Quase toda a operacao deriva desses dois eixos.

## Agregados

- identidade: User, Session, RefreshToken;
- tenancy e acesso: Organization, UserOrganization, UserOrganizationPermission, UserVenuePermission;
- configuracao comercial do espaco: Venue (modelo de preco, capacidade, horarios, marca), Service, SeasonalFee, MinimumPricePeriod, Goal, TieredPrice/Tier;
- conteudo do espaco: VenueRule, VenueAmenity, Question (FAQ), Image, Text, EmailConfig, Contact (equipe e parceiros);
- comercial: Proposal, ProposalService (snapshot de servico), ProposalCost, ProposalIndication (parceiros indicados), History, Notification;
- evento: DateEvent (agenda; com ou sem Proposal), Person (convidado ou trabalhador), Schedule (programacao), Document;
- financeiro: Payment, Expense;
- contratos: Contract, Clause, Attachment;
- ownership: Owner, OwnerVenue;
- integracao: GoogleCalendarIntegration.

## Linguagem do produto

| Termo na tela | Entidade |
|---|---|
| Orcamento / Proposta | Proposal |
| Evento (fechado) | Proposal com `approved = true` e DateEvent `EVENT`/`PRODUCTION`/`BARTER` |
| Visita | DateEvent `VISIT` |
| Adicional / Desconto | SeasonalFee SURCHARGE / DISCOUNT |
| Preco minimo | `Venue.minimumPrice` e MinimumPricePeriod |
| Meta | Goal |
| Caracteristica | VenueAmenity |
| Regra do espaco | VenueRule |
| Parceiro / Fornecedor | Contact `SUPPLIER` com PartnerCategory |
| Colaborador / Equipe | Contact `TEAM_MEMBER` (cadastro) e Person `WORKER` (lista do evento) |
| Convidado | Person `GUEST` |
| Programacao | Schedule |
| Cores da casa | `Venue.proposal*Color` |

## Invariantes

- unicidade: Organization.name/email, Venue.name/email, User.email/googleId, (user, organization), (userOrganization, venue), (service.name, venue), (amenity.name, venue), (proposal, contact) em indicacao, (owner, venue);
- Proposal exige Venue; Payment exige Proposal e Venue; Document, Person, Schedule e History exigem Proposal;
- pagamento nao excede o saldo devedor; `amountPaid` acompanha pagamentos;
- `eventCategory` obrigatoria para `type = EVENT`;
- horas de servico por hora inteiras e nunca acima da duracao do evento;
- lista de convidados limitada a `guestNumber`; colaboradores sem limite;
- com `relationMode = "prisma"`, a aplicacao mantem a integridade.

## Ciclo implicito da Proposal

criada (publico ou painel) -> `approved = false` (Aberto) -> contato, edicao, envio, contrato -> DateEvent de evento cria `approved = true` (Fechado) -> pagamentos somam `amountPaid` -> operacao do dia (pessoas, programacao, documentos). Apagar o DateEvent volta a `approved = false`. Nao ha maquina de estados oficial (decisao pendente).

## Fonte detalhada

`product/08-data-model.md`, `docs/referencias/DOMAIN_MODEL.md` e `art56_server_v3/prisma/schema.prisma`.
