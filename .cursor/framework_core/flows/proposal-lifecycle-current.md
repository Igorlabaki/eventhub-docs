# Proposal Lifecycle — Current

## Objetivo

Mapear o fluxo comercial atual sem inventar uma maquina de estados oficial.

## Passos

1. cliente cria Proposal pelo formulario publico ou equipe cria pelo painel (`flows/public-budget-request-current.md`);
2. use case calcula preco por modelo, sazonalidade, meta e piso, grava servicos como snapshot e cria Notification;
3. cliente ajusta no link publico (recalculo e servicos) enquanto aberta, nao paga e de um dia;
4. equipe lista em Orcamentos (Aberto), edita, contata, envia proposta, indica parceiros;
5. contrato e dados PF/PJ do cliente;
6. DateEvent de evento aprova a proposta (Fechado) e aparece em Eventos, Agenda e KPIs;
7. pagamentos atualizam `amountPaid`;
8. operacao do dia: pessoas, programacao e documentos (`flows/event-operation-current.md`);
9. History registra parte das acoes.

## Estados implicitos

| Sinal | Origem |
|---|---|
| Aberto / Fechado | `approved` (DateEvent de evento) |
| valor pago | `amountPaid` (Payment) |
| pago | `paid` (nunca gravado como `true`) |
| contatado | `contact` |
| termos aceitos | `termsAccepted` |

## Lacunas

Estados e transicoes nao sao centralizados, criacao multi-escrita nem sempre e transacional, total pago precisa de consistencia e parte do fluxo publico/autenticado nao esta protegida de modo uniforme.
