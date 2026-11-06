# State — Apresentacao publica do orcamento

## Snapshot

- status: codigo de `T-01` a `T-05` escrito; nao esta pronto para producao
- ultima task concluida: `T-05`
- task em andamento: nenhuma
- proxima task exata: nenhuma
- prova mais recente: descricao antes do valor; capa sem o nome em texto; pino abre o Google Maps; vitest do pacote publico 3 testes verdes

## Delta da ultima task

- mudou: o papel das cores na pagina publica; primaria no fundo, secundaria nos cards, texto na fonte
- ficou pendente: review da entrega (`fw:review`)
- lacunas de prova: cor vazia nao foi aberta no browser; o caso com as tres cores preenchidas foi

## Decisoes recentes

- a pagina publica nao chama mais `GET /venue/getById`
- cor vazia vira nulo no schema do update; cor invalida responde 400
- primaria pinta o fundo da pagina, secundaria pinta os cards e o texto pinta a fonte; o painel nao muda

## Riscos ou bloqueios

- as tres colunas existem no `main`; a pagina com as tres cores preenchidas foi conferida no browser
- `GET /proposal/byId` continua devolvendo pagamento e pessoas; fora desta feature

## Memoria promovida

- topics: nenhum
- project-decisions: nenhuma
- ADRs: nenhum
