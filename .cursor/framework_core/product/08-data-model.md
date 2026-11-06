# Data Model — EventHub

## Tecnologia

MySQL com Prisma 5. O datasource usa `relationMode = "prisma"`; relacoes e cascatas nao devem ser presumidas como foreign keys fisicas.

## Dados sensiveis

- credenciais e tokens: password, reset/confirmation tokens, Session, RefreshToken e tokens Google criptografados;
- PII: CPF/CNPJ/RG, endereco, e-mail, WhatsApp e dados bancarios/PIX;
- financeiros: precos, totais, pagamentos, despesas e metas;
- permissoes: strings em campos LongText.
- regras do espaco: `VenueRule` (`venue_rule`), uma lista por venue, com titulo opcional, texto e posicao.
- caracteristicas do espaco: `VenueAmenity` (`venue_amenity`), uma lista por venue, com nome unico no venue, posicao, e `description`, `imageUrl` e `videoUrl` opcionais. No maximo uma midia: foto ou link do YouTube.
- servico do espaco: `Service.pricingType` (`FIXED`, `PER_HOUR`, `PER_PERSON`, padrao fixo), `description` e `imageUrl` opcionais; a linha gravada no orcamento fica em `ProposalService` (`pricingType`, `unitPrice`, `quantity`, `amount`), todos opcionais.

## Convencoes e riscos

- IDs misturam UUID e CUID;
- dinheiro usa Float e nao tem regra central de moeda/arredondamento;
- datas nao possuem politica global unica; agenda segue wall-clock;
- varios fluxos de escrita multipla nao usam transacao;
- `ProposalCost.teste` e `ProposalService.teste` parecem legado nao explicado;
- indices existem para varios FKs logicos, mas paginacao e medicao ainda sao lacunas.

## Fonte detalhada

`docs/referencias/DATA_MODEL_EXPLAINED.md`, `database.dbml` e `prisma/schema.prisma`.
