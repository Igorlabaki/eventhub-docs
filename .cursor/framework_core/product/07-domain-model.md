# Domain Model — EventHub

## Agregados e relacoes

- identidade: User, Session e RefreshToken;
- tenancy/acesso: Organization, UserOrganization, UserOrganizationPermission e UserVenuePermission;
- espaco: Venue, Service, Expense, Goal, SeasonalFee, MinimumPricePeriod, Contact, Question, EmailConfig, Image e Text;
- comercial: Proposal, Payment, Document, Person, Schedule, History e DateEvent;
- contratos: Contract, Clause e Attachment;
- ownership: Owner e OwnerVenue;
- integracao: GoogleCalendarIntegration.

Organization contem Venues. Proposal pertence a Venue. A maior parte da operacao deriva desses dois eixos. Contract liga Organization a Clauses e Venues. DateEvent pode existir com ou sem Proposal.

## Invariantes importantes

Unicidades de organization, venue, user email e vinculos de permissao devem ser preservadas. Proposal exige Venue; Payment exige Proposal e Venue; Document exige Proposal. Como `relationMode = "prisma"`, a aplicacao precisa manter integridade.

## Fonte detalhada

`docs/referencias/DOMAIN_MODEL.md` e `art56_server_v3/prisma/schema.prisma`.
