# Infra Map — EventHub

## Ambientes e topologia

- local: backend 3000, frontend 8080;
- producao: Vercel indicado nos dois repositorios;
- staging, regiao, contas e dominios: nao documentados;
- backend: handler serverless Express;
- frontend: bundle Vite SPA;
- banco: PlanetScale Vitess/MySQL, org `igorlabakig`, banco `ar756`, producao na branch `main`, AWS `us-east-2`; detalhes em `project/planetscale.md`;
- storage: S3;
- filas: nenhuma;
- auth: JWT proprio, Session/RefreshToken e Google OAuth;
- notificacoes: registro no banco e Web Push; Firebase removido;
- calendario: Google Calendar, tokens criptografados no banco.

## Entrega e operacao

- IaC e pipeline CI/CD: nao encontrados;
- migrations: SQL versionado em `prisma/migrations/`; a `main` tem safe migrations e so recebe DDL por deploy request do PlanetScale;
- rollback de schema: revert do deploy request dentro da janela; rollback de aplicacao e promocao: nao documentados;
- backups do banco: automaticos a cada ~12h, retencao de 2 dias, restore nunca ensaiado;
- health: `GET /` retorna `API online!`;
- logs: console; metricas, tracing, alertas e dashboards nao mapeados.

## Configuracao sensivel

- backend (nomes): `DATABASE_URL`, `SHADOW_DATABASE_URL`, `JWT_SECRET_KEY`, `AWS_BUCKET_NAME`, `AWS_REGION`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `EMAIL_PASSWORD`, `EMAIL_GMAIL_PASSWORD`, `VAPID_PUBLIC_KEY`, `VAPID_PRIVATE_KEY`, `NODE_ENV`, `PORT`, `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, `GOOGLE_REDIRECT_URI`, `ENCRYPTION_KEY`, `FRONTEND_URL` (fora do exemplo); `CORS_ORIGIN` existe no exemplo e e ignorada;
- frontend (nomes): `VITE_API_URL`, `VITE_GOOGLE_CLIENT_ID` (ambas fora do exemplo), `VITE_VERCEL_PROJECT_ID`, `VITE_VERCEL_API_TOKEN` (exposta no bundle);
- valores fixos no codigo que dependem de ambiente: dominio `event-hub-dashboard.vercel.app` (links publicos, reset de senha, sidebar), SMTP Hostinger e remetente, conta Gmail;
- `.env.example` esta incompleto nos dois repositorios;
- o exemplo backend contem valor com aparencia de credencial: nao reproduzir; remover e rotacionar em tarefa de seguranca aprovada.

## Fontes

`docs/planos/PRODUCTION_SETUP.md`, `docs/INTEGRATIONS_GOOGLE_CALENDAR.md`, os dois `vercel.json` e `pscale` somente leitura em 2026-11-08.
