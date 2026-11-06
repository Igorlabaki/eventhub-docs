# State — Horario de evento sem fuso

## Snapshot

- status: `T-01` a `T-08` implementadas; review humana pendente; nao pronta para producao
- ultima task concluida: `T-08`
- task em andamento: nenhuma
- proxima task exata: nenhuma no lote
- prova mais recente: `vitest` backend 9 testes e frontend 12 testes verdes em 2026-11-02; `tsc` do frontend sem erro

## Delta da ultima task

- mudou: parser dual-format, util UTC, cronograma, e-mail, notificacao, dia da sazonalidade, telas de evento, Google sem `Z`, pagamento e despesa ao meio-dia UTC
- ficou pendente: abrir uma proposta `11:00`/`11:00` no browser e no Google Calendar real
- lacunas de prova: calendario, detalhe e e-mail nao foram exercitados na interface; sync Google nao chamou a API

## Decisoes recentes

- Data so de dia com prefixo `T` usa o dia civil UTC e grava meio-dia, para update de despesa ja salva nao quebrar
- D-06 segue valendo; sem migration

## Riscos ou bloqueios

- Linha antiga gravada pelo caminho errado continua errada
- Nenhum bloqueio de implementacao

## Memoria promovida

- topics atualizados: nenhum
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: nao se aplica (lote L2, sem review)
- bloqueantes: nenhum
- achados: nenhum
