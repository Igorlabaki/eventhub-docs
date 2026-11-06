# Clarify — Assinatura do contrato no DocuSign

## Perguntas criticas

- Uma conta do EventHub ou uma conta por organizacao?
- O cliente entra no EventHub para assinar?
- O PDF nasce no browser ou no servidor?
- O arquivo assinado pode ir para o mesmo bucket dos outros documentos?

## Respostas confirmadas

- Uma conta do EventHub, app privado, JWT, sandbox. O operador nao conecta outra conta.
- O cliente nao tem conta DocuSign e nao assina dentro do EventHub. O convite chega por e-mail.
- O PDF continua o que a tela ja gera. O servidor nao remonta clausulas.
- O signatario e uma pessoa: o cliente da proposta.

## Requisitos implicitos confirmados

- A permissao vale no venue da proposta, no backend.
- O e-mail usado e o que ja esta salvo na proposta.
- Segredo nao volta na API nem no log.
- Envelope aberto ou ja assinado nao e reenviado.

## Premissas assumidas

- A aba de assinatura do cliente usa a ancora de texto `Locatário(a)`, que o PDF ja desenha. Se o texto nao existir no arquivo, o envio falha com erro claro e nao cria envelope. Risco se a premissa falhar: o cliente recebe um PDF sem lugar para assinar.
- O Connect do DocuSign sera configurado em JSON. Risco se vier XML: o webhook responde 400 e nao marca assinado.
- O PDF assinado usa o mesmo bucket e a mesma URL publica dos documentos da proposta, com chave aleatoria. Trocar para objeto privado e outra feature. Risco: o endereco, se vazado, abre um PDF com dado pessoal.
- O webhook faz o download e o upload na mesma invocacao e so entao responde 200. Nao ha fila no projeto. Risco: a funcao serverless estoura o tempo e o DocuSign tenta de novo; a idempotencia segura o segundo efeito.
- Consentimento JWT ja foi feito no sandbox. Se o DocuSign responder `consent_required`, o envio falha com essa mensagem e nao grava `sent`.
- `DOCUSIGN_CONNECT_SECRET` ainda nao esta no `.env` local. Ele entra quando o Connect existir. Os testes do webhook usam um segredo de fixture.

## Perguntas de erro e borda ainda abertas

- O locador tambem assina? Premissa: nao nesta feature. Risco: o contrato segue com uma assinatura so.
- Reenvio depois de `declined` ou `voided`? Premissa: sim, um envelope novo, e o ponteiro da proposta passa a apontar para ele. Risco: o envelope antigo continua no DocuSign, sem efeito na proposta.
- A tela de leitura dos documentos, separada do contrato, precisa de selo "assinado"? Premissa: nao; o PDF aparece como documento da proposta e o estado fica na tela de contrato.

## Itens bloqueantes

- Nenhum para escrever a spec e executar `T-01`.
- Prova manual do webhook no sandbox espera a URL publica da API e o segredo do Connect. Nao bloqueia o teste de HMAC com fixture.

## O que pode seguir mesmo com lacunas

- `T-01` e `T-02` seguem sem Connect.
- `T-03` segue com HMAC e S3 mockados. O ensaio ao vivo fica para depois do deploy.
