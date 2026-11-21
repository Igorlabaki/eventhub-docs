# Integrations — EventHub

## Integracoes ativas

| Integracao | Uso | Lado |
|---|---|---|
| PlanetScale MySQL | persistencia via Prisma | backend |
| AWS S3 | imagens, logos, comprovantes, documentos, assets de e-mail | backend |
| SMTP Hostinger | e-mail de orcamento, contrato e confirmacao de presenca | backend |
| Gmail | e-mail de reset de senha | backend |
| Google OAuth | login e cadastro | frontend + backend |
| Google Calendar API | sync unidirecional de DateEvent | backend |
| Vercel | deploy dos dois repos | ambos |
| Vercel Insights API | visitas e performance no painel, com token exposto no bundle | frontend |
| WhatsApp (links `wa.me`) | contato, envio de orcamento, agendar visita | frontend |
| Google Maps (link e iframe) | mapa do espaco na proposta publica | frontend |
| YouTube (embed) | video do tour | frontend |

## Presentes no codigo sem uso

Web Push/VAPID (servico e script, nenhuma rota envia), Firebase removido (`User.fcmToken` sem uso), socket.io, pdf-lib/canvas.

## Planejadas e ausentes

DocuSign: plano em `docs/planos/PLANO_INTEGRACAO_DOCUSIGN.md` e spec aberta; codigo nao esta nos repos.

## Regras operacionais

- falha de sync Google nao reverte operacao local;
- tokens Google ficam cifrados no banco;
- envs e segredos nunca entram no core;
- integracoes sincronas na request nao possuem fila/retry padronizado;
- alteracao de payload, scope, callback, remetente ou permissao exige `security` e teste de compatibilidade.

## Fontes

`topics/integrations.md`, `docs/INTEGRATIONS_GOOGLE_CALENDAR.md` e `docs/planos/PRODUCTION_SETUP.md`.
