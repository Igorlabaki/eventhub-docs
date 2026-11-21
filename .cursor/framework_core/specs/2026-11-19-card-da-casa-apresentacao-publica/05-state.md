# State — Card da casa na apresentacao publica

## Snapshot

- status: `T-01` e `T-02` no codigo; browser pendente
- ultima task concluida: `T-02`
- task em andamento: nenhuma
- proxima task exata: nenhuma; revisar a entrega se o usuario pedir
- prova mais recente: vitest back 5 no GET; vitest front 352; browser nao aberto

## Delta da ultima task

- mudou: `slogan` no GET; card da casa entre o hero e a foto; slogan no topo e na aba desta pagina
- ficou pendente: ver a pagina no browser com uma casa real
- lacunas de prova: sessao no browser; a API publicada ainda nao tem `slogan` ate o deploy

## Decisoes recentes

- horario incompleto omite o lado vazio
- a aba desta pagina recebe o slogan ja aparado pela funcao pura
- sem migration e sem componente compartilhado com `ProposalView`

## Riscos ou bloqueios

- publicar o frontend antes da API deixa o topo sem o texto curto; o card usa o que o GET ja devolve
- nenhum bloqueio de codigo

## Memoria promovida

- topics atualizados: `topics/public-pages-and-branding.md#Demais paginas publicas`
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: codigo das duas tasks escrito; falta a prova visual
- bloqueantes: nenhum
- achados: o GET ja tinha horario, capacidade, pernoite, bairro e cidade
