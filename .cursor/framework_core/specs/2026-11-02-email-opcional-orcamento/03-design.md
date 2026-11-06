# Design — e-mail opcional na criacao do orcamento

## Visao geral da solucao

`Proposal.email` passa a aceitar ausencia. No painel, vazio vira `null` e texto preenchido precisa ser e-mail. No salvamento dos dados do contrato, o e-mail e obrigatorio e valido.

O pedido do cliente no site nao muda.

## Passada transversal

- architecture: nao. Continuam os mesmos endpoints e o model `Proposal`. Sem ADR.
- database: sim. `Proposal.email` vira `String?`. O indice `[email, startDate]` permanece. A migration so torna a coluna anulavel, sem backfill e sem reescrever e-mails existentes.
- design: sim. No painel o campo deixa de bloquear o submit quando vazio. Nos links do contrato o campo entra com label visivel, teclado de e-mail e erro no submit.
- observability: nao. Sem metrica, alerta ou log novo. O valor do e-mail nao aparece em log nem na URL.
- security: sim. O e-mail e PII. `PUT /proposal/updatePersonalInfo` ja e publico e continua publico, porque o cliente nao tem login. A mudanca valida o campo no schema e nao abre outra rota.
- patterns/06: nao. Sem fila, cache, retry ou idempotencia nova. Salvar de novo sobrescreve o e-mail.

## Componentes e modulos impactados

- `art56_server_v3/prisma/schema.prisma`: `Proposal.email`
- schemas Zod de criacao e de edicao por dia e por pessoa
- `CreateProposalInDbParams.email` e o tipo de lista, para aceitar `null`
- `update-personal-info-proposal-params-schema.ts` e `proposal-in-prisma-repository.ts` `updatePersonalInfo`
- `eventhub-vista-dashboard`: `PerDayProposalForm`, `PerPersonProposalForm`, `ProposalEdit`
- links: `PFContractPersonalInfoForm`, `PJContractPersonalInfoForm`
- mesmo salvamento interno: `pf-contract-form`, `pj-contract-form`
- tipos `Proposal`, DTOs de criacao, edicao e `UpdateProposalPersonalInfoDTO`

Fora desta mudanca: `ClientPerDayProposalForm`, `ClientPerPersonProposalForm`, envio de e-mail e `ProposalContractForm` (nao chama a API).

## Reuso previsto

- Zod nos dois repositorios, no padrao ja usado
- `Input type="email"` e `FormMessage` ja usados no painel
- `updateProposalPersonalInfo` ja usado pelos quatro formularios de dados do contrato
- nenhuma biblioteca nova e nenhuma terceira forma de estado no frontend

## Contratos e dados

- painel, criacao e edicao: e-mail ausente, vazio ou so espacos vira `null`; valor presente precisa passar em e-mail
- updates parciais do orcamento (pagamento, aprovacao) nao enviam e-mail e nao apagam o valor
- `PUT /proposal/updatePersonalInfo`: `data.email` obrigatorio e valido; a escrita inclui `email`
- pedido publico do site: `z.string().email()` permanece obrigatorio
- WhatsApp permanece obrigatorio
- `""` nao e valor persistido
- repositorio de criacao ja espalha `email` no `create`; com o schema anulavel, `null` segue esse caminho

## Falhas, casos de borda e invariantes

- espacos nas pontas sao removidos antes da validacao
- e-mail invalido nao altera o orcamento
- rejeicao de `updatePersonalInfo` preserva o e-mail anterior
- link com e-mail ja gravado mostra o valor e recusa salvar vazio
- orcamento antigo com e-mail nao e migrado nem apagado
- dono sem e-mail ainda nao envia orcamento por e-mail; isso fica fora desta feature

## Decisoes arquiteturais importantes

- Uma coluna anulavel, nao um segundo campo. A obrigatoriedade muda por fluxo.
- O painel afrouxa criacao e edicao. A edicao entra para o orcamento sem e-mail poder ser salvo de novo.
- O link endurece o endpoint que ja grava dados pessoais. Os dois formularios internos do dono passam a exigir e-mail porque usam esse endpoint. Sem isso, o salvar interno quebra.
- Nao autenticar o link nesta feature. A justificativa e o uso atual pelo cliente sem login.
- Descartado gravar `""`: texto vazio nao e ausencia e quebra o significado de "sem e-mail".
- Descartado exigir e-mail so na tela: a rota publica continuaria aceitando o payload antigo.

## Riscos e mitigacoes

- publicar a API obrigatoria antes dos formularios faz o salvar do contrato responder erro. `T-04` leva API e os quatro formularios juntos.
- tornar a coluna `NOT NULL` de novo depois que existirem ausencias falha. Rollback da coluna nao faz parte do plano; o retorno e por codigo, voltando a exigir e-mail so se nao houver `null`.
- `person-contract` e `b2b-contract` nao estao em `PUBLIC_ROUTES`. Se o carregamento sem sessao redirecionar para `/login`, `T-04` inclui as duas rotas nessa lista no axios e no bootstrap.

## Rollout, observabilidade e rollback

- ordem: `T-01`, `T-02`, `T-03`, `T-04`
- `T-01` e compativel com o codigo atual, que ainda envia e-mail
- sem dashboard novo
- prova de producao: criar no painel sem e-mail; salvar cada link com e-mail valido e sem e-mail

## Estrategia de validacao

- `npx prisma validate` e leitura do SQL: coluna anulavel, sem backfill
- teste dos schemas: vazio vira `null`, invalido falha, `updatePersonalInfo` sem e-mail falha
- painel: criar por dia e por pessoa em branco; editar em branco; invalido nao salva
- links: pessoa fisica e pessoa juridica sem e-mail nao salvam; com e-mail valido o valor aparece no orcamento
- site: formularios publicos de pedido continuam exigindo e-mail

## Fontes determinantes

- `product/03-user-profiles.md`: cliente fornece dados por link publico
- `product/05-functional-flows.md`: formulario publico, proposta e contrato
- `product/08-data-model.md`: e-mail e PII
- `project-decisions.md` D-02, D-03 e D-05
- `framework-libs/database/rules/04_migrations_and_zero_downtime.md`: nao reescrever a coluna nem misturar backfill
- `framework-libs/security/skills/reviewing-security-sensitive-changes.md`: PII fora de log e de URL; input validado no schema
- `framework-libs/design/rules/06_forms_and_input_ux.md`: label visivel, erro no submit, teclado de e-mail
