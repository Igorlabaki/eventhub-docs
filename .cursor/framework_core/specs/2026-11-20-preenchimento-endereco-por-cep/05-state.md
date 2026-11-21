# State

## Snapshot

- status: `T-01` a `T-05` no codigo; browser parado no login
- ultima task concluida: `T-05`
- task em andamento: nenhuma
- proxima task exata: revisar entrega (`fw:review`)
- prova mais recente: vitest 26 (`cep-lookup` 8, bloco 11, telas 5, configuracoes 2)

## Delta da ultima task

- mudou: o bloco entrou em criar espaco, configuracoes, contrato do painel e publico, proprietario e cidade do site da organizacao
- ficou pendente: digitar um CEP de verdade no browser
- lacunas de prova: `http://localhost:8080/venue/AR756/settings?aba=endereco` cai em `/login`

## Decisoes recentes

- ViaCEP, depois BrasilAPI, timeout de 4s, sem proxy
- select nativo na reserva de UF e cidade
- CEP do `EditVenueForm` nao entra no salvamento
- configuracoes abre a aba por `?aba=`
- sem coluna nova e sem mudanca no relatorio

## Riscos ou bloqueios

- a prova no browser depende de login
- o CEP do cliente sai para a ViaCEP; o teste da URL cobre so os 8 digitos

## Memoria promovida

- topics atualizados: nenhum
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: lote no codigo, review ainda nao rodou
- bloqueantes: nenhum de codigo
- achados: browser nao passou do login
