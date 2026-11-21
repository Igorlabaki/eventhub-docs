# State — Total estimado do orcamento no painel

## Snapshot

- status: `T-01` a `T-05` implementadas em lote; aguardando revisao e prova no browser
- ultima task concluida: `T-05`
- task em andamento: nenhuma
- proxima task exata: nenhuma; revisar entrega (`fw:review`) e provar os fluxos de `T-04` e `T-05` no browser
- prova mais recente:
  - backend `npx vitest run`: 46 arquivos, 321 testes verdes (1 skip antigo)
  - frontend `npx vitest run`: 39 arquivos, 215 testes verdes
  - `npx tsc --noEmit` no backend sem erro nos arquivos tocados (erros antigos em outros specs e repositorios in-memory)
  - `tsc -p tsconfig.app.json` no front sem erro nos arquivos tocados (erros antigos em outros componentes)
  - `eslint` nos arquivos tocados do front: 0 erros (1 aviso antigo de `generateTimeOptions`)
  - servidor local: `POST /proposal/quote` sem token responde 401; rota inexistente responde 404

## Delta da ultima task

- mudou:
  - `T-01`: `src/functions/proposal-amounts.ts` com a conta do recalculo publico; o use case do recalculo importa a funcao
  - `T-02`: `POST /proposal/quote` (`ensureAuthenticate`), `ProposalQuoteAuthorizer`, `quote-proposal-schema.ts`, use case, controller com seis chaves e factory
  - `T-03`: create e update por pessoa usam `adjustVenueUnitPrice` + `calcProposalAmounts` nos ramos de tabela; `adjustProposalUnitPrice` so fica no update por dia
  - `T-04`: tipos `ProposalQuoteInput` e `ProposalQuote`, `proposalService.quoteProposal`, `lib/proposal-quote-input.ts`, `hooks/proposal/queries/quote.ts`, `ProposalQuoteSummary`, bloco abaixo de Servicos em `PerPersonProposalForm` e rotulo `(estimado)`
  - `T-05`: mesmo bloco em `ProposalEdit` com o aviso "Ao salvar sem mudar o Total, o valor passa para R$ X."
- ficou pendente: prova no browser dos fluxos de `T-04` e `T-05`
- lacunas de prova: debounce, "Usar este valor", aviso de minimo, erro 400 no bloco e salvar na edicao nao foram vistos no browser. O backend local aponta para o banco de producao, entao criar ou salvar orcamento ali gravaria em producao; precisa de banco de dev ou de prova manual

## Decisoes recentes

- conta compartilhada nasce do recalculo publico (wall-clock); `adjustProposalUnitPrice` sai do update por pessoa
- rota `POST /proposal/quote` autenticada; aceita `VIEW_VENUE_PROPOSALS` ou `EDIT_VENUE_INFO`
- cotacao so para `PER_PERSON` e `PER_PERSON_HOUR`
- update por pessoa passa a aplicar temporada que vira o ano (ex.: 15/12 a 15/01 em evento de janeiro); teste em `use-case-update-proposal-per-person.spec.ts`
- create e update abaixo do minimo gravam `extraHoursQty` e `extraHourPrice` 0, como o recalculo publico; antes gravavam as horas extras calculadas que nao entravam no total. `basePrice` e `totalAmount` nao mudam
- campo Total da criacao e da edicao com `valueIsNumericString`: o valor do form e string numerica com ponto, e sem a flag o `NumericFormat` com virgula decimal leria um valor programatico com centavos como milhar
- no front, a entrada da cotacao so e montada com servicos por hora validos; sem isso o bloco mostra o traco e o erro fica no campo do servico
- Troca mostra `R$ 0,00` sem chamar a rota

## Riscos ou bloqueios

- prova no browser bloqueada: login e backend local apontando para producao
- cada cotacao faz ate 6 leituras; debounce de 400 ms e `staleTime` de 30 s limitam

## Memoria promovida

- topics atualizados: nenhum
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum
