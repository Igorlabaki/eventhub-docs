# State — Indicacoes publicas do orcamento

## Snapshot

- status: codigo das cinco tasks escrito; nao esta pronta para producao
- ultima task concluida: `T-05`
- task em andamento: nenhuma
- proxima task exata: nenhuma no card; falta prova com orcamento real
- prova mais recente: tabela `proposal_indication` no `main` do ar756, deploy request 39; vitest 14 testes; PUT sem token 401; GET de orcamento ausente 404

## Delta da ultima task

- mudou: vinculo `proposal_indication`, PUT autenticado, GET publico, painel sem WhatsApp e rota `/proposal/:id/indications`
- ficou pendente: abrir um orcamento real no browser
- lacunas de prova: salvar, recarregar e copiar o link no painel; card com parceiro e lista vazia na marca do espaco

## Decisoes recentes

- a checagem de token acontece antes de revelar se o orcamento existe
- `ensurePermission` do calendario nao entra
- a tabela entrou no `main` pelo deploy request 39, porque o `main` nao aceita DDL direto

## Riscos ou bloqueios

- a tabela ja esta no `main`; o que falta e provar o fluxo com um orcamento real
- a listagem geral de contatos continua publica e ficou fora desta spec

## Memoria promovida

- topics atualizados: `topics/auth-and-security.md` registra o GET publico e o PUT autenticado
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: lote executado em L2; review de entrega nao rodou
- bloqueantes: nenhum de schema; falta o fluxo com orcamento real no browser
- achados: a pagina de id inexistente cai no fallback EventHub, porque nao ha espaco para carregar
