# Public Budget Request — Current

Do link publico do formulario ate o orcamento apresentado ao cliente. Observado em 2026-11-10.

## Passos

1. equipe copia o link `/venue/:id/form` no painel de orcamentos (dominio fixo `event-hub-dashboard.vercel.app`);
2. cliente abre o link; frontend busca `GET /venue/getById` e `GET /service/list` (publicos) e aplica a marca do espaco;
3. formulario em 3 passos: dados pessoais, evento (por pessoa ou por dia, conforme `hasOvernightStay`), origem e servicos (obrigatorios travados, horas para servico por hora);
4. envio `POST /proposal/createPerPerson` ou `createPerDay` (publicos);
5. backend valida com Zod, calcula preco (`topics/pricing-and-proposal-calculation.md`), grava Proposal + linhas `ProposalService` e cria Notification no banco;
6. frontend redireciona para `/proposal/:id/view`;
7. pagina publica busca `GET /proposal/byId`, `GET /proposal/presentation/:id` e servicos; cliente pode recalcular (dia, convidados, horas) e alterar servicos;
8. no painel, a notificacao aparece em `/venue/:id/notifications` e o orcamento em `/venue/:id/budgets` como Aberto; abrir `/proposal/:id` marca as notificacoes como lidas.

## Variacao pelo painel

`/venue/:id/budgets` -> Novo Orcamento usa os formularios internos (`PerPersonProposalForm`/`PerDayProposalForm`), com total estimado por `POST /proposal/quote` (autenticado) e total manual opcional; cria pelos mesmos endpoints.

## Lacunas

- criacao publica sem rate limit nem captcha;
- `GET /proposal/byId` publico devolve PII completa;
- criacao multi-escrita sem transacao garantida;
- e-mail opcional: envio por e-mail depende de o cliente informar.
