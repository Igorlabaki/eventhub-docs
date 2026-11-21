# State — Apresentacao publica do espaco

## Snapshot

- status: `T-01` e `T-02` escritas
- ultima task concluida: `T-02`
- task em andamento: nenhuma
- proxima task exata: nenhuma; falta a casa real no browser
- prova mais recente: vitest back 4 e front 346; `GET /venue/presentation/venue-inexistente` 404 sem token; `/venue/venue-inexistente/apresentacao` sem login mostra a frase de falha

## Delta da ultima task

- mudou: leitura publica com recorte; pagina `/venue/:id/apresentacao` na ordem fechada; allowlists e docs
- ficou pendente: clique da sidebar e a sequencia com uma casa real
- lacunas de prova: o painel parou no login; o espaco inexistente nao exercita foto, servico, investimento e mapa

## Decisoes recentes

- `TIERED` devolve `amount: null` e nao leva a tabela de faixas
- a pagina nova nao altera `ProposalView`

## Riscos ou bloqueios

- o item Apresentação ja abre o endereco; a sequencia visual com dados reais ainda nao foi vista
- nenhum bloqueio de schema

## Memoria promovida

- topics atualizados: `topics/public-pages-and-branding.md`
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: codigo das duas tasks pronto para review
- bloqueantes: nenhum
- achados: prova de browser da casa real ficou no login
