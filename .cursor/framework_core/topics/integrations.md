# Integrations

## S3 e arquivos

- bucket `AWS_BUCKET_NAME` em `AWS_REGION`; URL publica `https://<bucket>.s3.<region>.amazonaws.com/<key>`;
- padrao: multer em memoria + `PutObjectCommand`; update apaga o objeto antigo com `DeleteObjectCommand`; delete de image e document apaga no S3;
- uploads em venue, user, payment, organization, image, image-organization, email-config, document, service e contact;
- sharp converte imagem de servico e logo de contato para webp 1200px q80 (limite 5 MB); image/upload tambem usa sharp;
- validar tipo, tamanho, ownership, nome de objeto, acesso publico/privado e remocao.

## E-mail

| E-mail | Origem | Canal |
|---|---|---|
| orcamento | `POST /email/proposal` | SMTP Hostinger, remetente fixo; fundo de `EmailConfig` tipo `PROPOSAL`; link `${venue.url}/orcamento/byId/:id` |
| contrato | `POST /email/contract` | Hostinger; PDF gerado no navegador (jsPDF) chega em base64 e vai anexado |
| confirmacao de presenca | `person/create` e `createMany` | Hostinger |
| reset de senha | `forgot-password` | Gmail com conta fixa; link fixo `event-hub-dashboard.vercel.app/reset-password` |

HTML inline nos use cases, sem pasta de templates, fila, retry ou idempotencia; falha externa pode falhar a request.

## Notificacoes

Notificacao do painel e gravada no banco ao criar orcamento. Push Firebase foi removido; `User.fcmToken` permanece sem uso. Web Push/VAPID existe em `services/web-push-service.ts`, mas nenhuma rota envia push.

## Google Calendar

- OAuth por user/organization; `state` JWT de 10 min; `access_type=offline`, `prompt=consent`, escopos `calendar` e `calendar.events`;
- tokens cifrados em `GoogleCalendarIntegration`, renovados quando faltam menos de 5 min;
- sync unidirecional EventHub -> Google em create/update/delete de DateEvent, so se o usuario tiver `EDIT_VENUE_CALENDAR`; titulo `<type> - <title>`, fuso America/Sao_Paulo, recria evento em 404;
- VIEW permite status, conexao, calendarios; EDIT permite selecao e desconexao;
- falha Google nao reverte escrita local.

## Vercel Analytics

`analytics.service.ts` chama `api.vercel.com/v1/insights/*` direto do navegador com `VITE_VERCEL_API_TOKEN` exposto no bundle.

## Inexistentes no codigo

- DocuSign: so plano em `docs/planos/PLANO_INTEGRACAO_DOCUSIGN.md` e spec `2026-11-05-assinatura-contrato-docusign`; o codigo descrito na spec nao esta nos repos (ver `topics/delivery-and-known-gaps.md`);
- geracao de PDF no servidor, cron/jobs, webhooks e websocket (dependencias instaladas sem uso).

## Contratos e prova

Mudanca de scope, callback, payload ou remetente e sensivel. Provar sucesso, falha, expiracao, retry/reconexao e permissao. Nunca registrar tokens. Fonte: `docs/INTEGRATIONS_GOOGLE_CALENDAR.md`.
