# State — Filtros de status e valor na lista de orcamentos

## Snapshot

- status: `T-01` e `T-02` escritas; tela sem prova
- ultima task concluida: `T-02` no codigo; browser parado no login
- task em andamento: nenhuma
- proxima task exata: nenhuma
- prova mais recente: vitest 12 em `use-case-list-proposal.spec.ts`; `GET` da tela nao foi visto logado

## Delta da ultima task

- mudou: `minAmount` na listagem; `monthAmount` e `daily.amount` so do aprovado na janela; `amountMax` no resumo; status e arraste na pagina de orcamentos
- ficou pendente: soltar o arraste, status e a altura dos cards com a sessao logada
- lacunas de prova: o browser abriu `http://localhost:8080/login` e nao entrou na pagina de orcamentos

## Decisoes recentes

- `monthAmount` vem de uma segunda leitura, so com espaco e janela
- no piso a tela nao envia `minAmount`
- a lista de eventos nao foi alterada

## Riscos ou bloqueios

- a tela nova ainda nao foi exercitada; o backend publicado antes dela ja muda o Valor no mes

## Memoria promovida

- topics atualizados: nenhum
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: codigo das duas tasks escrito; prova da tela pendente
- bloqueantes: login do painel
- achados: 12 testes da listagem passaram
