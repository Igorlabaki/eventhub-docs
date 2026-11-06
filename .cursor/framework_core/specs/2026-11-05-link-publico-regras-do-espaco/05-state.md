# State — Link publico das regras do espaco

## Snapshot

- status: `T-01` a `T-03` escritas
- ultima task concluida: `T-03`
- task em andamento: nenhuma
- proxima task exata: nenhuma nesta spec; o gesto do painel esta em `specs/2026-11-05-links-painel-e-formularios/` (`T-01`)
- prova mais recente: vitest backend 6 e frontend 13 verdes; no browser, `/venue/8159e209-0057-4df3-ae72-855363c3b84e/rules/view` mostrou a marca AR756 e a frase de lista vazia, sem login; venue inexistente mostrou a frase de falha e o titulo EventHub; ao ir para o login, a aba voltou ao titulo EventHub

## Delta da ultima task

- mudou: rota publica, pagina, copia na tela Regras e sexto destino do Link do evento
- ficou pendente: clique no destino "Regras do espaço" da pagina publica, e um espaco com regra cadastrada; o campo de copiar do painel deixa de ser prova desta spec
- lacunas de prova: nenhum espaco com regra cadastrada foi aberto no browser

## Decisoes recentes

- `GET /venue-rule/public/:venueId` registrado antes de `ensureAuthenticate`
- a pagina nao reordena e nao interpreta o texto como HTML
- erro de carga oferece "Tentar de novo", alem da frase da spec

## Riscos ou bloqueios

- nenhum bloqueio
- o servidor que respondeu a leitura publica ja estava no ar; se outro processo subir sem este codigo, a pagina cai na frase de falha

## Memoria promovida

- topics atualizados: nenhum
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: lote executado, sem review
- bloqueantes: nenhum
- achados: a copia no painel e o botao do Link do evento ficaram na prova automatica, nao no clique
