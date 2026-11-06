# Delivery and Known Gaps

## Entrega atual

- backend e frontend possuem `vercel.json`;
- nao ha CI/CD de produto mapeado;
- backend tem dois arquivos de teste, um historicamente pulado;
- frontend tem um teste mapeado;
- nao ha cobertura minima, e2e ou gate de PR documentado;
- observabilidade atual e console + `GET /`.

## Lacunas prioritarias observadas

1. auth e autorizacao de rotas sensiveis;
2. refresh token e contrato FE/BE;
3. segredos/configuracao e CORS;
4. testes de auth, Proposal e Payment;
5. transacoes em fluxos multi-escrita;
6. paginacao e performance medida;
7. logging estruturado, correlation id, metricas e alertas;
8. consolidacao React Query/Zustand;
9. maquina de estados de Proposal, dinheiro e timezone;
10. owners, ambientes, rollback e SLOs.

## Backlog legado

`docs/estado/integracao/TODO_MASTER.md`, `KNOWN_LIMITATIONS.md`, `docs/planos/ROADMAP_TECHNICAL.md`, `PERFORMANCE_PLAN.md` e `OBSERVABILITY_PLAN.md` contem propostas historicas. Antes de executar qualquer item, confirmar no codigo se ainda existe e convertê-lo por `fw:intake` ou `fw:spec`.

## Configuracao divergente

Backend `.env.example` nao lista `FRONTEND_URL` e contem um valor que deve ser tratado como credencial. Frontend `.env.example` nao lista `VITE_API_URL` nem `VITE_GOOGLE_CLIENT_ID`.
