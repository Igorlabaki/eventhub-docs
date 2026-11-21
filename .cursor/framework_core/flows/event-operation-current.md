# Event Operation — Current

Do orcamento aberto ate o dia do evento, pela sidebar da proposta (`/proposal/:id`). Observado em 2026-11-10.

## Falar com o cliente

- Entrar em contato (`/send-message`): mensagem por WhatsApp montada no navegador;
- Enviar Orcamento (`/send-proposal`): `POST /email/proposal` (Hostinger, fundo de `EmailConfig` `PROPOSAL`) ou WhatsApp com o link;
- Link do evento: abre `/proposal/:id/links` (publico, contagem regressiva e atalhos);
- Indicar parceiros (`/send-suppliers`): `PUT /proposal/indications/:id` (auth + `SEND_PROPOSAL_INFO`); cliente ve em `/proposal/:id/indications`.

## Fechar

- Gerar Contrato (`/contract`): escolhe Contract da organizacao, monta clausulas por `position`, gera PDF com jsPDF no navegador e envia por `POST /email/contract`; cliente preenche dados em `/person-contract` ou `/b2b-contract` (`PUT /proposal/updatePersonalInfo`, publico);
- Agendar Data (`/dates`): `POST /dateEvent/createSameDay` ou `createOvernigth`; DateEvent `EVENT`, `PRODUCTION` ou `BARTER` aprova a proposta; sync Google se o usuario tiver `EDIT_VENUE_CALENDAR`;
- Efetuar Pagamento (`/payment`): `POST /payment/create` com comprovante opcional (S3); atualiza `amountPaid` e recusa valor acima do saldo.

## No dia

- Lista de Presenca (`/attendance-list`): Person `GUEST` e `WORKER`; cliente preenche em `guest-list` e `staff-list` (planilha opcional); criar pessoa envia confirmacao por e-mail;
- Programacao (`/schedule`): Schedule com horarios dentro do evento; cliente edita em `schedule-list`;
- Documentos (`/documents`): `POST /document/create` (PDF ou imagem no S3, opcional ligado a Payment).

## Historico

`/history` lista History; nem toda acao grava historico.

## Lacunas

- payment, document, person, schedule, contract e e-mail sao endpoints publicos;
- contrato depende de PDF gerado no cliente; DocuSign so planejado;
- pagamento e `amountPaid` sem transacao garantida; `paid` nunca vira `true`;
- falha de e-mail ou Google pode falhar ou nao refletir na request, sem retry.
