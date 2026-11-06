# State — Links do painel e formularios de cadastro

## Snapshot

- status: `T-01` a `T-03` escritas; falta o fluxo no browser
- ultima task concluida: `T-03`
- task em andamento: nenhuma
- proxima task exata: nenhuma
- prova mais recente: vitest 26 verdes nos cinco arquivos; o painel em `localhost:8080` caiu no login

## Delta da ultima task

- mudou: botao de copiar em Regras; key de criacao em regra e caracteristica; Link do evento abre a URL absoluta noutra aba
- ficou pendente: copiar, cadastrar de novo e clicar o item com sessao
- lacunas de prova: toast, formulario vazio depois de salvar e a aba nova nao foram vistos logado

## Decisoes recentes

- a sidebar ja estava em secoes; o item externo ficou em `opensExternalUrl`, nao num `NavItem` solto
- a rota `/proposal/:id/event-link` permanece
- o `catch` das secoes nao incrementa a sessao nem fecha o formulario

## Riscos ou bloqueios

- nenhum bloqueio de codigo
- sem sessao, o browser nao passou do login

## Memoria promovida

- topics atualizados: nenhum
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: lote escrito, sem review e sem prova logada
- bloqueantes: nenhum
- achados: a sidebar mudou de lugar em relacao ao card; o gesto ficou no modelo de secoes
