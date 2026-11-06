# Proposal Lifecycle — Current

## Objetivo

Mapear o fluxo comercial atual sem inventar uma maquina de estados oficial.

## Passos

1. cliente ou equipe cria Proposal por fluxo de preco do Venue;
2. use case calcula preco, datas e capacidade e persiste dados relacionados;
3. equipe lista e atualiza informacoes, contato e datas;
4. contratos, documentos, pessoas, escala e mensagens sao vinculados;
5. pagamentos atualizam valor pago e indicador `paid`;
6. DateEvents representam agenda e podem sincronizar com Google;
7. History registra parte das acoes.

## Lacunas

Estados e transicoes nao sao centralizados, criacao multi-escrita nem sempre e transacional, total pago precisa de consistencia e parte do fluxo publico/autenticado nao esta protegida de modo uniforme.
