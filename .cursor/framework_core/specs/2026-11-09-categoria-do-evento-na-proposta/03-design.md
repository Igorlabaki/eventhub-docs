# Design — Categoria do evento na proposta

## Visao geral da solucao

A categoria mora em `Proposal`, ao lado de `type`. A migration so adiciona a coluna opcional. No backend, uma funcao pura `resolveEventCategory(type, value)` decide o valor gravado e e chamada no inicio dos quatro use cases de create e update; o resultado sobrescreve o que vier no payload. No frontend, um modulo de rotulos alimenta o select condicional dos formularios e o texto do detalhe.

## Passada transversal

- muda topologia, fronteira ou fluxo entre partes? nao — mesmas rotas `/proposal/createPerPerson`, `createPerDay`, `updatePerPerson`, `updatePerDay`; so um campo a mais no contrato
- toca dados persistidos? sim — enum e coluna opcional em `proposal`; sem backfill, sem indice, sem `NOT NULL`
- toca interface? sim — select condicional em tres formularios do painel e dois publicos; uma linha no detalhe
- vai para producao? sim, sem sinal novo — o 400 e o toast atuais provam a falha
- toca fluxo sensivel? nao — categoria nao e PII; a rota publica de create ja existe e so ganha um campo validado
- tem gatilho de conceito senior? nao — sem fila, retry, cache ou concorrencia alem da ultima gravacao

## Componentes e modulos impactados

Backend (`art56_server_v3/`):

- `prisma/schema.prisma`: `enum EventCategory` e `eventCategory EventCategory?` em `Proposal`
- `prisma/migrations/20261109190000_add_proposal_event_category/migration.sql`
- `src/functions/event-category.ts` (novo): `EVENT_CATEGORIES` e `resolveEventCategory`
- `src/zod/proposal/create-proposal-per-person-params-schema.ts`, `create-proposal-per-day-params-schema.ts`, `update-proposal-per-person-params-schema.ts`, `update-proposal-per-day--params-schema.ts`, `update-proposal-in-db-params-schema.ts`: campo `eventCategory`
- `src/repositories/interface/proposal-repository-interface.ts`: `CreateProposalInDbParams.eventCategory`
- `src/use-cases/proposal/create-proposal-per-person/`, `create-proposal-per-day/`, `update-proposal-per-person/`, `update-proposal-per-day/`: chamar a regra

Frontend (`eventhub-vista-dashboard/`):

- `src/types/proposal.ts`: enum `EventCategory`, campo em `Proposal` e nos quatro DTOs
- `src/lib/event-category.ts` (novo): opcoes, rotulos, `eventCategoryForPayload`, `proposalTypeWithCategoryLabel`
- `src/components/proposal/forms/PerPersonProposalForm.tsx`, `PerDayProposalForm.tsx`, `src/pages/ProposalEdit.tsx`
- `src/components/proposal/forms/ClientPerPersonProposalForm.tsx`, `ClientPerDayProposalForm.tsx`
- `src/pages/ProposalDetails.tsx`

## Reuso previsto

- `HttpBadRequestError`, como em `assertChosenServiceHours` (`src/functions/quote-service-lines.ts`)
- o `...rest` dos use cases e do repositorio, que ja leva campos novos ate o Prisma
- `Select`, `FormField` e `FormMessage` do select "Tipo do aluguel"
- `PROPOSAL_TYPE_OPTIONS` de `components/proposal/forms/constants.ts` para o rotulo do tipo no detalhe
- `proposal-email-schema.spec.ts` como modelo de teste de schema

## Contratos e dados

Prisma:

```prisma
enum EventCategory {
  CORPORATE
  BIRTHDAY
  BACHELOR_PARTY
  WEDDING
  COFFEE_BREAK
  OTHER
}

model Proposal {
  // ...
  type          ProposalType
  eventCategory EventCategory?
  // ...
}
```

SQL esperado (gerado pelo Prisma e revisado; sem `UPDATE`):

```sql
ALTER TABLE `proposal` ADD COLUMN `eventCategory` ENUM('CORPORATE', 'BIRTHDAY', 'BACHELOR_PARTY', 'WEDDING', 'COFFEE_BREAK', 'OTHER') NULL;
```

Backend, `src/functions/event-category.ts`:

```ts
export const EVENT_CATEGORIES = ["CORPORATE", "BIRTHDAY", "BACHELOR_PARTY", "WEDDING", "COFFEE_BREAK", "OTHER"] as const;
export type EventCategory = typeof EVENT_CATEGORIES[number];
export const EVENT_CATEGORY_MESSAGE = "Selecione a categoria do evento";

// type === "EVENT": devolve o valor se estiver na lista; senao HttpBadRequestError(EVENT_CATEGORY_MESSAGE)
// outro type: devolve null
export function resolveEventCategory(type: string, value: unknown): EventCategory | null
```

- schemas Zod: `eventCategory: z.enum(EVENT_CATEGORIES).nullable().optional()` nos quatro schemas de rota e no `updateProposalInDbParam`
- `CreateProposalInDbParams`: `eventCategory?: EventCategory | null`
- use cases: `const eventCategory = resolveEventCategory(params.type, params.eventCategory)` antes de qualquer branch (inclusive o de `BARTER`), e todo objeto enviado ao repositorio usa `{ ...rest, eventCategory }`. O valor do payload nunca chega cru ao Prisma.
- `GET` da proposta ja devolve todas as colunas; nao muda.

