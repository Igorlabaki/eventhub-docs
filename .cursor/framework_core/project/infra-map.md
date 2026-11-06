# Infra Map — EventHub

## Ambientes e topologia

- local: backend 3000, frontend 8080;
- producao: Vercel indicado nos dois repositorios;
- staging, regiao, contas e dominios: nao documentados;
- backend: handler serverless Express;
- frontend: bundle Vite SPA;
- banco: MySQL externo, provedor desconhecido;
- storage: S3;
- filas: nenhuma;
- auth: JWT proprio, Session/RefreshToken e Google OAuth;
- notificacoes: registro no banco e Web Push; Firebase removido;
- calendario: Google Calendar, tokens criptografados no banco.

## Entrega e operacao

- IaC e pipeline CI/CD: nao encontrados;
- migrations: Prisma SQL, producao com `prisma migrate deploy`;
- rollback e promocao: nao documentados;
- health: `GET /` retorna `API online!`;
- logs: console; metricas, tracing, alertas e dashboards nao mapeados.

## Configuracao sensivel

- backend depende de banco, JWT, AWS, e-mail, VAPID, Google OAuth e criptografia;
- frontend depende de API URL, Google client ID e analytics opcional;
- `.env.example` esta incompleto nos dois repositorios;
- o exemplo backend contem valor com aparencia de credencial: nao reproduzir; remover e rotacionar em tarefa de seguranca aprovada.

## Fontes

`docs/planos/PRODUCTION_SETUP.md`, `docs/INTEGRATIONS_GOOGLE_CALENDAR.md` e os dois `vercel.json`.
