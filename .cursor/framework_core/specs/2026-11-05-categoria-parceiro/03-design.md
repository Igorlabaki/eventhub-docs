# Design — Categoria do parceiro

## Visao geral da solucao

A categoria mora em `Contact`, nao na indicacao. A migration adiciona a coluna opcional e preenche `OUTROS` nos fornecedores. O schema recusa parceiro sem valor da lista e zera a categoria quando o contato vira equipe. A leitura publica acrescenta `category` na lista que ja existe. O frontend traduz o enum e agrupa essa lista.

## Passada transversal

- muda topologia, fronteira ou fluxo entre partes? nao — mesmas rotas de contato e o mesmo `GET /proposal/indications/:proposalId`
- toca dados persistidos? sim — coluna opcional e backfill; sem indice e sem `NOT NULL`
- toca interface? sim — select nos dois cadastros, rotulo na lista e grupos na pagina publica
- vai para producao? sim, mas sem sinal novo — o toast e o 400 atuais provam a falha
- toca fluxo sensivel? nao — a categoria nao e PII; as rotas publicas ja existem; a consequencia e validar o enum no schema
- tem gatilho de conceito senior? nao — sem fila, retry, cache nem concorrencia alem da ultima gravacao

## Componentes e modulos impactados

- `art56_server_v3/prisma/schema.prisma`: enum e campo
- `art56_server_v3/prisma/migrations/<timestamp>_add_partner_category/migration.sql`
- `art56_server_v3/src/zod/contact/partner-category.ts`: enum e a regra compartilhada
- `create-contact-params-schema.ts` e `update-contact-params-schema.ts`
- `proposal-indication-in-prisma-repository.ts`: `publicContactSelect`
- `proposal-indication-repository-interface.ts`: `PublicIndication.category`
- `use-case-list-proposal-indications.ts`: incluir `category` em `PUBLIC_KEYS`
- `eventhub-vista-dashboard/src/lib/partner-category.ts`
- `contact-form.tsx`, `PartnerForm.tsx`, `contact-list.tsx`, `types/contact.ts`
- `ProposalIndications.tsx` e `proposal.service.ts` (`PublicIndication`)

## Reuso previsto

- `Select` ja usado no tipo do contato
- casca, card e links de `ProposalIndications` e `indicationLinks`
- `toPublic`, que continua sendo a allowlist
- repositorio de contato, que ja grava o objeto do schema

## Contratos e dados

Enum Prisma `PartnerCategory` e campo `category PartnerCategory?` em `Contact`, sem `@default`.

SQL da migration, escrito a mao no arquivo alem do `ALTER` que o Prisma gerar:

```sql
UPDATE `contact`
SET `category` = 'OUTROS'
WHERE `type` = 'SUPPLIER' AND `category` IS NULL;
```

Regra `assertPartnerCategory(type, category)`:

- `SUPPLIER` exige um valor do enum
- `TEAM_MEMBER` exige categoria ausente; na atualizacao, a gravacao forca `category: null`
- tipo ausente no create equivale a `TEAM_MEMBER`, que e o default do banco
- tipo ausente no update nao mexe na categoria, salvo se o payload trouxer um valor do enum

`GET` publico acrescenta so `category: PartnerCategory | null`. Continua sem `venueId` e sem `type`.

Rotulos, nesta ordem, em `src/lib/partner-category.ts`:

| Valor | Rotulo |
|---|---|
| `BUFFET` | Buffet |
| `CHURRASCO` | Churrasco |
| `BAR` | Bar |
| `DJ` | DJ |
| `MUSICA_AO_VIVO` | Musica ao vivo |
| `FOTOGRAFIA` | Fotografia |
| `FILMAGEM` | Filmagem |
| `DECORACAO` | Decoracao |
| `CENOGRAFIA` | Cenografia |
| `BOLOS_DOCES` | Bolos e doces |
| `RECREACAO` | Recreacao |
| `ENTRETENIMENTO` | Entretenimento |
| `CERIMONIAL` | Cerimonial |
| `AUDIOVISUAL` | Audiovisual |
| `MOBILIARIO` | Mobiliario |
| `BRINDES` | Brindes |
| `OUTROS` | Outros |

`groupIndicationsByCategory` percorre essa ordem, junta `null` no grupo `OUTROS` e preserva a ordem de chegada dentro do grupo. Nao escreve no servidor.

No painel, o select aparece so com tipo Fornecedor, depois do tipo, label "Categoria". No formulario publico, o select e obrigatorio porque o tipo ja e fornecedor. Mensagem: "Selecione a categoria". Na lista, o fornecedor mostra o rotulo e, se houver, a funcao; a equipe continua mostrando a funcao.

Na pagina publica, cada grupo e um titulo com o rotulo e, abaixo, os mesmos itens de hoje, dentro do card que ja existe. Lista vazia nao ganha titulo.

## Falhas, casos de borda e invariantes

- fornecedor gravado tem categoria da lista; equipe gravada tem categoria nula
- a pagina nao inclui quem nao foi indicado
- grupo vazio nao renderiza
- erro de validacao nao apaga o formulario

## Decisoes arquiteturais importantes

- coluna opcional, sem default: um default preencheria membro de equipe
- backfill no mesmo SQL: a mudanca e aditiva; o `UPDATE` so preenche a coluna nova
- agrupamento no cliente: a API continua uma lista ordenada por `position`
- um modulo de rotulos no frontend e um de regra no backend: os repos nao compartilham arquivo
- sem ADR: a fronteira dos repositorios nao muda

Alternativa descartada: copiar a categoria para `proposal_indication`. A pagina precisa do cadastro atual.

## Riscos e mitigacoes

- cliente antigo salvar fornecedor sem categoria e receber 400: subir API e formularios juntos
- `UPDATE` amplo na migration: a condicao e `type = SUPPLIER` e categoria nula

## Rollout, observabilidade e rollback

- ordem: migration, API, frontend, no mesmo ciclo
- sem dashboard novo
- rollback da aplicacao deixa a coluna no lugar; nao remover a coluna nesta entrega

## Estrategia de validacao

- `npx prisma validate` e leitura do SQL
- unitario da regra de categoria
- unitario da allowlist publica, estendendo o spec que ja exige a lista exata de campos
- unitario dos rotulos e de `groupIndicationsByCategory`
- browser do cadastro e da pagina fica para a execucao, se o ambiente local tiver dados

## Fontes

- `topics/data-and-migrations.md#Regras`: migration aditiva e `migrate deploy`
- `project/project-decisions.md#D-01` e `#D-03`: dois repos e integridade no Prisma
- `framework-libs/database/skills/writing-zero-downtime-migrations.md`: coluna opcional e compativel
- `framework-libs/design/rules/06_forms_and_input_ux.md`: label visivel, erro no campo, nao limpar apos erro
- codigo: `Contact`, `POST /contact/create` sem auth, `PUBLIC_KEYS` e `ProposalIndications.tsx`
