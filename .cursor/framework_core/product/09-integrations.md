# Integrations — EventHub

## Integracoes ativas

- MySQL: persistencia principal via Prisma;
- AWS S3: imagens, documentos e assets de configuracao;
- Nodemailer/Gmail: proposta, contrato, confirmacao e reset de senha;
- notificacao no painel: gravada no banco ao criar orcamento;
- Web Push/VAPID: codigo presente, separado do push removido;
- Google OAuth: login no frontend;
- Google Calendar API: sync unidirecional de DateEvent;
- Vercel: deploy dos dois repositorios e analytics opcional no frontend.

## Regras operacionais

- falha de sync Google nao reverte operacao local;
- tokens Google ficam criptografados no banco;
- envs e segredos nunca entram no core;
- integracoes sincrona na request nao possuem fila/retry padronizado;
- alteracao de payload, scope, callback ou permissao exige `security` e teste de compatibilidade.

## Fontes

`docs/INTEGRATIONS_GOOGLE_CALENDAR.md`, `docs/planos/PRODUCTION_SETUP.md` e `topics/integrations.md`.
