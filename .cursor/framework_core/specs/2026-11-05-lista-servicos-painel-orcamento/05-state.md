# State — Lista de servicos no painel

## Snapshot

- status: codigo das 3 tasks escrito; tela ainda nao provada
- ultima task concluida: `T-03` no codigo
- task em andamento: nenhuma
- proxima task exata: nenhuma; falta a prova no browser
- prova mais recente: vitest 37 verdes nos specs de criacao e edicao; eslint sem erro novo nos arquivos do painel

## Delta da ultima task

- mudou: os dois PUT gravam `serviceHours`; criar e editar no painel usam `DashboardServiceChoices` e enviam as horas digitadas
- ficou pendente: ver no browser a lista, o texto de obrigatorio e o campo de horas
- lacunas de prova: o browser abriu em `/login`; sem sessao nao deu para criar nem editar

## Decisoes recentes

- `requiredServiceIds` ficou em `src/lib/required-service-ids.ts` para o componente exportar so a lista
- a frase de produto em `product/02-business-rules.md#Proposal` cobre o painel

## Riscos ou bloqueios

- deploy da edicao ainda precisa do backend e da tela juntos
- a prova visual depende de entrar no painel

## Memoria promovida

- topics atualizados: nenhum
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: lote implementado; nao esta pronto para producao enquanto o browser nao confirmar a lista
- bloqueantes: login do painel para a prova visual
- achados: nenhum erro de compilacao no Vite depois do HMR