Frontend, `src/lib/event-category.ts`:

| Valor | Rotulo |
|---|---|
| `CORPORATE` | Empresarial / confraternização |
| `BIRTHDAY` | Aniversário |
| `BACHELOR_PARTY` | Despedida de solteiro |
| `WEDDING` | Casamento |
| `COFFEE_BREAK` | Coffee break |
| `OTHER` | Outro |

- `EVENT_CATEGORY_OPTIONS`: a tabela acima, nessa ordem
- `eventCategoryForPayload(type, category)`: `category ?? null` se `type === EVENT`; senao `null`
- `proposalTypeWithCategoryLabel(type, category)`: `"Evento · Aniversário"`; sem categoria ou tipo diferente de Evento, so o rotulo do tipo; tipo desconhecido devolve o valor cru

Formularios:

- painel: campo `eventCategory: z.nativeEnum(EventCategory).optional()` no schema do form e um `refine` com `path: ["eventCategory"]`, mensagem "Selecione a categoria do evento", exigindo valor quando `type === EVENT`. Select logo abaixo de "Tipo do aluguel", label "Categoria do evento", placeholder "Selecione". No `onValueChange` do tipo, se o novo tipo nao for Evento, `setValue("eventCategory", undefined)`. Payload: `eventCategory: eventCategoryForPayload(values.type, values.eventCategory)`.
- `ProposalEdit`: mesmo campo dentro de `data`; `form.reset` usa `currentProposal.eventCategory ?? undefined`.
- publico: `eventCategory: z.nativeEnum(EventCategory, { required_error: "Selecione a categoria do evento" })` (obrigatorio, porque o tipo e fixo `EVENT`); select no passo 2, antes da descricao; `eventCategory` entra na lista de campos do `goNext` do passo 2; payload envia o valor.
- detalhe: linha "Tipo do evento" com `proposalTypeWithCategoryLabel(type, eventCategory)` no card "Informações Pessoais", abaixo de "Por onde nos conheceu".

## Falhas, casos de borda e invariantes

- proposta gravada com `type = EVENT` a partir desta entrega tem categoria da lista
- proposta gravada com outro tipo tem categoria nula
- proposta antiga continua com categoria nula ate ser editada
- erro de validacao nao limpa o formulario
- categoria desconhecida no payload nunca chega ao Prisma

## Decisoes arquiteturais importantes

- regra no use case, nao em `superRefine`: o controller de create por pessoa chama `safeParse` e repassa o body cru; corrigir o controller mudaria quais payloads passam hoje (ex.: `OVERNIGHT` por pessoa) e fica fora desta spec
- funcao pura compartilhada pelos quatro use cases: uma regra, testavel sem Prisma
- coluna opcional sem default: um default inventaria a ocasiao das propostas antigas
- sem indice: nao ha consulta por categoria nesta entrega
- sem ADR: a fronteira dos repositorios nao muda

Alternativas descartadas:

- ampliar `ProposalType` com as ocasioes: mistura modalidade com ocasiao e afeta agenda e notificacoes, que espelham o enum
- tabela de categorias por espaco: o pedido e lista fechada; custo de cadastro sem ganho agora

## Riscos e mitigacoes

- painel antigo em cache recebe 400 ao criar Evento: subir API e front no mesmo ciclo
- front novo contra API sem a coluna: o Prisma recusa o campo; subir na ordem coluna, API, front
- esquecer um caminho de gravacao no use case (cada use case tem varios `createPerPerson`/`update`): a regra roda uma vez no topo e todos os objetos usam a mesma variavel; teste cobre o branch de `BARTER` e o de valor customizado

## Rollout, observabilidade e rollback

- ordem: branch de desenvolvimento no PlanetScale com a DDL, deploy request para `main` (aprovacao nomeada), API, frontend
- prova da coluna: `pscale sql ar756 main --org igorlabakig --format json --query "SHOW COLUMNS FROM proposal LIKE 'eventCategory'"`
- sem dashboard novo
- rollback: reverter o deploy request enquanto a janela existir; depois disso a coluna fica e a aplicacao antiga a ignora

## Estrategia de validacao

- `npx prisma format` e `npx prisma validate`; leitura do SQL
- vitest backend: `event-category.spec.ts` e casos nos specs dos use cases de create
- vitest frontend: `event-category.test.ts`
- `npm run lint` e `npm run build` do front
- browser (depois da coluna no `main`): criar Evento sem categoria e com categoria no painel; trocar tipo; formulario publico; detalhe

## Fontes

- `topics/data-and-migrations.md#Regras`: migration aditiva, deploy request, sem `migrate dev`
- `project/planetscale.md#Fluxo real de schema`: branch, deploy request, revert
- `framework-libs/database/skills/writing-zero-downtime-migrations.md#Processo obrigatorio`: coluna opcional compativel
- `framework-libs/design/rules/06_forms_and_input_ux.md#Validacao`: erro no campo, nao limpar apos erro
- spec `2026-11-05-categoria-parceiro`: precedente de enum novo opcional
- codigo: `controller-create-proposal-per-person.ts` (safeParse ignorado), `use-case-create-proposal-per-person.ts` (`...rest` e branch `BARTER`), `proposal-in-prisma-repository.ts` (`...rest` no create e update), `NewBudget.tsx` (mock), `ProposalDetails.tsx` (card Informações Pessoais)
